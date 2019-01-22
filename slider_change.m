function slider_change(src,evt)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% slider_change.m
%
% callback for the sime slider change to edit in real time.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES PARAMS
value = get(HANDLES.time.slider, 'Value');
new_time = PARAMS.raw.dnumStart(1)+datenum([2000 0 0 0 0 value]);
set(HANDLES.time.edtxt1, 'String', datestr(new_time, 'mm/dd/yyyy HH:MM:SS'));