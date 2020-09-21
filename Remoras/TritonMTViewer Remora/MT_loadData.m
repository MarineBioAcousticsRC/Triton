function MT_loadData
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
MT_init_settings;
MT_speed_gui;
REMORA.TritonMTViewer = uimenu(HANDLES.remmenu,'Label','TritonMTViewer', ...
                       'Callback', 'TritonMTViewer_gui1');
                   
end
%PlotMTdata(handles)
