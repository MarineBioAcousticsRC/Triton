
#include "CreateEndpointed.h"
#include <usr/SignalAnalysis.h>

/*
 * mxArray * CreateEndpointedComplement(Signal *, EndpointInfo *)
 *
 * Given a signal and information about what was detected,
 * extract the complement of the detected signal.
 */

mxArray *CreateEndpointedComplement(Signal *Sig, EndpointInfo *EP)
{
  EndpointInfo	EPComp;		/* Complement information */

  int		ComplementCount, OutputCount;
  int		CurrentSegment, NextStartFrame, LastFrame;

  /* Build complement information */

  ComplementCount = 0;
  NextStartFrame = 0;
  /* locate the last complete frame */
  LastFrame = LastCompleteFrame(Sig->Props.SampleCount,
				Sig->Props.Length.N, Sig->Props.Advance.N);
  if (EP->SegmentCount > 0) {

    /* Segments were detected */
    CurrentSegment = 0;

    /* If no frames were detected before the first segment,
     * set starting frame one past the first segment.
     */
    if (FrameStart(EP->SegmentFrames[CurrentSegment]) == 0) {
      NextStartFrame = FrameEnd(EP->SegmentFrames[CurrentSegment]) + 1;
      CurrentSegment++;
    }

    /* handle segments up to last detected frame */
    while (CurrentSegment < EP->SegmentCount) {

      /* Insert a segment which spans from
       *	one past the last detected segment
       *	to one before the current detected segment
       */ 
      FrameStart(EPComp.SegmentFrames[ComplementCount]) = NextStartFrame;
      FrameEnd(EPComp.SegmentFrames[ComplementCount]) =
	FrameStart(EP->SegmentFrames[CurrentSegment]) - 1;
      NextStartFrame =  
	FrameEnd(EP->SegmentFrames[CurrentSegment]) + 1;

      CurrentSegment++;
      ComplementCount++;
    }
  }

  /* Handle anything after last detected frame (even if no frames detected) */
  if (NextStartFrame < LastFrame) {
    FrameStart(EPComp.SegmentFrames[ComplementCount]) = NextStartFrame;
    FrameEnd(EPComp.SegmentFrames[ComplementCount]) = LastFrame;
    ComplementCount++;
  }

  EPComp.SegmentCount = ComplementCount;

  /* Extract information using the complemented segment structure */
  return CreateEndpointed(Sig, &EPComp);
    
}
