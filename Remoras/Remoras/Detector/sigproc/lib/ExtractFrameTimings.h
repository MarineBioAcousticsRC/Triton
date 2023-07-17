#ifndef EXTRACTFRAMETIMINGS_H
#define	EXTRACTFRAMETIMINGS_H

#include <usr/Endpoint.h>
#include <mex.h>
#include <matrix.h>

mxArray *ExtractFrameTimings(Signal *, EndpointInfo *, double FrameRate);

#endif
