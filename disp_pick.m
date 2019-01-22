function disp_pick(pick)
%
% display pickxyz value from pickxyz.m in Message Window
%
global HANDLES

x = get(HANDLES.pick.disp,'String');
lx = length(x);
x(lx+1) = {pick};
set(HANDLES.pick.disp,'String',x,'Value',lx+1)

%places the cursor to the bottom, need to use eval because it only works on
%terminal
eval('jDEdit = findjobj(HANDLES.pick.disp);');
eval('jDisp = jDEdit.getComponent(0).getComponent(0);')
eval('jDisp.setCaretPosition(jDisp.getDocument.getLength)')
