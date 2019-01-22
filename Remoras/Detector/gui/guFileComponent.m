function varargout = guFileComponent(varargin)
% varargout = guFileComponent(varargin)
% GUIDE style callback - 
%      guFileComponent('CALLBACK',hObject,eventData,handles,...) calls the
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
%               handles = guFileComponent('CreateFcn', hObject, eventData, handles)
%               guidata(hObject, handles);      % save changes made by guGetFiles
%
%       CreateFcn returns a set of handles that should be saved by the
%       application using guidata.
% 'LTSAHeader' - Return the LTSA header structure if one is being used to
%       specify the group of files.  Otherwise returns [].
%
% The following optional arguments can be used to add callbacks for
% changes to either the list of files or the selected files.
%
% 'FileChangeCallback', Function Handle - Add callback for when filelist changes
%       It is assumed that the callback follows guide standards.
% 'SelectionChangeCallback', Function Handle - Add callback for when the
%       selected files change.  This is of limited use at the moment, as
%       there does not appear to be a callback for when listbox selections
%       change.  The callback is implemented (but not tested) for when the
%       list of files changes or when selection changes through the filter
%       buttons (=/-/+), but not through clicking on individual items.

nargchk(1,Inf,nargin);

if nargout
  [varargout{1:nargout}] = feval(varargin{:});
else
  feval(varargin{:});
end

function handles = guFileComponent_OpeningFcn(hObject, eventdata, handles, varargin)
% CreateFcn - create the panel as a subchild of existing figure object
global PARAMS

handles.(mfilename).textcolor.valid = 'black';
handles.(mfilename).textcolor.invalid = 'red';
% initialize root directory and file list to empty
fileinfo.files = [];
fileinfo.basedir = '';
set(handles.(mfilename).filelist, 'UserData', fileinfo);
% Initialize callback function list for when file list changes
handles.(mfilename).file_change_callback = {};

% Determine whether or not an LTSA is currently active (loaded)
% and set.  Default is active LTSA if enabled, otherwise default 
% to specify LTSA.
if ~ isvarname('PARAMS') || ~ isfield(PARAMS, 'ltsahd') || ...
        ~ isfield(PARAMS.ltsahd, 'fname')
  LTSAEnable = 'off';   % no LTSA
  LTSAValue = 0;
else
  LTSAEnable = 'on';    % LTSA present
  LTSAValue = 1;  
  ltsaactive(hObject, eventdata, handles);      % update files/basedir
end

set(handles.(mfilename).specify_ltsa_active, 'Enable', LTSAEnable, ...
                  'Value', LTSAValue);
set(handles.(mfilename).specify_ltsa_active, 'Value', LTSAValue);

% control for wildcard vs. regexp matching
handles.(mfilename).match.regexp = 1;
handles.(mfilename).match.wildcard = 2;
handles.(mfilename).selection_change_callback = {};

guidata(hObject, handles);      % Save handles changes

% Output =================================================================
function [SelectedFiles, BaseDir, SelIdx] = OutputFcn(hObject, eventdata, handles)
% Returns currently selected file names and the base directory.
% Also returns the indices of the selected files which may be useful
% for obtaining auxilary information about the complete list stored
% by users of this component.
Max = get(handles.(mfilename).filelist, 'Max');
SelIdx = get(handles.(mfilename).filelist, 'Value');
FileInfo = get(handles.(mfilename).filelist, 'UserData');
if Max > 0 && ~ isempty(SelIdx)
    SelectedFiles = FileInfo.files(SelIdx);
else
    SelectedFiles = {};
end
BaseDir = FileInfo.basedir;

% Callbacks ==============================================================

function radio_specify_ltsa(hObject, eventdata, handles)
% LTSA - user has switched from files to using LTSA
% Switch the view and load the appropriate set of files
set(handles.(mfilename).ltsa_panel, 'Visible', 'on');
set(handles.(mfilename).specify_files_panel, 'Visible', 'off');
if get(handles.(mfilename).specify_ltsa_active, 'Value')
    ltsaactive(hObject, eventdata, handles);
else
    newltsafile(hObject, eventdata, handles);
end

function radio_specify_files(hObject, eventdata, handles)
% rooted files active
% Switch the view and load files from the specified
% root directory if possible
set(handles.(mfilename).ltsa_panel, 'Visible', 'off');
set(handles.(mfilename).specify_files_panel, 'Visible', 'on');
newrootdir(hObject, eventdata, handles);

function force_specify_files_only(handles)
% Set to use rooted files and disable obtaining files from LTSA

% Set as if user clicked to specify file root
set(handles.(mfilename).radio_specify_files, 'Value', 1);       
% Turn off radio buttons to switch between LTSA & Specific files
set(handles.(mfilename).radio_specify_files, 'Visible', 'off');
set(handles.(mfilename).radio_specify_ltsa, 'Visible', 'off');
% Make sure right subcomponents displayed.
radio_specify_files(handles.(mfilename).radio_specify_files, [], handles)



% Functions for LTSA specified files ========================================
function ltsaactive(hObject, eventdata, handles)
global PARAMS
% find physical files (raw index == 1)
physidx = find(PARAMS.ltsahd.rfileid == 1);
% get real xwav names as opposed to
fnames = {};
for k = 1:length(physidx)
    index = physidx(k);
    fnames{end+1} = char(deblank(PARAMS.ltsahd.fname(index,:)));
end
updatefiles(fnames, handles, PARAMS.ltsa.inpath);       


function newltsafile(hObject, eventdata, handles)
ltsafile = get(handles.(mfilename).specify_ltsa_fname, 'String');
if ~ isdir(ltsafile) && exist(ltsafile, 'file') 
  hdr = ioReadLTSAHeader(ltsafile);
  % Filenames can be obtained from the first raw file of each set
  % whose filename is not empty.
  notempty = ~cellfun(@isempty, hdr.ltsahd.fname)';
  firstraw = hdr.ltsahd.rfileid == 1;
  updatefiles(hdr.ltsahd.fname(notempty & firstraw), ...
      handles, hdr.ltsa.inpath);
  textcolor = handles.(mfilename).textcolor.valid;
else
  updatefiles([], handles, '');
  textcolor = handles.(mfilename).textcolor.invalid;
end
set(handles.(mfilename).specify_ltsa_fname, 'ForegroundColor', textcolor);

function browseltsafile(hObject, eventdata, handles)
% browseltsafile(hObject, eventdata, handles)
% Select an LTSA file to work on
[ltsafile, ltsadir] = uigetfile('*.ltsa', 'Select LTSA file');
if ~ isscalar(ltsafile)
  set(handles.(mfilename).specify_ltsa_fname, 'String', fullfile(ltsadir, ltsafile));
end
newltsafile(hObject, eventdata, handles);

function handles = ltsaavailable(hObject, eventdata, handles)
% ltsaavailable(hObject, eventdata, handles)
% Enable LTSA functions
set(handles.(mfilename).radio_specify_ltsa, 'Enable', 'on', ...
                  'Visible', 'on');

function handles = ltsaunavailable(hObject, eventdata, handles)
% ltsaunavailable(hObject, eventdata, handles)
% Disable and hide the LTSA section of the file selection.
set(handles.(mfilename).radio_specify_ltsa, 'Enable', 'off', ...
                  'Value', 0, 'Visible', 'off');
% Make file button active 
set(handles.(mfilename).radio_specify_files, 'Value', 1)
radio_specify_files(handles.(mfilename).radio_specify_files, ...
                    eventdata, handles);




% Functions for rooted file search ==========================================
function selectrootdir(hObject, eventdata, handles)
startdir = get(handles.(mfilename).specify_files_dir, 'String');
if ~ isdir(startdir)
  startdir = pwd;
end
selected = uigetdir(startdir, 'Select new base folder');
if ~ isscalar(selected)
  % Picked a new one.  Update root dir box and process
  handles = guidata(hObject);
  set(handles.(mfilename).specify_files_dir, 'String', selected);
  newrootdir(hObject, eventdata, handles);
end

% Functions for file selection ==========================================
function initrootdir(hObject, eventdata, handles)
% Initialize the contents of the specify_files_dir entry
% to the current directory on startup.  Note that we
% cannot use our standard handles.(mfilename) convention
% as this is called at startup and has not yet been initialized
set(hObject, 'String', pwd);

function newrootdir(hObject, eventdata, handles)
% Find root directory and desired mask
pattern = get(handles.(mfilename).specify_files_pattern, 'String');
rootdir = get(handles.(mfilename).specify_files_dir, 'String');
if isdir(rootdir)
  
  % Save current point and set to delay
  pointer = get(handles.ContainingFig, 'Pointer');
  set(handles.ContainingFig, 'pointer', 'watch');

  files = utFindFiles(pattern, rootdir, ...
                      get(handles.(mfilename).specify_files_subdirs, ...
                          'Value'));
% TODO!
%  if ~ isempty(handles.(mfilename).need_corresponding_ext)
    % Look for files with the specified extension. 
    % If they are not present, remove them from the list.
    %    corresponding = strrep(files, 
% end
  % Strip root out of each file & protect special character \
  rootpat = sprintf('^%s[\\\\/]?', strrep(rootdir, '\', '\\'));
  for idx=1:length(files)
    files{idx} = regexprep(files{idx}, rootpat, '', 'ignorecase');
  end
  updatefiles(files, handles, rootdir);
  textcolor = handles.(mfilename).textcolor.valid;
  
  set(handles.ContainingFig, 'Pointer', pointer);
  
else
  updatefiles([], handles, '');
  textcolor = handles.(mfilename).textcolor.invalid;
end
set(handles.(mfilename).specify_files_dir, 'ForegroundColor', textcolor);

function updatefiles(files, handles, basedir)
% updatefiles(files, handles, basedir)
% Set the current list of files to files.
% If file change callbacks have been registered (see FileChangeCallback
% in this function), execute them.
fileinfo.files = files;
fileinfo.basedir = basedir;
set(handles.(mfilename).filelist, 'UserData', fileinfo);
set(handles.(mfilename).filelist, 'String', files);
for idx = 1:length(handles.(mfilename).file_change_callback)
  feval(handles.(mfilename).file_change_callback{idx}, [], ...
        [], handles);
end
set(handles.(mfilename).filelist, 'Max', length(files));
if isempty(files)
  set(handles.(mfilename).filelist, 'Value', []);
else
  set(handles.(mfilename).filelist, 'Value', 1:length(files));
end

function permutefiles(permutation, handles)
% permutefieles(permutation, handles)
% Change the current ordering of files to order, where
% permutation is a permuted set of 1:N where N is the current
% number of files.

fileinfo = get(handles.(mfilename).filelist, 'UserData');
if length(permutation) ~= length(fileinfo.files) || ...
        sum(1:length(fileinfo.files)) ~= sum(permutation)
    guBacktraceError('Internal error - bad permutation list');
end
fileinfo.files = fileinfo.files(permutation);
set(handles.(mfilename).filelist, 'UserData', fileinfo);
% Reorder strings
formatted = get(handles.(mfilename).filelist, 'String');
set(handles.(mfilename).filelist, 'String', formatted(permutation));
% Take selected and determine their new order
selected = get(handles.(mfilename).filelist, 'Value');
[common, dontcare, permidx] = intersect(selected, permutation);
set(handles.(mfilename).filelist, 'Value', permidx);


function updateselections(hObject, eventdata, handles)
action = get(hObject, 'Tag');
convert = get(handles.(mfilename).filter_type, 'Value') == ...
          handles.(mfilename).match.wildcard;
matchstr = get(handles.(mfilename).filter_pattern, 'String');
if convert
  matchstr = strrep(matchstr, '.', '\.');
  matchstr = strrep(matchstr, '*', '.*');
end
matches = regexp(get(handles.(mfilename).filelist, 'String'), matchstr);
matches_i = [];
for idx=1:length(matches)
  if ~ isempty(matches{idx})
    matches_i(end+1) = idx;
  end
end
for idx = 1:length(handles.(mfilename).selection_change_callback)
  feval(handles.(mfilename).selection_change_callback{idx}, hObject, ...
        eventdata, handles);
end

switch(action)
 case 'selection_eq'       % Set selection to matched files
  set(handles.(mfilename).filelist, 'Value', matches_i);
 case 'selection_rm'       % Remove selection from matched files
  selected = get(handles.(mfilename).filelist, 'Value');
  selected = setdiff(selected, matches_i);
  set(handles.(mfilename).filelist, 'Value', selected);
 case 'selection_add'       % Add selection to matched files
  selected = get(handles.(mfilename).filelist, 'Value');
  selected = union(selected, matches_i);
  set(handles.(mfilename).filelist, 'Value', selected);
end

for idx = 1:length(handles.(mfilename).selection_change_callback)
  feval(handles.(mfilename).selection_change_callback{idx}, hObject, ...
        eventdata, handles);
end

function header = LTSAHeader(hObject, eventdata, handles)
global PARAMS
header = [];
if get(handles.(mfilename).radio_specify_ltsa, 'Value') == 1
  % Using an LTSA?  If so, active one or specified from file?
  if get(handles.(mfilename).specify_ltsa_active, 'Value') == 1
    % Using active LTSA
    header.ltsa = PARAMS.ltsa;
    header.ltsahd = PARAMS.ltsahd;
  else
    fname = get(handles.(mfilename).specify_ltsa_fname, 'String');
    try
      header = ioReadLTSAHeader(fname);
    catch
      guErrorBacktrace(lasterror, 'Cannot read LTSA', ...
                       sprintf('Unable to read LTSA file "%s".\n', ...
                               fname));
    end
  end
end

function SpecifyFilesVisibility(hObject, eventdata, handles, boolean)
% FileVisibility(hObject, eventdata, handles, boolean)
% Enable/disable selection of individual files.
if boolean
  set(handles.(mfilename).radio_specify_files, 'Enable', 'on');
else
  set(handles.(mfilename).radio_specify_files, 'Enable', 'off');
end

% Add callbacks ===================================================================
function handles = FileChangeCallback(handles, FnHandle)
% handles = FileChangeCallback(handles, FnHandle)
% Add function specified by FnHandle to the list of functions that will
% be called when the list of files changes.  FnHandle must take the
% standard handle graphics arguments:  hObject, eventdata, handles
% Note that the handles structure is modified and the returned value must
% be saved using the guidata function.
handles.(mfilename).file_change_callback{end+1} = FnHandle;

function handles = SelectionChangeCallback(handles, FnHandle)
% handles = FileChangeCallback(handles, FnHandle)
% Add function specified by FnHandle to the list of functions that will be
% called when the user changes the set of selected files.  FnHandle must
% take the standard handle graphics arguments: hObject, eventdata, handles
% Note that the handles structure is modified and the returned value must be
% saved using the guidata function.
%
% There is currently no easy mechanism known to the author to trigger a callback
% when the selection changes by clicking, so this currently only applies
% to selection changes made using the file filter buttons.
handles.(mfilename).selection_change_callback{end+1} = FnHandle;
