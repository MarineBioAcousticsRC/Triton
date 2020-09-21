%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------------------------------------------------------------------
%     GLOBAL                    |           DESCRIPTION
% ------------------------------------------------------------------------
%   REMORA.pick.value = 1       |   use pickxyz.m for mouse selection
%   REMORA.pick.value = 0       |   user has already selected from pickxyz.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This should be in ever initialize function. HANDLES is the global
% varible that holds all the graphical buttons and windows of triton
global HANDLES REMORA PARAMS

%MT_loadData;
%our "Localization" button is added to the tool menu
REMORA.TritonMTViewer = uimenu(HANDLES.remmenu,'Label','TritonMTViewer', ...
                      'Callback', 'TritonMTViewer_gui1');
                   
% allow "TritonMTViewer" Remora to use the mouse click down button in the main
% Plot Window 
REMORA.pick.value = 1 ;  
REMORA.pick.fcn{1} = {''};         % define what function to run after picking in the main Plot Window

    
    
    % Function for adding hotkey commands to the plot figure
xmlFile = which('keymapHello.xml');  % won't work for deployed (compiled)
PARAMS.keypress = xml_read(xmlFile);
set(HANDLES.fig.main,'KeyPressFcn',@handleKeypress)
