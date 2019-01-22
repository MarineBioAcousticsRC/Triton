function [copy parent] = guCopyHandleStruct(handles, parent)
% [copy parent] = guCopyHandleStruct(handles, parent)
%
% Given a set of handle objects in structure handles, return a copy of the
% handles.  The new handles are reparented to the optional graphics handle
% parent (e.g. handle to a figure).  
%
% If parent is omitted, a new invisible figure window is created and
% can be accessed by output argument parent.

error(nargchk(1,2,nargin));     % Right # input args?

if ~ isa(handles, 'struct')
  error('handles must be a structure');
end

if nargin < 2
  parent = figure('Visible', 'off');
end

% Get fields of structure and copy all handles
fields = fieldnames(handles);
for fidx = 1:length(fields)
  if ishandle(handles.(fields{fidx}))
    copy.(fields{fidx}) = copyobj(handles.(fields{fidx}), parent);
  end
end
