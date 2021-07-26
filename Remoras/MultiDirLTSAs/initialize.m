
global HANDLES REMORA PARAMS

REMORA.mdLTSA.menu = uimenu(HANDLES.remmenu,'Label','&MultiDirLTSA',...
    'Enable','on','Visible','on');
                   
% allow "Hello World" Remora to use the mouse click down button in the main
% Plot Window (not the Hello World Window)
REMORA.pick.value = 1;
% define what function to run after picking in the main Plot Window
% put m-file name in REMORA.pick.fcn cell array in order of execution
REMORA.pick.fcn{1} = {'hello_pick'};

% Function for adding hotkey commands to the plot figure
xmlFile = which('keymapHello.xml');  % won't work for deployed (compiled)
PARAMS.keypress = xml_read(xmlFile);
set(HANDLES.fig.main,'KeyPressFcn',@handleKeypress)