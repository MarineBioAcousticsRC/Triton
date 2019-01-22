function varargout = guLabelsComponent(varargin)
% GULABELSCOMPONENT M-file for guLabelsComponent.fig
%      GULABELSCOMPONENT, by itself, creates a new GULABELSCOMPONENT or raises the existing
%      singleton*.
%
%      H = GULABELSCOMPONENT returns the handle to a new GULABELSCOMPONENT or the handle to
%      the existing singleton*.
%
%      GULABELSCOMPONENT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GULABELSCOMPONENT.M with the given input arguments.
%
%      GULABELSCOMPONENT('Property','Value',...) creates a new GULABELSCOMPONENT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guLabelsComponent_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guLabelsComponent_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help guLabelsComponent

% Last Modified by GUIDE v2.5 13-Jun-2007 22:56:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guLabelsComponent_OpeningFcn, ...
                   'gui_OutputFcn',  @OutputFcn, ...
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


% --- Executes just before guLabelsComponent is made visible.
function handles = guLabelsComponent_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guLabelsComponent (see VARARGIN)

% Choose default command line output for guLabelsComponent
%handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guLabelsComponent wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

varargout{1}.filter = get(handles.(mfilename).labelFilter, 'String');
varargout{1}.script = get(handles.(mfilename).script, 'String');
varargout{1}.re_pat = get(handles.(mfilename).re_pat, 'String');
varargout{1}.re_replace = get(handles.(mfilename).re_replace, 'String');



function re_input_Callback(hObject, eventdata, handles)
% hObject    handle to re_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of re_input as text
%        str2double(get(hObject,'String')) returns contents of re_input as a double


% --- Executes during object creation, after setting all properties.
function re_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to re_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in re_test.
function re_test_Callback(hObject, eventdata, handles)
% hObject    handle to re_test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
re_pat = get(handles.(mfilename).re_pat, 'String');
re_rep = get(handles.(mfilename).re_replace, 'String');
userText = get(handles.(mfilename).re_input, 'String');
fprintf('%s, %s, %s\n', re_pat, re_rep, userText);
output = regexprep(userText, re_pat, re_rep);
set(handles.(mfilename).re_output, 'String', ...
    sprintf('Replace with:  "%s"', output));


% --- Executes on selection change in mlfOutputStyle.
function mlfOutputStyle_Callback(hObject, eventdata, handles)
% hObject    handle to mlfOutputStyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns mlfOutputStyle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from mlfOutputStyle


% --- Executes during object creation, after setting all properties.
function mlfOutputStyle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mlfOutputStyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in scriptBrowse.
function scriptBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to scriptBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, path] = uiputfile('*.scp', 'Specify script file');
if ~ isscalar(file)
  % Update entry box and call script_Callback
  set(handles.(mfilename).script, 'String', fullfile(path, file));
  script_Callback(handles.(mfilename).script, eventdata, handles);
end





function script_Callback(hObject, eventdata, handles)
% hObject    handle to script (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of script as text
%        str2double(get(hObject,'String')) returns contents of script as a double


% --- Executes during object creation, after setting all properties.
function script_CreateFcn(hObject, eventdata, handles)
% hObject    handle to script (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function re_pat_Callback(hObject, eventdata, handles)
% hObject    handle to re_pat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of re_pat as text
%        str2double(get(hObject,'String')) returns contents of re_pat as a double
set(handles.(mfilename).re_output, 'String', 'Replace with:');


% --- Executes during object creation, after setting all properties.
function re_pat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to re_pat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function re_replace_Callback(hObject, eventdata, handles)
% hObject    handle to re_replace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of re_replace as text
%        str2double(get(hObject,'String')) returns contents of re_replace as a double
set(handles.(mfilename).re_output, 'String', 'Replace with:');


% --- Executes during object creation, after setting all properties.
function re_replace_CreateFcn(hObject, eventdata, handles)
% hObject    handle to re_replace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function labelFilter_Callback(hObject, eventdata, handles)
% hObject    handle to labelFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of labelFilter as text
%        str2double(get(hObject,'String')) returns contents of labelFilter as a double


% --- Executes during object creation, after setting all properties.
function labelFilter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to labelFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


