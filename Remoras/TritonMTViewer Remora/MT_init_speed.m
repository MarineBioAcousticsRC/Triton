function MT_init_speed

global out strt data T
data = [] ;
T = [] ;
ask = inputdlg('Import MT Aux data? Y or N','Import.MT Data?') ;
if strcmp(ask{1},'y')||strcmp(ask{1},'Y')
    [handles.out, handles.strt] = MT2MAT_PC() ;
elseif strcmp(ask{1},'N')||strcmp(ask{1},'n')
    if ~isfield(handles,'out')
        try
            out = evalin('base','out');
            strt = evalin('base','strt');
            handles.out = out;
            handles.strt = strt;
         catch
            fprintf('Too bad.\n') ;
            [handles.out, handles.strt] = MT2MAT_PC() ;
            out = handles.out;
            strt = handles.strt;
            assignin('base','out',out)
            assignin('base','strt',strt)
        end
    else
        fprintf('ok, using previously loaded AUX data.\n');
    end
end

MT_init_settings;
MT_speed_gui;
end