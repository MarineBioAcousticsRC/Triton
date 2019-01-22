#include "CreateEndpointedFrameEnergy.h"

mxArray *CreateEndpointedFrameEnergy(Signal *Sig, EndpointInfo *EP)
{
  double	*OutPtr;
  SIGNAL	*InPtr;
  mxArray	*Out;

  int		OutputCount, i, j;

  OutputCount = endpoint_framecount(Sig, EP);
  if ((Out = mxCreateDoubleMatrix(OutputCount, 1, mxREAL))) {

    OutPtr = mxGetPr(Out);
    /* copy endpointed information */
    for (i=0; i < EP->SegmentCount; i++) {
      for (j=FrameStart(EP->SegmentFrames[i]);
	   j <= FrameEnd(EP->SegmentFrames[i]);
	   j++)
	*(OutPtr++) = EP->SignalLevels.FrameEnergy[j];
    }
  }

  return Out;
}
