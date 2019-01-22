function dtpd(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% dtpd.m
% initializes pulldowns for detector
%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES PARAMS DATA REMORA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dialog box - interactive spectrogram detector 
if strcmp(action, 'xwav')
    setpointers('watch');
    
    if ~isfield(REMORA.fig, 'dt') % if figure name hasn't been create
        dt_initwins;
        dt_initcontrol;
    else
        % if the name exists, is it an active figure handle?
        if ~ishandle(REMORA.fig.dt) 
            dt_initwins;
            dt_initcontrol;
            
            % Detection Parameters pulldown 
            % make sure that the save/load params pd is recreated after
            % closing/reopening interactive detector
            REMORA.dt.fig.filemenu = uimenu(REMORA.fig.dt,'Label','Save/Load Params',...
                'Enable','on','Visible','on');

            % Spectrogram load/save params
            uimenu(REMORA.dt.fig.filemenu,'Label','&Load Specgram ParamFile',...
                'Callback','dt_paramspd(''STparamload'')');
            uimenu(REMORA.dt.fig.filemenu,'Label','&Save Specgram ParamFile',...
                'Callback','dt_paramspd(''STparamsave'')');
            
        end
    end
     
    if isfield(PARAMS, 'xhd')
        set(REMORA.dt.MinBBFreqEdtxt, 'Enable', 'on');
        set(REMORA.dt.MaxBBFreqEdtxt, 'Enable', 'on');
    end
    
    set(REMORA.fig.dt,'Visible','on');
    
    setpointers('arrow');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dialog box - short time spectrum detection
elseif strcmp(action,'dtShortTimeDetection')
    setpointers('watch');
    dtShortTimeDetector;
    setpointers('arrow');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dialog box ST guided 3rd level search
% Finds clicks with high resolution based upon coarse
% location.
elseif strcmp(action,'dtST_GuidedHRClickDet')
    setpointers('watch');
    dtST_GuidedHiResDetector;
    %dtST_GuidedHRClickDet;
    setpointers('arrow');
    
elseif strcmp(action,'dtST_GuidedHRClickDet_v2')
	setpointers('watch');
    dtST_GuidedHiResDetector_v2;
    setpointers('arrow');

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dialog box - short time --> Hi res v1
elseif strcmp(action, 'dt_procStream')
    setpointers('watch');
    dtProcStream;
    setpointers('arrow');
elseif strcmp(action, 'dt_procStreamv2')
    setpointers('watch');
    dtProcStream_v2;
    setpointers('arrow');
end


function setpointers(icon)
global HANDLES
set(HANDLES.fig.ctrl, 'Pointer', icon);
set(HANDLES.fig.main, 'Pointer', icon);
set(HANDLES.fig.msg, 'Pointer', icon);
