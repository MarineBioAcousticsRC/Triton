%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Initialize the Logger pulldown
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES REMORA PARAMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

REMORA.logmenu = uimenu(HANDLES.remmenu,'Label','&Log',...
    'Enable','on','Visible','on');
% select a logging GUI
 uimenu(REMORA.logmenu,'Label', 'New log', ...
    'MenuSelectedFcn', {@initLogctrl, 'create'});
uimenu(REMORA.logmenu, 'Label', 'Continue existing log', ...
    'MenuSelectedFcn', {@initLogctrl, 'append'});
uimenu(REMORA.logmenu, 'Label', 'Submit log', ...
    'MenuSelectedFcn', @submit_to_tethys);
uimenu(REMORA.logmenu, 'Label', 'Toggle workbook visibility', ...
    'MenuSelectedFcn', {@control_log, 'workbook_visibility_toggle'});
uimenu(REMORA.logmenu, 'Label', '&Add hotkey', 'Enable', 'on', ...
    'Visible', 'on', 'MenuSelectedFcn', @addHotKey);

% allow Logger Remora to use the mouse click down button in the main
% Plot Window 
REMORA.pick.value = 1;
% define what function to run after picking in the main Plot Window
% put m-file name in REMORA.pick.fcn cell array in order of execution
REMORA.pick.fcn{1} = {'logpickOn'};

% Function for adding hotkey commands to the plot figure
xmlFile = which('keymapLogger.xml');
PARAMS.keypress = xml_read(xmlFile);
set(HANDLES.fig.main,'KeyPressFcn',@handleKeypress)