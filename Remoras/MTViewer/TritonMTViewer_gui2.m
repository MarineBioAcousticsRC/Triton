function varargout = TritonMTViewer_gui2(varargin)
% TRITONMTVIEWER_GUI2 MATLAB code for TritonMTViewer_gui2.fig
%      TRITONMTVIEWER_GUI2, by itself, creates a new TRITONMTVIEWER_GUI2 or raises the existing
%      singleton*.
%
%      H = TRITONMTVIEWER_GUI2 returns the handle to a new TRITONMTVIEWER_GUI2 or the handle to
%      the existing singleton*.
%
%      TRITONMTVIEWER_GUI2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRITONMTVIEWER_GUI2.M with the given input arguments.
%
%      TRITONMTVIEWER_GUI2('Property','Value',...) creates a new TRITONMTVIEWER_GUI2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TritonMTViewer_gui2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TritonMTViewer_gui2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TritonMTViewer_gui2

% Last Modified by GUIDE v2.5 12-Sep-2025 10:32:37

%% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @TritonMTViewer_gui2_OpeningFcn, ...
    'gui_OutputFcn',  @TritonMTViewer_gui2_OutputFcn, ...
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

%% --- Executes just before TritonMTViewer_gui2 is made visible.
function varargout = TritonMTViewer_gui2_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TritonMTViewer_gui2 (see VARARGIN)

% Choose default command line output for TritonMTViewer_gui2
handles.output = hObject;


% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global out strt data T Gtable Gpath Gfile
data = [] ;
T = [] ;

prompt1={'Enter tag type (1=Acousonde, 2=DTAG2, 3=DTAG3, 4=XLS)'};
inl = inputdlg(prompt1); flag = str2num(inl{1});
if strcmp(inl,'1')
    [handles.out, handles.strt] = MTPRH2MAT_PC() ;
elseif strcmp(inl,'2')
    [handles.out, handles.strt] = D2PRH2MAT_PC() ;
elseif strcmp(inl,'3')
    [handles.out, handles.strt] = PRH2MAT_PC() ;
elseif strcmp(inl,'4')
    [handles.out, handles.strt] = XLS2MAT_PC() ;
else
    disp('Unknow tag type')
    return
end
guidata(hObject, handles);

varargout{1} = handles.out;
varargout{2} = handles.strt;
handles.data = [];
PlotMTdata(handles)

% --- Outputs from this function are returned to the command line.
function varargout = TritonMTViewer_gui2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.Untitled_1,'Visible','off')

% --- Executes during object creation, after setting all properties.
function axes6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: place code in OpeningFcn to populate axes6

% --- Executes during object creation, after setting all properties.
function axes7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: place code in OpeningFcn to populate axes7

% --- Executes during object creation, after setting all properties.
function axes8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: place code in OpeningFcn to populate axes8

% --- Executes during object creation, after setting all properties.
function axes9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: place code in OpeningFcn to populate axes9

% --- Executes during object creation, after setting all properties.
function checkbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function text1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
%
% function dataType(hObject,eventdata,handles)\

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%initialize
index_selected = get(hObject,'Value');
idx_selected = get(hObject,'Value');
list = get(hObject,'String');
item_selected = list{index_selected};
call_selected = list{idx_selected};

% --- Executes during object creation, after setting all properties.
function checkbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function bselection(source,event)
disp(['Previous: ' event.OldValue.String]);
disp(['Current: ' event.NewValue.String]);
disp('------------------');

%% CHECKBOXES AND BUTTONS
% Executes on button press in checkbox1.
% Log Spec data point
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% handles    structure with handles and user data (see GUIDATA)
global data T item_selected all Gtable Gpath Gfile call_selected
global HANDLES PARAMS
if isempty(Gpath)
    disp('Load Gtable')
    return
else
    save(fullfile([Gpath,'global.mat']),'T')
    save(fullfile([Gpath,Gfile]),'Gtable')
end
if get(handles.checkbox1,'Value')
    clc
    fprintf('[\bClick on an Spectrogram to select points]\b\n')
    figure(HANDLES.fig.main)
    set(gcf, 'pointer', 'arrow');
    handles.datanew = [];
    % determine which plots are active
    savalue = get(HANDLES.display.ltsa,'Value');
    sgvalue = get(HANDLES.display.specgram,'Value');
    wpick = [];
    if savalue && sgvalue
        wpick = input('Pick in LTSA or Sgram? L or S  ','s');
    elseif savalue
        wpick = 'L';
    elseif sgvalue
        wpick = 'S';
    end
    fprintf('[\bReturn to end point selection]\b\n')
    [pickx, pickf] = ginput;

    for ixp = 1:length(pickx)
        if strcmp(wpick,'S')
            xloc = find(pickx(ixp) > PARAMS.t,1,'last');
            floc = find(pickf(ixp) > PARAMS.f,1,'last');
            x = datenum(PARAMS.plot.dvec + [2000 0 0 0 0 pickx(ixp)]);
            power = PARAMS.pwr(floc,xloc);
        elseif strcmp(wpick,'L')
            xloc = find(pickx(ixp) > PARAMS.ltsa.t,1,'last');
            floc = find(pickf(ixp) > PARAMS.ltsa.f,1,'last');
            x = datenum(datevec(PARAMS.ltsa.plot.dnum) + [2000 0 0 pickx(ixp) 0 0]);
            power = PARAMS.ltsa.pwr(floc,xloc);
        end
        freq = pickf(ixp);
        indx  = find(all.press(:,2)<=x,1,'last');
        depth  = all.press(indx,1) ;

        indx  = find(all.temp(:,2)<=x,1,'last');
        temp  = all.temp(indx,1) ;

        indx  = find(all.xaccel(:,2)<=x,1,'last');
        compass_x  = all.xaccel(indx,1) ;
        compass_y  = all.yaccel(indx,1) ;
        compass_z  = all.zaccel(indx,1) ;

        indx  = find(all.iaccel(:,2)<=x,1,'last');
        accel_i  = all.iaccel(indx,1) ;
        accel_j  = all.jaccel(indx,1) ;
        accel_k  = all.kaccel(indx,1) ;

        indx  = find(all.pitch(:,2)<=x,1,'last'); % A.Lloyd adding in PRH
        pitch = all.pitch(indx,1) ;

        indx  = find(all.roll(:,2)<=x,1,'last');
        roll = all.roll(indx,1);

        indx = find(all.azi(:,2)<=x,1,'last');
        azi = all.azi(indx,1);


        if isempty(item_selected)
            data_type  = 'unknown';
        else 
            data_type = item_selected;
        end
        if isempty(call_selected)
            call_type = 'N/A';
        else
            call_type = call_selected;
        end

        xdt = datetime(x,'ConvertFrom','datenum');
        handles.datanew = vertcat(handles.datanew,{xdt depth  temp  compass_x  compass_y  compass_z  accel_i  accel_j  accel_k  pitch roll azi data_type call_type power freq}) ;
    end
    data = handles.datanew ;

    %     disp('Time    Depth(m)    Temp(C)    Compass_x    Compass_y    Compass_z    Accel_i    Accel_j    Accel_k')
    sdata = size(data); sT = 12;
    if sdata(2) < sT
        zt = zeros(sdata(1),sT-sdata(2));
        ztc = num2cell(zt);
        data = [data,ztc];
    end
    T = [T;data];
    %     Gtable = cell2table(T,'VariableNames',{'date','depth','temp','xcomp','ycomp','zcomp',...
    %     'iaccel','jaccel','kaccel','dtype','power','freq'});
    dtable = cell2table(data,'VariableNames',{'date','depth','temp','xcomp','ycomp','zcomp',...
        'iaccel','jaccel','kaccel','pitch','roll','azi','dtype','ctype','power','freq'});
    %         'varTypes',{'datetime','double','double','double','double','double',...
    %         'double','double','double','double','double','double','string','double','double'});
    data = [];
    
    Gtable = [Gtable;dtable];
    % Extract the date column (assuming it's the first column)
    dates = Gtable{:, 1};
    % Sort the dates and get the sorted indices
    [~, sortOrder] = sort(dates);
    % Reorder the whole table using the sorted indices
    Gtable = Gtable(sortOrder, :);

    %     Gtable = sortrows(Gtable,1);

    if get(handles.checkbox4,'Value')
        PlotANNOdata(handles)
    end
    %     disp(T(end,:))
    %     disp('Type "global Gtable" to view data table.')

    set(handles.checkbox1,'Value',0)

    return
else
    clc
    set(gcf,'Pointer', 'arrow','b')
    return;
end

% Select Data Type
% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
global item_selected
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index_selected = get(hObject,'Value');
list = get(hObject,'String');
item_selected = list{index_selected};

% Select Call Type
function listbox2_Callback(hObject, eventdata, handles)
global call_selected
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
idx_selected = get(hObject,'Value');
list = get(hObject,'String');
call_selected = list{idx_selected};


% Log data point
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global data T item_selected all Gtable Gpath Gfile call_selected
if isempty(Gpath)
    disp('Load Gtable')
    return
else
    save(fullfile([Gpath,'global.mat']),'T')
    save(fullfile([Gpath,Gfile]),'Gtable')
end
if get(handles.checkbox2,'Value')
    clc
    fprintf('[\bClick on an AUX plot to select points]\b\n')
    set(gcf, 'pointer', 'arrow');

    fprintf('[\bReturn to end point selection]\b\n')
    [pickx, ~] = ginput;
    handles.datanew = [];

    for ixp = 1:length(pickx)

        indx  = find(all.press(:,2)<=pickx(ixp),1,'last');
        depth  = all.press(indx,1) ;
        
        indx  = find(all.temp(:,2)<=pickx(ixp),1,'last');
        temp  = all.temp(indx,1) ;

        indx  = find(all.xaccel(:,2)<=pickx(ixp),1,'last');
        compass_x  = all.xaccel(indx,1) ;
        compass_y  = all.yaccel(indx,1) ;
        compass_z  = all.zaccel(indx,1) ;

        indx  = find(all.iaccel(:,2)<=pickx(ixp),1,'last');
        accel_i  = all.iaccel(indx,1) ;
        accel_j  = all.jaccel(indx,1) ;
        accel_k  = all.kaccel(indx,1) ;

        indx  = find(all.pitch(:,2)<=pickx(ixp),1,'last'); % A.Lloyd adding in PRH
        pitch = all.pitch(indx,1) ;

        indx  = find(all.roll(:,2)<=pickx(ixp),1,'last');
        roll = all.roll(indx,1);

        indx = find(all.azi(:,2)<=pickx(ixp),1,'last');
        azi = all.azi(indx,1);

        power = 0;
        freq = 0;
        if isempty(item_selected)
            data_type  = 'unknown';
        else 
            data_type  = item_selected;
        end
        if isempty(call_selected)
            call_type = 'N/A';
        else
            call_type = call_selected;
        end

        xdt = datetime(pickx(ixp),'ConvertFrom','datenum');
        handles.datanew = vertcat(handles.datanew,{xdt depth  temp  compass_x  compass_y  compass_z  accel_i  accel_j  accel_k pitch roll azi data_type call_type power freq}) ;
    end
    data = handles.datanew ;

    %     disp('Time    Depth(m)    Temp(C)    Compass_x    Compass_y    Compass_z    Accel_i    Accel_j    Accel_k Pitch Roll Azi')
    sdata = size(data); sT = 13;
    if sdata(2) < sT
        zt = zeros(sdata(1),sT-sdata(2));
        ztc = num2cell(zt);
        data = [data,ztc];
    end
    T = [T;data];
    %     Gtable = cell2table(T,'VariableNames',{'date','depth','temp','xcomp','ycomp','zcomp',...
    %     'iaccel','jaccel','kaccel','dtype','power','freq'});
    dtable = cell2table(data,'VariableNames',{'date','depth','temp','xcomp','ycomp','zcomp',...
        'iaccel','jaccel','kaccel', 'pitch', 'roll','azi','dtype','ctype','power','freq'});
    %         'varTypes',{'datetime','double','double','double','double','double',...
    %         'double','double','double','string','double','double'});
    data = [];
    
    Gtable = [Gtable;dtable];
    % Extract the date column (assuming it's the first column)
    dates = Gtable{:, 1};
    % Sort the dates and get the sorted indices
    [~, sortOrder] = sort(dates);
    % Reorder the whole table using the sorted indices
    Gtable = Gtable(sortOrder, :);

    %     Gtable = sortrows(Gtable,1);
    if get(handles.checkbox4,'Value')
        PlotANNOdata(handles)
    end
    disp(T(end,:))
    disp('Type "global Gtable" to view data table.')

    set(handles.checkbox2,'Value',0)

    return
else
    clc
    set(gcf,'Pointer', 'arrow','b')
    return;
end

% Plot Full Dataset
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global HANDLES
% set(handles.checkbox1,'Value',0)
if get(handles.pushbutton1,'Value')
    handles.index_newstart = 1 ;
    handles.index_newend = 'end' ;
    guidata(hObject, handles);
    PlotMTdata(handles)
end

% Synch to Triton
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SynctoTriton(handles,hObject);
% Load Annotations
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data T Gtable Gpath Gfile PARAMS
% cd '/Volumes/GoogleDrive/Shared drives/MBARC_All/Code/TritonMTViewer Data/Data'
tabin = input('Annotation Table: Input i, Create c  or Ignore x: ','s');
if strcmp(tabin,'i')
    [Gfile,Gpath] = uigetfile('Select GTable file');
    load(fullfile(Gpath,Gfile),'Gtable')
end
if strcmp(tabin,'c')
    sz = [1 16];
    varTypes = ["datetime","double","double","double","double","double",...
        "double","double","double","double","double","double","string","string","double","double"];
    varNames =["date","depth","temp","xcomp","ycomp","zcomp","iaccel","jaccel","kaccel",...
        "pitch","roll","azi","dtype","ctype","power","freq"];
    Gtable = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
    Gtable.date(1) = datetime(PARAMS.ltsa.start.dvec + [2000 0 0 0 0 0]);
    Gtable.dtype(1) = 'None';
    Gtable.ctype(1) = 'None';
    [Gfile, Gpath] = uiputfile('Gtable.mat', 'Save File As');
    save(fullfile([Gpath,'global.mat']),'T')
    save(fullfile([Gpath,Gfile]),'Gtable')
end
% 
data = [];
T = table2cell(Gtable);

% --- Executes on button press in checkbox3.
% Show Legend
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% set(handles.checkbox1,'Value',0)

axes(handles.axes9)
if get(handles.checkbox3,'Value')
    legend('I','J','K','Location','northwest')
else
    legend('hide')
end

axes(handles.axes8)
if get(handles.checkbox3,'Value')
    legend('X','Y','Z','Location','northwest')
else
    legend('hide')
end
%
% % --- Executes on button press in pushbutton4.
% % Convert MT to WAV file
% function pushbutton4_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbutton4 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% mt2wav_PC.m
%

% --- Executes on button press in pushbutton5.
% Saves data in global T to
% existing  global.mat file as cell
% and Gtable table of data
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global T Gtable Gpath Gfile
% save global T
T = table2cell(Gtable);
save(fullfile([Gpath,'global.mat']),'T')
save(fullfile([Gpath,Gfile]),'Gtable')
disp(['Annotations saved to: ',fullfile([Gpath,Gfile])])
%Show Annotations
% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.checkbox4,'Value')
    PlotANNOdata(handles)
else
    disp('Do not display annotations')
end
% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in checkbox6.
% Show Raw Acc/Mag or PRH angles (A.Lloyd)
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6
%code for 
if get(handles.checkbox6,'Value')
    PlotMTdata(handles)
   disp('Display Pitch Roll Heading ')
else
    disp('Display raw acc + mag ')
end


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
