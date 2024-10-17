
global REMORA HANDLES

% made by SGB 20240717
% Shelby G. Bloom (sbloom@ucsd.edu)
% modified/based on Soundscape-Metrics Remora initialize.m code by Simone Baumann-Pickering

REMORA.cc.menu = uimenu(HANDLES.remmenu,'Label','&countCOFI',...
    'Enable','on','Visible','on');

% Make countCOFI Table
uimenu(REMORA.cc.menu, 'Label', 'Make countCOFI Table', ...
    'Callback', 'cc_pulldown(''countCOFI'')');

% Make Concatenated File
uimenu(REMORA.cc.menu, 'Label', 'Concatenate Daily Expanded Files', ...
    'Callback', 'cc_pulldown(''concatenate'')');

% Make visEffort Files
uimenu(REMORA.cc.menu, 'Label', 'Make visEffort Outputs', ...
    'Callback', 'cc_pulldown(''visEffort'')');

% Make odontocete and mysticete GMT plots
uimenu(REMORA.cc.menu, 'Label', 'Make Odontocete and Mysticete GMT Plots', ...
    'Callback', 'cc_pulldown(''gmtmaps'')');