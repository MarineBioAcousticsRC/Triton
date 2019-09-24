function varargout = sh_evaluate(varargin)
% SH_EVALUATE MATLAB code for sh_evaluate.fig
%      SH_EVALUATE, by itself, creates a new SH_EVALUATE or raises the existing
%      singleton*.
%
%      H = SH_EVALUATE returns the handle to a new SH_EVALUATE or the handle to
%      the existing singleton*.
%
%      SH_EVALUATE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SH_EVALUATE.M with the given input arguments.
%
%      SH_EVALUATE('Property','Value',...) creates a new SH_EVALUATE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sh_evaluate_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sh_evaluate_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sh_evaluate

% Last Modified by GUIDE v2.5 18-Sep-2019 11:28:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name', mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @sh_evaluate_OpeningFcn, ...
    'gui_OutputFcn',  @sh_evaluate_OutputFcn, ...
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


% --- Executes just before sh_evaluate is made visible.
function sh_evaluate_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sh_evaluate (see

handles.j = 1;
handles.marker_count = 0;
handles.dim_coords = 0;
handles.brightness = 0.4;
handles.NextFile = 0;
handles.replot = 0;

% Choose default command line output for sh_evaluate
handles.output = hObject;
set(handles.figure1,'KeyPressFcn',@initialize_buttons);

% Compute starting values
handles.StartFreqVal = str2double(get(handles.start_freq,'String'));
handles.EndFreqVal = str2double(get(handles.end_freq,'String'));
handles.PlotLengthVal = str2double(get(handles.plot_length,'String'));
handles.StartDetVal = str2double(get(handles.start_detection,'String'));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes sh_evaluate wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = sh_evaluate_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function start_freq_Callback(hObject, ~, handles)
% hObject    handle to start_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.StartFreqVal = str2double(get(handles.start_freq,'String'));
guidata(hObject, handles);
plot_ltsa_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function start_freq_CreateFcn(hObject, ~, handles)
% hObject    handle to start_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function end_freq_Callback(hObject, ~, handles)
% hObject    handle to end_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.EndFreqVal = str2double(get(handles.end_freq,'String'));
guidata(hObject, handles);
plot_ltsa_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function end_freq_CreateFcn(hObject, ~, handles)
% hObject    handle to end_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function plot_length_Callback(hObject, ~, handles)
% hObject    handle to plot_length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.PlotLengthVal = max(1,str2double(get(handles.plot_length,'String')));
handles.replot = 1;
guidata(hObject, handles);
motion_forwards_Callback(hObject, 1, handles)


% --- Executes during object creation, after setting all properties.
function plot_length_CreateFcn(hObject, ~, handles)
% hObject    handle to plot_length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot_ltsa.
function plot_ltsa_Callback(hObject, ~, handles)
% hObject    handle to plot_ltsa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'LtsaFile')
    error('Please select LTSA file.')
end
if isempty(handles.shipTimes)
    disp('No detections in this file.')
end
if ~isfield(handles,'ltsaData') || isempty(handles.ltsaData)
    motion_forwards_Callback(hObject, 1, handles)    
else
    sh_draw_ltsa(handles);
    
    enabledBack = get(handles.motion_backwards,'Enable');
    enabledFwd = get(handles.motion_forwards,'Enable');
    
    % set backwards button off (start file) and on (not start of file)
    if handles.j == 1
        if strcmp(enabledBack,'on')
            set(handles.motion_backwards,'Enable','off')
        end
    else
        if handles.ViewStart == 1
            if strcmp(enabledBack,'on')
                set(handles.motion_backwards,'Enable','off')
            end
        else
            if strcmp(enabledBack,'off')
                set(handles.motion_backwards,'Enable','on')
            end
        end
    end
    
    % set forwards button off (end file) and on (not end of file)
    if handles.j > size(handles.shipTimes,1)
        if strcmp(enabledFwd,'on')
            set(handles.motion_forwards,'Enable','off')
        end
    else
        if strcmp(enabledFwd,'off')
            set(handles.motion_forwards,'Enable','on')
        end
    end
end
guidata(hObject, handles);


% --- Executes on button press in motion_forwards.
function motion_forwards_Callback(hObject, eventdata, handles)
% hObject    handle to motion_forwards (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% % Move forward button '>'
ltsaData = []; handles.ltsaData=[]; handles.markers=0; length_index=0;
repeat = 0;

shipTimes = handles.shipTimes;
% if replot 1, keep same start time, if not the last detection processed.
if ~handles.replot
    handles.ViewStart = handles.j;
else 
    handles.replot = 0; % set to 0 again after settings changed.
end

while(size(handles.ltsaData,2) < floor(handles.PlotLengthVal*60*60/handles.ltsa.tave))...
        && (handles.j <= size(shipTimes,1))
    
    % Read the ltsa data portion of the file
    ltsaData = sh_read_ltsadata(handles,shipTimes(handles.j,1),shipTimes(handles.j,2));
    
    length_index = length_index+size(ltsaData,2);
    if length_index > floor((handles.PlotLengthVal*60*60)/handles.ltsa.tave)
        remove = length_index - ...
            floor((handles.PlotLengthVal*60*60)/handles.ltsa.tave);
        ltsaData = ltsaData(:,1:end-remove);
        repeat = 1;
    end
    handles.ltsaData=[handles.ltsaData,ltsaData];
    handles.markers = [handles.markers,length_index];
    handles.j = handles.j+1;
end
handles.ViewEnd = handles.j-1;

% show cutted detection from previous window in the next window
if repeat
    handles.j = handles.j-1;
end

% update text
set(handles.percent_completed,'String',round(handles.ViewEnd/size(handles.shipTimes,1)*100))
handles.marker_count = handles.marker_count + length(handles.markers);
handles.plot_length_prev = get(handles.plot_length,'string');

% if end of file is less than the designated plot length, just show the
% current length of the plot
if(handles.j >= size(shipTimes,1))
    set(handles.plot_length,'String',(size(handles.ltsaData,2)*...
        handles.ltsa.tave)/(60*60))
end
guidata(hObject, handles);

% plot data
plot_ltsa_Callback(hObject, eventdata, handles)

% reached end of file, disable forward button
if(handles.ViewEnd>=size(shipTimes,1))
    set(handles.motion_forwards,'Enable','off')
    fprintf('Reached end of this detection file.\n')
else
    enabled = get(handles.motion_forwards,'Enable');
    if strcmp(enabled,'off')
        set(handles.motion_forwards,'Enable','on')
    end
end
guidata(hObject, handles);


% --- Executes on button press in motion_backwards.
function motion_backwards_Callback(hObject, eventdata, handles)
% hObject    handle to motion_backwards (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% % Scroll backward button '<'
if handles.ViewStart<=1
    set(handles.motion_backwards,'Enable','off')
else
    handles.j = handles.ViewStart;
    handles.ViewEnd = handles.j;
    viewStart = handles.ViewStart;
end

handles.ltsaData = [];
handles.markers = 0;
repeat = 0;
shipTimes = handles.shipTimes;

while(size(handles.ltsaData,2) < floor(handles.PlotLengthVal*60*60/handles.ltsa.tave))...
        && (viewStart > 0)
    
    % Read the ltsa data portion of the file
    ltsaData = sh_read_ltsadata(handles,shipTimes(viewStart,1),shipTimes(viewStart,2));
    
    % concatenate data in reverse
    handles.ltsaData = [ltsaData,handles.ltsaData];
    
    reverseLengthIndex = size(handles.ltsaData,2);
    handles.markers = [0,handles.markers+size(ltsaData,2)];
    viewStart = viewStart-1;
    
    % remove data exciding window size
    if reverseLengthIndex > floor((handles.PlotLengthVal*60*60)/handles.ltsa.tave)
        remove = reverseLengthIndex - ...
            floor((handles.PlotLengthVal*60*60)/handles.ltsa.tave);
        handles.ltsaData = handles.ltsaData(:,1:end-remove);
        repeat = 1;
    end
end
handles.ViewStart = viewStart+1;
handles.j = handles.ViewEnd+1;

% show cutted detection from previous window in the next window
if repeat
    handles.j = handles.j-1;
end

% update text
set(handles.percent_completed,'String',round(handles.ViewEnd/size(handles.shipTimes,1)*100))
handles.marker_count = handles.marker_count+length(handles.markers);

guidata(hObject, handles);
plot_ltsa_Callback(hObject, eventdata, handles)
guidata(hObject, handles);



% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.brightness = get(hObject,'Value');
guidata(hObject,handles);
plot_ltsa_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in listen_selection.
function listen_selection_Callback(hObject, eventdata, handles)
% hObject    handle to play_audio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

coordinates = ginput(2);
round(coordinates);

[~, k2] = find(handles.markers/handles.OverlapVal > coordinates(1,1));
[~, k4] = find(handles.markers/handles.OverlapVal <= coordinates(2,1));

%added so that Amanda can see exact time of audio that's playing:
k5 = intersect(k2-1,k4);
datestr(handles.shipTimes(handles.ViewStart+k5(1)-1,4))
datestr(handles.shipTimes(handles.ViewStart+k5(end),4))

if(handles.filter == 1)
    % Apply a band pass filter
    lower_freq = coordinates(1,2)/handles.FFTLVal*handles.ltsa.fs;
    upper_freq = coordinates(2,2)/handles.FFTLVal*handles.ltsa.fs;
    
    fs = handles.ltsa.fs; % sampling rate
    
    F = [lower_freq-50, lower_freq, upper_freq, upper_freq+50];  % band limits
    A = [0 1 0];                % band type: 0='stop', 1='pass'
    dev = [0.0001, 10^(0.1/20)-1, 0.0001]; % ripple/attenuation spec
    [M,Wn,beta,typ] = kaiserord(F,A,dev,fs);  % window parameters
    b = fir1(M,Wn,typ,kaiser(M+1,beta),'noscale'); % filter design
    DATA = filter(b,1,handles.AudioData(coordinates(1,1)*...
        handles.OverlapVal:coordinates(2,1)...
        *handles.OverlapVal));
    
    handles.dim_coords = [floor(coordinates(1,2)),floor(coordinates(2,2))];
    
    plot_ltsa_Callback(hObject, eventdata, handles)
    
    if(handles.speedup==1)
        soundsc(DATA,5*handles.ltsa.fs);
    else
        soundsc(DATA,handles.ltsa.fs);
    end
    handles.dim_coords=0;
    plot_ltsa_Callback(hObject, eventdata, handles)
    
else
    
    if(handles.speedup==1)
        soundsc(handles.AudioData(coordinates(1,1)*handles.OverlapVal:coordinates(2,1)*handles.OverlapVal),5*handles.ltsa.fs);
    else
        soundsc(handles.AudioData(coordinates(1,1)*handles.OverlapVal:coordinates(2,1)*handles.OverlapVal),handles.ltsa.fs);
    end
end

guidata(hObject,handles);



% --- Executes on button press in all_ship.
function all_ship_Callback(hObject, eventdata, handles)
% hObject    handle to all_ship (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.shipLabels(handles.ViewStart:handles.ViewEnd) = {'ship'};
shipLabels = handles.shipLabels;
save(strcat([handles.DetectionFilePath,handles.DetectionFile]), 'shipLabels','-append')

guidata(hObject,handles);
plot_ltsa_Callback(hObject, eventdata, handles)


% --- Executes on button press in all_no_ship.
function all_no_ship_Callback(hObject, eventdata, handles)
% hObject    handle to all_no_ship (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.shipLabels(handles.ViewStart:handles.ViewEnd) = {'ambient'};
shipLabels = handles.shipLabels;
save(strcat([handles.DetectionFilePath,handles.DetectionFile]), 'shipLabels','-append')

guidata(hObject,handles);
plot_ltsa_Callback(hObject, eventdata, handles)


function initialize_buttons(src, eventdata, handles, hObject)
%this function takes in two inputs by default

%src is the gui figure
%evnt is the keypress information

%this line brings the handles structures into the local workspace
%now we can use handles.cats in this subfunction!

handles = guidata(src);
hObject = handles.output;
%switch evnt.Key
switch eventdata.Key
    case 'leftarrow'
        motion_backwards_Callback(hObject, eventdata, handles)
    case 'rightarrow'
        motion_forwards_Callback(hObject, eventdata, handles)
    case 'y'
        all_ship_Callback(hObject, eventdata, handles)
    case 'n'
        all_no_ship_Callback(hObject, eventdata, handles)
    case 'a'
        subset_ship_Callback(hObject, eventdata, handles)
    case 'm'
        listen_selection_Callback(hObject, eventdata, handles)
        
    case 'escape'
end;


% --------------------------------------------------------------------
function detection_file_ClickedCallback(hObject, eventdata, handles)
% Choose folder of detection_file files to be reviewed, and specify start file
% hObject    handle to detection_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName,FilterIndex] = uigetfile('.mat',...
    'Select detection file');

if FilterIndex >0
    fprintf('Selected detection file %s\n',FileName)
    handles.DetectionFile = FileName;
    handles.DetectionFilePath = PathName;
    
    load([PathName,handles.DetectionFile]);
    handles.shipTimes = shipTimes;
    handles.shipLabels = shipLabels;
    handles.settingsRemora = settings;
    set(handles.detection_filename,'String',handles.DetectionFile)
    guidata(hObject,handles);
else
    error('No detection file selected. \n')
end

% --------------------------------------------------------------------
function ltsa_file_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to ltsa_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName,FilterIndex] = uigetfile('.ltsa',...
    'Select LTSA file');

% make sure detection_file has been selected
if ~isfield(handles,'DetectionFile')
    error('Please select a detection file first')
end

% find if detection file matches ltsa file
if FilterIndex > 0
    fprintf('Evaluation detections from LTSA file %s\n',FileName)
    targetFileName = strrep(FileName,'.ltsa','');
    match = strfind(handles.DetectionFile,targetFileName);
    if isempty(match)
        error('Selected LTSA file (%s)\n does not match detection file (%s)\n',handles.LtsaFile,handles.DetectionFile)
    else
        handles.LtsaFile = FileName;
        handles.LtsaPath = PathName;
        fprintf('Selected LTSA file (%s)\n matches detection file (%s)\n',handles.LtsaFile,handles.DetectionFile)
        
        % read LTSA header
        [handles.ltsa, handles.ltsahd] = sh_read_ltsahead(handles);
    end
    set(handles.start_freq,'String',handles.ltsa.freq0)
    set(handles.end_freq,'String',handles.ltsa.freq1)
    %     start_freq_Callback(hObject, eventdata, handles)
    %     end_freq_Callback(hObject, eventdata, handles)
    handles.StartFreqVal = str2double(get(handles.start_freq,'String'));
    handles.EndFreqVal = str2double(get(handles.end_freq,'String'));
    guidata(hObject,handles);
else
    error('No LTSA file selected. \n')
end


% --------------------------------------------------------------------
function wave_file_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to wave_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PathName = uigetdir('','Select base folder of audio files');

% make sure detection_file file has been selected
if ~isfield(handles,'DetectionFile')
    error('Please select a detection file first')
end

% Search folder and subfolders for audio files
if PathName~=0
    dirList = dir(PathName); %are there subfolders?
    dirList = dirList(3:end);
    wavEnding = strfind({dirList.name},'.wav');
    wavFileFlag = ~cellfun(@isempty,wavEnding);
    fileList = [];
    if sum(wavFileFlag)>0
        fileList = dirList(~cellfun(@isempty,wavEnding));
        for iFile0 = 1:length(fileList)
            fileList(iFile0).pathName = fullfile(PathName);
        end
    end
    for iDir = 1:length(dirList)
        if dirList(iDir).isdir
            subDirList = dir(fullfile(PathName,dirList(iDir).name));
            wavEnding = strfind({subDirList.name},'.wav');
            newFileSet = subDirList(~cellfun(@isempty,wavEnding));
            for iFile = 1:length(newFileSet)
                newFileSet(iFile).pathName = fullfile(PathName,dirList(iDir).name);
            end
            fileList = [fileList;newFileSet];
        end
    end
    %addpath(PathName);
    handles.WaveFileList = fileList;
    targetFileName = strrep(handles.DetectionFile,'.mat','');
    findUscores = strfind(targetFileName,'_');
    matchNameTF = strfind({fileList(:).name},targetFileName);
    audioIdx = find(~cellfun(@isempty,matchNameTF));
    if isempty(audioIdx)
        error('No audio file found to match detection file %s\n',handles.DetectionFile)
    else
        handles.WaveFile = fullfile(fileList(audioIdx).pathName,fileList(audioIdx).name);
        handles.CurrentWavIdx = audioIdx;
        fprintf('Found matching wav file %s\n',handles.WaveFile)
        
    end
    guidata(hObject,handles);
else
    fprintf('No audio file folder selected.\n')
end
%%

% --- Executes on button press in subset_ship.
function subset_ship_Callback(hObject, eventdata, handles)
% hObject    handle to subset_ship (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('Labeling %0.0f detections as TRUE.\n',...
    handles.ViewEnd-handles.ViewStart)
handles.shipTimes(handles.ViewStart:handles.ViewEnd,3)=1;

shipTimes = handles.shipTimes;
save(strcat([handles.DetectionFilePath,handles.DetectionFile]), 'shipTimes','-append')
guidata(hObject,handles);

motion_forwards_Callback(hObject, eventdata, handles)


function start_detection_Callback(hObject, eventdata, handles)
% hObject    handle to start_detection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.MarkerNumberVal = str2double(get(handles.start_detection,'String'));
handles.ViewStart = handles.MarkerNumberVal;
handles.replot = 1;
motion_forwards_Callback(hObject, 1, handles)
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function start_detection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start_detection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

handles.start_detection = get(hObject,'Value');

guidata(hObject,handles);


% --- Executes on button press in subset_no_ship.
function subset_no_ship_Callback(hObject, eventdata, handles)
% hObject    handle to subset_no_ship (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

coordinates = ginput(2);
handles.value_mark = str2double(get(handles.start_detection,'String'));

% identify which detections were picked
[~, k2] = find(handles.markers/handles.OverlapVal > coordinates(1,1));
[~, k4] = find(handles.markers/handles.OverlapVal <= coordinates(2,1));

k5 = intersect(k2-1,k4);
% Flag them as zeros
fprintf('Flagging %.0f detection(s) as false.\n',length(k5))
handles.shipTimes(handles.ViewStart+k5-1,3) = 0;

shipTimes = handles.shipTimes;
save(strcat([handles.DetectionFilePath,handles.DetectionFile]), 'shipTimes','-append')
guidata(hObject,handles);

plot_ltsa_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes during object creation, after setting all properties.
function detection_filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to detection_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function ltsa_filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ltsa_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
