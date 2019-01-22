function varargout = guGetFiles(varargin)
% varargout = guGetFiles(varargin)
% GUIDE style callback - 
%      guGetFiles('CALLBACK',hObject,eventData,handles,...) calls the
%      local function named CALLBACK int this function with the given input
%      arguments.
% GUI component for retrieving a list of files either from an LTSA or by
% a rooted directory.  Creates a user interface panel in normalized
% coordinates in the current figure.
% The following callbacks are expected:
%
% 'OutputFcn' - Return list of curently selected files.
% 'CreateFcn' - Create panel objects with associated parameters relative
%       to the current handle.
%       Example:  
%
%               handles = guGetFiles('CreateFcn', hObject, eventData, handles, ...
%                       'Position', [0 0 1 .4])
%               ... other stuff ...
%               guidata(hObject, handles);      % save changes made by guGetFiles
%
%       Note that making the panel too small results in
%       unreadable/cluttered text.  It is suggested that the code be
%       tested on a small display.  
%       CreateFcn returns a set of handles that should be saved by the
%       application using guidata.

nargchk(1,Inf,nargin);

% format function name and call it
%varargin{1} = sprintf('%s.%s', mfilename, varargin{1});
if nargout
  [varargout{1:nargout}] = feval(varargin{:});
else
  feval(varargin{:});
end

function handles = CreateFcn(hObject, eventdata, handles, varargin)
% CreateFcn - create the panel
global PARAMS REMORA

handles.guGetFiles.textcolor.valid = 'black';
handles.guGetFiles.textcolor.invalid = 'red';

% Positions laid out in guide and then copied into here.  Perhaps not the
% most effective way... 

% Button panel which is main item in this component.
handles.guGetFiles.buttongrp = uibuttongroup(...
    'parent', hObject, 'Title', 'Specify files', ...
    'Tag', 'guFiles', 'SelectionChangeFcn', @LTSAvFiles);

% Radio buttons which indicate whether we are doing LTSA or selecting files.
handles.guGetFiles.ltsaButton = uicontrol('Style', 'radiobutton', ...
    'Units', 'normalized', 'parent', handles.guGetFiles.buttongrp, ...
    'Position', [0.025, 0.94, 0.15, 0.04], ...
    'String', 'LTSA', 'Value', 1);
handles.guGetFiles.filesButton = uicontrol('Style', 'radiobutton', ...
    'Units', 'normalized', 'parent', handles.guGetFiles.buttongrp, ...
    'Position', [0.143, 0.939, 0.157, 0.040], ...
    'String', 'Specify files');

% Subpanel button group for LTSA
handles.guGetFiles.ltsa.buttongrp = ...
    uibuttongroup('parent', handles.guGetFiles.buttongrp, 'Units', 'normalized', ...
                  'Position', [0.013, 0.726, 0.975, 0.195], ...
                  'Title', 'Use files in Long Term Spectral Avg');
% Determine whether or not an LTSA is currently active (loaded)
% and set
if ~ isvarname(PARAMS) || ~ isfield(PARAMS, 'ltsa') || ...
      ~ isfield(PARAMS.ltsa, 'ltsahd');
  LTSAEnable = 'off';   % no LTSA
  LTSAValue = 0;
  LTSASpecify = 1;
else
  LTSAEnable = 'on';    % LTSA present
  LTSAValue = 1;
  LTSASpecify = 0;
end
  
handles.guGetFiles.ltsa.active = uicontrol('Style', 'radiobutton', ...
    'parent', handles.guGetFiles.ltsa.buttongrp, 'Units', 'normalized', ...
    'String', 'Active', 'Enable', LTSAEnable, 'Value', LTSAValue, ...
    'Callback', @ltsaactive, 'Position', [0.028, 0.672, 0.162, 0.259]);
handles.guGetFiles.ltsa.specify = uicontrol('Style', 'radiobutton', ...
    'parent', handles.guGetFiles.ltsa.buttongrp, 'Units', 'normalized', ...
    'String', 'Load', 'Value', LTSASpecify, ...
    'Position', [0.028, 0.276, 0.091, 0.259]);
handles.guGetFiles.ltsa.filename = uicontrol('Style', 'edit', ...
    'parent', handles.guGetFiles.ltsa.buttongrp, 'Units', 'normalized', ...
    'Callback', @newltsafile, 'HorizontalAlignment', 'left', ...
    'Position', [0.138, 0.224, 0.717, 0.379]);
handles.guGetFiles.ltsa.browse = uicontrol('Style', 'pushbutton', ...
    'parent', handles.guGetFiles.ltsa.buttongrp, 'Units', 'normalized', ...
    'Callback', @browseltsafile, 'String', 'Browse', ...
    'Position', [0.866, 0.207, 0.113, 0.397]);

% Subpanel group for specifying files
handles.guGetFiles.files.panel = uipanel(...
    'parent', handles.guGetFiles.buttongrp, 'Title', 'Specify files', ...
    'Position', [0.013, 0.726, 0.975, 0.195], 'Visible', 'off');
handles.guGetFiles.files.fileslabel = uicontrol('Style', 'text', ...
    'parent', handles.guGetFiles.files.panel, 'Units', 'normalized', ...
    'Position', [0.01, 0.655, 0.115, 0.259], ...
    'HorizontalAlignment', 'left', 'String', 'Base Folder');
handles.guGetFiles.files.rootdir = uicontrol(...
    'Style', 'edit', 'parent', handles.guGetFiles.files.panel, ...
    'HorizontalAlignment', 'left', 'Units', 'normalized', ...
    'Position', [0.136, 0.621, 0.717, 0.379], 'Callback', @newrootdir);
handles.guGetFiles.files.browse = uicontrol(...
    'Style', 'pushbutton', 'parent', handles.guGetFiles.files.panel, ...
    'Units', 'normalized', 'Position', [0.866, 0.603, 0.113, 0.397], ...
    'String', 'Browse', 'callback', @selectrootdir);
handles.guGetFiles.files.masklabel = uicontrol('Style', 'text', ...
    'parent', handles.guGetFiles.files.panel, 'Units', 'normalized', ...
    'Position', [0.013, 0.190, 0.100, 0.259], ...
    'HorizontalAlignment', 'left', 'String', 'wildcard *');
handles.guGetFiles.files.mask = uicontrol(...
    'Style', 'edit', 'parent', handles.guGetFiles.files.panel, ...
    'Units', 'normalized', 'Position', [0.136, 0.138, 0.310, 0.362], ...
    'HorizontalAlignment', 'left', 'String', '*.wav');
handles.guGetFiles.files.subfolders = uicontrol(...
    'Style', 'checkbox', 'parent', handles.guGetFiles.files.panel, ...
    'Units', 'normalized', 'Position', [0.470 0.190 0.235 0.259], ...
    'HorizontalAlignment', 'left', 'String', 'Include subfolders?', ...
    'Callback', @newrootdir);

handles.guGetFiles.filelist = uicontrol(...
    'Style', 'listbox', 'parent', handles.guGetFiles.buttongrp, ...
    'Units', 'normalized', 'Position', [0.015, 0.082, 0.971, 0.633]);
% control for wildcard vs. regexp matching
handles.guGetFiles.match.regexp = 1;
handles.guGetFiles.match.wildcard = 2;
handles.guGetFiles.match.ctl = uicontrol(...
    'TooltipString', 'Specifies how pattern should be interpreted', ...
    'Style', 'popupmenu', 'parent', handles.guGetFiles.buttongrp, ...
    'Units', 'normalized', 'Position', [0.013 0.018 0.189 0.053], ...
    'String', {'regular expression', 'wildcard *'}, ...
    'Value', handles.guGetFiles.match.wildcard);
handles.guGetFiles.match.str = uicontrol(...
    'TooltipString', 'Pattern used for including/excluding files in list', ...
    'Style', 'edit', 'parent', handles.guGetFiles.buttongrp, ...
    'Units', 'normalized', 'Position', [0.207 0.013 0.535 0.058], ...
    'HorizontalAlignment', 'left');
handles.guGetFiles.include = uicontrol(...
    'TooltipString', 'Adds all files with pattern from list', ...
    'parent', handles.guGetFiles.buttongrp, ...
    'Style', 'pushbutton', 'String', 'Include', ...
    'Units', 'normalized', 'Position', [0.755 0.011 0.113 0.069]);
handles.guGetFiles.exclude = uicontrol(...
    'TooltipString', 'Removes all files with pattern from list', ...
    'parent', handles.guGetFiles.buttongrp, ...
    'Style', 'pushbutton', 'String', 'Exclude', ...
    'Units', 'normalized', 'Position', [0.878 0.011 0.107 0.063]);

% Set background of text boxes to white on pcs
if ispc && isequal(get(handles.guGetFiles.buttongrp,'BackgroundColor'), ...
                   get(0,'defaultUicontrolBackgroundColor'))
  props = {'BackgroundColor', 'white'};
  set(handles.guGetFiles.ltsa.filename, props{:});
  set(handles.guGetFiles.files.rootdir, props{:});
  set(handles.guGetFiles.files.mask, props{:});
  set(handles.guGetFiles.match.ctl, props{:});
  set(handles.guGetFiles.match.str, props{:});
end
                                             
% Temporarily save the GUI Data.  This should be done by the calling
% function at some point later
guidata(handles.guGetFiles.buttongrp, handles);


% Callbacks ==============================================================

function LTSAvFiles(hObject, eventdata)
handles = guidata(hObject);     % Retrieve handle information
if strcmp(eventdata.EventName, 'SelectionChanged')
  if eventdata.NewValue == handles.guGetFiles.ltsaButton
    % LTSA active
    set(handles.guGetFiles.ltsa.buttongrp, 'Visible', 'on');
    set(handles.guGetFiles.files.panel, 'Visible', 'off');
    ltsaactive(hObject, eventdata);
  else
    % rooted files active
    set(handles.guGetFiles.ltsa.buttongrp, 'Visible', 'off');
    set(handles.guGetFiles.files.panel, 'Visible', 'on');
    newrootdir(hObject, eventdata);
  end
end

% Functions for LTSA specified files ========================================
function ltsaactive(hObject, eventdata)
global PARAMS
handles = guidata(hObject);     % retrieve handle structure
updatefiles(PARAMS.ltsahd.fname, handles);       

function newltsafile(hObject, eventdata)
handles = guidata(hObject);     % retrieve handle structure
ltsafile = get(handles.guGetFiles.ltsa.filename, 'String');
if ~ isdir(ltsafile) && exist(ltsafile, 'file') 
  hdr = ioReadLTSAHeader(ltsafile);
  updatefiles(hdr.ltsahd.fname, handles);
  textcolor = handles.guGetFiles.textcolor.valid;
else
  textcolor = handles.guGetFiles.textcolor.invalid;
end
set(handles.guGetFiles.ltsa.filename, 'ForegroundColor', textcolor);

function browseltsafile(hObject, eventdata)
handles = guidata(hObject);     % retrieve handle structure
[ltsafile, ltsadir] = uigetfile('*.ltsa', 'Select LTSA file');
if ~ isscalar(ltsafile)
  set(handles.guGetFiles.ltsa.filename, 'String', fullfile(ltsadir, ltsafile));
end
newltsafile(hObject, eventdata);

% Functions for rooted file search ==========================================
function selectrootdir(hObject, eventdata)
selected = uigetdir(pwd, 'Select new base folder');
if ~ isscalar(selected)
  % Picked a new one.  Update root dir box and process
  handles = guidata(hObject);
  set(handles.guGetFiles.files.rootdir, 'String', selected);
  newrootdir(hObject, eventdata);
end

function newrootdir(hObject, eventdata)
handles = guidata(hObject);     % Retrieve handles data structure
% Find root directory and desired mask
pattern = get(handles.guGetFiles.files.mask, 'String');
rootdir = get(handles.guGetFiles.files.rootdir, 'String');
if isdir(rootdir)
  files = utFindFiles(pattern, rootdir, ...
                      get(handles.guGetFiles.files.subfolders, 'Value'));
  updatefiles(files, handles);
  textcolor = handles.guGetFiles.textcolor.valid;
else
  updatefiles([], handles);
  textcolor = handles.guGetFiles.textcolor.invalid;
end
set(handles.guGetFiles.files.rootdir, 'ForegroundColor', textcolor);

function updatefiles(files, handles)
set(handles.guGetFiles.filelist, 'String', files);
if isempty(files)
  set(handles.guGetFiles.filelist, 'Value', [])
else
  set(handles.guGetFiles.filelist, 'Value', 1:length(files));
end
set(handles.guGetFiles.filelist, 'Max', length(files));



