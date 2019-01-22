function varargout = guTimeEncoding(varargin)
% GUTIMEENCODING M-file for guTimeEncoding.fig
%      GUTIMEENCODING, by itself, creates a new GUTIMEENCODING or raises the existing
%      singleton*.
% GUIDE re_style callback - 
%      guFileComponent('CALLBACK',hObject,eventData,handles,...) calls the
%      local function named CALLBACK int this function with the given input
%      arguments.
% GUI component determining timestamps from filenames.
% It is assume that guFileComponent has already been added to the window.
%
% The following callbacks are expected:
%
% 'OutputFcn' - Return two cell lists of curently selected files and their dates.
% 'CreateFcn' - Create panel objects with associated parameters relative
%       to the current handle.
%       Example:  
%
%               handles = guTimeEncoding('CreateFcn', hObject, eventData, handles)
%               guidata(hObject, handles);      % save changes made by guGetFiles
%
%       CreateFcn returns a set of handles that should be saved by the
%       application using guidata.
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guTimeEncoding

% Last Modified by GUIDE v2.5 06-Dec-2007 15:19:01

nargchk(1,Inf,nargin);

if nargout
  [varargout{1:nargout}] = feval(varargin{:});
else
  feval(varargin{:});
end

% --- Executes just before guTimeEncoding is made visible.
function handles = guTimeEncoding_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guTimeEncoding (see VARARGIN)

% Populate drop down with regular expressions for timestamps and
% set the default to the last possible predefined pattern.
regexpstyles = datepatterns;
regexpnames = regexpstyles(:,1);
regexpnames{end+1}='Custom';
% Work around for broken code in R2006a where opening fcn called 2x
if ~ isfield(handles, mfilename)
    return
end
set(handles.(mfilename).re_style, 'String', regexpnames);
set(handles.(mfilename).re_style, 'Value', length(regexpnames)-1);

% Initialize callback function list for when user selects
% a different encoding.
handles.(mfilename).re_change_callback = {};

% Initialize regexp for parsing files
% Has side effects of initializing file list and saving handles 
re_style_Callback(handles.(mfilename).re_style, eventdata, handles);




% --- Outputs from this function are returned to the command line.
function varargout = OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get string used for time encoding
varargout{1} = get(handles.(mfilename).re, 'String');


% --- Executes on selection change in re_style.
function re_style_Callback(hObject, eventdata, handles)
% hObject    handle to re_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns re_style contents as cell array
%        contents{get(hObject,'Value')} returns selected item from re_style
% retrieve names for time styles and their accompanying patterns
styles = datepatterns();

% Retrieve string associated with current selection and find which
% one of the styles it matches.
values = get(hObject, 'String');   % List of possible values
selection = get(hObject, 'Value'); % Currently selected
style_idx = find(strcmp(styles(:,1), values{selection}) == 1);
% If the user has not selected a style for which we do not have a preset
% (e.g. custom), set the regular expression to the preset
if ~ isempty(style_idx)
  set(handles.(mfilename).re, 'String', styles{style_idx, 2});
  for idx=1:length(handles.(mfilename).re_change_callback)
    feval(handles.(mfilename).re_change_callback{idx}, ...
          hObject, eventdata, handles);
  end


end


% --- Executes during object creation, after setting all properties.
function re_style_CreateFcn(hObject, eventdata, handles)
% hObject    handle to re_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function re_Callback(hObject, eventdata, handles)
% hObject    handle to re (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of re as text
%        str2double(get(hObject,'String')) returns contents of re as a double


custom_idx = find(strcmp(get(handles.(mfilename).re_style, 'String'), ...
                         'Custom')==1);
set(handles.(mfilename).re_style, 'Value', custom_idx);

for idx=1:length(handles.(mfilename).re_change_callback)
  feval(handles.(mfilename).re_change_callback{idx}, ...
       hObject, eventdata, handles);
end

% --- Executes during object creation, after setting all properties.
function re_CreateFcn(hObject, eventdata, handles)
% hObject    handle to re (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function timeenc_panel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeenc_panel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% Add callbacks =====================================================
function handles = RegexpChangeCallback(handles, FnHandle)
% handles = RegexpChangeCallback(handles, FnHandle)
%
% Add function specified by FnHandle to the list of functions that will be
% called when the list of files changes.  FnHandle must take the standard
% handle graphics arguments: hObject, eventdata, handles Note that the
% handles structure is modified and the returned value must be saved using
% the guidata function.

handles.(mfilename).re_change_callback{end+1} = FnHandle;
