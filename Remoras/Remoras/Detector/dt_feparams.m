function varargout = dt_feparams(varargin)
% DT_FEPARAMS M-file for dt_feparams.fig
%      DT_FEPARAMS, by itself, creates a new DT_FEPARAMS or raises the existing
%      singleton*.
%
%      H = DT_FEPARAMS returns the handle to a new DT_FEPARAMS or the handle to
%      the existing singleton*.
%
%      DT_FEPARAMS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DT_FEPARAMS.M with the given input arguments.
%
%      DT_FEPARAMS('Property','Value',...) creates a new DT_FEPARAMS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dt_feparams_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dt_feparams_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dt_feparams

% Last Modified by GUIDE v2.5 10-Jun-2007 16:54:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dt_feparams_OpeningFcn, ...
                   'gui_OutputFcn',  @dt_feparams_OutputFcn, ...
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


% ---------------------------------------------------------------------------
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

% --- Executes just before dt_feparams is made visible.
function dt_feparams_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dt_feparams (see VARARGIN)

global PARAMS

% Choose default command line output for dt_feparams
handles.output = hObject;
handles.ctl.cancelled = false;
handles.error_delay = 2;
handles.valid_ltsa = false;

% Check if LTSA has been opened
if  ~isfield(PARAMS, 'ltsa') || ~ isfield(PARAMS, 'ltsahd')
    % no LTSA, disable radio button for using active LTSA
    % ans select the button for specifying LTSA file.
    set(handles.LTSAActive, 'Enable', 'off');
    set(handles.LTSASpecify, 'Value', 1);
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dt_feparams wait for user response (see UIRESUME)
uiwait(handles.figure1);  % wait for user response



% --- Outputs from this function are returned to the command line.
function varargout = dt_feparams_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

exists = ~ isempty(handles);     % Window still exists?
% User cancelled if window went bye-bye or they hit a cancel control.
cancelled = ~ exists || handles.ctl.cancelled;

if cancelled
    varargout{1} = [];
else  
    % label information
    varargout{1}.filter = get(handles.labelFilter, 'String');
    varargout{1}.mlf = get(handles.mlf, 'String');
    varargout{1}.script = get(handles.script, 'String');
    varargout{1}.tritonlabels = get(handles.tlab, 'String');
    varargout{1}.re_pat = get(handles.re_pat, 'String');
    varargout{1}.re_replace = get(handles.re_replace, 'String');
    % Set ltsa name to user provided file or empy matrix to
    % use the currently active LTSA
    if get(handles.LTSAActive, 'Value')
        varargout{1}.ltsaname = [];
    else
        varargout{1}.ltsaname = get(handles.ltsaFile, 'String');
    end

    % feature extraction
    maxsep_s = get(handles.groupMaxSep_s, 'String');
    if ~ isempty(maxsep_s)
        varargout{1}.maxsep_s = str2double(maxsep_s);
    end
    maxlen_s = get(handles.groupMaxLength_s, 'String');
    if ~ isempty(maxlen_s)
        varargout{1}.maxlen_s = str2double(maxlen_s);
    end
    switch getstring(handles.clicktype)
     case 'click only'
      feat = '.s';
     case 'click+resonances'
      feat = '.c';
     otherwise 
      error('bad click type')
    end
    
    if strcmp(getstring(handles.normalization), 'none')
      meanssub = false;
    else
      feat = [feat, 'z'];       % means subtraction
      meanssub = true;
    end
    
    switch getstring(handles.feature)
     case 'cepstra'
      feat = [feat, 'cc'];
     case 'spectra'
      feat = [feat, 'pwr'];
     otherwise
      error('bad analysis type')
    end
    varargout{1}.FeatureType = feat;
    
    if meanssub
      switch getstring(handles.normalization)
       case 'cepstral means subtraction'
        varargout{1}.meanssub = 'cepstral';
       case 'spectral means subtraction'
        varargout{1}.meanssub = 'spectral';
      end
    end
end

if exists
    delete(handles.figure1);
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
    set(handles.ltsaFile, 'String', path);  % update text box
    set(handles.ltsaFile, 'ForegroundColor', 'black');
    handles.valid_ltsa = true;   % Note valid file
    set(handles.LTSASpecify, 'Value', 1);  % select appropriate radio box
    guidata(hObject, handles);  % save changes
end

function ltsaFile_Callback(hObject, eventdata, handles)
% hObject    handle to ltsaFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ltsaFile as text
%        str2double(get(hObject,'String')) returns contents of ltsaFile as a double

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
    handles.valid_ltsa = true;
else
    set(hObject, 'ForegroundColor', 'red');
    handles.valid_ltsa = false;
end
guidata(hObject, handles);        
        


% --- Executes during object creation, after setting all properties.
function ltsaFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ltsaFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function scriptBrowse_Callback(hObject, eventdata, handles)
[file, path] = uiputfile('*.scp', 'Specify script file');
if ~ isscalar(file)
  % Update entry box and call script_Callback
  set(handles.script, 'String', fullfile(path, file));
  script_Callback(handles.script, eventdata, handles);
end

function script_Callback(hObject, eventdata, handles)
% hObject    handle to script (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of script as text
%        str2double(get(hObject,'String')) returns contents of script as a double

script = get(hObject, 'String');
[path, file, ext] = fileparts(script);
% derive other filenames from script
set(handles.mlf, 'String', sprintf('%s.mlf', fullfile(path, file)))
set(handles.tlab, 'String', sprintf('%s.tlab', fullfile(path, file)))

% --- Executes during object creation, after setting all properties.
function script_CreateFcn(hObject, eventdata, handles)
% hObject    handle to script (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mlf_Callback(hObject, eventdata, handles)
% hObject    handle to mlf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mlf as text
%        str2double(get(hObject,'String')) returns contents of mlf as a double

% --- Executes during object creation, after setting all properties.
function mlf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mlf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function mlfBrowse_Callback(hObject, eventdata, handles)
[file, path] = uiputfile('*.mlf', 'Specify master label file (MLF)');
if ~ isscalar(file)
    set(handles.mlf, 'String', fullfile(path, file));
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
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in okay.
function okay_Callback(hObject, eventdata, handles)
% hObject    handle to okay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

errors = {};
if get(handles.LTSASpecify, 'Value') && ~ handles.valid_ltsa
    errors{end+1} = 'LTSA';
end
if isempty(get(handles.script, 'String'))
    errors{end+1} = 'script';
end
if isempty(get(handles.mlf, 'String'))
    errors{end+1} = 'master label file';
end

if length(errors)
    errstr = errors{1};
    if length(errors) > 1
        errstr = [errstr, sprintf(', %s', errors{2:end})];
    end
    errorText(hObject, sprintf('Specify valid %s', errstr), ...
        handles.error_delay);
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



% --- Executes on button press in mlfAppend.
function mlfAppend_Callback(hObject, eventdata, handles)
% hObject    handle to mlfAppend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of mlfAppend


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
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function re_pat_Callback(hObject, eventdata, handles)
% hObject    handle to re_pat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of re_pat as text
%        str2double(get(hObject,'String')) returns contents of re_pat as a double
set(handles.re_output, 'String', 'Replace with:');

% --- Executes during object creation, after setting all properties.
function re_pat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to re_pat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function re_replace_Callback(hObject, eventdata, handles)
% hObject    handle to re_replace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of re_replace as text
%        str2double(get(hObject,'String')) returns contents of re_replace as a double
set(handles.re_output, 'String', 'Replace with:');

% --- Executes during object creation, after setting all properties.
function re_replace_CreateFcn(hObject, eventdata, handles)
% hObject    handle to re_replace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in re_test.
function re_test_Callback(hObject, eventdata, handles)
% hObject    handle to re_test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

re_pat = get(handles.re_pat, 'String');
re_rep = get(handles.re_replace, 'String');
userText = get(handles.re_input, 'String');
output = regexprep(userText, re_pat, re_rep);
set(handles.re_output, 'String', ...
    sprintf('Replace with:  "%s"', output));

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
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function re_output_Callback(hObject, eventdata, handles)
% hObject    handle to re_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of re_output as text
%        str2double(get(hObject,'String')) returns contents of re_output as a double


% --- Executes during object creation, after setting all properties.
function re_output_CreateFcn(hObject, eventdata, handles)
% hObject    handle to re_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function groupMaxSep_s_Callback(hObject, eventdata, handles)
% hObject    handle to groupMaxSep_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of groupMaxSep_s as text
%        str2double(get(hObject,'String')) returns contents of groupMaxSep_s as a double
if isnan(str2double(get(hObject, 'String')))
  errorText(hObject, 'Bad Value', 1.5) % User entered bad number
  set(hObject, 'String', '2.0');
end  


% --- Executes during object creation, after setting all properties.
function groupMaxSep_s_CreateFcn(hObject, eventdata, handles)
% hObject    handle to groupMaxSep_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in feature.
function feature_Callback(hObject, eventdata, handles)
% hObject    handle to feature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns feature contents as cell array
%        contents{get(hObject,'Value')} returns selected item from feature


if strcmp(getstring(hObject), 'spectra') && ...
      strcmp(getstring(handles.normalization), 'cepstral means subtraction')
  % Cannot do cepstral means subtraction when spectral means subtraction
  % is specified
  setstring(handles.normalization, 'spectral means subtraction');
end
  
% --- Executes during object creation, after setting all properties.
function feature_CreateFcn(hObject, eventdata, handles)
% hObject    handle to feature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in normalization.
function normalization_Callback(hObject, eventdata, handles)
% hObject    handle to normalization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns normalization contents as cell array
%        contents{get(hObject,'Value')} returns selected item from normalization

if strcmp(getstring(hObject), 'cepstral means subtraction') && ...
      strcmp(getstring(handles.feature), 'spectra')
  % Cannot have CMS when feature type is spectra, change feature type
  setstring(handles.feature, 'cepstra')
end

% --- Executes during object creation, after setting all properties.
function normalization_CreateFcn(hObject, eventdata, handles)
% hObject    handle to normalization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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


% --- Executes on button press in tritonbrowse.
function tritonbrowse_Callback(hObject, eventdata, handles)
% hObject    handle to tritonbrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function tlab_Callback(hObject, eventdata, handles)
% hObject    handle to TritonLabels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TritonLabels as text
%        str2double(get(hObject,'String')) returns contents of TritonLabels as a double


% --- Executes during object creation, after setting all properties.
function tlab_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TritonLabels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


