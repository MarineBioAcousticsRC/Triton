%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% If the remora has been added through the Triton interface, This function 
% is called at the start of every triton session. This file populates 
% toolbars with remora specific options and callbacks.
%
% A best practice for remoras that have multiple m-files containing callbacks
% would be initializing new control windows and buttons here rather than in 
% child m-files.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This should be in ever initialize function. HANDLES is the global
% varible that holds all the graphical buttons and windows of triton
global HANDLES REMORA PARAMS

% add "Image Set" button is added to the tool menu
REMORA.image_set = uimenu(HANDLES.remmenu,'Label','&Image Set', ...
                       'Enable','on','Visible','on');
                   % select a logging GUI
uimenu(REMORA.image_set,'Label', 'Label LTSA images', ...
    'Callback', @is_initGui);

% allow "Image Set" Remora to use the mouse click down button in the main
% Plot Window (not the Hello World Window)
REMORA.pick.value = 1;
% define what function to run after picking in the main Plot Window
% put m-file name in REMORA.pick.fcn cell array in order of execution
REMORA.pick.fcn{1} = {'is_imagePickOn'};

% Function for adding hotkey commands to the plot figure
xmlFile = which('keymapImageSet.xml');  % won't work for deployed (compiled)
PARAMS.keypress = xml_read(xmlFile);