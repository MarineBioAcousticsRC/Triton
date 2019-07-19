function ship_dt_pd(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ship_dt_pd.m
% initializes pulldowns for detector
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS REMORA HANDLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dialog box - interactive spectrogram detector
if strcmp(action, 'interactive')
    if isempty(PARAMS.ltsa.infile)
        % no data loaded, display message to load data.
        disp_msg('Please load ltsa file before launching detector gui')
        return
    end
    ship_setpointers('watch');
    
    warning('Under construction')
%     ship_dt_initparams
%     ship_dt_initwins;
%     ship_dt_initcontrol;

    set(REMORA.fig.ship_dt,'Visible','on');
    
    ship_setpointers('arrow');
        
elseif strcmp(action,'full_detector')
    % dialog box - run full detector
    ship_setpointers('watch');
    ui_get_detector_settings
%     dtLTSAShipDetector;
    %in some point will do it like the spice detector
%     ui_select_detector_settings;
    ship_setpointers('arrow');

elseif strcmp(action,'create_labels')
    ship_setpointers('watch');
    fn_createShipLabels
    ship_setpointers('arrow');
    
elseif strcmp(action,'load_labels')
    [basename, path] = uigetfile('*.tlab', 'Set detection label file');
    % if canceled button pushed:
    if strcmp(num2str(basename),'0')
        return
    end
    file = fullfile(path, basename);
    if ~ exist(file,'file')
        disp_msg(sprintf('Detection file %s does not exist', file));
    else
        [Starts, Stops, Labels] = ioReadLabelFile(file, 'Binary', true);
        REMORA.ship_dt.class.starts = Starts;
        REMORA.ship_dt.class.stops = Stops;
        REMORA.ship_dt.class.labels = Labels;
        REMORA.ship_dt.class.files = {file}; % May want to add display
                                        % filename later on...
        REMORA.ship_dt.ValidLabels = true;
        REMORA.ship_dt.PlotLabels = true; % Assume they want to see them.
        set(REMORA.ship_dt.labelplot, 'Checked', 'on');
        disp_msg(sprintf('Detection file %s read', file));
    end
    dt_plotLabels;
%     plot_triton;        % Replot showing labels

elseif strcmp(action, 'display_labels')
    if PARAMS.dt.class.ValidLabels
        % toggle plot status & flag
        if PARAMS.dt.class.PlotLabels
            set(REMORA.ship_dt.labelplot, 'Checked', 'off');
        else
            set(REMORA.ship_dt.labelplot, 'Checked', 'on');
        end
        PARAMS.dt.class.PlotLabels = ~ PARAMS.dt.class.PlotLabels;
        plot_triton;   % Replot with/without labels
    else
        ship_dt_pd('load_labels');        % No valid label set, ask for one
    end
elseif strcmp(action,'evaluate_detections')
%     sp_dt_mkTPWS_gui
    warning('Under construction')
end


function ship_setpointers(icon)
global HANDLES
set(HANDLES.fig.ctrl, 'Pointer', icon);
set(HANDLES.fig.main, 'Pointer', icon);
set(HANDLES.fig.msg, 'Pointer', icon);
