function old = set_pointer(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% set_pointer.m
%
% Set the figure pointer and return the value of the current one.  
% Contains a workaround for a known bug when the current pointer
% is 'fullcross'.
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES

if length(varargin) < 2
    error('Expecing figure handle and cursor')
end

figH = varargin{end-1};
new = varargin{end};

old = get(figH, 'Pointer');  % return current value

if ~ strcmp(old, new)  % Any need to actually change it?
    if strcmp(old, 'fullcrosshair')
        % fullcross will not always erase itself when the focus
        % is on the current window.  We select another window,
        % set the pointer, hide the window, then restore focus.
%        figure(HANDLES.fig.fullcrossbug);
        set(figH, 'Pointer', new);
%        set(HANDLES.fig.fullcrossbug, 'Visible', 'off');
        figure(figH);
    else
        set(figH, 'Pointer', new);  % Set new pointer type
    end
end