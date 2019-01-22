function varargout = dtPlotBrightContrast(varargin)
% Brightness and Contrast controls created using Matlab GUIDE.
%
% dtPlotBrightContrast M-file for dtPlotBrightContrast.fig
%      DTPLOTBRIGHTCONTRAST, by itself, creates a new DTPLOTBRIGHTCONTRAST or raises the existing
%      singleton*.
%
%      H = DTPLOTBRIGHTCONTRAST returns the handle to a new DTPLOTBRIGHTCONTRAST or the handle to
%      the existing singleton*.
%
%      DTPLOTBRIGHTCONTRAST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DTPLOTBRIGHTCONTRAST.M with the given input arguments.
%
%      DTPLOTBRIGHTCONTRAST('Property','Value',...) creates a new DTPLOTBRIGHTCONTRAST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dtPlotBrightContrast_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dtPlotBrightContrast_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @dtPlotBrightContrast_OpeningFcn, ...
    'gui_OutputFcn',  @dtPlotBrightContrast_OutputFcn, ...
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


% --- Executes just before dtPlotBrightContrast is made visible.
function dtPlotBrightContrast_OpeningFcn(hObject, eventdata, handles, varargin)
% Get the handle of the image passed as an argument.
handles.ImageH = varargin{1};
pwr_brt_cont = get(handles.ImageH(1), 'UserData');
set(handles.brightscr, 'Value', pwr_brt_cont.bright_dB);
set(handles.contrastscr, 'Value', pwr_brt_cont.contrast_dB);
set(handles.brightedt, 'String', num2str(pwr_brt_cont.bright_dB));
set(handles.contrastedt, 'String', num2str(pwr_brt_cont.contrast_dB));

% Choose default command line output for dtPlotBrightContrast
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = dtPlotBrightContrast_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on slider movement (brightness).
function brightscr_Callback(hObject, eventdata, handles)
ImageH = handles.ImageH;
bright_dB = round(get(hObject, 'Value'));
for idx = 1 : length(ImageH)
    % Get the structure associated with image
    pwr_brt_cont = get(ImageH(idx), 'UserData');
    % Change the brightness of spectrogram.
    dtBrightContrast(ImageH(idx), bright_dB, pwr_brt_cont.contrast_dB);
end
set(handles.brightedt, 'String', num2str(bright_dB));

% --- Executes during object creation, after setting all properties.
function brightscr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to brightescr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement (contrast).
function contrastscr_Callback(hObject, eventdata, handles)
ImageH = handles.ImageH;
contrast_dB = round(get(hObject, 'Value'));
for idx = 1 : length(ImageH)
    % Get the structure associated with image
    pwr_brt_cont = get(ImageH(idx), 'UserData');
    % Change the contrast of spectrogram.
    dtBrightContrast(ImageH(idx), pwr_brt_cont.bright_dB, contrast_dB);
end
set(handles.contrastedt, 'String', num2str(contrast_dB));

% --- Executes during object creation, after setting all properties.
function contrastscr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contrastscr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on edit (brightnesss).
function brightedt_Callback(hObject, eventdata, handles)
ImageH = handles.ImageH;
bright_dB = str2double(get(hObject,'String'));
for idx = 1 : length(ImageH)
    % Get the structure associated with image
    pwr_brt_cont = get(ImageH(idx), 'UserData');
    % Change the brightness of spectrogram.
    dtBrightContrast(ImageH(idx), bright_dB, pwr_brt_cont.contrast_dB);
end
set(handles.brightscr, 'Value', bright_dB);

% --- Executes during object creation, after setting all properties.
function brightedt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to brightedt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on edit (contrast).
function contrastedt_Callback(hObject, eventdata, handles)
ImageH = handles.ImageH;
contrast_dB = str2double(get(hObject,'String'));
for idx = 1 : length(ImageH)
    % Get the structure associated with image
    pwr_brt_cont = get(ImageH(idx), 'UserData');
    % Change the contrast of spectrogram.
    dtBrightContrast(ImageH(idx), pwr_brt_cont.bright_dB, contrast_dB);
end
set(handles.contrastscr, 'Value', contrast_dB);

% --- Executes during object creation, after setting all properties.
function contrastedt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contrastedt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end







