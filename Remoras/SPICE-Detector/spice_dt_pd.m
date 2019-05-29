function spice_dt_pd(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% spice_dt_pd.m
% initializes pulldowns for detector
%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES PARAMS DATA REMORA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dialog box - interactive spectrogram detector 
if strcmp(action, 'xwav')
    if ~isfield(PARAMS, 'xhd')
        % no data loaded, display message to load data.
        disp_msg('Please load audio data before launching detector gui')
        return
    end
    spice_setpointers('watch');
    
    %if ~isfield(REMORA.fig, 'spice_dt') || ~ishandle(REMORA.fig.spice_dt) % if figure name hasn't been created
        spice_dt_initwins;
        spice_dt_initcontrol;
%     else
%         % if the name exists, is it an active figure handle?
%         if ~ishandle(REMORA.fig.spice_dt) 
%             spice_dt_initwins;
%             spice_dt_initcontrol;
            
%             % Detection Parameters pulldown 
%             % make sure that the save/load params pd is recreated after
%             % closing/reopening interactive detector
%             REMORA.spice_dt.fig.filemenu = uimenu(REMORA.fig.spice_dt,'Label','Save/Load Params',...
%                 'Enable','on','Visible','on');
% 
%             % Spectrogram load/save params
%             uimenu(REMORA.spice_dt.fig.filemenu,'Label','&Load Detector ParamFile',...
%                 'Callback','spice_dt_paramspd(''spice_dt_paramload'')');
%             uimenu(REMORA.spice_dt.fig.filemenu,'Label','&Save Detector ParamFile',...
%                 'Callback','spice_dt_paramspd(''spice_dt_paramsave'')');
%             
%        end
%    end
     
%     if isfield(PARAMS, 'xhd')
%         set(REMORA.spice_dt.MinBBFreqEdtxt, 'Enable', 'on');
%         set(REMORA.spice_dt.MaxBBFreqEdtxt, 'Enable', 'on');
%     end
    
    set(REMORA.fig.spice_dt,'Visible','on');
    
    spice_setpointers('arrow');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dialog box - run full detector
elseif strcmp(action,'full_detector')
    spice_setpointers('watch');
    ui_select_detector_settings;
    spice_setpointers('arrow');

end


function spice_setpointers(icon)
global HANDLES
set(HANDLES.fig.ctrl, 'Pointer', icon);
set(HANDLES.fig.main, 'Pointer', icon);
set(HANDLES.fig.msg, 'Pointer', icon);
