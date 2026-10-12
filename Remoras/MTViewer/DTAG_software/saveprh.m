function    saveprh(tag,varargin)
%
%    saveprh(tag,...)
%    Save the named variables to the prh file associated with a tag deployment.
%    This will overwrite any previoue prh file for the same tag.
%    Examples:
%    save variables to the prh file of md04_287a
%       saveprh('md04_287a','p','fs')
%    or equivalently:
%       saveprh md04_287a p fs

%    mark johnson
%    majohnson@whoi.edu
%    last modified: 28 June 2006

if nargin<1,
   help saveprh
   return
end

fname = makefname(tag,'PRH') ;
if isempty(fname),
   return
end

% save the variables to the file
s = sprintf('save ''%s''',fname) ;
for k=1:nargin-1, 
   s = strcat(s,sprintf(' %s',varargin{k})) ;
end
s = strcat(s,';') ;
evalin('caller',s)

