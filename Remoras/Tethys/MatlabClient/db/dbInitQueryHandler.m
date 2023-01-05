function query_h = dbInitQueryHandler(server, port, secure)
% query_h = dbInitQueryHandler(server, port, secure)
% Create a query handler given the server name, the port
% on the server, and whether or not secure socket layer transport
% should be used.
%
% This function should not be called directly.
% Call dbInit instead which calls this function after configuring
% the paths for Java classes.

% Create a connection to the Tethys database
if secure
    urlstr = sprintf('https://%s:%d', server, port);
else
    urlstr = sprintf('http://%s:%d', server, port);
end

% Sun Jersey implmentation for JAX-RS RESTful web services
% http://jersey.java.net
import dbxml.JerseyClient;
client = JerseyClient(urlstr);

% Create a query manager.
% The query manager has some predefined queries and let's us perform
% arbitrary ones as well.
% Queries are written in the XQuery language.
% To learn XQuery, Priscilla Walmsley's book:
%    Walmsley, P. (2006) XQuery. O'Reilly, Farnham.
% is quite helpful.  In addition to the print version, Safari subscribers
% (many university libraries) have electronic subscriptions to this book.
import dbxml.Queries;
query_h = Queries(client);
