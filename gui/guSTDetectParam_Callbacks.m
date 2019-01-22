function varargout = guSTDetectParam_Callbacks(varargin)
% guSTParam_Callbacks(varargin)
% GUIDE style callback - for short time spectral parameters.
%      guSTDetectParam_Callbacks('CALLBACK',hObject,eventData,handles,...) calls
%      the local function named CALLBACK int this function with the given
%      input arguments.
%
% Expects the following UI components to be in the handles group:
% ST_active - Use current detection parameters
% ST_browse - pushbutton for requesting new LTSA
% ST_file - edit box containing LTSA string
% ST_specify, ST_active - radio buttons
%
% Information can be retrieved with argument:  'values'
% which returns:
%       short time detection parameter structure, [] if none selected
%
% Initialize with argument:  'init'
%
% Creates private data structure in handles:  guLTSA_prv
nargchk(1,Inf,nargin);

if nargout
  [varargout{1:nargout}] = feval(varargin{:});
else
  feval(varargin{:});
end

function handles = init(hObject, eventdata, handles, varargin)
% defaults to short time spectral parameters which are initialized
% when Triton starts, so always true
handles.STDetect.valid_det = true;

function okay = valid(hObject, eventdata, handles, varargin)
okay = handles.STDetect.valid_det;

function varargout = OutputFcn(hObject, eventdata, handles, varargin)
global PARAMS
if handles.STDetect.valid_det
    % Need to figure out what to do about the enable/disable  TODO
    if get(handles.ST_active, 'Value')
        % use global
        varargout{1} = PARAMS.dt;
    else
        [dt, tonals, bb] = ioReadDetSpecgram(get(handles.ST_file, 'String'));
    end
else
    varargout{1} = [];
end

function ST_specify(hObject, eventdata, handles, varargin)
ST_file(hObject, eventdata, handles, varargin);

function ST_browse(hObject, eventdata, handles, varargin)
% Select a detection file
[file, dir] = uigetfile('*.st', ...
                        'Short-time spectral detection parameter file');
if ~ isscalar(file)
    % user picked something
    path = fullfile(dir, file);
    set(handles.ST_file, 'String', path);  % update text box
    set(handles.ST_file, 'ForegroundColor', 'black');
    handles.STDetect.valid_det = true;   % Note valid file
    set(handles.ST_specify, 'Value', 1);  % select appropriate radio box
    guidata(hObject, handles);  % save changes
end

function ST_active(hObject, eventdata, handles, varargin)
handles.STDetect.valid_det = true;
guidata(hObject, handles);

function ST_file(hObject, eventdata, handles, varargin)
set(handles.ST_specify, 'Value', 1);  % select appropriate radio box
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

handles.STDetect.valid_det = valid;
if valid
    set(hObject, 'ForegroundColor', 'black')
else
    set(hObject, 'ForegroundColor', 'red');
end
guidata(hObject, handles);





