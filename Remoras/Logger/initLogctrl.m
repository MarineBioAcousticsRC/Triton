function initLogctrl(varargin)
% initLogctrl(mode)
% Callback for starting logger
% The mode should be 'create' or 'append'
% May be called directly or as a GUI callback.
% GUI callbacks have the signature:
%   hObject, eventdata, guidata
% where guidata is expected to be the mode argument.
%
% Initialize GUI for logger and request log file
% mode:  'create' - new log, 'append' - continue existing

global PARAMS TREE handles HANDLES REMORA

% Get a Tethys query handler instance from the Tethys REMORA
if exist('get_tethys_server') ~= 2
    error('Tethys Remora must be installed')
else
    query_h = get_tethys_server();
end

if length(varargin) > 2
    hObject = varargin{1};
    eventdata = varargin{2};
end
mode = varargin{end};


if exist('handles', 'var') && isfield(handles, 'Server') ...
        && ~isempty(handles.Server)
    errordlg('Cannot start a log while one is in progress.')
    return;
end

template = getEffortTemplate();  % Filename for effort template

if ~ exist(template, 'file')
    errordlg(sprintf('Unble to locate the effort template:\n%s', template));
    return
end

switch mode
    case 'create'
        [fname, fdir] = uiputfile('.xlsx', 'New annotation log', 'unique_logname');
    case 'append'
        [fname, fdir] = ...
            uigetfile({'*.xls'; '*.xlsx'}, 'Open existing annotation log');
    otherwise
        error('triton:logger', 'Bad log mode')
end

if isnumeric(fname)
    return  % User did not select a filename
end

handles.logfile = fullfile(fdir, fname);


PARAMS.numfreq = 6;
handles.calltype = [];
%create GUI figure window 4 since Triton has 3 figure windows already
handles.logcallgui=figure('CloseRequestFcn', @restore_pointer,...
    'menubar', 'none',...
    'NumberTitle', 'off',...
    'name', 'Log Calls',...
    'units', 'normalized',...
    'position', [0.025,0.05,0.3,0.4]);

% initialize fields
PARAMS.log.mode = 'OnEffort';   % Assume on effort until user say otherwise
PARAMS.log.effort = 1; % effort button is turned on
PARAMS.log.start = 0; % effort button is turned on
PARAMS.effort.end = [];  % end effort has not been specified
handles.eventcount=[];       %no events logged yet
handles.dateid = datestr(clock, 'yyyy-mm-dd');


% 20 rows, 4 columns, except for motion control buttons
r = 20; % rows
c = 4;  % columns
h = 1/r;
w = 1/c;
dsepx = w *.10; % use this if you you dont want a seperation
dsepy = h * .25; % use this if you you dont want a seperation
%
% make x and y locations in plot control window (relative units)
for ci = 1:c
    x(:,ci) = ((ci-1)/c) .* ones(r,1);
    y(:,ci) = h .* [r-1:-1:0]';
end

% now only 15 columns
for ri = 1:r
dy = h * 0.25;
y(ri,:) = y(ri,:) - ri*dy;
end

for ci = 1:c
    dx = w * 0.1;
    x(:,ci) = x(:,ci) + ci*dy;
end

%  disp(x)
%  disp(y)
%
% offset y to provide space between control sections

bgColor1 = [1 1 1];  % white

bgColor2 = [0.9 0.9 0]; % yellow
bgColor3 = [.75 .875 1]; % light blue 
bgColor4 = [1.0 .60 .0]; % orange
bgColor5 = [0.8 0.3 0.8]; % purple
bgColor6 = [0.1 0.8 1.0]; % blue
bgColor7 = [0.4 1.0 0.4]; % green
bgColor8 = [0.8 0.8 0.8]; % gray

mid = (x(1,2) - dsepx) + w/2; % for the effort button in the middle
midOff = x(1,4)/2 + dsepx; %for slightly off too the right
midR1 = (x(1,3) - dsepx) + w/2; % for the pick freq
midR2 = (x(1,3) - dsepx) + w/3; % for the freq ops

ButtonAttrib = { ...
    'Style', 'pushbutton',...
    'Units', 'normalized',...
    'HorizontalAlignment', 'left',...
    'BackgroundColor', bgColor3,...
    'Visible', 'off', ...
};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  initiate the TREE controls
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% make the tree for the species
species_tree(template)

jtree = TREE.tree.getTree;
set(jtree, 'LargeModel',1);
set(TREE.tree, 'Visible', 0);


labelStr = 'Load Effort Template';
btnpos = [x(1,1), y(1,1), w, h];
handles.effortL=uicontrol(handles.logcallgui,...
    ButtonAttrib{:}, 'String', labelStr, 'Position', btnpos, ...
    'Callback', {@control_log, 'load_effort'});

labelStr = 'Save Effort Template';
btnpos = [x(2,1), y(2,1), w, h];
handles.effortS=uicontrol(handles.logcallgui,...
    ButtonAttrib{:}, 'String', labelStr, 'Position', btnpos, ...
    'Callback', {@control_log, 'save_effort'});

%create an effort button 
labelStr = 'Set Effort';
btnpos = [x(1,3)*1.3 y(2,1), w, 2*h];
handles.effort = uicontrol(handles.logcallgui,...
    ButtonAttrib{:}, ...
    'String', labelStr,  'Position', btnpos, ...
    'Callback', {@control_log, 'set_effort'});

%create ganularity label
labelStr = 'Granularity';
btnpos = [x(2,2), y(1,1), w/2, h];
handles.granularityLabel = uicontrol(handles.logcallgui,...
    'Style', 'text',...
    'String', labelStr,...
    'Units', 'normalized',...
    'Position',btnpos,...
    'HorizontalAlignment', 'center',...
    'BackgroundColor', bgColor8,...
    'Visible', 'off');

%granularity popup menu
btnpos = [x(2,2), y(2,1), w/2, h];
labelStr = {'encounter', 'call', 'binned'};
handles.granularity = uicontrol(handles.logcallgui,...
    'Style', 'popupmenu',...
    'Units', 'normalized',...
    'BackgroundColor', bgColor3,...
    'Visible', 'off',...
    'String', labelStr,...
    'Position', btnpos,...
    'Callback',{@control_log,'set_gran'});



%Bin time editable textbox
btnpos = [x(2,2)*1.5  y(2,1) w h];
labelStr = '60';
handles.binTime = uicontrol(handles.logcallgui,...
    'Style', 'edit',...
    'Units', 'normalized',...
    'Visible', 'off',...
    'String', labelStr,...
    'BackgroundColor', bgColor3,...
    'Position', btnpos);

%Bin time label
btnpos = [x(2,2)*1.5 y(1,1) w h*1.1];
labelStr = 'Time in minutes (must divide evenly into 24h)';
handles.binLabel = uicontrol(handles.logcallgui,...
    'Style', 'text',...
    'Units', 'normalized',...
    'Visible', 'off',...
    'String', labelStr,...
    'BackgroundColor', bgColor8,...
    'Position', btnpos);

%puts the second pane of the logger window in one handle for easy way to
%make visible
handles.effortPane = [handles.effortL handles.effortS handles.effort...
                      handles.granularity handles.granularityLabel];
                      

% Last selected time and frequency range
handles.timefreq = zeros(1, 2);
labels = {'Start', 'End'};
for k=1:2
    labelStr = sprintf('%s time/freq:  ', labels{k});
    btnpos = [x(k,1), y(k,1), 2*w, h];
    handles.timefreq(k) = uicontrol(handles.logcallgui, ...
        'String', labelStr, 'Units', 'normalized', 'Position', btnpos, ...
        'Style', 'text', 'BackgroundColor', bgColor1, ...
        'HorizontalAlignment', 'left');
end

%create an effort button
labelStr = 'On Effort -> Off Effort';
btnpos = [midR1, y(2,1), w, 2*h];
handles.adhoc=uicontrol(handles.logcallgui,...
    ButtonAttrib{:}, 'String', labelStr,  'Position', btnpos, ...
    'Callback', {@control_log, 'adhoc'});

labelStr = 'No previous detections';
btnpos = [x(1,1), y(3,1), w, h];
handles.deletelog=uicontrol(handles.logcallgui,...
    'style', 'pushbutton',...
    'string', labelStr,...
    'units', 'normalized',...
    'position', btnpos, ...
    'FontSize', 10,...
    'FontWeight','bold',...
    'HorizontalAlignment', 'left',...
    'BackgroundColor', bgColor3,...
    'Callback', {@control_log, 'delete_log'});

% Previous log entry display
btnpos = [x(1,2), y(3,1), 3*w, h];
handles.previouspicks=uicontrol(handles.logcallgui,...
    'Style', 'text',...
    'Units', 'normalized',...
    'Position', btnpos,...
    'HorizontalAlignment', 'left',...
    'BackgroundColor', bgColor1,...
    'String', '');

%create a group text window
labelStr = 'Group';
btnpos = [x(1,1), y(4,1), w*.95, h];
handles.group.txt =uicontrol(handles.logcallgui,...
    'Style', 'text',...
    'String', labelStr,...
    'Units', 'normalized',...
    'Position', btnpos, ...
    'HorizontalAlignment', 'center',...
    'BackgroundColor', bgColor6);

%create a group pull down menu
labelStr = ['none'];
btnpos = [x(1,1), y(5,1)+dsepy, w*.95, h];
handles.group.pulldown =uicontrol(handles.logcallgui,...
    'style', 'popupmenu',...
    'string', labelStr,...
    'units', 'normalized',...
    'position', btnpos, ...
    'HorizontalAlignment', 'left',...
    'BackgroundColor', bgColor1,...
    'Callback', {@control_log, 'group'}');

%create a group text window
labelStr = 'Species';
btnpos = [x(1,2), y(4,1), w*.95, h];
handles.species.txt =uicontrol(handles.logcallgui,...
    'style', 'text',...
    'string', labelStr,...
    'units', 'normalized',...
    'position', btnpos, ...
    'HorizontalAlignment', 'center',...
    'BackgroundColor', bgColor7);
%create a group pull down menu
labelStr = ['none'];
btnpos = [x(1,2), y(5,1)+dsepy, w*.95, h];
handles.species.pulldown = uicontrol(handles.logcallgui,...
    'style', 'popupmenu',...
    'string', labelStr,...
    'units', 'normalized',...
    'position', btnpos, ...
    'HorizontalAlignment', 'left',...
    'BackgroundColor', bgColor1,...
    'callback', {@control_log, 'species'});

%create radio buttons for species
labelStr = 'Call Types';
btnpos = [x(1,1), y(10,1), 2*w, 6*h];
handles.speciesbuttons=uibuttongroup('parent',handles.logcallgui,...
    'units', 'normalized',...
    'position', btnpos,...
    'backgroundcolor', bgColor5,...
    'Title', labelStr);

%create 'pick call time' button and editable text box
pckW = w*.60;
labelStr = 'Pick Start';
btnpos = [x(1,1), y(11,1), pckW, h];
handles.pickstart=uicontrol(handles.logcallgui,...
    'style', 'pushbutton',...
    'string', labelStr,...
    'units', 'normalized',...
    'position', btnpos,...
    'backgroundcolor', bgColor4,...
    'callback',{@control_log, 'pickstart'});

%want the text box to get its input from user-picked cursor value
%similar to pickxy
width = w + abs(pckW - w);
xpos = x(1,1)+pckW;
btnpos = [xpos, y(11,1), width, h];
    handles.pickstartdisplay=uicontrol(handles.logcallgui,...
    'style', 'edit',...
    'units', 'normalized',...
    'position', btnpos,...
    'HorizontalAlignment', 'left');

%create 'pick call end' button and editable text box
pckW = w*.60;
labelStr = 'Pick End';
btnpos = [x(1,1), y(12,1), pckW, h];
handles.pickend=uicontrol(handles.logcallgui,...
    'style', 'pushbutton',...
    'string', labelStr,...
    'units', 'normalized',...
    'position', btnpos,...
    'backgroundcolor', bgColor4,...
    'callback',{@control_log, 'pickend'});
%want the text box to get its input from user-picked cursor value
%similar to pickxyz
width = w + abs(pckW - w);
xpos = x(1,1)+pckW;
btnpos = [xpos, y(12,1), width, h];
    handles.pickenddisplay=uicontrol(handles.logcallgui,...
    'style', 'edit',...
    'units', 'normalized',...
    'position', btnpos,...
    'HorizontalAlignment', 'left');

%create 'comments' editable text box
btnpos = [x(1,1), y(16,1)+2*dsepy, 2*w, 3*h];
handles.comments=uicontrol(handles.logcallgui,...
    'style', 'edit',...
    'units', 'normalized',...
    'position', btnpos,...
    'backgroundcolor', bgColor1,...
    'HorizontalAlignment', 'left',...
    'max', 3, 'min', 0);

%create 'comments' text box
labelStr = 'Comments:';
btnpos = [x(1,1), y(13,1)-dsepy, w, h];
handles.commentstext=uicontrol(handles.logcallgui,...
    'style', 'text',...
    'string', labelStr,...
    'units', 'normalized',...
    'backgroundcolor', bgColor2,...
    'position', btnpos);

%create 'Pick freq' text box
labelStr = 'Time/Frequency scratchpad';
btnpos = [x(1,3), y(4,1), 1.8*w, h];
handles.pkfreq=uicontrol(handles.logcallgui,...
    'style', 'radiobutton',...
    'units', 'normalized',...
    'string', labelStr,...
    'position', btnpos,...
    'ToolTipString', 'These selections are not logged.', ...
    'backgroundcolor', bgColor4);

%create Pick freq editable text box
labelStr = {'Unlogged time-frequency selections'};
btnpos = [x(1,3), y(8,1), 1.8*w, 5*h];
handles.pkfreqdisplay=uicontrol(handles.logcallgui,...
    'style', 'listbox',...
    'units', 'normalized',...
    'string', labelStr,...
    'position', btnpos,...
    'backgroundcolor', bgColor1,...
    'HorizontalAlignment', 'left',...
    'max', 4, 'min', 0);

if PARAMS.numfreq > 0
    k = 1;
    while k <= PARAMS.numfreq
        
        frqbtnpos{k} = [x(1,3), y(8+k,1), w, h];
        txtbtpos{k} = [x(1,4)-dsepx, y(8+k,1), w-2*dsepx, h];
        frqlabelStr{k} = ['Param ',num2str(k)];
        calback{k} = {@control_log, 'set_parameter'};
        k = k+1;
    end

    for i=1:PARAMS.numfreq
        % create 'freq' buttons and editable text box
        handles.freq(i)=uicontrol(handles.logcallgui,...
            'Style', 'pushbutton',...
            'String', frqlabelStr{i},...
            'Units', 'normalized',...
            'Position', frqbtnpos{i},...
            'Backgroundcolor', bgColor4,...
            'HorizontalAlignment', 'left', ...
            'Callback',calback{i});
        % want the text box to get its input from user-picked cursor value
        % similar to pickxyz
        handles.freqdisplay(i)=uicontrol(handles.logcallgui,...
            'style', 'edit',...
            'units', 'normalized',...
            'position', txtbtpos{i},...
            'backgroundcolor', bgColor1, ...
            'HorizontalAlignment', 'left', ...
            'Callback', calback{i});
    end
end

labelStr = 'Log';
btnpos = [x(1,4)+1.5*dsepx, y(16,1)+dsepy, w*0.6, 2*h];
handles.logbutton=uicontrol(handles.logcallgui,...
    'style', 'pushbutton',...
    'string', labelStr,...
    'units', 'normalized',...
    'position', btnpos, ...
    'FontSize', 10,...
    'FontWeight','bold',...
    'HorizontalAlignment', 'left',...
    'BackgroundColor', bgColor3,...
    'Callback', {@control_log, 'log'});

labelStr = 'Save Image';
btnpos = [x(1,3)-.7*dsepx, y(16,1)+dsepy, w*0.6, 2*h];
handles.savejpegbutton=uicontrol(handles.logcallgui,...
    'style', 'pushbutton',...
    'string', labelStr,...
    'units', 'normalized',...
    'position', btnpos, ...
    'FontSize', 8,...
    'FontWeight','bold',...
    'HorizontalAlignment', 'center',...
    'BackgroundColor', bgColor8,...
    'Callback', {@control_log, 'savejpg'});
set(handles.savejpegbutton, 'value', 0);

labelStr = 'Save Audio';
btnpos = [midR1+1.7*dsepx, y(16,1)+dsepy, w*0.6, 2*h];
handles.savexwavbutton=uicontrol(handles.logcallgui,...
    'style', 'pushbutton',...
    'string', labelStr,...
    'units', 'normalized',...
    'position', btnpos, ...
    'FontSize', 8,...
    'FontWeight','bold',...
    'HorizontalAlignment', 'center',...
    'BackgroundColor', bgColor8,...
    'Max', 3,...
    'Callback', {@control_log, 'mkXWAV'});

handles.menu = uimenu(handles.logcallgui, 'Label','Tools');
labelStr = 'Save kernel';
handles.kernelsav = uimenu(handles.menu, 'Label', 'Generate kernel',...
    'callback', @kernel_gen);

handles.log.control = ...
    [handles.timefreq handles.adhoc handles.previouspicks...
    handles.group.txt handles.group.pulldown handles.species.txt handles.deletelog...
    handles.species.pulldown handles.speciesbuttons handles.pickstart...
    handles.pickstartdisplay handles.pickend handles.pickenddisplay...
    handles.comments handles.commentstext handles.pkfreq...
    handles.pkfreqdisplay handles.freq handles.freqdisplay ...
    handles.logbutton handles.savejpegbutton handles.savexwavbutton];

 set(handles.log.control, 'visible', 'off')
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  initiate the EFFORT controls
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.effortstart = [];
handles.effortend = [];

% Text boxes have these attributes
TextAttrib = {'Style', 'text', 'Units', 'normalized', ...
    'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
    'BackgroundColor', bgColor4};
% Edit boxes have these attributes
EditAttrib = { ...
    'Style', 'edit', 'String', '', 'Units', 'normalized', ...
    'HorizontalAlignment', 'left', 'BackgroundColor', bgColor1};
% popup menu have these attributes
PopupAttrib = {
    'Style', 'popupmenu', 'Units', 'normalized', ...
    'HorizontalAlignment', 'left', 'BackgroundColor', bgColor1};
    
% User ID
btnpos = [x(1,1), y(4,1), w, h];
handles.user.text= uicontrol(handles.logcallgui,TextAttrib{:},...
    'String', 'User ID', 'Position', btnpos );
btnpos = [x(1,2)-dsepx, y(4,1), w, h];
handles.user.disp= uicontrol(handles.logcallgui,EditAttrib{:},...
    'Position', btnpos);

% Retrieve valid deployment identifiers if we have a valid query handler
if ~ isempty(query_h)
    try
        dep = dbGetDeployments(query_h, "return", "Id");
        deployment_id = sort(string(arrayfun(@(x) x.Deployment.Id, dep)));
    catch e
        deployment_id = [];
        fprintf("Unable to query Tethys, list of valid deployment identifiers unavailable\n")
        fprintf("Error:\n")
        e
    end
else
    deployment_id = [];
end
% Attempt to divine the deployment identifier from an open LTSA or audio
% file
if length(PARAMS.ltsa.infile) + length(PARAMS.infile) > 0
    % See if any of the deployment Ids are a substring of the filename
    if ~ isempty(deployment_id)
        fnames = string({PARAMS.ltsa.infile, PARAMS.infile});
        for idx = 1:length(fnames)
            if ~ isempty(fnames(idx))
                % See if a deployment matches
                matches = arrayfun(...
                    @(dep) contains(fnames(1), dep, 'IgnoreCase', true), ...
                    deployment_id);
                match_idx = find(matches > 0, 1, 'first');
                if ~ isempty(match_idx)
                    break;
                end
            end
        end
    end
else
    match_idx = [];
end
handles.DeploymentStart = '';
handles.DeploymentEnd = '';

% Deployment
labelStr = 'Deployment/Id';
btnpos = [x(1,1), y(5,1), w, h];
handles.deploy.text= uicontrol(handles.logcallgui, TextAttrib{:},...
    'String', labelStr, 'Position', btnpos);
btnpos = [x(1,2)-dsepx, y(5,1), w, h];
if isempty(deployment_id)
    handles.deploy.disp = uicontrol(handles.logcallgui, EditAttrib{:},...
        'Position', btnpos,  'String', 'id');
else
    handles.deploy.disp = uicontrol(handles.logcallgui, PopupAttrib{:},...
        'Position', btnpos,  'String', deployment_id);
    if ~ isempty(match_idx)
        % Set guess as first match
        handles.deploy.disp.Value = match_idx;
    end
end
    
% Effort start time
btnpos = [x(1,1), y(8,1), w, h];
handles.effort_start.txt = uicontrol(handles.logcallgui,...
    ButtonAttrib{:}, 'HorizontalAlignment', 'center', ...
    'Callback', {@set_time, 'effort_start'}, ...
    'String', 'Effort Start Time', 'position', btnpos, ...
    'TooltipString', 'Set to start of deployment (if available)');
btnpos = [x(1,2)-dsepx, y(8,1), w, h];
handles.effort_start.disp = uicontrol(handles.logcallgui, EditAttrib{:},...
    'position', btnpos, ...
    'String', datestr(handles.DeploymentStart, 31));


labelStr = 'Set deployment metadata';
btnpos = [mid-w, y(2,1), 2*w, 2*h];
handles.done= uicontrol(handles.logcallgui,...
    'style', 'pushbutton',...
    'string', labelStr,...
    'units', 'normalized',...
    'FontSize', 10,...
    'FontWeight','bold',...
    'position', btnpos, ...
    'HorizontalAlignment', 'left',...
    'BackgroundColor', bgColor3,...
    'Callback', {@control_log, 'set_metadata'}');

% Effort end time
btnpos = [x(1,1), y(4,1), w, h];
handles.effort_end.txt = uicontrol(handles.logcallgui, ButtonAttrib{:}, 'Visible', 'off', ...
    'String', 'Effort End Time', 'position', btnpos, ...
    'HorizontalAlignment', 'center', ...
    'TooltipString', 'Set to end of deployment (if available)', ...
    'Callback', {@set_time, 'effort_end'});
btnpos = [x(1,2)-dsepx, y(4,2), w, h];
handles.effort_end.disp = uicontrol(handles.logcallgui, EditAttrib{:}, ...
    'Visible', 'off','position', btnpos, ...
    'String', datestr(handles.DeploymentEnd, 31));

btnpos = [x(2,1), y(5,1), w, h];
handles.end_previous.txt = uicontrol(handles.logcallgui, TextAttrib{:}, ...
     'Visible', 'off','String', 'Existing End Effort', 'position', btnpos);
btnpos = [x(2,2)-dsepx, y(5,2), w, h];
handles.end_previous.disp = uicontrol(handles.logcallgui, TextAttrib{:}, ...
     'Visible', 'off','position', btnpos);

btnpos = [x(2,1), y(6,1), w, h];
handles.end_pick.txt = uicontrol(handles.logcallgui, TextAttrib{:}, ...
     'Visible', 'off','String', 'Last Detection', 'position', btnpos);
btnpos = [x(2,2)-dsepx, y(6,2), w, h];
handles.end_pick.disp = uicontrol(handles.logcallgui, TextAttrib{:}, ...
    'Visible', 'off', 'position', btnpos);



handles.log.disp = [handles.deploy.disp handles.user.disp];
handles.log.text = [handles.deploy.text handles.user.text];

handles.log.effort = [...
    handles.user.text handles.user.disp ...
    handles.deploy.text handles.deploy.disp ...
    handles.effort_start.txt handles.effort_start.disp ...
    handles.done ];

handles.log.close = [handles.done, ...
    handles.effort_end.txt, handles.effort_end.disp, ...
    handles.end_previous.txt handles.end_previous.disp, ...
    handles.end_pick.txt handles.end_pick.disp];

% Is the user required to set pick end?
handles.log.pickend_mandatory = false;

% End of effort not yet known
handles.log.endDate = [];

% Set up audio and image directories and current picks
[~, basename, ~] = fileparts(fname);
handles.log.imagedir = sprintf('%s-image', fullfile(fdir, basename));
handles.log.image = [];
handles.log.audiodir = sprintf('%s-audio', fullfile(fdir, basename));
handles.log.audio = [];

switch mode
    case 'create'
        handles.meta = 0;  % meta data has not yet been specified
        % Start with a copy of the template
        try
            copyfile(template, handles.logfile, 'f');
        catch err
            if strcmp(err.identifier, 'MATLAB:COPYFILE:OSError')
                msg = sprintf(...
                    ['Unable to copy template %s to %s.  ' ...
                     'Possible causes:  open file or file permissions'], ...
                     template, handles.logfile);
            else
                msg = err.message;
            end
            delete(handles.logcallgui);
            errordlg(msg, 'Unable to start new log');
            return
        end
        PARAMS.log.pick = 'effort_start';
        effort.log.end = [];
        set(handles.log.effort, 'Visible', 'on');
        pickxyz(true);  % Set cursor for pick (no actual pick)
        
    case 'append'
        set(handles.log.effort, 'Visible', 'off');  % Hide metadata
        set(handles.done, 'Visible', 'off');        
        control_log(mode);
end

    
function restore_pointer(varargin)
% restore_pointer
% During the initial phase of gathering information before
% we actually open the log, the user may abort by closing the 
% new window.  Make sure that we are in a sane state when this
% happens

global handles PARAMS

PARAMS.log.pick = [];  % Turn off time X freq callback
pickxyz;  % reset cursor

delete(handles.logcallgui);  % Remove logger gui
clear GLOBAL handles;  % No longer valid


function set_time(hObj, event, type)
global handles
time = [];
switch type
    case 'effort_start'
        time = handles.DeploymentStart;
    case 'effort_end'
        time = handles.DeploymentEnd;
    otherwise
        return  % bad value
end
if ~ isempty(time)
    timestr = datestr(time, 31);
    set(handles.(type).disp, 'String', timestr);
end