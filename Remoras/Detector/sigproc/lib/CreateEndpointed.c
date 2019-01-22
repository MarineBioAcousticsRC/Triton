
#include "CreateEndpointed.h"

/*
 * mxArray * CreateEndpointed(Signal *, EndpointInfo *)
 */

mxArray *CreateEndpointed(Signal *Sig, EndpointInfo *EP)
{
  double	*OutPtr;
  SIGNAL	*InPtr;
  mxArray	*Out;

  int		OutputCount, i, j;

  OutputCount = endpoint_samplecount(Sig, EP);
  if ((Out = mxCreateDoubleMatrix(OutputCount, 1, mxREAL))) {

    OutPtr = mxGetPr(Out);
    /* copy endpointed information */
    for (i=0; i < EP->SegmentCount; i++) {
      for (j=FrameStartSample(EP->SegmentFrames[i], Sig->Props);
	   j <= FrameEndSample(EP->SegmentFrames[i], Sig->Props);
	   j++)
	*(OutPtr++) = Sig->Data[j];
    }
  }

  return Out;
}
