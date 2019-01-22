function varargout = guGetDir(varargin)
% GUGETDIR M-file for guGetDir.fig
%      GUGETDIR, by itself, creates a new GUGETDIR or raises the existing
%      singleton*.
%
%      H = GUGETDIR returns the handle to a new GUGETDIR or the handle to
%      the existing singleton*.
%
%      GUGETDIR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUGETDIR.M with the given input arguments.
%
%      GUGETDIR('Property','Value',...) creates a new GUGETDIR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guGetDir_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guGetDir_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guGetDir

% Last Modified by GUIDE v2.5 18-Apr-2011 11:26:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guGetDir_OpeningFcn, ...
                   'gui_OutputFcn',  @guGetDir_OutputFcn, ...
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


% --- Executes just before guGetDir is made visible.
function handles = guGetDir_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guGetDir (see VARARGIN)
%   varargin{1} - default root directory

% Choose default command line output for guGetDir
%handles.output = hObject;

set(handles.(mfilename).Directory, 'String', ...
    fullfile(varargin{1}, 'metadata'));  % initialize directory
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guGetDir wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = guGetDir_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = get(handles.(mfilename).Directory, 'String');



function Directory_Callback(hObject, eventdata, handles)
% hObject    handle to Directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Directory as text
%        str2double(get(hObject,'String')) returns contents of Directory as a double


% --- Executes during object creation, after setting all properties.
function Directory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browse.
function browse_Callback(hObject, eventdata, handles)
% hObject    handle to browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dir = uigetdir();
if ~ isnumeric(dir)
    % User selected something
    set(handles.(mfilename).Directory, 'String', dir);
end
    
