#include <mex.h>
#include <matrix.h>
#include <stdio.h>

#include <sp/sphere.h>
#include <snr/spfchar1.h>
#include <snr/snr.h>
#include <snr/speech_det.h>
#include <usr/endpoint.h>

/* gateway function
 *
 * LHS Arguments:
 *	Data
 *	SampleRate
 *	Channels
 *	Bytes
 * RHS Arguments:
 *	FileName
 *	N -	Optional, Non zero indicates data should be endpointed
 *
 * Read a Sphere file.
 * 
 *	[GlobalLevels] = ...
 *		spSignalLevels(PCMData, SampleRate);
 *
 * Requires the NIST Sphere library and a custom version of the NIST SPQA
 * library.
 *
 * This code is copyrighted 1998 by Marie Roch.
 * e-mail:  marie-roch@uiowa.edu
 *
 * Permission is granted to use this code as per version 2 of the
 * Free Software Foundation's GNU General Public License.
 */

void
mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray 
	    *prhs[])
{
  /* positional parameters */
# define		InFileName 0		/* in */
# define		InEndpoint 1

# define		OutSamples 0
# define		OutSamplesRead 1
# define		OutSampleRate 2
# define		OutChannels 3
# define		OutBytes 4

# define		MaxStringLength 512
  char			FileName[MaxStringLength];
  char			String[MaxStringLength];	
  int			i;

  const int		EndpointVerbose = 0;
  int			OutputFree = 0;		/* allocated memory for output */

  int			Endpoint;

  SP_INTEGER		BytesPerSample,
			ChannelCount,
			OutputSampleCount,
			SampleCount,
			SampleRate;

  EndpointInfo		Info;
  SP_FILE		*SphereFile;
  SIGNAL		*Data, *OutputData;
  double		*OutputMatlab;

  if (nrhs < 1 || nrhs > 2)
    mexErrMsgTxt("Invalid argument count");
      
  if (mxGetString(prhs[InFileName], FileName, MaxStringLength)) {
    mexErrMsgTxt("Filename not a string or too long");
  } 

  Endpoint = 0;		/* default no endpoint */

  if (nrhs > 1) {
      Endpoint = (int) mxGetScalar(prhs[InEndpoint]);
  }

  if (! (SphereFile = sp_open(FileName, "r"))) {
    sprintf(String, "Unable to open Sphere file <%s>.", InFileName);
    mexErrMsgTxt(String);
  }

  (void) sp_h_get_field(SphereFile, SAMPLE_COUNT_FIELD,
			T_INTEGER, (void **) &SampleCount);
  (void) sp_h_get_field(SphereFile, CHANNEL_COUNT_FIELD,
			T_INTEGER, (void **) &ChannelCount);
  (void) sp_h_get_field(SphereFile, SAMPLE_RATE_FIELD,
			T_INTEGER, (void **) &SampleRate);
  (void) sp_h_get_field(SphereFile, SAMPLE_N_BYTES_FIELD,
			T_INTEGER, (void **) &BytesPerSample);

  if (sp_set_data_mode(SphereFile, "SE-PCM-2:SBF-N")) {
    sp_close(SphereFile);
    mexErrMsgTxt("Invalid Sphere data mode");
  }

  /* Warning:  We're using the library's memory management..
   * If a signal causes termintation before this Mex file exits,
   * a memory leak may occur.  Fortunately, this is a small window.
   */
  if (! (Data = (SIGNAL *) sp_data_alloc(SphereFile, SampleCount)))
    mexErrMsgTxt("Unable to allocate space for sample");
  
  if (! sp_read_data((void *) Data, SampleCount, SphereFile)) {
    sp_data_free(SphereFile, Data);
    mexErrMsgTxt("Unable to read file after obtaining file handle");
  }
  
  if (Endpoint) {
    Info = endpoint(Data, SampleRate, SampleCount, &OutputData,
			    KUBALA, EndpointVerbose);
    OutputSampleCount = Info.Samples;
    if (! OutputSampleCount) {
      sp_data_free(SphereFile, Data);
      mexErrMsgTxt("Unable to endpoint data");
    }
    OutputFree = 1;
  } else {
    OutputSampleCount = SampleCount;
    OutputData = Data;
  }

  if (! (plhs[OutSamples] = mxCreateDoubleMatrix(OutputSampleCount, 1, mxREAL))) {
    if (OutputFree)
      free(OutputData);
    sp_data_free(SphereFile, Data);
    mexErrMsgTxt("Unable to allocate output matrix");
  }
  
  i = nlhs - 1;
  while (i > 0) {
    if (! (plhs[i] = mxCreateDoubleMatrix(1,1,mxREAL))) {
      if (OutputFree)
	free(OutputData);
      sp_data_free(SphereFile, Data);
      mexErrMsgTxt("Unable to allocate output scalars");
    }
    i--;
  }

  /* Populate output fields that are present */
  switch (nlhs - 1) {	/* fall through switch */
  case OutBytes:
    (*(mxGetPr(plhs[OutBytes]))) = BytesPerSample;
  case OutChannels:
    (*(mxGetPr(plhs[OutChannels]))) = ChannelCount;
  case OutSampleRate:
    (*(mxGetPr(plhs[OutSampleRate]))) = SampleRate;
  case OutSamplesRead:
    (*(mxGetPr(plhs[OutSamplesRead]))) = OutputSampleCount;
  case OutSamples:
    OutputMatlab = mxGetPr(plhs[OutSamples]);
    for (i=0; i < OutputSampleCount; i++)
      OutputMatlab[i] = (double) OutputData[i];
  }

  if (OutputFree)
    free(OutputData);

  sp_data_free(SphereFile, Data);
  sp_close(SphereFile);
}


    


    
	  

    

  
    
  

  
    
      
      
	

      
      
    

