function valid = dbVerifyQueryHandler(q)
% valid = dbVerifyQueryHandler(q)
% Checks to see if q is an instance of a Tethys query handler
% (Java class dbxml.Queries).  
% Sets valid to true if it is.
%
% Note that this only guarantees that the query handler has been
% initialized properly, it does not guarantee that the Tethys server
% is active.  To check if the server is active, use q.ping() which will
% return true if is, and false if it is not.  Note that when the server
% is not active there will be delay before q.ping() returns as we are
% waiting for a timeout.

import dbxml.Queries

valid = isjava(q) && isa(q, 'dbxml.Queries');
