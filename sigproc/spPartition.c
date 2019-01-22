#include <mex.h>
#include <matrix.h>
#include <stdio.h>
#include <string.h>

#include <sp/sphere.h>
#include <snr/spfchar1.h>
#include <snr/snr.h>
#include <snr/speech_det.h>
#include <usr/Endpoint.h>
#include <usr/SignalAnalysis.h>

#include <Frame.h>
#include <CreateEndpointed.h>
#include <ExtractFrameTimings.h>

/* gateway function
 *
 * LHS Arguments:
 *	PartitionedSignal
 * RHS Arguments:
 *	Signal - vector of 16 bit signed integeters (Matlab type int16)
 *	SampleRate
 *	Method String
 *		String is partitioning method.  See spPartiont.m
 *		for details.
 *
 * This code is copyrighted 2002 by Marie Roch.
 * e-mail:  marie.roch@ieee.org
 *
 * Permission is granted to use this code for non-commercial research
 * purposes.  Use of this code, or programs derived from this code for
 * commercial purposes without the consent of the author is strictly
 * prohibited. 
 */


/* Fields in information structure.
 * Enumerations and field name must be in the same order.
 */

typedef enum {
  /* Field name position indicators start with F_ */ 
  F_Speech,
  F_NonSpeech,
} SpeechDetectionPositionIndicators;

const char *SpeechDetectionNames[] = {
  "Speech",
  "NonSpeech",
};

#define SpeechDetectionFieldCount \
	(sizeof(SpeechDetectionNames) / sizeof(char *))

void
mexFunction(int nlhs, mxArray *plhs[],
	    int nrhs, const mxArray *prhs[])
{
  /* positional parameters */
# define		InData		0		/* in */
# define		InSampleRate	1
# define		InMethod	2

# define		InCountMin	3
# define		InCountMax	3

# define		OutPartition 0			/* out */

  Signal		Sig;
  EndpointInfo		EP;
  EndpointFn		EndpointMethod;
  int			OutputFieldCount;
  int			Error = 0;
  int			MinSamplesPerFrame = 1;
  
  /* do not turn this on, Matlab does not play well with printf */
  int			EndpointVerbose = 0;	

# define		MaxStringLength 512
  char			String[MaxStringLength];	
  int			i;

  /* Verify args ok */
  if (nrhs < InCountMin || nrhs > InCountMax)
    mexErrMsgTxt("Invalid input arguments.");
  
  if (! mxIsInt16(prhs[InData]))
    mexErrMsgTxt("Input signal must be of type int16.");
  if (mxGetM(prhs[InData]) != 1 && mxGetN(prhs[InData]) != 1)
    mexErrMsgTxt("Input signal must be a row or column vector.");

  if (! mxIsDouble(prhs[InSampleRate]) ||

      mxGetM(prhs[InSampleRate]) * mxGetN(prhs[InSampleRate]) != 1)
    mexErrMsgTxt("Sample rate must be a scalar.");
  
  /* access the data */

  Sig.Data = (SIGNAL *) mxGetData(prhs[InData]);
  Sig.Props.SampleCount = mxGetM(prhs[InData]) * mxGetN(prhs[InData]);
  Sig.Props.SampleRate = *mxGetPr(prhs[InSampleRate]);
  if (mxGetString(prhs[InMethod], String, MaxStringLength))
    mexErrMsgTxt("Invalid partition method.");

  if (strcmp(String, "kubala") == 0)
	     EndpointMethod = KUBALA;
  else
    mexErrMsgTxt("Invalid partition method.");
  
  FrameDefault(&Sig.Props);
  SignalComputeWindowSize(&Sig, MinSamplesPerFrame);

  EP = endpoint(&Sig, EndpointMethod, EndpointVerbose);		/* do it! */

  strcpy(String, "Unable to allocate:  ");	/* be prepared... */

  switch (EndpointMethod) {
  case KUBALA:
    plhs[OutPartition] =
      mxCreateStructMatrix(1, 1, SpeechDetectionFieldCount,
			   SpeechDetectionNames);
    if (plhs[OutPartition]) {
      mxArray	*Speech;
      mxArray	*NonSpeech;

      Speech = CreateEndpointed(&Sig, &EP);
      NonSpeech = CreateEndpointedComplement(&Sig, &EP);

      if (! Speech || ! NonSpeech) {
	Error = 1;
	strcat(String, "Unable to allocate memory for partitioned data.");
      } else {
	mxSetFieldByNumber(plhs[OutPartition], 0, F_Speech, Speech);
	mxSetFieldByNumber(plhs[OutPartition], 0, F_NonSpeech, NonSpeech);
      }
    }
  }
  
  if (Error)
    mexErrMsgTxt(String);
}
