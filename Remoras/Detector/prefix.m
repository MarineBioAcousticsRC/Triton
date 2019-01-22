function nth = prefix(search_in, prefixes)
% Given a string and a cell array of possible prefixes, 
% find the first prefixes{nth} such that prefixes{nth} is
% a prefix of search_in.
%
% Returns 0 when no such prefix exists.
%
% Example:
%   prefix('C:\Users\YogiBear\picnic_booboo.jpg', ...
%          {'C:\Users\BooBo'; 'C:\Users\YogiBear'})
% returns 2
%
% Do not modify the following line, maintained by CVS
% $Id: prefix.m,v 1.1 2009/11/28 17:00:04 mroch Exp $

error(nargchk(2, 2, nargin));
if ~ ischar(search_in) || ~iscellstr(prefixes) || isempty(prefixes)
    error('search_in must be a string and prefixes must be a cell string')
end

% prime loop
idx = 1;
found = strncmpi(prefixes{idx}, search_in, length(prefixes{idx}));
while ~ found && idx < length(prefixes)
    idx = idx + 1;
    found = strncmpi(prefixes{idx}, search_in, length(prefixes{idx}));
end

if ~ found
    nth = 0;
else
    nth = idx;
end
    
