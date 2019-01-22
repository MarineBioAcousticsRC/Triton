function varargout = guNameToPattern(varargin)
% GUNAMETOPATTERN M-file for guNameToPattern.fig
%      GUNAMETOPATTERN, by itself, creates a new GUNAMETOPATTERN or raises the existing
%      singleton*.
%
%      H = GUNAMETOPATTERN returns the handle to a new GUNAMETOPATTERN or the handle to
%      the existing singleton*.
%
%      GUNAMETOPATTERN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUNAMETOPATTERN.M with the given input arguments.
%
%      GUNAMETOPATTERN('Property','Value',...) creates a new GUNAMETOPATTERN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guNameToPattern_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guNameToPattern_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guNameToPattern

% Last Modified by GUIDE v2.5 14-Apr-2007 07:20:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guNameToPattern_OpeningFcn, ...
                   'gui_OutputFcn',  @guNameToPattern_OutputFcn, ...
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


% --- Executes just before guNameToPattern is made visible.
function guNameToPattern_OpeningFcn(hObject, eventdata, handles, files, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% files      List of files to be processed

% Choose default command line output for guNameToPattern
handles.output = hObject;
handles.ctl.cancelled = false;
% initialize pseudo-components
handles = guRegExpMap('init', hObject, eventdata, handles);
if iscell(files)
    handles.files = files;
else
    error('Argument files must be a cell array');
end
handles.unknown = 'unknown';    % Label for unknown pattern
% Set up callback for updating file patterns whenever the regexps
% are modified and display the initial mapping.
handles = guRegExpMap('MapChange_Callback', ...
                      hObject, eventdata, handles, @UpdateFilePatterns);
handles = UpdateFilePatterns(handles.FilesToClass, eventdata, handles);
guidata(hObject, handles);      % Save updated handles


% UIWAIT makes guNameToPattern wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function labels = guNameToPattern_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
exists = ~ isempty(handles);     % Window still exists?
% User cancelled if window went bye-bye or they hit a cancel control.
cancelled = ~ exists || handles.ctl.cancelled;

if cancelled
  labels = [];
else  
  labels = handles.assignedTo;  % Classes to which list items were assigned
end
if exists
  delete(handles.figure1);
end

function REMapToClass_Callback(hObject, eventdata, handles)
% hObject    handle to REMapToClass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of REMapToClass as text
%        str2double(get(hObject,'String')) returns contents of REMapToClass as a double


function handles = UpdateFilePatterns(hObject, eventdata, handles)
% UpdateFilePatterns(hObject, eventdata, handles)
% Create map from files to labels based upon stored regexps

% Retrieve patterns and the classes to which each pattern is mapped.
[patterns, classes] = guRegExpMap('output', hObject, eventdata, handles);

assignedTo = cell(size(handles.files));
% When multiple patterns match the same filename, we will use the first
% one that matches.  One way of enforcing this is to blindly process all
% patterns in reverse order.
for pidx = length(patterns):-1:1
  match = regexp(handles.files, patterns{pidx});
  for f = 1:length(match)
    if ~ isempty(match{f})
      assignedTo{f} = classes{pidx};
    end
  end
end

% Set all remaining to default
for f=1:length(handles.files)
  if isempty(assignedTo{f})
    assignedTo{f} = handles.unknown;
  end
end

% Format list box
strings = cell(size(handles.files));
for f = 1:length(handles.files);
  strings{f} = sprintf('%s <- %s', assignedTo{f}, handles.files{f});
end
set(handles.FilesToClass, 'String', strings);
handles.assignedTo = assignedTo;
guidata(hObject, handles);


% --- Executes on selection change in REMapList.
function REMapList_Callback(hObject, eventdata, handles)
% hObject    handle to REMapList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns REMapList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from REMapList


% --- Executes on button press in confirm.
function confirm_Callback(hObject, eventdata, handles)
% hObject    handle to confirm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Verify okay to continue.
errors = {};
% Make sure every file has a label associated with it
% (should always be the case by design)
if size(handles.assignedTo) ~= size(handles.files)
  errors{end+1} = 'Not all labels assigned';   
end
if ~ isempty(errors)
  color = get(hObject, 'BackgroundColor');
  textstr = get(hObject, 'String');
  error_str = sprintf('%s ', errors{:});
  set(hObject, 'BackgroundColor', 'red');
  set(hObject, 'String', sprintf('Correct %s', error_str));
  pause(.7);
  set(hObject, 'String', textstr);
  set(hObject, 'BackgroundColor', color);
else
  uiresume(handles.figure1);
end
  


% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ctl.cancelled = true;
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on selection change in FilesToClass.
function FilesToClass_Callback(hObject, eventdata, handles)
% hObject    handle to FilesToClass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns FilesToClass contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FilesToClass


% --- Executes during object creation, after setting all properties.
function FilesToClass_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FilesToClass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


