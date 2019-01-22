function varargout = guDetectionParmComponent(varargin)
% GUDETECTIONPARMCOMPONENT M-file for guDetectionParmComponent.fig
%      GUDETECTIONPARMCOMPONENT, by itself, creates a new GUDETECTIONPARMCOMPONENT or raises the existing
%      singleton*.
%
%      H = GUDETECTIONPARMCOMPONENT returns the handle to a new GUDETECTIONPARMCOMPONENT or the handle to
%      the existing singleton*.
%
%      GUDETECTIONPARMCOMPONENT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUDETECTIONPARMCOMPONENT.M with the given input arguments.
%
%      GUDETECTIONPARMCOMPONENT('Property','Value',...) creates a new GUDETECTIONPARMCOMPONENT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guDetectionParmComponent_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guDetectionParmComponent_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guDetectionParmComponent

% Last Modified by GUIDE v2.5 12-Apr-2007 16:51:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guDetectionParmComponent_OpeningFcn, ...
                   'gui_OutputFcn',  @guDetectionParmComponent_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before guDetectionParmComponent is made visible.
function handles = guDetectionParmComponent_OpeningFcn(hObject, eventdata, handles, ...
    DetectionMode)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% DetectionMode     Detection method:  'ltsa', 'short-time-spectrum'

global PARAMS REMORA
handles.(mfilename).DetectionMode = DetectionMode;   % Remember what kind
handles.(mfilename).detect = [];        % No parameters yet
handles.(mfilename).textcolor.valid = 'black';
handles.(mfilename).textcolor.invalid = 'red';
active = false;
enable = 'off';

% Set detection mode specific parameters including current
% detection parameters if global ones are available
switch DetectionMode
 case 'ltsa'
  handles.(mfilename).filemask = '*.ltsa.prm';
  DetectionStr = 'Long Term Spectral Avg Detection Parameters';
  % check LTSA long term detection currently loaded
  if isfield(PARAMS.ltsa, 'dt') % TODO remove this
    active = true;
    enable = 'on';
    handles.(mfilename).detect = PARAMS.ltsa.dt;
  end
 case 'short-time-spectrum'
  DetectionStr = 'Short Time Spectrum Detection Parameters';
  handles.(mfilename).filemask = '*.spec.prm';
  % check Short Time spectral detection parameters loaded
  if isfield(REMORA, 'dt')
    active = true;
    enable = 'on';
    handles.(mfilename).detect = REMORA.dt.params; 
  end
 otherwise
  error('Bad detect method')
end
set(handles.(mfilename).DetectionParams, 'Title', DetectionStr);
set(handles.(mfilename).active, 'Enable', enable);
set(handles.(mfilename).active, 'Value', active);

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function detect = OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

detect = handles.(mfilename).detect;        % Return detection parameters

function parameter_Callback(hObject, eventdata, handles)
% hObject    Text edit box with parameter filename
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Parameter filename field has been updated.
% Attempt to load parameters and save them to guidata

global HANDLES REMORA % May need to access handles

filename = get(hObject, 'String');
if ~ isempty(filename)
    switch handles.(mfilename).DetectionMode
        case 'ltsa'
            detect = ioLoadLTSAParams(filename);
        case 'short-time-spectrum'
            % Clone handles so we can read in file w/o destroying
            % user's parameters.
            [dethandles detfig] = guCopyHandleStruct(REMORA.dt);
            result = ioLoadSpecgramParams(filename, dethandles);
            if result
              % extract parameters from handles
              detect = dtGetSTParams(dethandles);
            else
              detect = [];
            end
            delete(detfig);
    end

    if isempty(detect)
        textcolor = handles.(mfilename).textcolor.invalid;
    else
        textcolor = handles.(mfilename).textcolor.valid;
    end
    set(hObject, 'ForegroundColor', textcolor);
else
    detect = [];
end

handles.(mfilename).detect = detect;
% Set load radio button
set(handles.guDetectionParmComponent.DetectionParams, ...
    'SelectedObject', handles.guDetectionParmComponent.load);

guidata(hObject, handles);      % Save detection parameters


% --- Executes during object creation, after setting all properties.
function parameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to parameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% User selects active detection
function active_Callback(hObject, eventdata, handles)
% Active button will only be enabled if there is an active parameter set
% loaded.  Copy it into the handles

global PARAMS
global HANDLES
global REMORA
switch handles.(mfilename).DetectionMode
 case 'ltsa'
  handles.(mfilename).detect = PARAMS.ltsa.dt;
 case 'short-time-spectrum'
  handles.(mfilename).detect = REMORA.dt;
  % Tonal/broadband detector enable/disable part of GUI design
  % might want to reconsider at a later date... copy out for now
  handles.(mfilename).detect.tonals = get(REMORA.dt.tonals, 'Value');
  handles.(mfilename).detect.bb = get(REMORA.dt.broadbands, 'Value');
end
guidata(hObject, handles);      % Store detection parameters

% --- Executes when user selects the load radio button.
function load_Callback(hObject, eventdata, handles)
% Run callback which examines parameter filename box and loads
% parameters
parameter_Callback(handles.(mfilename).parameter, eventdata, handles);

% --- Executes on button press in browse.
function browse_Callback(hObject, eventdata, handles)
% hObject    handle to browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Ask for filename starting at either the current working directory or
% the valid directory portion of what the user has typed into the box.
dir = guFindExistingDir(get(handles.(mfilename).parameter, 'String'), pwd);
[fname, fpath] = uigetfile(handles.(mfilename).filemask, dir);

if ~ isscalar(fname)
  % selected a file:  update filename and process
  set(handles.(mfilename).parameter, 'String', fullfile(fpath, fname));
  parameter_Callback(handles.(mfilename).parameter, eventdata, handles);
end

  



