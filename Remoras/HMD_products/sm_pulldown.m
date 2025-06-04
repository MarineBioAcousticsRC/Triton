function sm_pulldown(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sm_pulldown.m
% initializes pulldowns for soundscape metrics calculation (when you click
% on the soundscape remora what are your options?)
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS REMORA HANDLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(action, 'make_ltsa') % make LTSA
    sm_setpointers('watch');
    
    sm_ltsa_settings_init;
    
    REMORA.sm.ltsa = PARAMS.ltsa;
    if ~isfield(REMORA,'fig')
        REMORA.fig = [];
    end
    
    %initialize ltsa parameters
    sm_ltsa_params_window;
    
    sm_setpointers('arrow');
        
elseif strcmp(action,'compute_metrics') % compute soundscape metrics
    % dialog box - compute metrics
    sm_setpointers('watch');
    
    sm_cmpt_settings_init;
    
    if ~isfield(REMORA,'fig')
        REMORA.fig = [];
    end
    
    %initialize ltsa parameters
    sm_cmpt_params_window;
    
    sm_setpointers('arrow');
    
elseif strcmp(action,'load_ltsa') % load ltsa
    
    % reset default of standard LTSA plot length to SanctSound data length
    PARAMS.ltsa.tseg.hr = 0.5;
    PARAMS.ltsa.tseg.sec = 0.5 * 60 * 60;
    PARAMS.ltsa.bright = 50;
    
    %initialize ltsa plotting functionality
    sm_initcontrol
    
    % user interface retrieve file to open through a dialog box
    boxTitle1 = 'Open LTSA File';
    filterSpec1 = '*.ltsa';
    [PARAMS.ltsa.infile,PARAMS.ltsa.inpath]=uigetfile(filterSpec1,boxTitle1);
    % if the cancel button is pushed, then no file is loaded so exit this script
    if strcmp(num2str(PARAMS.ltsa.infile),'0')
        PARAMS.ltsa.inpath = '';
        PARAMS.ltsa.infile = '';
        return
    else % give user some feedback
        disp_msg('Opened File: ')
        disp_msg([PARAMS.ltsa.inpath,PARAMS.ltsa.infile])
        cd(PARAMS.ltsa.inpath)
    end
    
    % calculate the number of blocks in the opened file
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    PARAMS.ltsa.ftype = 1;
    if(get(HANDLES.display.ltsa,'Value'))
        if get(HANDLES.mc.on,'Value') || get(HANDLES.mc.lock, 'Value')
            set(HANDLES.mc.on,'Value', 0)
            set(HANDLES.mc.lock,'Value', 0)
        end
    end
    set(HANDLES.display.ltsa,'Visible','on')
    set(HANDLES.display.ltsa,'Value',1);
    set(HANDLES.ltsa.delimit.but,'Visible','on')
    sm_control_ltsa('button')
    set([HANDLES.ltsa.motion.seekbof HANDLES.ltsa.motion.back HANDLES.ltsa.motion.autoback HANDLES.ltsa.motion.stop],...
        'Enable','off');
    sm_init_ltsadata
    sm_read_ltsadata
    PARAMS.plot.dnum = PARAMS.ltsa.plot.dnum;
    plot_triton
    %if link axes is on, lock all the axes zoom in together
    if get(HANDLES.mc.lock, 'Value') && get(HANDLES.mc.on,'Value')
        fig_hand = get(HANDLES.plot1,'Parent');
        all_hands = findobj(fig_hand, 'type', 'axes', 'tag', '');
        %add one for savalue so ltsa axis doesn't get linked
        all_hands (PARAMS.ch + 1) = 0;
        linkaxes(all_hands,'x');
    end
    sm_control_ltsa('timeon')   % was timecontrol(1)
    % turn on other menus now
    sm_control_ltsa('menuon')
    sm_control_ltsa('ampon')
    sm_control_ltsa('freqon')
    set(HANDLES.ltsa.motioncontrols,'Visible','on')
    set(HANDLES.ltsa.equal,'Visible','on')
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');


elseif strcmp(action,'plot_metrics') % plot soundscape metrics (not implemented yet)
    % dialog box - compute metrics
    sm_setpointers('watch');
    
    REMORA.sm.mkltsa_params = sm_init_mkltsa_settings; %load default settings
    % dialog box - make ltsa
    if ~isfield(REMORA,'fig')
        REMORA.fig = [];
    end
    

    sm_init_metrics_params_window
    
    % set up to open gui window for batch detector
    sm_init_batch_figure
    sm_init_settings
    
    % set up all default settings to motion gui
    sm_init_batch_gui
    sm_settings_to_sec
    
    sm_setpointers('arrow');

end


function sm_setpointers(icon)
global HANDLES
set(HANDLES.fig.ctrl, 'Pointer', icon);
set(HANDLES.fig.main, 'Pointer', icon);
set(HANDLES.fig.msg, 'Pointer', icon);

% function update_window_settings
% global HANDLES REMORA
% set(HANDLES.ltsa.time.edtxt3,'string',REMORA.sh.settings.durWind)
% set(HANDLES.ltsa.time.edtxt4,'string',REMORA.sh.settings.slide)
% control_ltsa('newtseg') %change Triton plot length
% control_ltsa('newtstep') %change Triton time step 
% % bring motion gui to front
% figure(REMORA.fig.sh.motion);



