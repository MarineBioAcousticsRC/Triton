function varargout = guChooseLTSAComponent(varargin)
%GUCHOOSELTSACOMPONENT M-file for guChooseLTSAComponent.fig
%      GUCHOOSELTSACOMPONENT, by itself, creates a new GUCHOOSELTSACOMPONENT or raises the existing
%      singleton*.
%
%      H = GUCHOOSELTSACOMPONENT returns the handle to a new GUCHOOSELTSACOMPONENT or the handle to
%      the existing singleton*.
%
%      GUCHOOSELTSACOMPONENT('Property','Value',...) creates a new GUCHOOSELTSACOMPONENT using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to guChooseLTSAComponent_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      GUCHOOSELTSACOMPONENT('CALLBACK') and GUCHOOSELTSACOMPONENT('CALLBACK',hObject,...) call the
%      local function named CALLBACK in GUCHOOSELTSACOMPONENT.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guChooseLTSAComponent

% Last Modified by GUIDE v2.5 13-Jun-2007 00:49:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guChooseLTSAComponent_OpeningFcn, ...
                   'gui_OutputFcn',  @OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before guChooseLTSAComponent is made visible.
function handles = guChooseLTSAComponent_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

global PARAMS

% Choose default command line output for guChooseLTSAComponent
%handles.output = hObject;

handles.(mfilename).textcolor.valid = 'black';
handles.(mfilename).textcolor.invalid = 'red';
handles.(mfilename).valid_ltsa = false;

% Check if LTSA has been opened
if ~ isvarname('PARAMS') || ~ isfield(PARAMS, 'ltsahd') || ...
        ~ isfield(PARAMS.ltsahd, 'fname')
    % no LTSA, disable radio button for using active LTSA
    % ans select the button for specifying LTSA file.
    set(handles.(mfilename).LTSASpecify, 'Value', 1);
    set(handles.(mfilename).LTSAActive, 'Enable', 'off');
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guChooseLTSAComponent wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set ltsa name to user provided file or empy matrix to
% use the currently active LTSA
varargout{1}.valid = handles.(mfilename).valid_ltsa;
if get(handles.(mfilename).LTSAActive, 'Value')
    varargout{1}.ltsaname = [];
    varargout{1}.LTSASpecified = false;
else
    varargout{1}.ltsaname = get(handles.(mfilename).ltsaFile, 'String');
    varargout{1}.LTSASpecified = true;
end


% --- Executes on button press in LTSABrowse.
function LTSABrowse_Callback(hObject, eventdata, handles)
% hObject    handle to LTSABrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Select an LTSA file
[file, dir] = uigetfile('*.ltsa', 'Select Long Term Spectral Avg file');
if ~ isscalar(file)
    % user picked something
    path = fullfile(dir, file);
    set(handles.(mfilename).ltsaFile, 'String', path);  % update text box
    % select appropriate radio box    
    set(handles.(mfilename).LTSASpecify, 'Value', 1);  
    %VerifySelectedLTSAFile(handles);
    textcolor = '';
    if ~ isdir(path) && exist(path, 'file')
        textcolor = handles.(mfilename).textcolor.valid;
        handles.(mfilename).valid_ltsa = true;   % Note valid file
    else
        textcolor = handles.(mfilename).textcolor.invalid;
        handles.(mfilename).valid_ltsa = false;
    end
    set(handles.(mfilename).ltsaFile, 'ForegroundColor', textcolor);
    guidata(hObject, handles);  % save changes
end


function ltsaFile_Callback(hObject, eventdata, handles)
% hObject    handle to ltsaFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ltsaFile as text
%        str2double(get(hObject,'String')) returns contents of ltsaFile as a double

set(handles.(mfilename).LTSASpecify, 'Value', 1);  % select appropriate radio box
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
    set(hObject, 'ForegroundColor', handles.(mfilename).textcolor.valid)
    handles.(mfilename).valid_ltsa = true;
else
    set(hObject, 'ForegroundColor', handles.(mfilename).textcolor.invalid);
    handles.(mfilename).valid_ltsa = false;
end


% --- Executes during object creation, after setting all properties.
function ltsaFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ltsaFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Helper functions
function VerifySelectedLTSAFile(handles)
path = get(handles.(mfilename).ltsaFile, 'String');
textcolor = '';
if ~ isdir(path) && exist(path, 'file')
    textcolor = handles.(mfilename).textcolor.valid;
    handles.(mfilename).valid_ltsa = true;   % Note valid file
else
    textcolor = handles.(mfilename).textcolor.invalid;
    handles.(mfilename).valid_ltsa = false;
end
set(handles.(mfilename).ltsaFile, 'ForegroundColor', textcolor);
