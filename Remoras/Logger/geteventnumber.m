function geteventnumber(action)

global handles


handles.eventcount=handles.eventcount+1;
%handles.userid=get(handles.userinitials, 'string');
%handles.dateid=datestr(clock, 'yyyymmdd');
set(handles.eventnumber,'String', [get(handles.userinitials, 'string'), ...
    handles.dateid '_' sprintf('%05d',handles.eventcount)]);

%filename for .wav or .jpeg output file if they make one
handles.outfilename=get(handles.eventnumber, 'string');

