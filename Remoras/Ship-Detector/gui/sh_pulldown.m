function sh_pulldown(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sh_pulldown.m
% initializes pulldowns for ship detector
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
    sh_load_settings
    ship_setpointers('arrow');

% elseif strcmp(action,'create_labels')
%     ship_setpointers('watch');
%     ship_setpointers('arrow');
    
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
        [Starts, Stops, Labels] = sh_read_TLABFile(file, 'Binary', true);
        REMORA.sh.class.starts = Starts;
        REMORA.sh.class.stops = Stops;
        REMORA.sh.class.labels = Labels;
        REMORA.sh.class.files = {file}; % May want to add display
                                        % filename later on...
        REMORA.sh.class.ValidLabels = true;
        REMORA.sh.class.PlotLabels = true; % Assume they want to see them.
%         set(HANDLES.labelplot, 'Checked', 'on');
        disp_msg(sprintf('Detection file %s read', file));
    end
    plot_triton;        % Replot showing labels

elseif strcmp(action, 'display_labels')
    if REMORA.sh.class.ValidLabels
        % toggle plot status & flag
%         if REMORA.sh.class.PlotLabels
%             set(HANDLES.labelplot, 'Checked', 'off');
%         else
%             set(HANDLES.labelplot, 'Checked', 'on');
%         end
        REMORA.sh.class.PlotLabels = ~ REMORA.sh.class.PlotLabels;
        plot_triton;   % Replot with/without labels
    else
        sh_pd('load_labels');        % No valid label set, ask for one
    end
elseif strcmp(action,'evaluate_detections')
    warning('Under construction')
end


function ship_setpointers(icon)
global HANDLES
set(HANDLES.fig.ctrl, 'Pointer', icon);
set(HANDLES.fig.main, 'Pointer', icon);
set(HANDLES.fig.msg, 'Pointer', icon);
