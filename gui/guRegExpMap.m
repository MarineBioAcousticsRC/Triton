function varargout = guRegExpMap(varargin)
% vararougt = guRegExpMap(varargin)
% GUIDE style callback - for regular expressions.
%      guLTSA_Callbacks('CALLBACK',hObject,eventData,handles,...) calls the
%      local function named CALLBACK int this function with the given input
%      arguments.
% Call guRegExpMap('init', hObject, eventdata, handles, varargin)
%    to initialize.
% Call [re, classes] = guRegExpMap('output', hObject, eventdata, handles, varargin)
%    to retrieve the list of patterns and associated classes.
%
% Expects the following UI components to be in the handles group:
% REMapList - list box showing patterns
% REMapRemove - Button for removing selected members of REMapList
% REMapPatternType - Popup menu for specifying pattern type (e.g.
%       wildcard or regular expression)
% REMapPattern - Text box for filename matching
% REMapToClass - Class to which regexp should be mapped.
% REMapAdd - Button for adding a new pattern
% REMapReplace - Button for replacing selected pattern
nargchk(1,Inf,nargin);

% format function name and call it
%varargin{1} = sprintf('%s.%s', mfilename, varargin{1});
if nargout
  [varargout{1:nargout}] = feval(varargin{:});
else
  feval(varargin{:});
end

function handles = init(hObject, eventdata, handles, varargin)
handles.RegExpMap.patterns = {};
handles.RegExpMap.classes = {};
handles.RegExpMap.MapChange_Callback = [];      % callback fn on change

function varargout = output(hObject, eventdata, handles, varargin)
varargout{1} = handles.RegExpMap.patterns;
varargout{2} = handles.RegExpMap.classes;

function handles = MapChange_Callback(hObject, eventdata, handles, hFunction)
% set_listchange_callback(hFunction)
% The function handle hFunction will be invoked each time the contents of
% the map is updated
handles.RegExpMap.MapChange_Callback = hFunction;

function okay = valid(hObject, eventdata, handles, varargin)
okay = length(handles.RegExpMap.patterns) > 0;

function REMapList(hObject, eventdata, handles, varargin)

function REMapRemove(hObject, eventdata, handles, varargin)
selected = get(handles.REMapList, 'Value');
update_listbox(hObject, eventdata, handles, selected, [], []);

function REMapReplace(hObject, eventdata, handles, varargin)
pattern = getPattern(hObject, eventdata, handles, varargin);
assign_to = get(handles.REMapToClass, 'String');
selected = get(handles.REMapList, 'Value');
update_listbox(hObject, eventdata, handles, selected, pattern, assign_to);

function REMapPatternType(hObject, eventdata, handles, varargin)

function REMapPattern(hObject, eventdata, handles, varargin)

function REMapAdd(hObject, eventdata, handles, varargin)
% Add current contents of 
pattern = getPattern(hObject, eventdata, handles, varargin);
assign_to = get(handles.REMapToClass, 'String');
update_listbox(hObject, eventdata, handles, Inf, pattern, assign_to);

function REMapSave(hObject, eventdata, handles, filename, prompt)
% Save current pattern information
if nargin < 5
    prompt = 'Save pattern associations';
end
% Request file name to save as
[filename, dir] = uiputfile('*.pat', prompt);
if ~ isstr(filename)
  return;       % User cancelled
else
    save(fullpath(dir, filename), get(handles.REMapPattern, 'String'));
end

function REMapLoad(hObject, eventdata, handles, filename, prompt);
% Load in a new set of patterns
if nargin < 5
    prompt = 'Load pattern associations';
end
% Request file to load
[filename, dir] = uigetfile('*.pat', prompt);
if ~ isstr(filename)
  return;       % User cancelled
else
    patterns = load(fullpath(dir, filename), get(handles.REMapPattern, 'String'));
    
end




function pattern = getPattern(hObject, eventdata, handles, varargin)
% Retrieve the pattern.  Convert to regexp if not already so.
pattern = get(handles.REMapPattern, 'String');
pattern_type = get(handles.REMapPatternType, 'Value');
if pattern_type == 2    % wildcard, convert to regexp
  pattern = strrep(pattern, '.', '\.');
  pattern = strrep(pattern, '*', '.*');
end

function update_listbox(hObject, eventdata, handles, position, regexp, class)
% Add/Replace/Remove mappings associated with the listbox.
% Position indicates the desired action
%       Vector - Replace/Delete specified specified items
%               deletes if regexp is [], otherwises replaces
%               all items in vector with specified regexp/class
%       Inf - Add new regexp/class pair

list = get(handles.REMapList, 'String');
remove = [];    % items to remove

if ~ isempty(regexp)
  item = sprintf('%s --> %s', regexp, class);   % add/replace
  if length(position) > 1
    % probably don't need, but interface spec doesn't say that it's sorted.
    position = sort(position); 
    remove = position(2:end);   % set to delete all items except first.
    position = position(1);
  elseif position == Inf
    position = length(list) + 1;    % append, set position to one past end
  end
  
  % Update/replace structure and listbox
  handles.RegExpMap.patterns{position} = regexp;
  handles.RegExpMap.classes{position} = class;
  list{position} = item;
  highlight = position;
else
  remove = position;    % set to delete all selected
  highlight = [];
end

if ~ isempty(remove)
  % remove unwanted entries
  handles.RegExpMap.patterns(remove) = [];
  handles.RegExpMap.classes(remove) = [];
  list(remove) = [];
  set(handles.REMapList, 'Value', []);
else
  set(handles.REMapList, 'Value', position);
end

set(handles.REMapList, 'String', list);  % update GUI
set(handles.REMapList, 'Value', highlight); % selections
% kludges for stange listbox behavior.  When there is only
% one item and we set Max to 1 which seems to be the right
% thing to do, the whole list disappears.  This has been seen
% in Matlab 7 and 2006b.
MaxVal = length(handles.RegExpMap.patterns);
if MaxVal == 1
    MaxVal = 2;
end
set(handles.REMapList, 'Max', MaxVal);

guidata(hObject, handles);  % save data

if isa(handles.RegExpMap.MapChange_Callback, 'function_handle')
  handles.RegExpMap.MapChange_Callback(hObject, eventdata, handles);
end

    
function REMapToClass_Callback(hObject, eventdata, handles)
% hObject    handle to REMapToClass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of REMapToClass as text
%        str2double(get(hObject,'String')) returns contents of REMapToClass as a double

% --- Executes during object creation, after setting all properties.
function REMapToClass_CreateFcn(hObject, eventdata, handles)
% hObject    handle to REMapToClass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function REMapList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to REMapList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in REMapPatternType.
function REMapPatternType_Callback(hObject, eventdata, handles)
% hObject    handle to REMapPatternType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns REMapPatternType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from REMapPatternType


% --- Executes during object creation, after setting all properties.
function REMapPatternType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to REMapPatternType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function filenamePattern_Callback(hObject, eventdata, handles)
% hObject    handle to filenamePattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filenamePattern as text
%        str2double(get(hObject,'String')) returns contents of filenamePattern as a double


% --- Executes during object creation, after setting all properties.
function filenamePattern_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filenamePattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in REMapAdd.
function REMapAdd_Callback(hObject, eventdata, handles)
% hObject    handle to REMapAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in REMapRemove.
function REMapRemove_Callback(hObject, eventdata, handles)
% hObject    handle to REMapRemove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function REMapPattern_Callback(hObject, eventdata, handles)
% hObject    handle to REMapPattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of REMapPattern as text
%        str2double(get(hObject,'String')) returns contents of REMapPattern as a double


% --- Executes during object creation, after setting all properties.
function REMapPattern_CreateFcn(hObject, eventdata, handles)
% hObject    handle to REMapPattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in REMapReplace.
function REMapReplace_Callback(hObject, eventdata, handles)
% hObject    handle to REMapReplace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
