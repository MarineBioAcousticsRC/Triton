function result = dbGetDocument(query_h, collection, DocId, varargin)
% result = dbGetDocument(query_h, collection, DocId, OptionalArgs)
% Return the document DocId from the specified collection.
%
% Optional arguments
% 'Encoding', String (default 'xml')
%   Specifies how document should be formatted.
%   'xml' - Return document as extended markup language (XML)
%   'struct' - Return document as a Matlab structure

name = sprintf('dbxml:///%s/%s', collection, DocId);
query = sprintf(...
  'for $doc in collection("%s") where base-uri($doc) = "%s" return $doc', ...
  collection, name);
    
result = query_h.QueryTethys(query);

