%enable pull-down menus for sound types according to which radio button is
%pushed in uibuttongroup

function whichspecies

global handles

%find out which button is selected and index into array of species names
handles.speciesindex= find(handles.speciesarray ==...
    get(handles.speciesbuttons, 'selectedObject'));

%match the call type array to whichever species is selected
set(handles.calltypemenu, 'string', handles.calltypearray{handles.speciesindex},...
    'enable', 'on');

%set the selected species string
handles.selectedspecies=handles.speciesStr(handles.speciesindex);

specstr=sscanf(char(handles.selectedspecies), '%s');

%if long species name, abbreviate to first 5 characters of species string
if length(specstr)>5;      
    handles.speciesabbrev=specstr(1:5);
else handles.speciesabbrev=specstr;
end

