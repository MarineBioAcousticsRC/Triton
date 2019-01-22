
#include "Frame.h"

/* mxArray *Frame(Signal *, EndpointInfo *)
 * Given a signal and a list of endpoints, construct
 * a matrix where each column is a frame.
 */

mxArray *Frame(Signal *In, EndpointInfo *EP)
{
  mxArray	*FramedSig;
  double	*OutPtr;
  SIGNAL	*InBase, *InPtr; 

  int		FrameLength, FrameAdvance, FrameCount;
  int		SegIdx, FrmIdx, SampIdx;

  FrameLength = In->Props.Length.N;
  FrameAdvance = In->Props.Advance.N;
  FrameCount = endpoint_framecount(In, EP);

  if ((FramedSig =
       mxCreateDoubleMatrix(FrameLength, FrameCount, mxREAL)) != NULL) {

    InBase = In->Data;
    OutPtr = mxGetPr(FramedSig);
    for (SegIdx = 0; SegIdx < EP->SegmentCount; SegIdx++) {

      /* Process segment */
      for (FrmIdx = FrameStart(EP->SegmentFrames[SegIdx]);
	   FrmIdx <= FrameEnd(EP->SegmentFrames[SegIdx]);
	   FrmIdx++) {
	
	/* Process frame */
	for (SampIdx=FrmIdx*FrameAdvance;
	     SampIdx < FrmIdx*FrameAdvance + FrameLength;
	     SampIdx++) {
	  *(OutPtr++) = InBase[SampIdx];
	}
      }
    }
  } else
    mexErrMsgTxt("Frame.c:  Unable to allocate matrix for framed signal.");
  
  return FramedSig;
}
  
   
