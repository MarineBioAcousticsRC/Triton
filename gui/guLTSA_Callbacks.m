function varargout = guLTSA_Callbacks(varargin)
% guLTSA_Callbacks(varargin)
% GUIDE style callback - for LTSA group.
%      guLTSA_Callbacks('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK int this function with the given input arguments.
%
% Expects the following UI components to be in the handles group:
% LTSA_browse - pushbutton for requesting new LTSA
% LTSA_file - edit box containing LTSA string
% LTSA_audiofiles - list box with files in LTSA box
% LTSA_specify, LTSA_active - radio buttons
%
% Information can be retrieved with argument:  'values'
% which returns:
%       ltsa structure
%       file_indices - indices of highlighted files
%       ltsa_fname - [] for active LTSA, otherwise filename
%
% Initialize with argument:  'init'
%
% Creates private data structure in handles:  guLTSA_prv
nargchk(1,Inf,nargin);

% format function name and call it
if nargout
  [varargout{1:nargout}] = feval(varargin{:});
else
  feval(varargin{:});
end


function handles = init(hObject, eventdata, handles, varargin)
global PARAMS
% Check if LTSA structure is available.
if ~ isvarname(PARAMS) || ~ isfield(PARAMS, 'ltsa') || ...
      ~ isfield(PARAMS.ltsa, 'ltsahd')
    set(handles.LTSA_active, 'Enable', 'off');
end
handles.guLTSA_prv.valid_ltsa = false;

function valid_ltsa = valid(hObject, eventdata, handles, varargin)
% LTSA set properly?
valid_ltsa = handles.guLTSA_prv.valid_ltsa;

function varargout = OutputFcn(hObject, eventdata, handles, varargin)
% Return LTSA information
if handles.guLTSA_prv.valid_ltsa
  varargout{1} = handles.guLTSA_prv.hdr;
  varargout{2} = get(handles.LTSA_audiofiles, 'Value');
else
  varargout{1} = [];
  varargout{2} = [];
end

function update_listbox(hObject, eventdata, handles, varargin)
% private work function
set(handles.LTSA_audiofiles, 'String', ...
                  handles.guLTSA_prv.hdr.ltsahd.fname);
N = length(handles.guLTSA_prv.hdr.ltsahd.fname);
set(handles.LTSA_audiofiles, 'Max', N);
set(handles.LTSA_audiofiles, 'Value', 1:N);


function LTSA_browse(hObject, eventdata, handles, varargin)
% Select an LTSA file
[file, dir] = uigetfile('*.ltsa', 'Select Long Term Spectral Avg file');
if ~ isscalar(file)
    % user picked something
    path = fullfile(dir, file);
    set(handles.LTSA_file, 'String', path);  % update text box
    set(handles.LTSA_file, 'ForegroundColor', 'black');
    handles.guLTSA_prv.valid_ltsa = true;   % Note valid file
    set(handles.LTSA_specify, 'Value', 1);  % select appropriate radio box
    handles.guLTSA_prv.hdr = ioReadLTSAHeader(path);
    update_listbox(hObject, eventdata, handles, varargin);
    guidata(hObject, handles);  % save changes
end

function LTSA_active(hObject, eventdata, handles, varargin)
% Radio box clicked validate box & update files
LTSA_file(handles.LTSA_file, eventdata, handles, varargin);

function LTSA_file(hObject, eventdata, handles, varargin)
set(handles.LTSASpecify, 'Value', 1);  % select appropriate radio box
file = get(hObject, 'String');
valid = false;
% Verify file exists
if ~ exist(file, 'file')
    % didn't exist in current directory, see if abs path helps
    if exist(fullfile(pwd, file), 'file')
        set(hObject, 'String', fullfile(pwd, file));
        valid = true;
    end
else 
    valid = true;
end

if valid
    set(hObject, 'ForegroundColor', 'black')
    handles.guLTSA_prv.valid_ltsa = true;
else
    set(hObject, 'ForegroundColor', 'red');
    handles.guLTSA_prv.valid_ltsa = false;
end
guidata(hObject, handles);

function LTSA_audiofiles(hObject, eventdata, handles, varargin)




