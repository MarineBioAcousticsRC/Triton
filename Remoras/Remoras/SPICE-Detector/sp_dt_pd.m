function sp_dt_pd(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sp_dt_pd.m
% initializes pulldowns for detector
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS REMORA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dialog box - interactive spectrogram detector
if strcmp(action, 'xwav')
    if ~isfield(PARAMS, 'xhd')
        % no data loaded, display message to load data.
        disp_msg('Please load audio data.')
    end
    sp_setpointers('watch');
    
    sp_dt_initparams
    sp_dt_initwins;
    sp_dt_initcontrol;

    set(REMORA.fig.spice_dt,'Visible','on');
    
    sp_setpointers('arrow');
        
elseif strcmp(action,'full_detector')
    % dialog box - run full detector
    sp_setpointers('watch');
    sp_ui_select_detector_settings;
    sp_setpointers('arrow');
    
elseif strcmp(action,'make_TPWS')
    sp_dt_mkTPWS_gui
end


function sp_setpointers(icon)
global HANDLES
set(HANDLES.fig.ctrl, 'Pointer', icon);
set(HANDLES.fig.main, 'Pointer', icon);
set(HANDLES.fig.msg, 'Pointer', icon);
