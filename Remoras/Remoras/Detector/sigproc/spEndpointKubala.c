#include <mex.h>
#include <matrix.h>
#include <stdio.h>

#include <sp/sphere.h>
#include <snr/spfchar1.h>
#include <snr/snr.h>
#include <snr/speech_det.h>
#include <usr/Endpoint.h>
#include <usr/SignalAnalysis.h>

#include <Frame.h>
#include <CreateEndpointed.h>
#include <CreateEndpointedFrameEnergy.h>
#include <ExtractFrameTimings.h>

/* gateway function
 *
 * LHS Arguments:
 *	EPFrames - Matrix where each row represents the beginning
 *		and ending frame of a speech segment.
 *	DataInfo - Information about the signal, SNR, etc.
 * RHS Arguments:
 *	Signal - vector of 16 bit signed integeters (Matlab type int16)
 *	SampleRate
 *	Frame -	
 *		[]    - Use default framing 
 *		[adv len] - Frame advance and length in MS
 *
 * This code is copyrighted 2002-2004 by Marie Roch.
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
  F_SampleCount,
  F_SampleRate,
  F_DCbias,
  F_Signal,
  F_Noise,
  F_SNR,
  F_FrameAdvanceN,
  F_FrameLengthN,
  F_FrameRate,
  /* All scalar fields must go before this label */
  F_FrameEnergy,
  F_SourceTime,
} InfoPositionIndicators;

const char *InfoNames[] = {
  "SampleCount",
  "SampleRate",
  "DCbias",
  "Signal",
  "Noise",
  "SNR",
  "FrameAdvanceN",
  "FrameLengthN",
  "FrameRate",
  "FrameEnergy",
  "SourceTimeSecs",
};

#define InfoFieldCount (sizeof(InfoNames) / sizeof(char *))

void
mexFunction(int nlhs, mxArray *plhs[],
	    int nrhs, const mxArray *prhs[])
{
  /* positional parameters */
# define		InData		0		/* in */
# define		InSampleRate	1
# define		InFrame		2

# define		InCountMin	2
# define		InCountMax	3

# define		OutEndpoints	0		/* out */
# define		OutInfo		1

  Signal		Sig;
  EndpointInfo		EP;
  EndpointFn		EndpointMethod = KUBALA;
  int			FrameResults;
  int			FrameAdvanceMS, FrameLengthMS;
  int			OutputFieldCount;
  int			MinSamplesPerFrame = 1;
  int			Error = 0;
  
  /* do not turn this on, Matlab does not play well with printf */
  int			EndpointVerbose = 0;	

# define		MaxStringLength 512
  char			String[MaxStringLength];	
  int			i;

  double		FrameRate;	/* Frames per second */
  double		*EndpointsPtr;
  
  /* Verify args ok */
  if (nrhs < InCountMin || nrhs > InCountMax)
    mexErrMsgTxt("Invalid input arguments.");
  
  if (! mxIsInt16(prhs[InData]))
    mexErrMsgTxt("Input signal must be of type int16.");
  if (mxGetM(prhs[InData]) != 1 && mxGetN(prhs[InData]) != 1)
    mexErrMsgTxt("Input signal must be a row or column vector.");

  if (! mxIsDouble(prhs[InSampleRate]) ||

      mxGetM(prhs[InSampleRate]) * mxGetN(prhs[InSampleRate]) != 1)
    mexErrMsgTxt("Sample rate must be a scalar");

  /* access the signal */

  Sig.Data = (SIGNAL *) mxGetData(prhs[InData]);
  Sig.Props.SampleCount = mxGetM(prhs[InData]) * mxGetN(prhs[InData]);
  Sig.Props.SampleRate = *mxGetPr(prhs[InSampleRate]);

  /* Retrieve framing scheme or use default (no framing) */
  if (nrhs > InFrame && (! mxIsEmpty(prhs[InFrame]))) {
    /* caller specifed framing */
    if (mxGetM(prhs[InFrame]) * mxGetN(prhs[InFrame]) == 2) {
      FrameAdvanceMS = (int) *(mxGetPr(prhs[InFrame]));
      FrameLengthMS = (int) *(mxGetPr(prhs[InFrame]) + 1);
      FrameResults = 1;
    } else
      mexErrMsgTxt("Framing parameters must be vector [AdvMS LenMS]");
  } else {
    FrameAdvanceMS = DefaultAdvanceMS;
    FrameLengthMS = DefaultLengthMS;
    FrameResults = 0;
  }

  /* Determine how many output fileds there should be.  If caller did
   * not request framing, we don't report frame energy
   */
  OutputFieldCount = (FrameResults) ?
    InfoFieldCount : InfoFieldCount - 1;
  
  FrameDefault(&Sig.Props);
  SignalComputeWindowSize(&Sig, MinSamplesPerFrame);

  EP = endpoint(&Sig, EndpointMethod, EndpointVerbose);		/* do it! */

  if (Sig.Props.Advance.MS != FrameAdvanceMS ||
      Sig.Props.Length.MS != FrameLengthMS) {
    /* frame rate different than that used for endpointing - convert */
    Signal	Tmp;
    
    Tmp = Sig;
    Tmp.Props.Advance.MS = FrameAdvanceMS;
    Tmp.Props.Length.MS = FrameLengthMS;
    SignalComputeWindowSize(&Tmp, MinSamplesPerFrame);
    
    endpoint_reframe(&Sig, &EP, &(Tmp.Props));
  }

  strcpy(String, "Unable to allocate:  ");	/* be prepared... */

  switch (nlhs - 1) {
    /* fall through switch */
  case OutInfo:
    FrameRate = (double) Sig.Props.SampleRate / (double) Sig.Props.Advance.N;

    plhs[OutInfo] = mxCreateStructMatrix(1, 1, OutputFieldCount, InfoNames);
    if (plhs[OutInfo]) {

      /* Allocate & populate scalars */
      i = 0;
      while (i < F_FrameEnergy) {
	mxArray	*Scalar;
	Scalar = mxCreateDoubleMatrix(1, 1, mxREAL);
	if (Scalar) {
	  mxSetFieldByNumber(plhs[OutInfo], 0, i, Scalar);
	} else {
	  Error = 1;
	  strcat(String, "SignalInfo scalars ");
	  i = F_FrameEnergy;
	}
	i++;
      }

      if (! Error) {
	mxArray	*FrameEnergy, *SourceTimings;
	
#	define ScalarFieldN(Field) \
		(*mxGetPr(mxGetFieldByNumber(plhs[OutInfo], 0, (Field))))
	
        ScalarFieldN(F_SampleCount) = endpoint_samplecount(&Sig, &EP);
	ScalarFieldN(F_SampleRate) = Sig.Props.SampleRate;
	ScalarFieldN(F_DCbias) = Sig.Props.DCbias;
	ScalarFieldN(F_Signal) = EP.SignalLevels.Signal;
	ScalarFieldN(F_Noise) = EP.SignalLevels.Noise;
	ScalarFieldN(F_SNR)= EP.SignalLevels.SNR;
	ScalarFieldN(F_FrameAdvanceN) = Sig.Props.Advance.N;
	ScalarFieldN(F_FrameLengthN) = Sig.Props.Length.N;
	ScalarFieldN(F_FrameRate) = FrameRate;

	/* If user requested that frames be returned, create
	 * and populate the frame energy vector
	 */
	if (FrameResults) {
	  if ((FrameEnergy = CreateEndpointedFrameEnergy(&Sig, &EP)))
	    mxSetFieldByNumber(plhs[OutInfo], 0, F_FrameEnergy, FrameEnergy);
	  else {
	    Error = 1;
	    strcat(String, "FrameEnergy array ");
	  }

	  if ((SourceTimings = ExtractFrameTimings(&Sig, &EP, FrameRate)))
	    mxSetFieldByNumber(plhs[OutInfo], 0, F_SourceTime, SourceTimings);
	  else {
	    Error = 1;
	    strcat(String, "SourceTimingsSecs array ");
	  }
	}
      }
    } else {
      Error = 1;
      strcat(String, "Info ");
    }

    /* fall into next case */
    
  case OutEndpoints:
    
    if ((plhs[OutEndpoints] =
	 mxCreateDoubleMatrix(EP.SegmentCount, 2, mxREAL)) == NULL)
      mxErrMsgTxt("Unable to allocate endpoint index matrix");

    
    /* Copy endpoints */
    EndpointsPtr = mxGetPr(plhs[OutEndpoints]);
    for (i = 0; i < EP.SegmentCount; i++) {
      *EndpointsPtr = FrameStart(EP.SegmentFrames[i]);
      *(EndpointsPtr + EP.SegmentCount) = FrameEnd(EP.SegmentFrames[i]);
      EndpointsPtr++;
    }
  };
  
  if (Error)
    mexErrMsgTxt(String);
}
