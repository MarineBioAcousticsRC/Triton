function spice_dt_pd(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% spice_dt_pd.m
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
    spice_setpointers('watch');
    
    spice_dt_initparams
    spice_dt_initwins;
    spice_dt_initcontrol;

    set(REMORA.fig.spice_dt,'Visible','on');
    
    spice_setpointers('arrow');
        
elseif strcmp(action,'full_detector')
    % dialog box - run full detector
    spice_setpointers('watch');
    ui_select_detector_settings;
    spice_setpointers('arrow');
    
elseif strcmp(action,'make_TPWS')
    sp_dt_mkTPWS_gui
end


function spice_setpointers(icon)
global HANDLES
set(HANDLES.fig.ctrl, 'Pointer', icon);
set(HANDLES.fig.main, 'Pointer', icon);
set(HANDLES.fig.msg, 'Pointer', icon);
