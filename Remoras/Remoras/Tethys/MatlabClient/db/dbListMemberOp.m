function str = dbListMemberOp(field, list, quotelist)
% str = dbListMemberOp(field, list)
% Generage an XQuery expression to test if value is a member of 
% a list of strings.  list may either be a cell array or a string.
% quotelist - boolean: items are quotes if true (default)

if nargin < 3
    quotelist = true;
end

if quotelist
    q = '"';
else
    q = '';
end

if ~iscell(list)
    list = {list};
end

conj = '';
str = '';
% build up string:  (field = list{1} or field = list{2] or ... )
for idx = 1:length(list)
    if ~ischar(list{idx})
        error('list must be a string or cell array of strings')
    end
    str = sprintf('%s%s%s = %s%s%s', str, conj, field, q, list{idx}, q);
    conj = ' or ';
end
if length(list) > 1
    str = sprintf('(%s)', str);
end