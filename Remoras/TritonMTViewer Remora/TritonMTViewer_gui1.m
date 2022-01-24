function varargout = TritonMTViewer_gui1(varargin)
% TRITONMTVIEWER_GUI1 MATLAB code for TritonMTViewer_gui1.fig
%      TRITONMTVIEWER_GUI1, by itself, creates a new TRITONMTVIEWER_GUI1 or raises the existing
%      singleton*.
%
%      H = TRITONMTVIEWER_GUI1 returns the handle to a new TRITONMTVIEWER_GUI1 or the handle to
%      the existing singleton*.
%
%      TRITONMTVIEWER_GUI1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRITONMTVIEWER_GUI1.M with the given input arguments.
%
%      TRITONMTVIEWER_GUI1('Property','Value',...) creates a new TRITONMTVIEWER_GUI1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TritonMTViewer_gui1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TritonMTViewer_gui1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TritonMTViewer_gui1

% Last Modified by GUIDE v2.5 02-Jul-2019 12:48:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @TritonMTViewer_gui1_OpeningFcn, ...
    'gui_OutputFcn',  @TritonMTViewer_gui1_OutputFcn, ...
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


% --- Executes just before TritonMTViewer_gui1 is made visible.
function varargout = TritonMTViewer_gui1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TritonMTViewer_gui1 (see VARARGIN)

% Choose default command line output for TritonMTViewer_gui1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global out strt data T
data = [] ;
T = [] ;
ask = inputdlg('Import MT Aux data? Y or N','Import.MT Data?') ;
if strcmp(ask{1},'y')||strcmp(ask{1},'Y')
    [handles.out, handles.strt] = MT2MAT_PC() ;
    guidata(hObject, handles);
elseif strcmp(ask{1},'N')||strcmp(ask{1},'n')
    if ~isfield(handles,'out')
        try
            out = evalin('base','out');
            strt = evalin('base','strt');
            handles.out = out;
            handles.strt = strt;
            guidata(hObject, handles);
        catch
            fprintf('Too bad.\n') ;
            [handles.out, handles.strt] = MT2MAT_PC() ;
            guidata(hObject , handles);
            out = handles.out;
            strt = handles.strt;
            assignin('base','out',out)
            assignin('base','strt',strt)
        end
    else
        fprintf('ok, using previously loaded AUX data.\n');
    end
end



varargout{1} = handles.out;
varargout{2} = handles.strt;
handles.data = [];
PlotMTdata(handles)
% % load('E:\test\Global T\FullData.mat')
load global T


% UIWAIT makes TritonMTViewer_gui1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TritonMTViewer_gui1_OutputFcn(hObject, eventdata, handles)
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
function text1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% 
% function dataType(hObject,eventdata,handles)\
% 
% global data T
% c = uicontrol(
% --- Executes on button press in checkbox2.  Log data points

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
    global item_selected 
    % hObject    handle to listbox1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    index_selected = get(hObject,'Value');
    list = get(hObject,'String');
    item_selected = list{index_selected};



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
function checkbox2_Callback(hObject, eventdata, handles)
    % hObject    handle to checkbox2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % clc
    % ax = gca;
    % if get(handles.checkbox2,'Value') == 0
    %         return;
    % elseif get(handles.checkbox2,'Value')
    global data T item_selected all
    %  [handles.out, handles.strt] = MT2MAT_PC() ;
    %  load('E:\test\Global T\global.mat')
    % load global T

    if get(handles.checkbox2,'Value')
        clc
        set(handles.checkbox1,'Value',0)
        %fig = unifigure('selection type',['NBup' 'NBdown' 'breath' 'feeding lunge' 'unknown']);
        %   dd = uidropdown(fig,'selection type',{'NBup' 'NBdown' 'breath' 'feeding lunge' 'unknown'});
        %     disp_msg('Click on an Axis to select points')
        fprintf('[\bClick on an Axis to select points]\b\n')
        %     k = waitforbuttonpress ;
        %     ax = gca ;
        set(gcf, 'pointer', 'arrow');

%         [x, y] = ginputc(1, 'Color', 'b');
        %     [x,y] = ginput(1); % x is time,
        %     set(gcf, 'pointer', 'crosshair');

        %     crossHair(k) = uicontrol(fig, 'Style', 'text', 'Visible', 'off', 'Units', 'pixels', 'BackgroundColor', [1 1 1], 'HandleVisibility', 'off', 'HitTest', 'off');

        %clc
        %     disp_msg('After selection press:')
        %     disp_msg('Backspace/Delete - UNDO,')
        %     disp_msg('Enter - FINISH SELECTION')
        %     fprintf('[\bAfter selection press:\n Backspace/Delete - UNDO\n Enter - FINISH SELECTION]\b\n')

        handles.datanew = [];
        %     if all.press(:,end)<=x || all.temp(:,end)<=x || all.xaccel(:,end)<=x || all.yaccel(:,end)<=x || all.zaccel(:,end)<=x
        %     all.total_time(:,1) = all.press(:,end)
        %     all.total_time(432000,2) = all.temp(432000,2)
        %     all.total_time(:,3) = all.xaccel(:,end)
        %     all.total_time(:,4) = all.yaccel(:,end)
        %     all.total_time(:,5) = all.zaccel(:,end)
        %     all.total_time(:,6) = all.iaccel(:,end)
        %     all.total_time(:,7) = all.jaccel(:,end)
        %     all.total_time(:,8) = all.kaccel(:,end)
        % size(all.temp(:,2))

        %     indx  = find(handles.out(:,9)<=x,1,'last');
        data_type = item_selected;

        if strcmp(data_type,'exhale')==1 || strcmp(data_type,'inhale')==1
            [x, y] = ginputc(1, 'Color', 'b');
            %creates ability to collect second data point for exhale/inhale out
            [x2, y2] = ginputc(1, 'Color', 'r');
            %records data for exhale/inhale in
            data_type = strcat(item_selected,' start');
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

            power = 0;
            freq = 0;


            handles.datanew = vertcat(handles.datanew,{datestr(x,'mmmm dd, yyyy HH:MM:SS.FFF') depth  temp  compass_x  compass_y  compass_z  accel_i  accel_j  accel_k data_type power freq}) ;
            data = handles.datanew ;
            if  isempty(T) == 1
                T = cell2table(data,...
                    'VariableNames',{'x' 'Depth' 'Temp' 'Compass_x' 'Compass_y' 'Compass_z'...
                    'Accel_i' 'Accel_j' 'Accel_k' 'Data_type' 'Power' 'Freq'}) ;
                data = [];
                handles.datanew =[];

            else
                T = [T;data];
                data = [];
                handles.datanew =[];

            end


            %records data for exhale/inhale out
            data_type = strcat(item_selected,' end')
            indx  = find(all.press(:,2)<=x2,1,'last');
            depth  = all.press(indx,1) ;

            indx  = find(all.temp(:,2)<=x2,1,'last');
            temp  = all.temp(indx,1) ;

            indx  = find(all.xaccel(:,2)<=x2,1,'last');
            compass_x  = all.xaccel(indx,1) ;
            compass_y  = all.yaccel(indx,1) ;
            compass_z  = all.zaccel(indx,1) ;

            indx  = find(all.iaccel(:,2)<=x2,1,'last');
            accel_i  = all.iaccel(indx,1) ;
            accel_j  = all.jaccel(indx,1) ;
            accel_k  = all.kaccel(indx,1) ;

            power = 0;
            freq = 0;

            handles.datanew = vertcat(handles.datanew,{datestr(x2,'mmmm dd, yyyy HH:MM:SS.FFF') depth  temp  compass_x  compass_y  compass_z  accel_i  accel_j  accel_k data_type power freq}) ;
            data = handles.datanew ;
            if  isempty(T) == 1
                T = cell2table(data,...
                    'VariableNames',{'x' 'Depth' 'Temp' 'Compass_x' 'Compass_y' 'Compass_z'...
                    'Accel_i' 'Accel_j' 'Accel_k' 'Data_type' 'Power' 'Freq'}) ;
                data = [];
                handles.datanew =[];

            else
                T = [T;data];
                data = [];
                handles.datanew =[];

            end
        elseif strcmp(data_type,'fluke')==1
            while get(handles.checkbox2,'Value') == 1
                [x, y] = ginputc(1, 'Color', 'b');
                
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
                
                power = 0;
                freq = 0;
                
                handles.datanew = vertcat(handles.datanew,{datestr(x,'mmmm dd, yyyy HH:MM:SS.FFF') depth  temp  compass_x  compass_y  compass_z  accel_i  accel_j  accel_k data_type power freq}) ;
                data = handles.datanew ;
                if  isempty(T) == 1
                    T = cell2table(data,...
                        'VariableNames',{'x' 'Depth' 'Temp' 'Compass_x' 'Compass_y' 'Compass_z'...
                        'Accel_i' 'Accel_j' 'Accel_k' 'Data_type' 'Power' 'Freq'}) ;
                    data = [];
                    handles.datanew =[];
                    
                else
                    T = [T;data];
                    data = [];
                    handles.datanew =[];
                    
                end
            end
        else
            [x, y] = ginputc(1, 'Color', 'b');

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

            power = 0;
            freq = 0;

            handles.datanew = vertcat(handles.datanew,{datestr(x,'mmmm dd, yyyy HH:MM:SS.FFF') depth  temp  compass_x  compass_y  compass_z  accel_i  accel_j  accel_k data_type power freq}) ;
            data = handles.datanew ;
            if  isempty(T) == 1
                T = cell2table(data,...
                    'VariableNames',{'x' 'Depth' 'Temp' 'Compass_x' 'Compass_y' 'Compass_z'...
                    'Accel_i' 'Accel_j' 'Accel_k' 'Data_type' 'Power' 'Freq'}) ;
                data = [];
                handles.datanew =[];

            else
                T = [T;data];
                data = [];
                handles.datanew =[];

            end
        end

        %     disp('Time    Depth(m)    Temp(C)    Compass_x    Compass_y    Compass_z    Accel_i    Accel_j    Accel_k')

        %     save('global.mat','T','-append')
        %


        disp(T)
        fprintf('[\bType "global T" to view data table.\nPress Reset Data button to clear data table.]\b\n')
        %     disp_msg('Type "Global T" to view data table.')

        if strcmp(data_type,'fluke')~= 1
            set(handles.checkbox2,'Value',0)
        end
        %     assignin('base','datanew',handles.data)
        %set(get(get(get(hObject,'parent'),'parent')),'Pointer','arrow')
        return
    else
        %set(get(get(get(hObject,'parent'),'parent')),'Pointer','arrow')
        clc
%         set(handles.checkbox2,'Value',0)
%         set(gcf,'Pointer', 'arrow','b')
        return;
    end

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes during object creation, after setting all properties.
function checkbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



    function bselection(source,event)
       disp(['Previous: ' event.OldValue.String]);
       disp(['Current: ' event.NewValue.String]);
       disp('------------------');
    



% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global HANDLES
set(handles.checkbox1,'Value',0)
if get(handles.pushbutton1,'Value')
    handles.index_newstart = 1 ;
    handles.index_newend = 'end' ;
    guidata(hObject, handles);
    PlotMTdata(handles)
end


% --- Executes on button press in pushbutton2. Synch to Triton
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% global HANDLES
% if get(handles.pushbutton2,'Value')
%     [Auxplot_start, Auxplot_end,index_newstart,index_newend,plot_start,data_start] = SyncAUX2TRITON(handles.out);
%     handles.Auxplot_start = Auxplot_start ;
%     handles.Auxplot_end = Auxplot_end ;
%     handles.index_newstart = index_newstart ;
%     handles.index_newend = index_newend ;
%     guidata(hObject, handles);
%     
%     if (Auxplot_start ~= data_start)
%         PlotMTdata(handles)
%     end
global HANDLES sync
if get(handles.pushbutton2,'Value')
    [plot_start,data_start] = SyncAUX2TRITON(handles.out);
    handles.Auxplot_start_p = sync.Auxplot_start_p ;
    handles.Auxplot_end_p = sync.Auxplot_end_p ;
    handles.index_newstart_p = sync.index_newstart_p ;
    handles.index_newend_p = sync.index_newend_p ;
    
    handles.Auxplot_start_t = sync.Auxplot_start_t ;
    handles.Auxplot_end_t = sync.Auxplot_end_t ;
    handles.index_newstart_t = sync.index_newstart_t ;
    handles.index_newend_t = sync.index_newend_t ;
    
    handles.Auxplot_start_x = sync.Auxplot_start_x ;
    handles.Auxplot_end_x = sync.Auxplot_end_x ;
    handles.index_newstart_x = sync.index_newstart_x ;
    handles.index_newend_x = sync.index_newend_x ;
    
    handles.Auxplot_start_i = sync.Auxplot_start_i ;
    handles.Auxplot_end_i = sync.Auxplot_end_i ;
    handles.index_newstart_i = sync.index_newstart_i ;
    handles.index_newend_i = sync.index_newend_i ;
    guidata(hObject, handles);
    
    sync.handles = handles;
    if (sync.Auxplot_start_p ~= data_start)||(sync.Auxplot_start_t ~= data_start)||(sync.Auxplot_start_x ~= data_start)||(sync.Auxplot_start_i ~= data_start)
        PlotMTdata(handles)
    end
    %     if (get(HANDLES.motion.fwd,'Value')||get(HANDLES.motion.back,'Value')||get(HANDLES.motion.autofwd,'Value')||get(HANDLES.motion.autoback,'Value'))
    %
    %     end
end

% --- Executes on button press in checkbox1. Synch to Triton
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% global HANDLES
% [Auxplot_start, Auxplot_end,index_newstart,index_newend,plot_start,data_start] = SyncAUX2TRITON(handles.out);
% handles.Auxplot_start = Auxplot_start ;
% handles.Auxplot_end = Auxplot_end ;
% handles.index_newstart = index_newstart ;
% handles.index_newend = index_newend ;
% guidata(hObject, handles);
% while get(handles.checkbox1,'Value')
%     if (Auxplot_start ~= plot_start)
%         PlotMTdata(handles)
%         return
%     end
% end
global sync 
while get(sync.handles.checkbox1,'Value')
    SyncAUX2TRITON(sync.handles.out);
%     handles.Auxplot_start_p = sync.Auxplot_start ;
%     handles.Auxplot_end_p = Auxplot_end ;
%     handles.index_newstart = index_newstart ;
%     handles.index_newend = index_newend ;
    guidata(hObject, sync);
    PlotMTdataHOLD(sync)
end
% while get(handles.checkbox1,'Value')
%     [Auxplot_start, Auxplot_end,index_newstart,index_newend] = SyncAUX2TRITON(handles.out);
%     handles.Auxplot_start = Auxplot_start ;
%     handles.Auxplot_end = Auxplot_end ;
%     handles.index_newstart = index_newstart ;
%     handles.index_newend = index_newend ;
%     guidata(hObject, handles);
%     PlotMTdata(handles)
% end


% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes during object creation, after setting all properties.
function checkbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% global HANDLES
global T
if get(handles.pushbutton6,'Value')
    load global T
%     [Auxplot_start, Auxplot_end,index_newstart,index_newend,plot_start,data_start] = SyncAUX2TRITON(handles.out);
%     handles.Auxplot_start = Auxplot_start ;
%     handles.Auxplot_end = Auxplot_end ;
%     handles.index_newstart = index_newstart ;
%     handles.index_newend = index_newend ;
%     guidata(hObject, handles);
%     
%     if (Auxplot_start ~= data_start)
%         PlotMTdata(handles)
%     end
%     %     if (get(HANDLES.motion.fwd,'Value')||get(HANDLES.motion.back,'Value')||get(HANDLES.motion.autofwd,'Value')||get(HANDLES.motion.autoback,'Value'))
%     %
    %     end
end


% --- Executes on button press in pushbutton3. Reset Plot
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data T
data = [];
T = [];


% --- Executes on button press in checkbox3. Show Legend
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.checkbox1,'Value',0)

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


% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in pushbutton4. MT to WAV
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mt2wav_PC.m
 


% --- Executes on button press in pushbutton5. Saves data in global T to
% existing  mat.file 
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global T
save global T
% full_data =  T  
% save('E:\test\Global T\FullData.mat','full_data','-append');
% 
% importdata('data.mat')

% filename = 'maria.mat'
% % save('maria.mat','T.x');
% m = matfile(filename,'Writable',true);
% m.x = T.x
% m.p = T.Depth
% m.t = T.Temp


% save('maria.mat','-append','T')
% maria = matfile('maria.mat','Writable',true);
% maria.T = T


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%global return_data
global all item_selected data T 
if get(handles.checkbox4,'Value')
%     plot_start = datenum(all.time+[2000 0 0 0 0 0])
%     plot_tseg = all.rtime * 3600 ; 
%     plot_end = datenum( datevec(plot_start) + [0 0 0 0 0 plot_tseg] );
%     
%ts is the time selected in the spectogram plot
    if strcmp(item_selected,'exhale')==1 || strcmp(item_selected,'inhale')==1 || strcmp(item_selected,'call')==1
        %creates ability to collect second data point for exhale/inhale out
        picktime;
        %records data for exhale/inhale in

        handles.datanew = [];
        ts = datenum(all.time+[2000 0 0 0 0 0])

        indx  = find(all.press(:,2)<=ts,1,'last');
        depth  = all.press(indx,1) ;

        indx  = find(all.temp(:,2)<=ts,1,'last');
        temp  = all.temp(indx,1) ;

        indx  = find(all.xaccel(:,2)<=ts,1,'last');
        compass_x  = all.xaccel(indx,1) ;
        compass_y  = all.yaccel(indx,1) ;
        compass_z  = all.zaccel(indx,1) ;

        indx  = find(all.iaccel(:,2)<=ts,1,'last');
        accel_i  = all.iaccel(indx,1) ;
        accel_j  = all.jaccel(indx,1) ;
        accel_k  = all.kaccel(indx,1) ;
        data_type = strcat(item_selected,' start')

        power = all.pwr;
        freq = all.frequency;


        handles.datanew = vertcat(handles.datanew,{datestr(ts,'mmmm dd, yyyy HH:MM:SS.FFF') depth  temp  compass_x  compass_y  compass_z  accel_i  accel_j  accel_k data_type power freq}) ;
        data = handles.datanew ;
        if  isempty(T) == 1
            T = cell2table(data,...
                'VariableNames',{'x' 'Depth' 'Temp' 'Compass_x' 'Compass_y' 'Compass_z'...
                'Accel_i' 'Accel_j' 'Accel_k' 'Data_type' 'Power' 'Freq'}) ;
            data = [];
            handles.datanew =[];

        else
            T = [T;data];
            data = [];
            handles.datanew =[];

        end
        
        picktime;
        %records data for exhale/inhale in
        ts = datenum(all.time+[2000 0 0 0 0 0])

        indx  = find(all.press(:,2)<=ts,1,'last');
        depth  = all.press(indx,1) ;

        indx  = find(all.temp(:,2)<=ts,1,'last');
        temp  = all.temp(indx,1) ;

        indx  = find(all.xaccel(:,2)<=ts,1,'last');
        compass_x  = all.xaccel(indx,1) ;
        compass_y  = all.yaccel(indx,1) ;
        compass_z  = all.zaccel(indx,1) ;

        indx  = find(all.iaccel(:,2)<=ts,1,'last');
        accel_i  = all.iaccel(indx,1) ;
        accel_j  = all.jaccel(indx,1) ;
        accel_k  = all.kaccel(indx,1) ;
        data_type = strcat(item_selected,' end')

        power = all.pwr;
        freq = all.frequency;


        handles.datanew = vertcat(handles.datanew,{datestr(ts,'mmmm dd, yyyy HH:MM:SS.FFF') depth  temp  compass_x  compass_y  compass_z  accel_i  accel_j  accel_k data_type power freq}) ;
        data = handles.datanew ;
        if  isempty(T) == 1
            T = cell2table(data,...
                'VariableNames',{'x' 'Depth' 'Temp' 'Compass_x' 'Compass_y' 'Compass_z'...
                'Accel_i' 'Accel_j' 'Accel_k' 'Data_type' 'Power' 'Freq'}) ;
            data = [];
            handles.datanew =[];

        else
            T = [T;data];
            data = [];
            handles.datanew =[];

        end
        set(handles.checkbox4,'Value',0)
    else
        picktime;
        handles.datanew =[];

        %records data for exhale/inhale in
        ts = datenum(all.time+[2000 0 0 0 0 0])

        indx  = find(all.press(:,2)<=ts,1,'last');
        depth  = all.press(indx,1) ;

        indx  = find(all.temp(:,2)<=ts,1,'last');
        temp  = all.temp(indx,1) ;

        indx  = find(all.xaccel(:,2)<=ts,1,'last');
        compass_x  = all.xaccel(indx,1) ;
        compass_y  = all.yaccel(indx,1) ;
        compass_z  = all.zaccel(indx,1) ;

        indx  = find(all.iaccel(:,2)<=ts,1,'last');
        accel_i  = all.iaccel(indx,1) ;
        accel_j  = all.jaccel(indx,1) ;
        accel_k  = all.kaccel(indx,1) ;
        data_type = item_selected

        power = all.pwr;
        freq = all.frequency;


        handles.datanew = vertcat(handles.datanew,{datestr(ts,'mmmm dd, yyyy HH:MM:SS.FFF') depth  temp  compass_x  compass_y  compass_z  accel_i  accel_j  accel_k data_type power freq}) ;
        data = handles.datanew ;
        if  isempty(T) == 1
            T = cell2table(data,...
                'VariableNames',{'x' 'Depth' 'Temp' 'Compass_x' 'Compass_y' 'Compass_z'...
                'Accel_i' 'Accel_j' 'Accel_k' 'Data_type' 'Power' 'Freq'}) ;
            data = [];
            handles.datanew =[];

        else
            T = [T;data];
            data = [];
            handles.datanew =[];

        end
        set(handles.checkbox4,'Value',0)
    end
end
% coorddisp_2(return_data)
% Hint: get(hObject,'Value') returns toggle state of checkbox4
