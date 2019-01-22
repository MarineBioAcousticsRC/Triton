function init_tslider(tstime)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Small function to set up the slider gui with the appropiate times
% called when you open a new file in the window.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS HANDLES
% get how many micro seconds are in the file.
file_length_sec = (PARAMS.end.dnum - PARAMS.start.dnum) * 60 * 60 * 24;
set(HANDLES.time.slider, 'Min', 0)
set(HANDLES.time.slider, 'Max', round(file_length_sec))
set(HANDLES.time.slider, 'Value', tstime)
step = (PARAMS.tseg.sec)/round(file_length_sec);
set(HANDLES.time.slider, 'SliderStep', [step step*3]);
