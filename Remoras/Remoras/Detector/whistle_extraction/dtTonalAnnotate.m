function varargout = dtTonalAnnotate(varargin)
% dtTonalAnnotate(AudioFilename, OptionalArguments)
% Whistle/Tonal annotation tool
% Optional arguments in any order:
%   'ParameterSet' 
%   'Framing', [Advance_ms, Length_ms] - frame advance and length in ms
%       Defaults to 2 and 8 ms respectively
%   'Noise', method
%       Method for noise compensation in spectrogram plots.
%       It is recommended that the same noise compensation as
%       used for creating the tonal set and plotting them be used.  See
%       dtSpectrogramNoiseComp for valid methods. (default 'median')
%   'Range, [LowCutoff, HighCutoff] - Specify low and high cutoffs in Hz
%       Defaults to values specified in dtThresh().  
%   'Start_s', s - Position window at specified start time
%   'Length_s', s -  Length of window in s
%   'Title', string - Prepend string to the figure name.
%   'Tonals', tonal_list - Use the specified tonal_list (must be a 
%       Java collection.  Any list produced by dtTonalAnnotate, 
%       or dtTonalTracking will satisfy this.
%   'TonalsLoad', filename - Load annotations from the specified 
%       filename.

% Note:
% This function requires dtTonalAnnotate.fig to be present and uses
% callbacks extensively.
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 22-Jun-2012 10:01:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dtTonalAnnotate_OpeningFcn, ...
                   'gui_OutputFcn',  @dtTonalAnnotate_OutputFcn, ...
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


% =====================================================================
% Callbacks 
% ====================================================================

% --- Executes just before dtTonalAnnotate is made visible.
function handles = dtTonalAnnotate_OpeningFcn(hObject, eventdata, handles, ...
    Filename, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dtTonalAnnotate 
%            See file header for list

% Verify correct number of inputs
error(nargchk(4,Inf,nargin));
% Choose default command line output for dtTonalAnnotate
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Settable Parameters --------------------------------------------------
% The threshold set is processed before any other argument as other
% arguments override the parameter set.
data.thr = dtParseParameterSet(varargin{:});  % retrieve parameters

% Defaults
data.NoiseMethod = {'median'};
% spectrogram colors
data.SpecgramColormap = bone();
% tonal plotting specifications
data.AnnotationColorN = 20;
data.AnnotationColorNext = 1;
data.AnnotationColormap = hsv(data.AnnotationColorN);
data.AnnotationColormap = ...
    data.AnnotationColormap(randperm(data.AnnotationColorN), :);
data.LineWidth = 2;
data.LineStyle = '-';
data.LineSelectedStyle = ':';

data.scale = 1000; % kHz

% default smoothing orders
data.SmoothSplineKnots = 8;
data.SmoothPolyOrder = 3;
data.EditKnots = data.SmoothSplineKnots;  % edit as spline

if isempty(Filename)
    [Filename, FileDir] = uigetfile('.wav', 'Develop ground truth for file');
    if isnumeric(Filename)
        fprintf('User abort\n');
        return
    else
        data.Filename = fullfile(FileDir, Filename);
        cd(FileDir);
    end
else
    data.Filename = Filename;
end

[fdir, fname] = fileparts(data.Filename);
data.hdr = ioReadWavHeader(data.Filename);
% defaults
data.Start_s = 0;
data.Stop_s = data.hdr.Chunks{data.hdr.dataChunk}.nSamples/data.hdr.fs;
data.RemoveTransients = false;

data.annotations = java.util.LinkedList(); % empty list of annotations

data.operation = [];

data.FigureTitle = '';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% processs arguments
%
k = 1;
while k <= length(varargin)
    switch varargin{k}
        case 'ParameterSet'
            k=k+2;  % handled earlier (must be processed first)
            
        case 'TonalsLoad'
            data.AnnotationFile = varargin{k+1};
            data.annotations = dtTonalsLoad(data.AnnotationFile, false);
            k=k+2;
            
        case 'Tonals'
            % User's tonals
            detections = varargin{k+1};
            % Basic sanity check for right type of argument, not very good
            if ~ isjava(detections)
                error('Tonals - expected Java collection of tonal objects')
            end
            % Copy user's detections to annotation list
            if detections.size() > 0
                it = detections.iterator();
                while it.hasNext()
                    a_tonal = it.next();
                    % Make a copy so we don't change the user's
                    % list if we make modifications
                    data.annotations.add(a_tonal.clone());
                end
            end
            k=k+2;

        case 'Framing'
            if length(varargin{k+1}) ~= 2
                error('%s must be [Advance_ms, Length_ms]', varargin{k});
            else
                data.thr.advance_ms = varargin{k+1}(1);
                data.thr.length_ms = varargin{k+1}(2);
            end
            k=k+2;
        case 'Noise'
            data.NoiseMethod = varargin{k+1}; k=k+2;
            if ~ iscell(data.NoiseMethod)
                data.NoiseMethod = {data.NoiseMethod};
            end
        case 'Range'
            if length(varargin{k+1}) ~= 2 || diff(varargin{k+1}) <= 0
                error('%s must be [LowCutoff_Hz, HighCutoff_Hz]', varargin{k});
            else
                data.thr.low_cutoff_Hz = varargin{k+1}(1);
                data.thr.high_cutoff_Hz = varargin{k+1}(2);
            end
            k=k+2;
        case 'Start_s'
            current_s = varargin{k+1}; k=k+2;
            if ~ isscalar(current_s) || ...
                    current_s < data.Start_s || current_s > data.Stop_s
                 error('Start_s not in range [%f, %f]', data.Start_s, data.Stop_s)
            else
                set(handles.Start_s, 'String', num2str(current_s));
            end
        case 'Length_s'
            length_s = varargin{k+1}; k=k+2;
            if ~ isscalar(length_s)
                error('Length_s must be a number specified in s');
            else
                set(handles.ViewLength_s, 'String', num2str(length_s));
            end
        case 'Title';
            FigureTitle = varargin{k+1}; k=k+2;
            if ~ ischar(FigureTitle)
                error('Title argument must be a character string');
            else
                data.FigureTitle = sprintf('%s: ', FigureTitle);
            end
        otherwise
            try
                if isnumeric(varargin{k})
                    errstr = sprintf('Bad option %f', varargin{k});
                else
                    errstr = sprintf('Bad option %s', char(varargin{k}));
                end
            catch e
                errstr = sprintf('Bad optional arg position %d', k);
            end
            error('%s', errstr);
    end
end
data.ms_per_s = 1000;
data.thr.advance_s = data.thr.advance_ms / data.ms_per_s;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables
%
data.low_disp_Hz = data.thr.low_cutoff_Hz;
set(handles.Low, 'String', num2str(data.low_disp_Hz));
data.high_disp_Hz = data.thr.high_cutoff_Hz;
set(handles.High, 'String', num2str(data.high_disp_Hz));
data.AnnotationFile = AudioFname2Tonal(data.Filename);
data.MarkerProps = {'Marker', 'none'};
data.LineStyle = '-';
% Track the previous popup option before the figure is redrawn
data.point_color = 'Cyan';

data.LastSave = 0;  % Used for tracking if the tonals have been modified

% Handles
handles.Rendered = [];  % plotted tonals
handles.Selected = [];  % selected tonals (subset of Tonals)
handles.Points = [];  % draggable points
handles.Preview = []; % preview of spline under construction
handles.Editing = []; % a tonal that is currently being edited


% Vectors for undo operation
data.undo = struct('before', {}, 'after', {});
handles.colorbar = [];
handles.image = [];

set(handles.Annotation, 'Name', sprintf('%s%s Annotation [%s]', ...
    data.FigureTitle, fname, fdir));

% I've observed some problems that may be due to a race condition.
% Try setting children's busyaction to cancel
children = setdiff(findobj(handles.Annotation, 'BusyAction', 'queue'), ...
    handles.Annotation);
set(children, 'BusyAction', 'cancel')

SaveDataInFigure(handles, data);  % save user/figure data before plot
% Plot data -- callback will plot
if data.RemoveTransients
%    set(handles.RemoveTransients, 'State', 'on');
else
%    set(handles.RemoveTransients, 'State', 'off');
end

% Set up for user interaction in default operation mode
%%handles = guidata(handles.Annotation); % pick up any changes from plotting
%operation_Callback(handles.operation, [], handles);
data = get(handles.Annotation, 'UserData');
[handles, data] = spectrogram(handles, data);
SaveDataInFigure(handles, data);
                    
% --- Outputs from this function are returned to the command line.
function varargout = dtTonalAnnotate_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% no output


% --- Executes on selection change in operation.
function operation_Callback(hObject, eventdata, handles)
% hObject    handle to operation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns operation contents as cell array
%        contents{get(hObject,'Value')} returns selected item from operation
data = get(handles.Annotation, 'UserData');

operations = get(handles.operation, 'String');
operation = operations{get(handles.operation, 'Value')};

if strcmp(operation, data.operation);
    % User selected the same operational state we are currently in.
    return
else
    set(handles.Rendered, 'HitTest', 'on');
    % disable further selections until everything ready
    set(handles.image, 'ButtonDownFcn', []);
    switch operation
        case 'Add/Merge'
            handles = edit_reset(handles);
            set(handles.SmoothOrderLabel, 'Visible', 'off');
            set(handles.SmoothOrder, 'Visible', 'off');
            data.operation = operation;

            set(handles.Annotation, 'UserData', data);
            guidata(handles.Annotation, handles);
            set(handles.image, 'ButtonDownFcn', @select_or_add);
            
        case 'Polynomial Smooth'
            handles = edit_reset(handles);
            set(handles.SmoothOrderLabel, 'Visible', 'on', ...
                'String', 'Polynomial order');
            set(handles.SmoothOrder, 'Visible', 'on', ...
                'String', num2str(data.SmoothPolyOrder));
            % No selection of spectrogram points
            set(handles.image, 'ButtonDownFcn', []);
            data.operation = operation;

            set(handles.Annotation, 'UserData', data);
            guidata(handles.Annotation, handles);
            set(handles.image, 'ButtonDownFcn', @select_or_add);
            
        case 'Spline Smooth'
            handles = edit_reset(handles);
            set(handles.SmoothOrderLabel, 'Visible', 'on', ...
                'String', 'Spline knots');
            set(handles.SmoothOrder, 'Visible', 'on', ...
                'String', num2str(data.SmoothSplineKnots));
            % No selection of spectrogram points
            set(handles.image, 'ButtonDownFcn', []);
            data.operation = operation;

            set(handles.Annotation, 'UserData', data);
            guidata(handles.Annotation, handles);
            set(handles.image, 'ButtonDownFcn', @select_or_add);
            
        case 'Edit'

            StartEdit = [];
            if length(handles.Selected) == 1 && isempty(handles.Points)
                StartEdit = handles.Selected;
            end
            handles = ReleaseSelections_Callback(hObject, eventdata, handles);
            handles = ReleasePoints(handles);
                        
            set(handles.SmoothOrderLabel, 'Visible', 'on', ...
                'String', 'Spline knots');
            set(handles.SmoothOrder, 'String', num2str(data.EditKnots));
            set(handles.SmoothOrderLabel, 'Visible', 'on');
            set(handles.SmoothOrder, 'Visible', 'on');
            data.operation = operation;

            SaveDataInFigure(handles, data);
            if ~isempty(StartEdit)
                edit_tonal(StartEdit, eventdata);
            else
                set(handles.image, 'ButtonDownFcn', @edit_tonal);
            end
            
        otherwise
            error('Silbido:InternalError', 'Invalid operation');
    end
end


% --- Executes during object creation, after setting all properties.
function operation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to operation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function SmoothOrder_Callback(hObject, eventdata, handles)
% hObject    handle to SmoothOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

op = getOperation(handles.operation);
data = get(handles.Annotation, 'UserData');

order = str2double(get(hObject,'String'));  % user entry
if isnan(order) || order < 1
    % Replace with old value
    switch (op)
        case 'Edit'
            old = data.EditKnots;
        case 'Polynomial Smooth'
            old = data.SmoothPolyOrder;
        case 'Spline Smooth'
            old = data.SmoothSplineKnots;
        otherwise
            error('Silbido:InternalError', ...
                'Unexepected operation menu state for smoothing order');
    end
    report(hObject, handles, 'Bad value');
    set(hObject, 'String', num2str(old));  % put back old value
    return
end

% Update with appropriate number
switch (op)
    case 'Edit'
        data.EditKnots = order;
    case 'Polynomial Smooth'
        data.SmoothPolyOrder = order;
    case 'Spline Smooth'
        data.SmoothSplineKnots = order;
    otherwise
        error('Silbido:InternalError', ...
            'Unexepected operation menu state for smoothing order');
end
set(handles.Annotation, 'UserData', data);


% --- Executes during object creation, after setting all properties.
function SmoothOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SmoothOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Commit.
function Commit_Callback(hObject, eventdata, handles)
% hObject    handle to Commit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

operation = getOperation(handles.operation);
switch operation
    % Commit operations save changes to handles as needed
    case 'Add/Merge'
        Commit_AddMerge(hObject, eventdata, handles);
    case {'Spline Smooth', 'Polynomial Smooth'}
        Commit_Smooth(hObject, eventdata, handles, operation);
    case 'Edit'
        Commit_Edit(hObject, eventdata, handles);
end
handles = guidata(handles.Annotation);  % may have changed, fresh copy
tonal_selected_count(handles);

function Commit_Edit(hObject, eventdata, handles)
% User has made changes to a tonal
data = get(handles.Annotation, 'UserData');
if isempty(handles.Editing)
    report(handles.Commit, handles, ...
        'Select tonal to edit before committing');
    return
end
new_tonal = getTonalFromPoints(handles, data);
if ~ isempty(new_tonal)
    % Update undo record
    change.before = {get(handles.Editing, 'UserData')};
    change.after = {new_tonal};
    data.undo(end+1) = change;
    
    % Update the tonal data structure with the new information
    tonal_rm(data.annotations, change.before{1});
    data.annotations.add(change.after{1});
    % Remove preview spline & points
    delete(handles.Points);
    handles.Points = [];
    delete(handles.Preview);
    handles.Preview = [];
    
    % Remove original tonal from list of rendered
    % tonals and insert new one
    handles.Rendered = setdiff(handles.Rendered, handles.Editing);
    [handles.Rendered(end+1), data] = plot_tonal(change.after{1}, handles, data);
    delete(handles.Editing);
    handles = exitEditMode(handles);
    % save changes
    set(handles.Annotation, 'UserData', data);
    guidata(handles.Annotation, handles);
end


function Commit_AddMerge(hObject, eventdata, handles)

import tonals.*;

% Has the user selected any points or tonals?
selectedN = length(handles.Selected);
if isempty(handles.Points)
    tonalFromPoints = 0;
else
    tonalFromPoints = 1 ;
end

if selectedN == 0 && tonalFromPoints == 0
    report(hObject, handles, 'Nothing selected to add/merge');
    return;
end

% Undoing the operation will restore the N selected items
change.before = cell(selectedN, 1);

data = get(handles.Annotation, 'UserData');

% Build matrix of tonal start and stop points so that we may check for
% overlap.  Three columns:
% start time of tonal
% end tme of tonal
% position of tonal in selected list
%   (selectedN+1 for points that will be formed into a new tonal)
extents = zeros(selectedN + tonalFromPoints, 3);

if selectedN
    for idx=1:selectedN
        a_tonal = get(handles.Selected(idx), 'UserData');
        extents(idx, :) = ...
            [a_tonal.getFirst().time, a_tonal.getLast().time, idx];
        change.before{idx} = a_tonal;
    end
end

if tonalFromPoints
    % Retrieve user points
    newtonal = getTonalFromPoints(handles, data);
    if isempty(newtonal)
        return;  % failed, error message already displayed
    end
    t = newtonal.get_time();
    extents(end, :) = [min(t), max(t), selectedN+1];
end

% Sort extents by start time
[values, order] = sort(extents(:,1)); 
extents = extents(order,:);

if selectedN+tonalFromPoints > 1
    % check for overlap in time
    overlap = extents(2:end, 1) - extents(1:end-1, 2);
    overlapped = find(overlap < 0);
    if ~ isempty(overlapped)
        % pull out original ordering
        overlapped = union(extents(overlapped,3), extents(overlapped+1,3));
        % todo:  provide visual feedback
        report(handles.Commit, handles, 'Cannot merge overlapping tonals\n');
        return
    end
end

% Create merged tonal
merged = tonal();
    
for idx=1:selectedN+tonalFromPoints
    if extents(idx,3) <= selectedN
        sidx = extents(idx, 3);  % index in selected list
        % This may become slow for very long merges
        % as the merge operator clones the list and then
        % appends to it, returning a new list.  A mutating
        % version of this wold be faster
        merged = merged.merge(change.before{sidx});
        tonal_rm(data.annotations, change.before{sidx});
    else
        % points the user requested
        merged = merged.merge(newtonal);
    end
end
data.annotations.add(merged);
change.after = {merged};

if ~isempty(handles.Selected)
    delete(handles.Selected);
    handles.Rendered = setdiff(handles.Rendered, handles.Selected);
    handles.Selected = [];
end
if ~isempty(handles.Points)
    delete(handles.Points)
    handles.Points = [];
end
if ~isempty(handles.Preview)
    delete(handles.Preview);
    handles.Preview = [];
end

N = length(change.after);
for idx = 1:length(change.after)
    [handles.Rendered(end+1), data] = ...
        plot_tonal(change.after{idx}, handles, data);
end

if ~ isempty(change)
    % Record to change log for undo operations
    data.undo(end+1) = change;
    SaveDataInFigure(handles, data);
    updateAnnotationLabel(handles, data.annotations);
end
    
function Commit_Smooth(hObject, eventdata, handles, SmoothType)
% Smooth all selected curves

order = str2double(get(handles.SmoothOrder, 'String'));
data = get(handles.Annotation, 'UserData');

SelectedN = length(handles.Selected);
if SelectedN > 0
    import tonals.*; 
    change.before = cell(1, SelectedN);
    change.after = cell(1, SelectedN);
    for idx = 1:SelectedN
        change.before{idx} = get(handles.Selected(idx), 'UserData');
        
        t = change.before{idx}.get_time();
        f = change.before{idx}.get_freq();

        % model will be fitted to times spanning the original
        % tonal with a resolution of the frame advance
        fit_t = t(1):data.thr.advance_s:t(end);
        
        switch SmoothType
            case 'Polynomial Smooth'
                % fit with polynomial of degree order
                model = polyfit(t, f, order);
                % Evaluate polyonmial 
                fit_f = polyval(model, fit_t);
            case 'Spline Smooth'
                % fit a spline with order knots
                model = splinefit(t, f, order);
                % Evaluate piecewise polyonmial 
                fit_f = ppval(model, fit_t);
        end
        
        smoothed = tonal(fit_t, fit_f);  % create replacement tonal

        change.after{idx} = smoothed;

        % Update the annotations list
        tonal_rm(data.annotations, change.before{idx});
        data.annotations.add(smoothed);

        % Update the plot to reflect the new situation
        set(handles.Selected(idx), 'UserData', smoothed, ...
            'XData', fit_t, 'YData', fit_f / data.scale);
    end
    
    data.undo(end+1) = change;
    SaveDataInFigure(handles, data);
    
end

% --- Executes on button press in ReleaseSelections.
function handles = ReleaseSelections_Callback(hObject, eventdata, handles)
% handles = ReleaseSelections_Callback(hObject, eventdata, handles)
% hObject    handle to ReleaseSelections (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Saves guidata if there is no output argument

data = get(handles.Annotation, 'UserData');
for idx=1:length(handles.Selected)
    if ismember(handles.Selected(idx), handles.Rendered)
        % Tonal is currently displayed on the screen, unselect
        set(handles.Selected(idx), ...
            'LineStyle', data.LineStyle, 'LineWidth', data.LineWidth);
    else
        % Tonal is not in the current window, delete the plot
        delete(handles.Selected(idx));
    end
end
handles.Selected = [];
tonal_selected_count(handles);

if nargout == 0 
    guidata(handles.Annotation, handles);  % save handle changes
end

% --- Executes on button press in Reset.
function Reset_Callback(hObject, eventdata, handles)
% hObject    handle to Reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function High_Callback(hObject, eventdata, handles)
% hObject    handle to High (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

high = str2double(get(hObject,'String'));
data = get(handles.Annotation, 'UserData');
if isnan(high)
    report(hObject, handles, 'Invalid high range');
    set(hObject, 'String', str2double(data.high_disp_Hz));
elseif high < data.low_disp_Hz
    report(hObject, handles, 'Display limits:  low > high ');
    set(hObject, 'String', str2double(data.high_disp_Hz));
else    
    data.high_disp_Hz = high;
    set(handles.Annotation, 'UserData', data);
end


% --- Executes during object creation, after setting all properties.
function High_CreateFcn(hObject, eventdata, handles)
% hObject    handle to High (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Low_Callback(hObject, eventdata, handles)
% Low_Callback(hObject, eventdata, handles)
% hObject    handle to Low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Set lower plot limit for spectrogram

low = str2double(get(hObject,'String'));
data = get(handles.Annotation, 'UserData');
if isnan(low)
    report(hObject, handles, 'Invalid low range');
    set(hObject, 'String', str2double(data.low_disp_Hz));
elseif low >= data.high_disp_Hz
    report(hObject, handles, 'Display limits:  low > high ');
    set(hObject, 'String', str2double(data.low_disp_Hz));
else    
    data.low_disp_Hz = low;
    set(handles.Annotation, 'UserData', data);
end

% --- Executes during object creation, after setting all properties.
function Low_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ThresholdEnable.
function ThresholdEnable_Callback(hObject, eventdata, handles)
% hObject    handle to ThresholdEnable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

threshold_p = get(hObject, 'Value');
brightness = get(handles.Brightness, 'Value');
contrast = get(handles.Contrast, 'Value');
if threshold_p
    dtBrightContrast(handles.image, brightness, contrast, ...
        str2double(get(handles.Threshold_dB, 'String')), handles.colorbar);
else
    dtBrightContrast(handles.image, brightness, contrast, -Inf, handles.colorbar);
end

function Threshold_dB_Callback(hObject, eventdata, handles)
% hObject    handle to Threshold_dB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

value = str2double(get(hObject, 'String'));
if isnan(value) 
    set(hObject, 'String', '10'); % bad value, set to default
end
if get(handles.ThresholdEnable, 'Value')
    % thresholding enabled, update
    ThresholdEnable_Callback(handles.ThresholdEnable, eventdata, handles);
end

% Hints: get(hObject,'String') returns contents of Threshold_dB as text
%        str2double(get(hObject,'String')) returns contents of Threshold_dB as a double


% --- Executes during object creation, after setting all properties.
function Threshold_dB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Threshold_dB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ViewLength_s_Callback(hObject, eventdata, handles)
% hObject    handle to ViewLength_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

length_s = str2double(get(hObject, 'String'));
if isnan(length_s);
    % bad entry, set to current display length, bad luck for user 
    % if they zoomed in
    xlim = get(handles.spectrogram, 'XLim');
    length_s = diff(xlim);
    report(hObject, handles, 'Bad plot length.');
    set(hObject, 'String', num2str(length_s));
else
    data = get(handles.Annotation, 'UserData');
    [handles, data] = spectrogram(handles, data);
    SaveDataInFigure(handles, data);
end
    
% --- Executes during object creation, after setting all properties.
function ViewLength_s_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ViewLength_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Advance_Pct_Callback(hObject, eventdata, handles)
% hObject    handle to Advance_Pct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

advance_pct = str2double(get(hObject, 'String'));
if isnan(advance_pct) || advance_pct <= 0
    report(hObject, handles, 'Advance % must be > 0');
    length_s = str2double(get(handles.ViewLength_s, 'String'));
    set(hObject, 'String', '80')
end

% --- Executes during object creation, after setting all properties.
function Advance_Pct_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Advance_Pct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Start.
function Start_Callback(hObject, eventdata, handles)
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set start time to earliest specified by the user.
data = get(handles.Annotation, 'UserData');
% See what we are currently starting at
if data.Start_s ~= 0
    data.Start_s = 0;
    set(handles.Annotation, 'UserData', data);
    set(handles.Start_s, 'String', num2str(data.Start_s));
    [handles, data] = spectrogram(handles, data);
    SaveDataInFigure(handles, data);
end


% --- Executes on button press in Rewind.
function Rewind_Callback(hObject, eventdata, handles)
% hObject    handle to Rewind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Rewind by specified Advance/Rewind frame parameters

data = get(handles.Annotation, 'UserData');
advance_s = getAdvance_s(handles);
new_s = start_in_range(data.Start_s - advance_s, handles, data);
if data.Start_s ~= new_s
    set(handles.Start_s, 'String', num2str(new_s));
    data.Start_s = new_s;
    [handles, data] = spectrogram(handles, data);
    SaveDataInFigure(handles, data);
end

% --- Executes on button press in Advance.
function Advance_Callback(hObject, eventdata, handles)
% hObject    handle to Advance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set start time to earliest specified by the user.
data = get(handles.Annotation, 'UserData');
advance_s = getAdvance_s(handles);
new_s = start_in_range(data.Start_s + advance_s, handles, data);
if data.Start_s ~= new_s
    set(handles.Start_s, 'String', num2str(new_s));
    data.Start_s = new_s;
    [handles, data] = spectrogram(handles, data);
    SaveDataInFigure(handles, data);
end

% --- Executes on button press in End.
function End_Callback(hObject, eventdata, handles)
% hObject    handle to End (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set start time to earliest specified by the user.
data = get(handles.Annotation, 'UserData');
% See what we are currently starting at
current_s = str2double(get(handles.Start_s, 'String'));
latest_start = start_in_range(data.Stop_s, handles, data);
if current_s ~= latest_start
    set(handles.Start_s, 'String', num2str(latest_start));
    data.Start_s = latest_start;
    [handles, data] = spectrogram(handles, data);
    SaveDataInFigure(handles, data);
end

% --- Executes on slider movement.
function Brightness_Callback(hObject, eventdata, handles)
% hObject    handle to Brightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

brightness = get(handles.Brightness, 'Value');
contrast = get(handles.Contrast, 'Value');
set(handles.BrightnessValue, 'String', num2str(brightness));
handles.colorbar = colorbar('peer', handles.spectrogram)
dtBrightContrast(handles.image, brightness, contrast, -Inf, handles.colorbar);
guidata(handles.Annotation, handles);

% --- Executes during object creation, after setting all properties.
function Brightness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Brightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function Contrast_Callback(hObject, eventdata, handles)
% hObject    handle to Contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
brightness = get(handles.Brightness, 'Value');
contrast = get(hObject, 'Value');
set(handles.ContrastValue, 'String', num2str(contrast));
handles.colorbar = colorbar('peer', handles.spectrogram)
dtBrightContrast(handles.image, brightness, contrast, -Inf, handles.colorbar);
guidata(handles.Annotation, handles);

% --- Executes during object creation, after setting all properties.
function Contrast_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function BrightnessValue_Callback(hObject, eventdata, handles)
% hObject    handle to BrightnessValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

brightness = str2double(get(hObject, 'String'));
% Ensure in range
brightness = max(get(handles.Brightness, 'Min'), brightness);
brightness = min(get(handles.Brightness, 'Max'), brightness);
set(handles.Brightness, 'Value', brightness);
Brightness_Callback(handles.Brightness, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function BrightnessValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BrightnessValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ContrastValue_Callback(hObject, eventdata, handles)
% hObject    handle to ContrastValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contrast = str2double(get(hObject, 'String'));
% Ensure in range
if isnan(contrast)
    contrast = 100;
end
contrast = max(get(handles.Contrast, 'Min'), contrast);
contrast = min(get(handles.Contrast, 'Max'), contrast);
set(handles.Contrast, 'Value', contrast);
Contrast_Callback(handles.Contrast, eventdata, handles);




% --- Executes during object creation, after setting all properties.
function ContrastValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ContrastValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on Annotation and none of its controls.
function Annotation_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to Annotation (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

    % operation pull down choices
    if ~ isempty(eventdata.Character)
        opchoices =  cellfun(@(x) lower(x(1)), ...
            get(handles.operation, 'String'))';
        choice = find(opchoices == eventdata.Character);
        % User pressed control?
        controlP = sum(cellfun(@(x) ~isempty(x), ...
                            strfind(eventdata.Modifier, 'control'))) > 0;
        if ~ isempty(choice)
            % fprintf('Call operation choice call back %d %s\n', choice, opchoices(choice));
            set(handles.operation, 'Value', choice);
            operation_Callback(handles.operation, [], handles);
        else switch(eventdata.Key)
                case 'space'
                    Commit_Callback(hObject, eventdata, handles);
                case 'd'
                    % Draw - Rerender the spectrogram 
                    data = get(handles.Annotation, 'UserData');
                    [handles, data] = spectrogram(handles, data);
                    SaveDataInFigure(handles, data);
                case 'v'
                    switch get(handles.ViewAnnotations, 'State');
                        case 'on'
                            set(handles.ViewAnnotations, 'State', 'off');
                            ViewAnnotations_OffCallback(...
                                handles.ViewAnnotations, [], handles);
                        case 'off'
                            set(handles.ViewAnnotations, 'State', 'on');
                            ViewAnnotations_OnCallback(...
                                handles.ViewAnnotations, [], handles);
                    end
                case 'r'
                    ReleaseSelections_Callback(hObject, eventdata, handles);
                case 't'
                    data = get(handles.Annotation, 'UserData');
                    if data.RemoveTransients
                        set(handles.RemoveTransients, 'State', 'off');
                    else
                        set(handles.RemoveTransients, 'State', 'on');
                    end
                case 'escape'
                    handles = ReleasePoints(handles);
                    guidata(handles.Annotation, handles);
                case {'rightarrow', '>'}
                    % Assumes US keyboard > is beneath .
                    Advance_Callback(handles.Advance, eventdata, handles);
                case {'leftarrow', '<'}
                    % Assumes US keyboard < is beneath ,
                    Rewind_Callback(handles.Rewind, eventdata, handles);
                case 'delete'
                    Delete_Callback(hObject, eventdata, handles);
                otherwise
                    %fprintf('Key %s Character %s\n', eventdata.Key, eventdata.Character);
            end
        end
    end


function selectTonal_Callback(hObject, eventdata, varargin)
figureH = gcbf;
handles = guidata(figureH);
data = get(figureH, 'UserData');

operation = get(handles.operation, 'String');
current = get(handles.operation, 'Value');
% User selected a tonal?
if find(handles.Rendered == hObject, 1, 'first')
    switch operation{current}
        case 'Edit'
            edit_tonal(hObject, eventdata);
        otherwise
            % [] if not already selected, otherwise selected index
            selected_idx = find(handles.Selected == hObject, 1, 'first');
            if isempty(selected_idx)
                handles.Selected(end+1) = hObject;
                set(hObject, 'LineStyle', data.LineSelectedStyle, ...
                    'LineWidth', data.LineWidth+1);
            else
                handles.Selected(selected_idx) = [];
                set(hObject, ...
                    'LineStyle', data.LineStyle, 'LineWidth', data.LineWidth);
            end
            guidata(figureH, handles);
    end
    tonal_selected_count(handles);  % update info about selections
end
        
function new_s = start_in_range(start_s, handles, data)
% Ensure start time is valid 

% Make sure we don't go past the end
viewlength_s = str2double(get(handles.ViewLength_s, 'String'));
new_s = min(data.Stop_s - viewlength_s, start_s);
% Start >= 0
new_s = max(0, new_s);

% Ensure aligned on a frame
new_s = new_s - rem(new_s, data.thr.length_ms/1000);

function Start_s_Callback(hObject, eventdata, handles)
% hObject    handle to Start_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Start_s as text
%        str2double(get(hObject,'String')) returns contents of Start_s as a double
data = get(handles.Annotation, 'UserData');
start_s = str2double(get(hObject, 'String'));
if isnan(start_s)
    report(hObject, handles, 'Bad start time');
    set(hObject, 'String', num2str(data.Start_s));
    return
end
new_s = start_in_range(start_s, handles, data);
if new_s ~= start_s
    report(hObject, handles, 'Adjusted start time');
    set(hObject, 'String', num2str(new_s));
end
data.Start_s = new_s;
[handles, data] = spectrogram(handles, data);
SaveDataInFigure(handles, data);

1;


% --- Executes during object creation, after setting all properties.
function Start_s_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Start_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_newpoint(hObject, eventdata)

if strcmp(get(gcbf, 'SelectionType'), 'extend')
    % User pressed shift-click which is only applicable to points
    return
end
figH = gcbf;
handles = guidata(figH);
data = get(handles.Annotation, 'UserData');

fprintf('new point, # handles before add = %d\n', length(handles.Points));
current_pt = get(handles.spectrogram, 'CurrentPoint');
time = current_pt(1, 1);
freq = current_pt(1, 2);

% Make sure that we don't already have a point at this time
validP = valid_newpoint(time, freq, handles.Points);

if validP
    pointerH = create_point(time, freq, handles, data.point_color);
    handles.Points = [handles.Points pointerH];
    guidata(handles.Annotation, handles);
    
    % Update preview to include new point
    if length(handles.Points) > 1
        previewSplineFit(pointerH);
    end
end

function select_or_add(hObject, eventdata)
% Callback to select a point in the time frequency display
% or select tonals via a rectangle drag

figH = gcbf;
handles = guidata(figH);
data = get(handles.Annotation, 'UserData');

current_pt = get(handles.spectrogram, 'CurrentPoint');
time = current_pt(1, 1);
freq = current_pt(1, 2);

extent = rbbox();

widthheight = [3 4];  % other corner of rectangle
if prod(extent(widthheight)) <= .0001  % .01*.01 = .0001
    if strcmp(get(handles.Annotation, 'SelectionType'), 'extend')
        % Shift click is used to remove points.  If user misses the
        % point, and the spectrogram background callback is called,
        % we do not want to add a point.
        return
    end
    % No or minimal movement of mouse between mouse down and mouse up
    % Assume the user wants to place a new point
    pointerH = create_point(time, freq, handles, data.point_color);
    if ~isempty(pointerH)
        % New point created
        handles.Points = [handles.Points pointerH];
        guidata(handles.Annotation, handles);
        
        % Update preview to include new point
        previewSplineFit(pointerH);
    end

else
    % User dragged out a bounding box
    
    % Find all tonals that overlap the bounding box and select them

    % Rewrite as vectors in normalized viewport space
    % As rect is a point and extent, we need to rewrite 
    % as two points
    vecs_vport = extent_to_rectangle(extent);
    % Make sure the first point is the lowest time
    if (vecs_vport(1, 1) > vecs_vport(1, 2))
        vecs_vport = vecs_vport(:, [2 1]);
    end
       
    % Map vectors to axis space
    vecs_ax = vport_to_axis(handles.spectrogram, vecs_vport);
    % Axis coordinate system may be scaled, convert to appropriate units
    vecs_ax(2,:) = vecs_ax(2,:) * data.scale;
    
    % We need to see what tonals overlap our bounding box.
    % Only tonals that are rendered could possibly be picked.
    %
    % As we are interested in selection, we need only concern
    % ourselves with the tonals that are not currently selected.
    possible = setdiff(handles.Rendered, handles.Selected);
    selection = tonalsInBoundingBox(vecs_ax, possible);
    
    if ~ isempty(selection)
        % Note selected tonals
        handles.Selected = [handles.Selected, selection];
        for idx=1:length(selection)
            % set display style
            set(selection(idx), 'LineStyle', data.LineSelectedStyle);
        end
        tonal_selected_count(handles);  % update selection count
        
        guidata(handles.Annotation, handles);  % store handle info
    end
end
   
function move_point(hObject, eventdata, point_Callback, pointH, figureH)
% move_point - Move an existing point
% hObject - handle graphics object associated with point
% eventdata - N/A
% point_Callback - fn handle for point's default selection behavior
% figureH - handle to containing figure

if strcmp(get(figureH, 'SelectionType'), 'extend')
    % Extended selection (shift) by user
    handles = guidata(figureH);
    
    % Find which point this is in our list of points
    idx = find(handles.Points == pointH);
    % Remove it
    handles.Points(idx) = [];
    guidata(figureH, handles);  % save updated information
    % plot with point removed, do this before the deleting
    % as previewSplineFit relies on being able to retrieve
    % the figure associated with the callback.
    previewSplineFit(pointH);   
    delete(pointH);
    
else
    % Let impoint handle the callback
    point_Callback(hObject, eventdata);
end

% --------------------------------------------------------------------
function ViewAnnotations_OffCallback(hObject, eventdata, handles)
% hObject    handle to ViewAnnotations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~ isempty(handles.Rendered)
    set(handles.Rendered, 'Visible', 'off');
end
if ~ isempty(handles.Preview)
   set(handles.Preview, 'Visible', 'off'); 
end

% --------------------------------------------------------------------
function ViewAnnotations_OnCallback(hObject, eventdata, handles)
% hObject    handle to ViewAnnotations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~ isempty(handles.Rendered)
    set(handles.Rendered, 'Visible', 'on');
end
if ~ isempty(handles.Preview)
   set(handles.Preview, 'Visible', 'on'); 
end

function report(handle, handles, message, delay_s)
if nargin < 4
    delay_s = 1.5;
end
if ishandle(handle)
    try
        color = get(handle, 'BackgroundColor');
        set(handle, 'BackgroundColor', [.8 0 0]);
        restore = true;
    catch e
        % object does not have a background color,
        % e.g. a toolbar widget.  Use something else...
        color = get(handles.Commit, 'BackgroundColor');
        restore = false;
    end
    
    axisposn = get(handles.spectrogram, 'Position');
    % Error message should be in a box spanning the axis
    % and about 10% of its height at and plotted high on the axis
    errposn = axisposn;
    errposn(4) = errposn(4) * .1;  % height
    errposn(2) = errposn(2) + axisposn(4)*.7;  % vertical position
    
    
    errH = uicontrol(handles.Annotation, 'Style', 'text', 'Position', errposn, ...
        'BackgroundColor', color, 'String', message, ...
        'Units', 'normalized', 'FontSize', 14, ...
        'HorizontalAlignment', 'center');
    pause(delay_s);
    delete(errH);
    if restore
        set(handle, 'BackgroundColor', color);
    end
end

function found = tonal_rm(iterable_tonals, a_tonal)
% Remove a tonal from iterable_tonals

it = iterable_tonals.iterator();
found = false;
while ~ found && it.hasNext();
    n_tonal = it.next();
    if a_tonal.compareTo(n_tonal) == 0
        found = true;
        it.remove();
    end
end

% --- Executes on button press in Delete.
function Delete_Callback(hObject, eventdata, handles)
% hObject    handle to Delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = get(handles.Annotation, 'UserData');
change.before = cell(1, length(handles.Selected));
change.after = {};
for idx=1:length(handles.Selected)
    a_tonal = get(handles.Selected(idx), 'UserData');
    change.before{idx} = a_tonal;
    tonal_rm(data.annotations, a_tonal);
    delete(handles.Selected(idx));
end
data.undo(end+1) = change;

% Remove the tonals that we deleted from the set of rendered tonals
handles.Rendered = setdiff(handles.Rendered, handles.Selected);
handles.Selected = [];  % None selected as all removed
tonal_selected_count(handles)
SaveDataInFigure(handles, data);
updateAnnotationLabel(handles, data.annotations);



% --------------------------------------------------------------------
function load_Annotations(hObject, eventdata, handles)
% hObject    handle to open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = get(handles.Annotation, 'UserData');
% Load in the annotations.  Make sure to pick up the name
% the user selected as they may have changed it.
[tonal_set, header, annotfile] = ...
    dtTonalsLoad(data.AnnotationFile, true);
if ~isempty(tonal_set) && tonal_set.size() > 0
    % Only replace existing tonals if user loaded new ones
    data = clear_History(data);
    [handles, data] = clear_RenderedAnnotations(handles, data);
    data = clear_History(data);
    data.annotations = tonal_set;
    data.AnnotationFile = annotfile;
    [fdir, fname] = fileparts(data.Filename);
    set(handles.Annotation, 'Name', sprintf('%s%s Annotation [%s]', ...
        data.FigureTitle, fname, fdir));
    [handles, data] = plot_tonals(handles, data);
    SaveDataInFigure(handles, data);
else
    report(hObject, handles, 'No tonals loaded');
end



% --------------------------------------------------------------------
function RemoveTransients_OffCallback(hObject, eventdata, handles)
% hObject    handle to RemoveTransients (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = get(handles.Annotation, 'UserData');
data.RemoveTransients = false;
[handles, data] = spectrogram(handles, data);
SaveDataInFigure(handles, data);


% --------------------------------------------------------------------
function RemoveTransients_OnCallback(hObject, eventdata, handles)
% hObject    handle to RemoveTransients (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = get(handles.Annotation, 'UserData');
data.RemoveTransients = true;
[handles, data] = spectrogram(handles, data);
SaveDataInFigure(handles, data);

% --------------------------------------------------------------------
function MarkerToggle_OffCallback(hObject, eventdata, handles)
% Turn off tonal markers
data = get(handles.Annotation, 'UserData');
data.MarkerProps = {'Marker', 'none'};
set(handles.Annotation, 'UserData', data);
updateMarkers(handles, data);


% --------------------------------------------------------------------
function MarkerToggle_OnCallback(hObject, eventdata, handles)
% Turn on markers

data = get(handles.Annotation, 'UserData');
data.MarkerProps = {'Marker', 's', 'MarkerSize', 4};
set(handles.Annotation, 'UserData', data);
updateMarkers(handles, data);

function updateMarkers(handles, data)
% updateMarkers(handles, data) - show current marker information
for r = handles.Rendered
    if ishandle(r)
            set(r, data.MarkerProps{:});
    end
end

% --- Executes on slider movement.
function MoveToAnnotationN_Callback(hObject, eventdata, handles)
% hObject    handle to MoveToAnnotationN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% We don't know if we are moving forward or backwards (we could check
% by looking at the start time and the annotation to which we are 
% seeking), so place the new tonal at the beginning if we need to move.
MoveToAnnotationN(handles, 1);


% --- Executes during object creation, after setting all properties.
function MoveToAnnotationN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MoveToAnnotationN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in GotoAnnotationNext.
function GotoAnnotationNext_Callback(hObject, eventdata, handles)
% hObject    handle to GotoAnnotationNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GotoAnnotationDeltaN(handles, 1);


% --- Executes on button press in GotoAnnotationPrev.
function GotoAnnotationPrev_Callback(hObject, eventdata, handles)
% hObject    handle to GotoAnnotationPrev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GotoAnnotationDeltaN(handles, -1);


% --------------------------------------------------------------------
function undo_ClickedCallback(hObject, eventdata, handles)
% Undo the last operation

data = get(handles.Annotation, 'UserData');

if length(data.undo) < 1
    report(hObject, handles, 'Nothing to undo');
    return
end

% Release any selections
handles = ReleaseSelections_Callback(hObject, eventdata, handles);

% pop the last item off the undo stack
changed = data.undo(end);
data.undo(end) = [];

% Any tonals that were added must be removed
for i=1:length(changed.after)
    found = tonal_rm(data.annotations, changed.after{i});
    assert(found, ...
        'undo:  Unable to remove tonal that should have been present');
end
% Add in tonals that were deleted
for i=1:length(changed.before)
    data.annotations.add(changed.before{i});
end

% Delete valid Rendered handles
delete(handles.Rendered(ishandle(handles.Rendered)));

% Replot tonals
[handles, data] = plot_tonals(handles, data);
SaveDataInFigure(handles, data);


% --------------------------------------------------------------------
function loadAnnotations_Callback(hObject, eventdata, handles)
% hObject    handle to loadAnnotations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function openAudioFile_Callback(hObject, eventdata, handles)
% hObject    handle to openAudioFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% TODO:  Add warning if there are unsaved annotatations as they will be lost

[Filename, FileDir] = uigetfile('.wav', 'Audio file to create/view annotations');
if isnumeric(Filename)
    return
else
    data = get(handles.Annotation, 'UserData');
    data.Filename = fullfile(FileDir, Filename);
    cd(FileDir);
    data.hdr = ioReadWavHeader(data.Filename);
    % defaults
    data.Start_s = 0;
    data.Stop_s = data.hdr.Chunks{data.hdr.dataChunk}.nSamples/data.hdr.fs;
    data.AnnotationFile = AudioFname2Tonal(data.Filename);
    
    % Clear out any existing selections/operations in progress
    handles = ReleaseSelections_Callback(hObject, eventdata, handles);
    handles = ReleasePoints(handles);
    
    % Remove all tonals and editing history
    data.annotations = java.util.LinkedList(); % empty list of annotations
    data.undo = struct('before', {}, 'after', {});

    % Make sure current point is not past end of file
    % We don't set the start to 0 in case the user wants
    % to look at the same point in similar files.
    newstart_s = start_in_range(data.Start_s, handles, data);
    data.Start_s = newstart_s;
    set(handles.Start_s, 'String', num2str(newstart_s));
    [handles, data] = spectrogram(handles, data)
    SaveDataInFigure(handles, data);
end


% --------------------------------------------------------------------
function Analysis_Callback(hObject, eventdata, handles)
% hObject    handle to Analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% No code, this is the Analysis menu 



% --------------------------------------------------------------------
function Detect_Callback(hObject, eventdata, handles)
% hObject    handle to Detect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

persistent warnExistingTonals

if isempty(warnExistingTonals)
    warnExistingTonals = true;
end

data = get(handles.Annotation, 'UserData');

% todo - wouldn't be too hard to have it 
if data.annotations.size() > 0 && warnExistingTonals == true
    action = questdlg('Overwrite existing tonals?', 'Detect tonals', ...
        'Overwrite', 'Overwrite every time', 'Cancel', 'Cancel');
    switch action
        case 'Cancel'
            return
        case 'Overwrite every time'
            action = 'Overwrite';
            warnExistingTonals = false;
    end
else
    action = 'Overwrite';
end

% wait pointer
pointer = get(handles.Annotation, 'Pointer');
set(handles.Annotation, 'Pointer', 'watch');

% Remove any plotted ones
drawnow update expose;

if strcmp(action, 'Overwrite')
    data = clear_History(data);
    [handles, data] = clear_RenderedAnnotations(handles, data);
end
data.annotations = ...
    dtTonalsTracking(data.Filename, 0, Inf, 'ParameterSet', data.thr);
set(handles.Annotation, 'UserData', data);

[handles, data] = plot_tonals(handles, data);
SaveDataInFigure(handles, data);

% Restore pointer
set(handles.Annotation, 'Pointer', pointer);


% --------------------------------------------------------------------
function ExportMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ExportMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function export_to_base_Callback(hObject, eventdata, handles)
% hObject    handle to export_to_base (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
persistent previous;
if ~ iscell(previous)
    previous = {'tonals'};   % Initialize first time it is called
end

varname = getVariableName('Name to which tonals will be exported:', ...
    'All annotations to workspace', previous);
if ~ isempty(varname)
    data = get(handles.Annotation, 'UserData');
    try
        assignin('base', varname, data.annotations);
        previous = {varname};
    catch e
        errordlg(e)
    end
end


% --------------------------------------------------------------------
function ExportSelected_Callback(hObject, eventdata, handles)
% hObject    handle to ExportSelected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

persistent previous;
if ~ iscell(previous)
    previous = {'tonals_selected'};   % Initialize first time it is called
end

varname = getVariableName('Name to which tonals will be exported:', ...
    'All annotations to workspace', previous);
if ~ isempty(varname)
    toexport = java.util.LinkedList();
    for idx = 1:length(handles.Selected)
        if ishandle(handles.Selected(idx))
            t = get(handles.Selected(idx), 'UserData');
            toexport.add(t);
        end
    end
    import java.util.Collections
    Collections.sort(toexport);
    try
        assignin('base', varname, toexport);
        previous = {varname};
    catch e
        errordlg(e)
    end
end


% --------------------------------------------------------------------
function tools_Callback(hObject, eventdata, handles)
% hObject    handle to tools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function copyClipboard_Callback(hObject, eventdata, handles)
% hObject    handle to copyClipboard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Annotations_Callback(hObject, eventdata, handles)
% hObject    handle to Annotations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function audioFilenameToClipboard_Callback(hObject, eventdata, handles)
% hObject    handle to audioFilenameToClipboard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = get(handles.Annotation, 'UserData');
clipboard('copy', data.Filename);


% --------------------------------------------------------------------
function annotationFilenameToClipboard_Callback(hObject, eventdata, handles)
% hObject    handle to annotationFilenameToClipboard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = get(handles.Annotation, 'UserData');
clipboard('copy', data.AnnotationFile);

% =====================================================================
% Helper functions 
% ====================================================================

% --------------------------------------------------------------------
function op = getOperation(hOperation)
% Given a handle to the Operation pull down, retrieve the current string
operations = get(hOperation, 'String');
op = operations{get(hOperation, 'Value')};

% --------------------------------------------------------------------
function handles = exitEditMode(handles)
% Exit the editing mode 
if ~ isempty(handles.Editing)
    handles.Editing = [];

    % rendered tonals become selectable and image selection allow drag
    % select
    set(handles.Rendered, 'HitTest', 'on');
    set(handles.image, 'ButtonDownFcn', @edit_tonal);
end    


% --------------------------------------------------------------------
function a_tonal = getTonalFromPoints(handles, data)
% Create a tonal from the current set of user selected Points
import tonals.*;

a_tonal = [];  % Assume failure until we learn otherwise

% Enough points for a tonal?
if length(handles.Points) < 2
    report(handles.Commit, handles, ...
        'Select at least two points before commiting');
    return
end

% Retrieve user selected data
[t,f] = getPoints(handles.Points, [], data.scale);

if length(unique(t)) < length(t)
    % User has two spline control points placed at same time.
    report(handles.Commit, handles, ...
        'Multiple control points positioned at same time location');
    return;
end

% Fit a spline to data points
[time, freq] = SplineFit(t, f, data.thr.advance_s);
a_tonal = tonal(time, freq);  % create a tonal


% --------------------------------------------------------------------
function handles = ReleasePoints(handles)
% Remove any selected points
% Be sure to commit handles afterwards

if ~ isempty(handles.Points)
    delete(handles.Points)
    handles.Points = [];
    if ~ isempty(handles.Preview)
        delete(handles.Preview);
        handles.Preview = [];
    end
end

op = getOperation(handles.operation);
if strcmp(op, 'Edit')
    handles = exitEditMode(handles);
end


% --------------------------------------------------------------------
function advance_s = getAdvance_s(handles)
% advance_s = getAdvance_s(handles)
% Compute the current advance based on the Adv/Rew percentage
% and the plot length
length_s = str2double(get(handles.ViewLength_s, 'String'));
percent = str2double(get(handles.Advance_Pct, 'String'))/100;
advance_s = length_s * percent;

% --------------------------------------------------------------------
function [handles, data] = spectrogram(handles, data)
% Plot spectrogram and add annotations

% wait pointer
pointer = get(handles.Annotation, 'Pointer');
set(handles.Annotation, 'Pointer', 'watch');
drawnow update;

% Remove existing tonal plots except for those that are already selected
if ~ isempty(handles.Rendered)  
    % Remove any defunct handles to prevent errors
    % It's not clear why we sometimes have defunct handles, it may have
    % to do with nested callbacks but this isn't clear...
    defunct = ~ ishandle(handles.Rendered);
    handles.Rendered(defunct) = [];
    
    % Remove any more that are valid handles and not yet selected.
    delete(setdiff(handles.Rendered, handles.Selected));
    handles.Rendered = union(handles.Rendered, handles.Selected);
end

spH = handles.spectrogram;
blkstart_s = str2double(get(handles.Start_s, 'String'));
blkstop_s = blkstart_s + str2double(get(handles.ViewLength_s, 'String'));
RenderOpts = {};
if ishandle(handles.colorbar)  % remove current colorbar if present
    delete(handles.colorbar);
end
if ~isempty(handles.image)   % remove old image panes before drawing new ones
    images = ishandle(handles.image);
    if sum(images) > 0
        delete(handles.image(images));
    end
    handles.image = [];
end

brightness = get(handles.Brightness, 'Value');
contrast = get(handles.Contrast, 'Value');

colormap(data.SpecgramColormap);
% minimum value may be set < 0 for knot editing
% make sure spectrogram is >= 0
low_spec_Hz = max(0, data.low_disp_Hz);
[axisH, handles.image, handles.colorbar] = ...
            dtPlotSpecgram(data.Filename, blkstart_s, blkstop_s, ...
            'Contrast_Pct', contrast, 'Brightness_dB', brightness, ...
            'Axis', spH, ...
            'Framing', [data.thr.advance_ms, data.thr.length_ms], ...
            'Noise', data.NoiseMethod, ...
            'ParameterSet', data.thr, ...
            'RemoveTransients', data.RemoveTransients, ...
            'Range', [low_spec_Hz, data.high_disp_Hz], ...
            RenderOpts{:});
if data.low_disp_Hz < low_spec_Hz
    set(axisH, 'YLim', ...
        [data.low_disp_Hz/data.scale, data.high_disp_Hz/data.scale]);
end
        
% Has user enabled thresholding?
threshold_p = get(handles.ThresholdEnable, 'Value');
if threshold_p
    % Perform thresholding of energy bins
    dtBrightContrast(handles.image, brightness, contrast, ...
        str2double(get(handles.Threshold_dB, 'String')), handles.colorbar);
end

% Images will painted on top of any preview or selected points, 
% Reorder, placing images at end of list
axisChildren = get(axisH, 'Children');
axisIndcs = 1:length(axisChildren);
% Locate the images in the list of children
imageIndcs = zeros(length(handles.image), 1);
for idx=1:length(imageIndcs)
    imageIndcs(idx) = find(axisChildren == handles.image(idx));
end
% Reorder to place at end
set(axisH, 'Children', ...
    axisChildren([setdiff(axisIndcs, imageIndcs'), imageIndcs']));

% Restore ButtonDown call back for any image points
if ~isempty(handles.image)
    set(handles.image, 'ButtonDownFcn', @select_or_add);
end
[handles, data] = plot_tonals(handles, data);
set(handles.Annotation, 'Pointer', pointer);


% --------------------------------------------------------------------
function [handles, data] = plot_tonals(handles, data)
% [handles, data] = plot_tonals(handles, data)
% Plot tonals overlapping the current display

global annot
annot = data.annotations;

% Clean up bad handles
% This should not be necessary
bad = ~ishandle(handles.Selected);
if sum(bad) > 0
    fprintf('Bad selected handles\n');
    handles.Selected(bad) = [];
end

xrange = get(handles.spectrogram, 'XLim');
% Create a fake tonal spanning the plotted area and ask for overlaps
import tonals.*;
phony = tonal(xrange, [data.thr.low_cutoff_Hz, data.thr.high_cutoff_Hz]);
overlap = phony.overlapping_tonals(data.annotations);

% update the annotation movement controls
updateAnnotationLabel(handles, data.annotations);

          
handles.Rendered = zeros(overlap.size(), 1);
it = overlap.iterator();
tidx = 0;
while it.hasNext()
    otonal = it.next();  % get overlapping tonal
    tidx = tidx + 1;
    % Selected tonals have already been rendered and are not
    % deleted when we move to another section.  See if this
    % overlapping tonal is one of those selected.
    sidx = has_handle(otonal, handles.Selected);
    if ~ isempty(sidx)
        handles.Rendered(tidx) = handles.Selected(sidx);
    else
        [handles.Rendered(tidx), data] = ...
            plot_tonal(otonal, handles, data);
    end
end

if strcmp(get(handles.ViewAnnotations, 'State'), 'off')
    ViewAnnotations_OffCallback(handles.ViewAnnotations, [], handles);
end

% --------------------------------------------------------------------
function [tonal_h, data] = plot_tonal(a_tonal, handles, data)
% plot a tonal and return a handle to the rendered tonal
% tonal_no indicates the position of the tonal in some list
% and handles, and data are used to determine the plot characteristics
% based on the tonal_no.

t = a_tonal.get_time();
f = a_tonal.get_freq() / data.scale;
tonal_h = plot(t, f, 'LineStyle', data.LineStyle, ...
    'Color', data.AnnotationColormap(data.AnnotationColorNext, :), ...
    'LineWidth', data.LineWidth, data.MarkerProps{:}, ... 
    'ButtonDownFcn', @selectTonal_Callback);
set(tonal_h, 'UserData', a_tonal);  % Save the tonal itself

% Next plot color
data.AnnotationColorNext = ...
    rem(data.AnnotationColorNext, data.AnnotationColorN)+1;

% --------------------------------------------------------------------
function tonal_selected_count(handles)
if isempty(handles.Selected)
    set(handles.SelectionCount, 'String', '0 tonals selected');
    set(handles.ReleaseSelections, 'Enable', 'off');
    set(handles.Delete, 'Enable', 'off');
else
    min_s = Inf;
    max_s = -Inf;
    for idx=1:length(handles.Selected)
        t = get(handles.Selected(idx), 'XData');
        min_s = min(min_s, min(t));
        max_s = max(max_s, max(t));
    end
    set(handles.SelectionCount, 'String', ...
        sprintf('%d tonals selected (%.3f - %.3f s)', ...
        length(handles.Selected), min_s, max_s));
    set(handles.ReleaseSelections, 'Enable', 'on');
    set(handles.Delete, 'Enable', 'on');
end

% --------------------------------------------------------------------
function valid = valid_newpoint(time, freq, Points)
% valid = valid_newpoint(time, freq, Points, scale)
% time, freq - point to be tested
% Points - Vector of impoints, possibly empty
%
% valid - true if it is okay to add this point
%
% See if time x freq point can be added to a list of points
% This is allowed if there is nothing in the selected
% list that occurs at the same time as the candidate point to be
% added.  (mulitple knots of the cubic spline cannot be placed
% at the same time instance)
%
% Inputs:

valid = true; % Assume okay until we learn otherwise
if length(Points) > 1
    % Retrieve existing points - note that we do not undo
    % any scaling on the frequencies as we don't really care
    % what their values are.
    [times, freqs] = getPoints(Points, []);
    if ~ isempty(find(time == times, 1))
        % This is a duplicate time, don't create a point.
        valid = false;
    end
end


% --------------------------------------------------------------------
function handles = edit_reset(handles)
% Leave the editing state 
% Be sure to commit hnadles changes
if ishandle(handles.Editing)
    handles.Editing = [];  % Remove
    handles = ReleasePoints(handles);
end
    
% --------------------------------------------------------------------
function edit_tonal(hObject, eventdata)
% Select a tonal for editing
figH = gcbf;
handles = guidata(figH);
data = get(handles.Annotation, 'UserData');

if ismember(hObject, handles.Rendered)
    % We know which object to edit
    selection = hObject
else
    current_pt = get(handles.spectrogram, 'CurrentPoint');
    time = current_pt(1, 1);
    freq = current_pt(1, 2);
    
    extent = rbbox();
    % Find all tonals that overlap the bounding box and select them

    % Rewrite as vectors in normalized viewport space
    % As rect is a point and extent, we need to rewrite 
    % as two points
    vecs_vport = extent_to_rectangle(extent);
    % Make sure the first point is the lowest time
    if (vecs_vport(1, 1) > vecs_vport(1, 2))
        vecs_vport = vecs_vport(:, [2 1]);
    end
       
    % Map vectors to axis space
    vecs_ax = vport_to_axis(handles.spectrogram, vecs_vport);
    % Axis coordinate system may be scaled, convert to appropriate units
    vecs_ax(2,:) = vecs_ax(2,:) * data.scale;
    
    % We need to see what tonals overlap our bounding box.
    % Only tonals that are rendered could possibly be picked.
    selection = tonalsInBoundingBox(vecs_ax, handles.Rendered);
    
    if isempty(selection)
        % nothing in pick regon
        return
    elseif length(selection) > 1
        report(handles.operation, handles, ...
            'Only one tonal may be edited at a time');
        return
    end
end

% We have a tonal to edit.  
% Set it as the tonal being edited and make all tonals unselectable
handles.Editing = selection;
set(handles.Rendered, 'HitTest', 'off');

% Find out how many knots the spline will have
order = str2double(get(handles.SmoothOrder, 'String'));
a_tonal = get(handles.Editing, 'UserData');
t = a_tonal.get_time();
f = a_tonal.get_freq();
indices = unique(round(linspace(1, length(t), order)));

handles.Points = [];
for idx=1:order
    handles.Points = [handles.Points, ...
        create_point(t(indices(idx)), f(indices(idx))/data.scale, ...
        handles, data.point_color)];
    if false %~ ishandle(handles.Points(idx))
        error('Silbido:InternalError', 'Unable to create a point during edit selection');
    end
end
set(handles.image, 'ButtonDownFcn', @edit_newpoint);
guidata(handles.Annotation, handles);
previewSplineFit(handles.Points(1));
handles = guidata(handles.Annotation);
handles.Points
1;


% --------------------------------------------------------------------
function pointerH = create_point(time, freq, handles, color)
% create a new point
if valid_newpoint(time, freq, handles.Points)
    pointerH = impoint(handles.spectrogram, time, freq);
    setColor(pointerH, color);
    
    % The next part is tricky.
    % impointer has its own callback so that it can be moved.
    % We want to add functionality that permits us to shift-click
    % a point to delete it.  We define a new callback that overrides
    % impoints.  We store impoint's original callback so that it
    % can be called in cases other than shift click.  The old callback
    % is passed as an argument to the new callback.
    set(pointerH, 'ButtonDownFcn', ...
        {@move_point, get(pointerH, 'ButtonDownFcn'), ...
        pointerH, handles.Annotation});
    
    % Add the point to the list of active points
    
    % When the point is moved, the preview should be updated
    % Add preview to the point's callback list (impoint fn),
    % While the callback function passes the point's coordinates, we need
    % the point itself so we define an anonymous function that discards
    % its arguemnt.
    addNewPositionCallback(pointerH, @(x) previewSplineFit(pointerH));
    
else
    pointerH = [];
end

% --------------------------------------------------------------------
function within = tonalsInBoundingBox(box, handles)
% within = tonalsInBoundingBox(box, handles)
% Given a bounding box and a list of handles that represent tonals,
% find those that lie within the bounding box.  The bounding
% box is specified as [x1 x2; y1 y2]

within = [];

tmin = min(box(1,:));
tmax = max(box(1,:));
fmin = min(box(2,:));
fmax = max(box(2,:));

within = logical(zeros(1, length(handles)));
for idx=1:length(handles)
    a_tonal = get(handles(idx), 'UserData');
    t = a_tonal.get_time();
    f = a_tonal.get_freq();
    
    % find overlaps in time & frequency
    % Todo:  Algorithm fails when there are no points in the bounding
    % box, but a line segment between two points in the tonal crosses
    % the bounding box.  (This way is easier for now.)
    ov = t >= tmin & t <= tmax & f >= fmin & f <= fmax;
    within(idx) = sum(ov) > 1;
end
within = handles(within);
if size(within, 1) > 1
    within = within';  % ensure row vector
end

% --------------------------------------------------------------------
function replaceTonal(tonals, oldtonal, newtonal)
% replaceTonal(tonals, oldtonal, newtonal)
% Given a list of tonals, an old tonal and a new tonal,
% replace the occurrence of old tonal in the list with new tonal

found = false;
it = tonals.iterator();

% Look for the old tonal and remove it
while ~ found && it.hasNext();
    next = it.next();
    if (next.compareTo(oldtonal) == 0)
        found = true;
        it.remove();  
    end
end

if found
    tonals.add(newtonal);
else
    error('Silbido:ValueError', ...
        'The tonal collection does not contain the tonal to be replaced.');
end

% --------------------------------------------------------------------
function ax_points = vport_to_axis(axis_h, points)
% fpoints = vport_to_axis(axis_h, points)
% Viewport to axis (window) mapping
%
% Given a set of points where each column is an (x,y) point in the
% coordinate system associated with a figure (the viewport), convert the
% points to the coordinate system of the specified axis that is associated
% with the figure.

% We will use a homogeneous coordinate system which appends
% a one after each vector (see any text on computer graphics
% for why we do this - bottom line is it makes affine
% transformations (scaling, rotation, translation) easy.
p = [points; ones(1, size(points, 2))];

% Get viewport extent [x, y, deltax, deltay]
extent = get(axis_h, 'Position');
% convert to [x1,x2 ; y2,y2]
VpCoord = extent_to_rectangle(extent);
% What range does the coordinate system span?
VpRange = diff(VpCoord, [], 2);  % delta x & y

% Get axis (window) rectangle
props = {'XLim', 'YLim'};
AxCoord = zeros(length(props), 2);
for idx=1:length(props)
    AxCoord(idx,:) = get(axis_h, props{idx});
end
% What range does the coordinate system span?
AxRange = diff(AxCoord, [], 2);  % delta x & y

% Build translation and scaling matrix
Op = diag(ones(3,1));
% Translate Axis Position back to origin
Op(1:2, 3) = - VpCoord(:, 1);

% Scale to the axis coordinate system 
NextOp = diag([AxRange ./ VpRange; 1]);
Op = NextOp * Op;

% Translate to axis coordinate system
NextOp = diag(ones(3,1));
NextOp(1:2, 3) = AxCoord(:,1);
Op = NextOp * Op;

ax_p = Op * p;  % transform
% Remove homogeneous space coordinate
ax_points = ax_p(1:end-1, :);


% --------------------------------------------------------------------
function rect = extent_to_rectangle(extent)
% rect = extent_to_rectangle(extent)
% Convert [x, y, width, height] to [x1 x2; y1 y2]

rect = reshape(extent, 2, 2); % [x1 width; y1 height]
rect(:,2) = rect(:,1) + rect(:,2); %[x1 x1+width; y1 y1+height]
    
% --------------------------------------------------------------------
function [time, freq, transient_posn] = ...
    getPoints(points, transient_pt, scale_Hz)
% [t, f, transient_posn] = getPoints(points, transient_pt, scale)
% Given a vector of impoints, pull out their times and frequencies.
%
% When a point is being dragged, it may occur that it has the same
% time abscissa.  In this case, we may wish to omit the data from
% that there is only one frequency value for each time.  Calling this
% function with an impoint bound to transient_pt will remove the time
% point associated with transinet_pt from the set of points if a
% duplicate time entry occurs.  Omit or set to [] if a transinet
% point does not exist.
%
% scale_Hz is an optional scale factor to scale up/down the data 
% (e.g. 1/1000 for points in kHz)
        
% get list of times and frequencies
N = length(points);
time = zeros(N,1);
freq = zeros(N,1);
for idx=1:N
    posn = getPosition(points(idx));
    time(idx) = posn(1);
    freq(idx) = posn(2);
end

transient_posn = [];
if nargin > 1 && ~ isempty(transient_pt)
    % Check to see if time(transient_pt) occurs > 1 time
    posn = getPosition(transient_pt);
    t = posn(1);
    duplicates = find(time == t);
    
    if length(duplicates) > 1
        % duplicate occurred, note the transient points position
        % in the list as some routines may wish to delete it
        transient_posn = find(points == transient_pt);
        % Remove the time frequency associated with the transient
        time(transient_posn) = [];
        freq(transient_posn) = [];
    end
end
    
if nargin > 2
    freq = freq * scale_Hz;  % set scaling appropriately
end

% sort by time
[time timeOrder] = sort(time);
freq = freq(timeOrder);


% --------------------------------------------------------------------
function [t, f] = SplineFit(time, freq, delta_s)
% [t,f] = SplineFit(time, freq, delta_s)
%
% Given a list of times and frequencies (ordered by time), fit a spline
% through the given points.  The resulting spline is evaluated every
% delta_s from the starting time to the ending time.  

switch length(time)  % # of entries
    case 0
        t = [];
        f = [];
    case 1
        t = floor(time/advance_s)*delta_s;
        f = freq;
    otherwise
        polynomial = spline(time, freq);
        start = floor(time(1)/delta_s)*delta_s;
        stop = floor(time(end)/delta_s)*delta_s;
        N = round((stop - start)/delta_s)+ 1;
        t = linspace(start, stop, N);
        f = ppval(polynomial, t);
end    

% --------------------------------------------------------------------
function previewSplineFit(pointH)

figureH = gcbf;
handles = guidata(figureH);
if ishandle(handles.Preview)
    delete(handles.Preview);
end
data = get(figureH, 'UserData');
if length(handles.Points) > 1
    % Retrieve points used to construct spline
    [time, freq] = getPoints(handles.Points, pointH, data.scale);
    % fit spline to data and return fitted values
    % the plotted spline should not be selectable so that
    % the user can continue placing points, even in areas that are
    % under the spline
    [t, f] = SplineFit(time, freq, data.thr.advance_s);
    visibility = get(handles.ViewAnnotations, 'State');
    handles.Preview = plot(t, f/data.scale, 'r:', ...
        'HitTest', 'off', 'LineWidth', 4, 'Visible', visibility);
    guidata(figureH, handles);  % save changes
end


% --------------------------------------------------------------------
function TonalName = AudioFname2Tonal(AudioName)
% TonalName = AudioFname2Tonal(AudioName)
% Given the name of an audio file, suggest a tonal filename from it.
[dir, name, ext] = fileparts(AudioName);
TonalName = fullfile(dir, [name, '.ann']);

% --------------------------------------------------------------------
function data = clear_History(data)
% clear undo data associated with prior changes
data.undo = struct('before', {}, 'after', {});  % Remove history
data.LastSave = 0;

% --------------------------------------------------------------------
function [handles, data] = clear_RenderedAnnotations(handles, data)
% Clear plotted tonals and any tonals under construction

handles = ReleasePoints(handles);  % tonals under constrcution

% Remove currently plotted tonals
valid = ishandle(handles.Rendered);
if ~ isempty(handles.Rendered(valid))
    delete(handles.Rendered(valid));
end
handles.Rendered = [];
% Remove tonals that are selected, but not currently displayed.
valid = ishandle(handles.Selected);
if ~ isempty(handles.Selected)
    delete(handles.Selected(valid));
end





% --------------------------------------------------------------------
function save_Annotations(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = get(handles.Annotation, 'UserData');
dtTonalsSave(data.AnnotationFile, data.annotations, true);

% --------------------------------------------------------------------
function SaveDataInFigure(handles, data)
% Save the handles/data structures as GUI and user data in the 
% figure

guidata(handles.Annotation, handles);
set(handles.Annotation, 'UserData', data);

% --------------------------------------------------------------------
function idx = has_handle(tonal, handlevec)
% idx = has_handle(tonal, handlevec)
% Given a tonal, see if it is represented by the list of handles
% It is assumed that all valid handles will have a UserData field
% containing a tonal.  The index of the handle is returned.

idx = [];  % Assume no match until we find out otherwise
matchP = false;

% Look for a tonal in handlevec that matches the one we specified
n = 0;
while ~ matchP && n < length(handlevec)
    n = n+1;
    if ishandle(handlevec(n))
        otonal = get(handlevec(n), 'UserData');
        matchP = tonal.compareTo(otonal) == 0;
    end
end

if matchP
    idx = n;  % found it
end


% --------------------------------------------------------------------
function varname = getVariableName(message, title, default)
% varname = getVariableName(message, title, default)
% Prompt user for a Matlab variable name

options.Resize = 'on';
% If message is much shorter than title, we'll have problems
minlen = length(title)+70;  % Account for close/min/max widgets
if length(message) < minlen
    % Pad the message and add a period at the far right
    % Not an elegant solution, but Matlab won't render trailing
    % spaces and there does not appear to be a good way of setting
    % the dialog width without rolling our own...
    message = sprintf(sprintf('%%s%%%ds', minlen), message, '.')
end

result = inputdlg(message, title, 1, default, options);
valid = false;
while ~ valid
    if isempty(result) 
        varname = []; 
        return   % User cancelled
    end
    varname = result{1};
    valid = isvarname(varname);
    if ~ valid
        result = inputdlg(...
            sprintf('"%s" INVALID NAME.  %s', varname, message, options), ...
            title, 1, default);                
    end
end

function GotoAnnotationDeltaN(handles, delta)
% GotoAnnotationDeltaN(handles, delta)
% Move from current annoation +/- delta
current = get(handles.MoveToAnnotationN, 'Value') + delta;
%fprintf('New tonal %d, previous %d (delta %d)\n', current - 1, current - 1 - delta, delta);

% Retrieve min and max values from slider.  Set min to 1
% if 0 which is a special case for a single tonal to prevent
% the slider from disappearing (behavior when Min == Max)
mintonal = max(1, get(handles.MoveToAnnotationN, 'Min'));
maxtonal = get(handles.MoveToAnnotationN, 'Max');
current = min(max(current, mintonal), maxtonal);
set(handles.MoveToAnnotationN, 'Value', current);
MoveToAnnotationN(handles, delta);

function MoveToAnnotationN(handles, delta)
current = max(1, round(get(handles.MoveToAnnotationN, 'Value')));
data = get(handles.Annotation, 'UserData');
target_tonal = data.annotations.get(current - 1);
rendered = HighlightAnnotation(handles, target_tonal);
if ~rendered
    % Position annotation near the start or end of the window
    % depending on which way we are going
    length_s = str2double(get(handles.ViewLength_s, 'String'));
    pad_s = length_s * .05;
    if sign(delta) == -1
        % moving backwards, put annotation near end
        last_s = target_tonal.getLast().time + pad_s;
        new_s = start_in_range(last_s - length_s, handles, data);
    else
        % moving forwards or an absolute seek, put near beginning
        first_s = target_tonal.getFirst().time - pad_s;
        new_s = start_in_range(first_s, handles, data);
    end
    if data.Start_s ~= new_s
        set(handles.Start_s, 'String', num2str(new_s));
        data.Start_s = new_s;
        [handles, data] = spectrogram(handles, data);
        SaveDataInFigure(handles, data);
    end
    HighlightAnnotation(handles, target_tonal);
end
updateAnnotationLabel(handles, data.annotations);


function updateAnnotationLabel(handles, annotations)
% Update the annotation label beneath the annotation slider
annotationsN = annotations.size();
if annotationsN == 0
    % no tonals to navigate, disable controls
    set(handles.MoveToAnnotationN, 'Enable', 'inactive');
    set(handles.GotoAnnotationNext, 'Enable', 'inactive');
    set(handles.GotoAnnotationPrev, 'Enable', 'inactive');
    set(handles.GotoAnnotationLabel, 'String', '0 tonals');
else
    current = max(1, round(get(handles.MoveToAnnotationN, 'Value')));
    if current > annotationsN
        % User deleted annotations, set to new max count
        current = annotationsN;
        set(handles.MoveToAnnotationN, 'Max', annotationsN);
        set(handles.MoveToAnnotationN, 'Value', current);
    end
    if annotationsN == 1
        % Special case, slider does not show in min/max are the same
        MinVal = .9;
        SliderStep = [1 1];
    else
        MinVal = 1;
        one_step = 1/annotationsN;
        SliderStep = [one_step, one_step*10];  % move by one tonal or 10%
    end
    set(handles.MoveToAnnotationN, 'Enable', 'on', ...
        'Min', MinVal, 'Max', annotationsN, 'SliderStep', SliderStep);
    set(handles.GotoAnnotationNext, 'Enable', 'on');
    set(handles.GotoAnnotationPrev, 'Enable', 'on');
    set(handles.GotoAnnotationLabel, 'String', ...
        sprintf('%d/%d', current, annotations.size()));    
end



function rendered = HighlightAnnotation(handles, tonal)
% If a tonal is rendered, highlight it briefly.  
% Return true if ti was rendered, otherwise false

valid = ishandle(handles.Rendered);
rendered = false;
idx = 0;
while ~ rendered && idx < length(handles.Rendered)
    idx = idx + 1;
    if valid(idx)
        atonal = get(handles.Rendered(idx), 'UserData');
        same = tonal.compareTo(atonal);
        if same == 0
            rendered = true;
            thickness = get(handles.Rendered(idx), 'LineWidth');
            for flash = 1:2
                set(handles.Rendered(idx), 'LineWidth', thickness*3);
                pause(.05);
                set(handles.Rendered(idx), 'LineWidth', thickness);
            end
        end
    end
end


% --------------------------------------------------------------------
function Help_Callback(hObject, eventdata, handles)
% hObject    handle to Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function HelpAnnotationTool_Callback(hObject, eventdata, handles)
% hObject    handle to HelpAnnotationTool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dir = fileparts(mfilename);
open(fullfile(dir, 'docs', 'Annotation.pdf'));


% --------------------------------------------------------------------
function HelpSilbidoSetup_Callback(hObject, eventdata, handles)
% hObject    handle to HelpSilbidoSetup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dir = fileparts(mfilename);
open(fullfile(dir, 'docs', 'ReadMeFirst.pdf'));


% --------------------------------------------------------------------
function HelpTonalsTracking_Callback(hObject, eventdata, handles)
% hObject    handle to HelpTonalsTracking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dir = fileparts(mfilename);
open(fullfile(dir, 'docs', 'Detector.pdf'));


% --------------------------------------------------------------------
function HelpManipulatingTonals_Callback(hObject, eventdata, handles)
% hObject    handle to HelpManipulatingTonals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dir = fileparts(mfilename);
open(fullfile(dir, 'docs', 'ManipulatingTonals.pdf'));


% --------------------------------------------------------------------
function HelpScoring_Callback(hObject, eventdata, handles)
% hObject    handle to HelpScoring (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dir = fileparts(mfilename);
open(fullfile(dir, 'docs', 'Scoring.pdf'));
