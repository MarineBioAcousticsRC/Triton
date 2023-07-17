#ifndef CREATEENDPOINTED_H
#define	CREATEENDPOINTED_H

#include <usr/Endpoint.h>
#include <mex.h>
#include <matrix.h>

mxArray *CreateEndpointed(Signal *, EndpointInfo *);
mxArray *CreateEndpointedComplement(Signal *, EndpointInfo *);
#endif
