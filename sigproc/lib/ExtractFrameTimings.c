#include "ExtractFrameTimings.h"

mxArray *ExtractFrameTimings(Signal *Sig, EndpointInfo *EP, double FrameRate)
{
  double	*OutPtr;
  SIGNAL	*InPtr;
  mxArray	*Out;

  int		OutputCount, i, j;

  OutputCount = endpoint_framecount(Sig, EP);
  if ((Out = mxCreateDoubleMatrix(OutputCount, 1, mxREAL))) {

    OutPtr = mxGetPr(Out);
    /* determine timings */
    for (i=0; i < EP->SegmentCount; i++) {
      for (j=FrameStart(EP->SegmentFrames[i]);
	   j <= FrameEnd(EP->SegmentFrames[i]);
	   j++)
	*(OutPtr++) = (double) j / FrameRate;
    }
  }

  return Out;
}
