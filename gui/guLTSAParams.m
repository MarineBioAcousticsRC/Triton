function varargout = guLTSAParams(varargin)
% GULTSAPARAMS M-file for guLTSAParams.fig
%      GULTSAPARAMS, by itself, creates a new GULTSAPARAMS or raises the existing
%      singleton*.
%
%      H = GULTSAPARAMS returns the handle to a new GULTSAPARAMS or the handle to
%      the existing singleton*.
%
%      GULTSAPARAMS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GULTSAPARAMS.M with the given input arguments.
%
%      GULTSAPARAMS('Property','Value',...) creates a new GULTSAPARAMS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guLTSAParams_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guLTSAParams_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guLTSAParams

% Last Modified by GUIDE v2.5 30-Oct-2007 16:52:08

% Begin initialization code
nargchk(1,Inf,nargin);

% format function name and call it
%varargin{1} = sprintf('%s.%s', mfilename, varargin{1});
if nargout
  [varargout{1:nargout}] = feval(varargin{:});
else
  feval(varargin{:});
end
% End initialization code

% --- Executes just before guLTSAParams is made visible.
function handles = guLTSAParams_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guLTSAParams (see VARARGIN)

% Nothing to do...

% --- Outputs from this function are returned to the command line.
function varargout = OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args
%       Contains {audio fmt (int), fmt encoding, avg window s, bin width Hz}
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% WARNING - Changing the values in the GUI will break this code.
% It must be changed as a pair.
audioFmtIdx = get(handles.(mfilename).audio_format, 'Value');
audioFmts = get(handles.(mfilename).audio_format, 'String');
audioFmt = audioFmts{audioFmtIdx};

if strcmp(audioFmt, 'X Wav')
  ftype = 2;   % X Wav file
  % Convert to appropriate encoding
  xwavfiletype = [2 1 3];
  datatype = xwavfiletype(get(handles.(mfilename).fileTypeSource, 'Value'));
elseif strcmp(audioFmt, 'Wav')
  ftype = 1;  % Wav file
  datatype = 4;
else
  error('Triton internal error:  Bad value for pulldown fileTypeSource')
end
interval_s = sscanf(get(handles.(mfilename).interval_s, 'String'), '%f');
bin_width_Hz = sscanf(get(handles.(mfilename).bin_width_Hz, 'String'), '%f');
varargout = {ftype, datatype, interval_s, bin_width_Hz};


% --- Executes on selection change in audio_format.
function audio_format_Callback(hObject, eventdata, handles)
% hObject    handle to audio_format (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns audio_format contents as cell array
%        contents{get(hObject,'Value')} returns selected item from audio_format

formats = get(hObject, 'String');
if strcmp(formats{get(hObject, 'Value')}, 'X Wav')
  set(handles.(mfilename).fileTypeSource, 'Enable', 'on');
else
  set(handles.(mfilename).fileTypeSource, 'Enable', 'off');
end

% --- Executes during object creation, after setting all properties.
function audio_format_CreateFcn(hObject, eventdata, handles)
% hObject    handle to audio_format (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in fileTypeSource.
function fileTypeSource_Callback(hObject, eventdata, handles)
% hObject    handle to fileTypeSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns fileTypeSource contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fileTypeSource


% --- Executes during object creation, after setting all properties.
function fileTypeSource_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileTypeSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function interval_s_Callback(hObject, eventdata, handles)
% hObject    handle to interval_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of interval_s as text
%        str2double(get(hObject,'String')) returns contents of interval_s as a double

value = sscanf(get(hObject, 'String'), '%f');   % Scan floating point number
if isempty(value)
  value = 5.0;
end
set(hObject, 'String', sprintf('%.2f', value));

% --- Executes during object creation, after setting all properties.
function interval_s_CreateFcn(hObject, eventdata, handles)
% hObject    handle to interval_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bin_width_Hz_Callback(hObject, eventdata, handles)
% hObject    handle to interval_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of interval_s as text
%        str2double(get(hObject,'String')) returns contents of interval_s as a double

value = sscanf(get(hObject, 'String'), '%f');   % Scan floating point number
if isempty(value)
  value = 100.0;
end
set(hObject, 'String', sprintf('%.1f', value));

% --- Executes during object creation, after setting all properties.
function bin_width_Hz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bin_width_Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


