function initwins
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% initwins.m
%
% initialize figure, control and command(display) windows
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% figure window
global HANDLES PARAMS

disp(' ')
disp('Clearing all windows to begin Triton')
disp(' ')

% disp('         Now loading Triton initial screen ');
% disp(' ');
% reads default settings
% rootDir = fileparts(which('triton'));
% settings_dir = fullfile(rootDir,'Settings');
% settings = fullfile(settings_dir, 'defaultWindow.tconfig');
settings = fullfile(PARAMS.path.Settings,'defaultWindow.tconfig');
% checks if the settings folder in on the path
% if ~exist('Settings', 'dir') && ~isdeployed
% %     addpath(settings_dir)
% end

fid = fopen(settings, 'r');

%puts settings in position cell array
if fid ~= -1
    for x=1:3
        defaultPos{x} = str2num(fgetl(fid));
    end
else
    %     errordlg( [ 'Settings folder not found, using default settings'] )
    disp(' ')
    disp('Settings file not found, using default settings')
    % no settings file found, using old default settings
    if str2num(PARAMS.mver(1:3)) ~= 7.4
        defaultPos{1}=[0.335,0.05,0.65,0.875];
    else
        defaultPos{1}=[0.335,0.049,0.65,0.875]; % needed for bug in 7.4.0.287 (R2007a)
    end
    defaultPos{2} = [0.025,0.35,0.3,0.6];
    defaultPos{3} = [0.025,0.05,0.3,0.25];
end

% open and setup figure window
HANDLES.fig.main = figure( ...
    'NumberTitle','off', ...
    'Name',['Plot - Triton '], ...
    'Units','normalized',...
    'Position',defaultPos{1});

% Tools for editing and annotating plots
% plotedit on
% put axis in bottom left, make it tiny,
% turn it off, and save location in variable axHndl1
axis off
axHndl1=gca;

% Function for adding hotkey commands to the plot figure
% possibly more functions will be added later on for
% the use on other figures
% path = which('keymap.xml');
hotkeysfn = fullfile(PARAMS.path.Settings,'keymap.xml');
if exist(hotkeysfn)
    PARAMS.keypress = xml_read(hotkeysfn);
    set(HANDLES.fig.main,'KeyPressFcn',@handleKeypress)
else
    disp(' ')
    disp('hotkeys keymap.xml does not exist')
end

logofn = fullfile(PARAMS.path.Extras,'Triton_logo.jpg');
if exist(logofn)
    image(imread(logofn))
    text('Position',[.7 .15],'Units','normalized',...
        'String',PARAMS.ver,...
        'FontSize', 14,'FontName','Times','FontWeight','Bold');
else
    disp(' ')
    disp('Triton logo jpeg does not exist')
end
axis off

% zoom tool stuff
%detect version
v=version;

%Get proper handles to zoom in and zoom out uitoggletool buttons.  Account
%for difference in tag names between version 6 and version 7

if (str2num(v(1))<7)
    HANDLES.zoom.hin = findall(HANDLES.fig.main,'tag','figToolZoomIn');
    HANDLES.zoom.hout = findall(HANDLES.fig.main,'tag','figToolZoomOut');
else
    HANDLES.zoom.hin = findall(HANDLES.fig.main,'tag','Exploration.ZoomIn');
    HANDLES.zoom.hout = findall(HANDLES.fig.main,'tag','Exploration.ZoomOut');
end

% Change the callback for the "Zoom In" toolbar button
set(HANDLES.zoom.hin,'OffCallback','zoomChangeTime')

% Change the callback for the "Zoom Out" toolbar button
set(HANDLES.zoom.hout,'OffCallback','zoomChangeTime')

% initialize control window
% open and setup figure window
HANDLES.fig.ctrl = figure( ...
    'NumberTitle','off', ...
    'Name',['Control - Triton '],...
    'Units','normalized',...
    'MenuBar','none',...
    'Position',defaultPos{2});

% initialize message display window
% open and setup figure window
HANDLES.fig.msg = figure( ...
    'NumberTitle','off', ...
    'Name',['Message - Triton '],...
    'Units','normalized',...
    'MenuBar','none',...
    'Position',defaultPos{3});

% When a figure is active and we change the cursor from fullcross to
% something else a trace is left.  This bug has been submitted to
% Mathworks (MAR, 2011-01-07).  We can workaround it by changing
% to another window first.  This invisible window does the trick
% Used by function set_cursor.
HANDLES.fig.fullcrossbug = figure('MenuBar', 'none', 'Visible', 'off');
