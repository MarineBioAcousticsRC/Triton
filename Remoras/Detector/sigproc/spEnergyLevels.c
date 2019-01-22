#include <mex.h>
#include <matrix.h>
#include <stdio.h>

#include <sp/sphere.h>
#include <snr/spfchar1.h>
#include <snr/snr.h>
#include <snr/speech_det.h>
#include <usr/Endpoint.h>
#include <usr/SignalAnalysis.h>

#define max(a,b) ((a) > (b) ? (a) : (b))
#define min(a,b) ((a) < (b) ? (a) : (b))

/* gateway function
 *
 * LHS Arguments:
 *	SignalInfo
 * RHS Arguments:
 *	Signal
 *
 * Read a Sphere file.
 * 
 *	[Info] = ...
 *		spEnergyLevels(Signal, SampleRate, ...
 *			FrameAdvanceMS, FrameLengthMS)
 *
 * Estimate signal, noise, SNR energy as well as per frame energy.
 * Signal should contain integer values which can be stored in a 16
 * bit signed integer.
 *
 * Requires a custom version of the NIST SPQA.
 *
 * This code is copyrighted 1998-1999 by Marie Roch.
 * e-mail:  marie-roch@uiowa.edu
 * */

/* Fields in information structure.
 * Enumerations and field name must be in the same order.
 */
typedef enum {
  /* Field name position indicators start with F_ */ 
  F_SampleCount,
  F_SampleRate,
  F_DCbias,
  F_Channels,
  F_Signal,
  F_Noise,
  F_SNR,
  F_FrameAdvanceN,
  F_FrameLengthN,
  F_FrameRate,
  F_FrameEnergy,
} InfoPositionIndicators;

char *InfoNames[] = {
  "SampleCount",
  "SampleRate",
  "DCbias",
  "Channels",
  "Signal",
  "Noise",
  "SNR",
  "FrameAdvanceN",
  "FrameLengthN",
  "FrameRate",
  "FrameEnergy"
};

#define InfoFieldCount (sizeof(InfoNames) / sizeof(char *))
  
void
mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray 
	    *prhs[])
{
  /* positional parameters */
# define		InSignal 0		/* in */
# define		InSampleRate 1
# define		InFrameAdvanceMS 2
# define		InFrameLengthMS 3

# define		OutInfo	0

  int			i;
  Signal		Signal;

  int			Error = 0;

  SP_INTEGER		BytesPerSample,
			ChannelCount,
			OutputSampleCount,
			SampleCount;

# define		MaxStringLength 512
  char			String[MaxStringLength];
  SignaldB		SignalLevels;

  if (nrhs <= (InSampleRate + 1)  || nrhs > (InFrameLengthMS + 1))
    mexErrMsgTxt("Invalid argument count");

  Signal.Props.Advance.MS = 16;	/* defaults */
  Signal.Props.Length.MS = 32;
  
  switch (nrhs - 1) {	/* fall through switch */
  case InFrameLengthMS:
    Signal.Props.Length.MS = mxGetScalar(prhs[InFrameLengthMS]);
  case InFrameAdvanceMS:
    Signal.Props.Advance.MS = mxGetScalar(prhs[InFrameAdvanceMS]);
    break;
  }
  
  ChannelCount = 1;	/* currently only handles single channel */
  if (min(mxGetM(prhs[InSignal]), mxGetN(prhs[InSignal])) != 1)
    mexErrMsgTxt("Signal must be a vector");
  
  Signal.Props.SampleCount =
    max(mxGetM(prhs[InSignal]), mxGetN(prhs[InSignal]));
  Signal.Props.SampleRate = (int) mxGetScalar(prhs[InSampleRate]);

  SignalComputeWindowSize(&Signal, 1);

  /* Setup int16 data */
  if (mxIsInt16(prhs[InSignal]))
    Signal.Data = (SIGNAL *) mxGetData(prhs[InSignal]);
  else
    mexErrMsgTxt("Signal must be signed 16 bit integers"
		 " (use int16) to convert");
  
  SignalLevels = signal_levels(&Signal);

  plhs[OutInfo] = mxCreateStructMatrix(1, 1, InfoFieldCount,
				       (const char **) InfoNames);
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
      mxArray	*FrameEnergy;
      
#	define ScalarFieldN(Field) \
		(*mxGetPr(mxGetFieldByNumber(plhs[OutInfo], 0, (Field))))
      
      ScalarFieldN(F_SampleCount) = Signal.Props.SampleCount;
      ScalarFieldN(F_SampleRate) = Signal.Props.SampleRate;
      ScalarFieldN(F_DCbias) = Signal.Props.DCbias;
      ScalarFieldN(F_Channels) = ChannelCount;
      ScalarFieldN(F_Signal) = SignalLevels.Signal;
      ScalarFieldN(F_Noise) = SignalLevels.Noise;
      ScalarFieldN(F_SNR)= SignalLevels.SNR;
      ScalarFieldN(F_FrameAdvanceN) = Signal.Props.Advance.N;
      ScalarFieldN(F_FrameLengthN) = Signal.Props.Length.N;
      ScalarFieldN(F_FrameRate) =
	(double) Signal.Props.SampleRate / (double) Signal.Props.Advance.N;
	
      if ((FrameEnergy =
	   mxCreateDoubleMatrix(SignalLevels.FrameCount, 1, mxREAL))) {
	double	*OutPtr, *InPtr;
	
	mxSetFieldByNumber(plhs[OutInfo], 0, F_FrameEnergy, FrameEnergy);
	OutPtr = mxGetPr(FrameEnergy);
	InPtr = SignalLevels.FrameEnergy;
	
	for (i=0; i < SignalLevels.FrameCount; i++)
	  *(OutPtr ++) = *(InPtr ++);
	
      } else {
	Error = 1;
	strcat(String, "FrameEnergy array ");
      }
    }
  } else {
    Error = 1;
    strcat(String, "Info ");
  }

  free(SignalLevels.FrameEnergy);
  
  if (Error)
    mexErrMsgTxt(String);
}

