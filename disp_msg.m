function disp_msg(msg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% dips_msg.m 
%
% display message in window
%
% Parameters:
%       msg - the string to be displayed on the message window
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES
x = get(HANDLES.msg,'String');
lx = length(x);
x(lx+1) = {msg};
set(HANDLES.msg,'String',x,'Value',lx+1)