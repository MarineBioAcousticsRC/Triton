function varargout = guFeatureExtractionComponent(varargin)
% GUFEATUREEXTRACTIONCOMPONENT M-file for guFeatureExtractionComponent.fig
%      GUFEATUREEXTRACTIONCOMPONENT, by itself, creates a new GUFEATUREEXTRACTIONCOMPONENT or raises the existing
%      singleton*.
%
%      H = GUFEATUREEXTRACTIONCOMPONENT returns the handle to a new GUFEATUREEXTRACTIONCOMPONENT or the handle to
%      the existing singleton*.
%
%      GUFEATUREEXTRACTIONCOMPONENT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUFEATUREEXTRACTIONCOMPONENT.M with the given input arguments.
%
%      GUFEATUREEXTRACTIONCOMPONENT('Property','Value',...) creates a new GUFEATUREEXTRACTIONCOMPONENT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guFeatureExtractionComponent_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guFeatureExtractionComponent_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help guFeatureExtractionComponent

% Last Modified by GUIDE v2.5 15-Sep-2011 16:00:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guFeatureExtractionComponent_OpeningFcn, ...
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


% --- Executes just before guFeatureExtractionComponent is made visible.
function handles = guFeatureExtractionComponent_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guFeatureExtractionComponent (see VARARGIN)

% Choose default command line output for guFeatureExtractionComponent
%handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guFeatureExtractionComponent wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

% Determine feature parameters and populate into structure
maxsep_s = get(handles.(mfilename).groupMaxSep_s, 'String');
if ~ isempty(maxsep_s)
    varargout{1}.maxsep_s = str2double(maxsep_s);
end
maxlen_s = get(handles.(mfilename).groupMaxLength_s, 'String');
if ~ isempty(maxlen_s)
    varargout{1}.maxlen_s = str2double(maxlen_s);
end
switch getstring(handles.(mfilename).clicktype)
    case 'click only'
        feat = '.s';
    case 'click+resonances'
        feat = '.c';
    otherwise 
        error('bad click type')
end
FrameAdvance_us = get(handles.(mfilename).FrameAdvance, 'String');
FrameLength_us = get(handles.(mfilename).FrameLength, 'String');
if ~ isempty(FrameAdvance_us)
  varargout{1}.FrameAdvance_us = str2double(FrameAdvance_us);
end
if ~ isempty(FrameLength_us)
  varargout{1}.FrameLength_us = str2double(FrameLength_us);
end

if strcmp(getstring(handles.(mfilename).normalization), 'none')
    meanssub = false;
else
    feat = [feat, 'z'];       % means subtraction
    meanssub = true;
end

switch getstring(handles.(mfilename).feature)
 case 'cepstra'
  feat = [feat, 'cc'];
 case 'spectra'
  feat = [feat, 'pwr'];
 case 'waveform'
  feat = [feat, 'pcm'];
  
 otherwise
  error('bad analysis type')
end
varargout{1}.FeatureType = feat;

if meanssub
    switch getstring(handles.(mfilename).normalization)
        case 'cepstral means subtraction'
            varargout{1}.meanssub = 'cepstral';
        case 'spectral means subtraction'
            varargout{1}.meanssub = 'spectral';
    end
end

varargout{1}.FeatureID = get(handles.(mfilename).ID, 'String');
varargout{1}.MaxFramesPerClick = str2double(get(handles.(mfilename).MaxFrames, 'String'));
varargout{1}.Narrowband = [str2double(get(handles.(mfilename).bandwidth_kHz, 'String')), ...
        str2double(get(handles.(mfilename).bandwidth_dB, 'String'))];
varargout{1}.HPTrans = [...
    str2double(get(handles.(mfilename).HPTranLow, 'String')), ...
    str2double(get(handles.(mfilename).HPTranHigh, 'String'))];
varargout{1}.PeakRange = [...
    str2double(get(handles.(mfilename).PeakLow, 'String')), ...
    str2double(get(handles.(mfilename).PeakHigh, 'String'))];

    

% --- Executes on selection change in clicktype.
function clicktype_Callback(hObject, eventdata, handles)
% hObject    handle to clicktype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns clicktype contents as cell array
%        contents{get(hObject,'Value')} returns selected item from clicktype


% --- Executes during object creation, after setting all properties.
function clicktype_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clicktype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function groupMaxSep_s_Callback(hObject, eventdata, handles)
% hObject    handle to groupMaxSep_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of groupMaxSep_s as text
%        str2double(get(hObject,'String')) returns contents of groupMaxSep_s as a double
if isnan(str2double(get(hObject, 'String')))
  errorText(hObject, 'Bad Value', 1.5) % User entered bad number
  set(hObject, 'String', '0.5');
end


% --- Executes during object creation, after setting all properties.
function groupMaxSep_s_CreateFcn(hObject, eventdata, handles)
% hObject    handle to groupMaxSep_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function groupMaxLength_s_Callback(hObject, eventdata, handles)
% hObject    handle to groupMaxLength_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of groupMaxLength_s as text
%        str2double(get(hObject,'String')) returns contents of groupMaxLength_s as a double
if isnan(str2double(get(hObject, 'String')))
  errorText(hObject, 'Bad Value', 1.5) % User entered bad number
  set(hObject, 'String', '2.0');
end


% --- Executes during object creation, after setting all properties.
function groupMaxLength_s_CreateFcn(hObject, eventdata, handles)
% hObject    handle to groupMaxLength_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in feature.
function feature_Callback(hObject, eventdata, handles)
% hObject    handle to feature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Ensure that the normalization method is not invalid
switch getstring(hObject)
 case 'spectra'
  if strcmp(getstring(handles.(mfilename).normalization), ...
             'cepstral means subtraction')
    % Cannot do cepstral means subtraction when spectral means subtraction
    % is specified
    setstring(handles.(mfilename).normalization, 'spectral means subtraction');
  end    

 case 'waveform'
  % no normalization possible
  setstring(handles.(mfilename).normalization, 'none');
end



% --- Executes during object creation, after setting all properties.
function feature_CreateFcn(hObject, eventdata, handles)
% hObject    handle to feature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in normalization.
function normalization_Callback(hObject, eventdata, handles)
% hObject    handle to normalization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns normalization contents as cell array
%        contents{get(hObject,'Value')} returns selected item from normalization
if strcmp(getstring(hObject), 'cepstral means subtraction') && ...
      strcmp(getstring(handles.(mfilename).feature), 'spectra')
  % Cannot have CMS when feature type is spectra, change feature type
  setstring(handles.(mfilename).feature, 'cepstra')
end


% --- Executes during object creation, after setting all properties.
function normalization_CreateFcn(hObject, eventdata, handles)
% hObject    handle to normalization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function errorText(hObject, error_msg, delay)
% errorText(hObject, handles, error_msg)
% Set the objects string value to error_msg for a brief period of time.
color = get(hObject, 'BackgroundColor');
textstr = get(hObject, 'String');
set(hObject, 'String', error_msg)
set(hObject, 'BackgroundColor', 'red');
pause(delay);
set(hObject, 'String', textstr);
set(hObject, 'BackgroundColor', color);


function string = getstring(handle)
% string = getstring(handle)
% Given a handle to a popup menu, determine its current value
strings = get(handle, 'String');
string = strings{get(handle, 'Value')};


function setstring(handle, string)
% setstring(handle, string)
% Given the handle to a popup menu and one of the text labels contained
% in the popup, set it to the string value.
strings = get(handle, 'String');
% Fin string which matches entry
value = find(strcmp(string, strings), 1);
if ~ isscalar(value)
  error('String value does not match entry in handle graphic labels')
end
set(handle, 'Value', value)



function FrameLength_Callback(hObject, eventdata, handles)
% hObject    handle to FrameLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrameLength as text
%        str2double(get(hObject,'String')) returns contents of FrameLength as a double


% --- Executes during object creation, after setting all properties.
function FrameLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FrameAdvance_Callback(hObject, eventdata, handles)
% hObject    handle to FrameAdvance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrameAdvance as text
%        str2double(get(hObject,'String')) returns contents of FrameAdvance as a double


% --- Executes during object creation, after setting all properties.
function FrameAdvance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameAdvance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ID_Callback(hObject, eventdata, handles)
% hObject    handle to ID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ID as text
%        str2double(get(hObject,'String')) returns contents of ID as a double


% --- Executes during object creation, after setting all properties.
function ID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bandwidth_kHz_Callback(hObject, eventdata, handles)
% hObject    handle to bandwidth_kHz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bandwidth_kHz as text
%        str2double(get(hObject,'String')) returns contents of bandwidth_kHz as a double


% --- Executes during object creation, after setting all properties.
function bandwidth_kHz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bandwidth_kHz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bandwidth_dB_Callback(hObject, eventdata, handles)
% hObject    handle to bandwidth_dB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bandwidth_dB as text
%        str2double(get(hObject,'String')) returns contents of bandwidth_dB as a double


% --- Executes during object creation, after setting all properties.
function bandwidth_dB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bandwidth_dB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaxFrames_Callback(hObject, eventdata, handles)
% hObject    handle to MaxFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxFrames as text
%        str2double(get(hObject,'String')) returns contents of MaxFrames as a double


% --- Executes during object creation, after setting all properties.
function MaxFrames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PeakLow_Callback(hObject, eventdata, handles)
% hObject    handle to PeakLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PeakLow as text
%        str2double(get(hObject,'String')) returns contents of PeakLow as a double


% --- Executes during object creation, after setting all properties.
function PeakLow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PeakLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PeakHigh_Callback(hObject, eventdata, handles)
% hObject    handle to PeakHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function PeakHigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PeakHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HPTranLow_Callback(hObject, eventdata, handles)
% hObject    handle to HPTranLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HPTranLow as text
%        str2double(get(hObject,'String')) returns contents of HPTranLow as a double


% --- Executes during object creation, after setting all properties.
function HPTranLow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HPTranLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HPTranHigh_Callback(hObject, eventdata, handles)
% hObject    handle to HPTranHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HPTranHigh as text
%        str2double(get(hObject,'String')) returns contents of HPTranHigh as a double


% --- Executes during object creation, after setting all properties.
function HPTranHigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HPTranHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SpecLow_Callback(hObject, eventdata, handles)
% hObject    handle to SpecLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SpecLow as text
%        str2double(get(hObject,'String')) returns contents of SpecLow as a double


% --- Executes during object creation, after setting all properties.
function SpecLow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SpecLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SpecHigh_Callback(hObject, eventdata, handles)
% hObject    handle to SpecHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SpecHigh as text
%        str2double(get(hObject,'String')) returns contents of SpecHigh as a double


% --- Executes during object creation, after setting all properties.
function SpecHigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SpecHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
