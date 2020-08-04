function lt_lVis_control(action,NFile)

%updates in response to GUI changes

global REMORA HANDLES PARAMS


if strcmp(action,'LoadLabels')
    % Get detection label file
    [filename, path]= uigetfile('*.tlab','Select detection labels file');
    % if canceled button pushed:
    if strcmp(num2str(filename),'0')
        return
    end
    fileFullPath = fullfile(path, filename);
    
    % Read detection label file and add detection times to remora
    [Starts, Stops, Labels] = lt_lVis_read_textFile(fileFullPath, 'Binary', true);
    % Ensure sorted
    if ~issorted(Starts)
        fprintf('Sorting labels...')
        [Starts, Permutation] = sort(Starts);
        Stops = Stops(Permutation);  % put Stops in new order
        fprintf('complete\n');
    end
    if strcmp(NFile,'labels1')
        REMORA.lt.lVis_det.detection.starts = Starts;
        REMORA.lt.lVis_det.detection.stops = Stops;
        REMORA.lt.lVis_det.detection.labels = Labels;
        % set to display labels
        REMORA.lt.lVis_det.detection.PlotLabels = true;
        set(REMORA.lt.lVis_labels.label1Check,'Value',1)
        % add file name to gui
        REMORA.lt.lVis_det.detection.files = {filename};
        set(REMORA.lt.lVis_labels.label1Check,'Enable','on')
        set(REMORA.lt.lVis_labels.label1Check,'String',filename)
        set(REMORA.lt.lVis_labels.label1Check,'BackgroundColor',[1 1 1])
        
        %initialize empty spots for change labels
        REMORA.lt.lEdit.detection = double.empty(0,3);
        REMORA.lt.lEdit.detectionLab = [];
        
        %calculate LTSA bouts
        %%% shorten detections to bout-level
        boutGap = datenum(0,0,0,0,0,15); %if spacing between start of detections...
        %is less than this, combine into a bout
        [REMORA.lt.lVis_det.detection.bouts.starts,REMORA.lt.lVis_det.detection.bouts.stops] = lt_lVis_defineBouts(...
            REMORA.lt.lVis_det.detection.starts, ...
            REMORA.lt.lVis_det.detection.stops, ...
            boutGap);
        
    elseif strcmp(NFile,'labels2')
        REMORA.lt.lVis_det.detection2.starts = Starts;
        REMORA.lt.lVis_det.detection2.stops = Stops;
        REMORA.lt.lVis_det.detection2.labels = Labels;
        % set to display labels
        REMORA.lt.lVis_det.detection2.PlotLabels = true;
        set(REMORA.lt.lVis_labels.label2Check,'Value',1)
        % add file name to gui
        REMORA.lt.lVis_det.detection2.files = {filename};
        set(REMORA.lt.lVis_labels.label2Check,'Enable','on')
        set(REMORA.lt.lVis_labels.label2Check,'String',filename)
        set(REMORA.lt.lVis_labels.label2Check,'BackgroundColor',[1 1 1])
        
        %initialize empty spots for change labels
        REMORA.lt.lEdit.detection2 = double.empty(0,3);
        REMORA.lt.lEdit.detection2Lab = [];
        
        %calculate LTSA bouts
        %%% shorten detections to bout-level
        boutGap = datenum(0,0,0,0,0,15); %if spacing between start of detections...
        %is less than this, combine into a bout
        [REMORA.lt.lVis_det.detection2.bouts.starts,REMORA.lt.lVis_det.detection2.bouts.stops] = lt_lVis_defineBouts(...
            REMORA.lt.lVis_det.detection2.starts, ...
            REMORA.lt.lVis_det.detection2.stops, ...
            boutGap);
        
    elseif strcmp(NFile,'labels3')
        REMORA.lt.lVis_det.detection3.starts = Starts;
        REMORA.lt.lVis_det.detection3.stops = Stops;
        REMORA.lt.lVis_det.detection3.labels = Labels;
        % set to display labels
        REMORA.lt.lVis_det.detection3.PlotLabels = true;
        set(REMORA.lt.lVis_labels.label3Check,'Value',1)
        % add file name to gui
        REMORA.lt.lVis_det.detection3.files = {filename};
        set(REMORA.lt.lVis_labels.label3Check,'Enable','on')
        set(REMORA.lt.lVis_labels.label3Check,'String',filename)
        set(REMORA.lt.lVis_labels.label3Check,'BackgroundColor',[1 1 1])
        
        %initialize empty spots for change labels
        REMORA.lt.lEdit.detection3 = double.empty(0,3);
        REMORA.lt.lEdit.detection3Lab = [];
        
        %calculate LTSA bouts
        %%% shorten detections to bout-level
        boutGap = datenum(0,0,0,0,0,15); %if spacing between start of detections...
        %is less than this, combine into a bout
        [REMORA.lt.lVis_det.detection3.bouts.starts,REMORA.lt.lVis_det.detection3.bouts.stops] = lt_lVis_defineBouts(...
            REMORA.lt.lVis_det.detection3.starts, ...
            REMORA.lt.lVis_det.detection3.stops, ...
            boutGap);
        
    elseif strcmp(NFile,'labels4')
        REMORA.lt.lVis_det.detection4.starts = Starts;
        REMORA.lt.lVis_det.detection4.stops = Stops;
        REMORA.lt.lVis_det.detection4.labels = Labels;
        % set to display labels
        REMORA.lt.lVis_det.detection4.PlotLabels = true;
        set(REMORA.lt.lVis_labels.label4Check,'Value',1)
        % add file name to gui
        REMORA.lt.lVis_det.detection4.files = {filename};
        set(REMORA.lt.lVis_labels.label4Check,'Enable','on')
        set(REMORA.lt.lVis_labels.label4Check,'String',filename)
        set(REMORA.lt.lVis_labels.label4Check,'BackgroundColor',[1 1 1])
        
        %initialize empty spots for change labels
        REMORA.lt.lEdit.detection4 = double.empty(0,3);
        REMORA.lt.lEdit.detection4Lab = [];
        
        %calculate LTSA bouts
        %%% shorten detections to bout-level
        boutGap = datenum(0,0,0,0,0,15); %if spacing between start of detections...
        %is less than this, combine into a bout
        [REMORA.lt.lVis_det.detection4.bouts.starts,REMORA.lt.lVis_det.detection4.bouts.stops] = lt_lVis_defineBouts(...
            REMORA.lt.lVis_det.detection4.starts, ...
            REMORA.lt.lVis_det.detection4.stops, ...
            boutGap);
        
    elseif strcmp(NFile,'labels5')
        REMORA.lt.lVis_det.detection5.starts = Starts;
        REMORA.lt.lVis_det.detection5.stops = Stops;
        REMORA.lt.lVis_det.detection5.labels = Labels;
        % set to display labels
        REMORA.lt.lVis_det.detection5.PlotLabels = true;
        set(REMORA.lt.lVis_labels.label5Check,'Value',1)
        % add file name to gui
        REMORA.lt.lVis_det.detection5.files = {filename};
        set(REMORA.lt.lVis_labels.label5Check,'Enable','on')
        set(REMORA.lt.lVis_labels.label5Check,'String',filename)
        set(REMORA.lt.lVis_labels.label5Check,'BackgroundColor',[1 1 1])
        
        %initialize empty spots for change labels
        REMORA.lt.lEdit.detection5 = double.empty(0,3);
        REMORA.lt.lEdit.detection5Lab = [];
        
        %calculate LTSA bouts
        %%% shorten detections to bout-level
        boutGap = datenum(0,0,0,0,0,15); %if spacing between start of detections...
        %is less than this, combine into a bout
        [REMORA.lt.lVis_det.detection5.bouts.starts,REMORA.lt.lVis_det.detection5.bouts.stops] = lt_lVis_defineBouts(...
            REMORA.lt.lVis_det.detection5.starts, ...
            REMORA.lt.lVis_det.detection5.stops, ...
            boutGap);
        
    elseif strcmp(NFile,'labels6')
        REMORA.lt.lVis_det.detection6.starts = Starts;
        REMORA.lt.lVis_det.detection6.stops = Stops;
        REMORA.lt.lVis_det.detection6.labels = Labels;
        % set to display labels
        REMORA.lt.lVis_det.detection6.PlotLabels = true;
        set(REMORA.lt.lVis_labels.label6Check,'Value',1)
        % add file name to gui
        REMORA.lt.lVis_det.detection6.files = {filename};
        set(REMORA.lt.lVis_labels.label6Check,'Enable','on')
        set(REMORA.lt.lVis_labels.label6Check,'String',filename)
        set(REMORA.lt.lVis_labels.label6Check,'BackgroundColor',[1 1 1])
        
        %initialize empty spots for change labels
        REMORA.lt.lEdit.detection6 = double.empty(0,3);
        REMORA.lt.lEdit.detection6Lab = [];
        
        %calculate LTSA bouts
        %%% shorten detections to bout-level
        boutGap = datenum(0,0,0,0,0,15); %if spacing between start of detections...
        %is less than this, combine into a bout
        [REMORA.lt.lVis_det.detection6.bouts.starts,REMORA.lt.lVis_det.detection6.bouts.stops] = lt_lVis_defineBouts(...
            REMORA.lt.lVis_det.detection6.starts, ...
            REMORA.lt.lVis_det.detection6.stops, ...
            boutGap);
        
    elseif strcmp(NFile,'labels7')
        REMORA.lt.lVis_det.detection7.starts = Starts;
        REMORA.lt.lVis_det.detection7.stops = Stops;
        REMORA.lt.lVis_det.detection7.labels = Labels;
        % set to display labels
        REMORA.lt.lVis_det.detection7.PlotLabels = true;
        set(REMORA.lt.lVis_labels.label7Check,'Value',1)
        % add file name to gui
        REMORA.lt.lVis_det.detection7.files = {filename};
        set(REMORA.lt.lVis_labels.label7Check,'Enable','on')
        set(REMORA.lt.lVis_labels.label7Check,'String',filename)
        set(REMORA.lt.lVis_labels.label7Check,'BackgroundColor',[1 1 1])
        
        %initialize empty spots for change labels
        REMORA.lt.lEdit.detection7 = double.empty(0,3);
        REMORA.lt.lEdit.detection7Lab = [];
        
        %calculate LTSA bouts
        %%% shorten detections to bout-level
        boutGap = datenum(0,0,0,0,0,15); %if spacing between start of detections...
        %is less than this, combine into a bout
        [REMORA.lt.lVis_det.detection7.bouts.starts,REMORA.lt.lVis_det.detection7.bouts.stops] = lt_lVis_defineBouts(...
            REMORA.lt.lVis_det.detection7.starts, ...
            REMORA.lt.lVis_det.detection7.stops, ...
            boutGap);
        
    elseif strcmp(NFile,'labels8')
        REMORA.lt.lVis_det.detection8.starts = Starts;
        REMORA.lt.lVis_det.detection8.stops = Stops;
        REMORA.lt.lVis_det.detection8.labels = Labels;
        % set to display labels
        REMORA.lt.lVis_det.detection8.PlotLabels = true;
        set(REMORA.lt.lVis_labels.label8Check,'Value',1)
        % add file name to gui
        REMORA.lt.lVis_det.detection8.files = {filename};
        set(REMORA.lt.lVis_labels.label8Check,'Enable','on')
        set(REMORA.lt.lVis_labels.label8Check,'String',filename)
        set(REMORA.lt.lVis_labels.label8Check,'BackgroundColor',[1 1 1])
        
        %initialize empty spots for change labels
        REMORA.lt.lEdit.detection8 = double.empty(0,3);
        REMORA.lt.lEdit.detection8Lab = [];
        
        %calculate LTSA bouts
        %%% shorten detections to bout-level
        boutGap = datenum(0,0,0,0,0,15); %if spacing between start of detections...
        %is less than this, combine into a bout
        [REMORA.lt.lVis_det.detection8.bouts.starts,REMORA.lt.lVis_det.detection8.bouts.stops] = lt_lVis_defineBouts(...
            REMORA.lt.lVis_det.detection8.starts, ...
            REMORA.lt.lVis_det.detection8.stops, ...
            boutGap);
    end
    
    %refresh window
    plot_triton
    %which labels to display
    if HANDLES.display.ltsa.Value
        lt_lVis_plot_LTSA_labels
    end
    
    if HANDLES.display.specgram.Value
        lt_lVis_plot_WAV_labels
    end
    
    if HANDLES.display.timeseries.Value
        lt_lVis_plot_TS_labels
    end
    
    
elseif strcmp(action,'Display')
    if strcmp(NFile,'labels1')
        enabled = get(REMORA.lt.lVis_labels.label1Check,'Enable');
        if strcmp(enabled,'on')
            checked = get(REMORA.lt.lVis_labels.label1Check,'Value');
            if checked
                REMORA.lt.lVis_det.detection.PlotLabels = true;
            else
                REMORA.lt.lVis_det.detection.PlotLabels = false;
            end
        else
            return
        end
        
    elseif strcmp(NFile,'labels2')
        enabled = get(REMORA.lt.lVis_labels.label2Check,'Enable');
        if strcmp(enabled,'on')
            checked = get(REMORA.lt.lVis_labels.label2Check,'Value');
            if checked
                REMORA.lt.lVis_det.detection2.PlotLabels = true;
            else
                REMORA.lt.lVis_det.detection2.PlotLabels = false;
            end
        else
            return
        end
        
    elseif strcmp(NFile,'labels3')
        enabled = get(REMORA.lt.lVis_labels.label3Check,'Enable');
        if strcmp (enabled,'on')
            checked = get(REMORA.lt.lVis_labels.label3Check,'Value');
            if checked
                REMORA.lt.lVis_det.detection3.PlotLabels = true;
            else
                REMORA.lt.lVis_det.detection3.PlotLabels = false;
            end
        else
            return
        end
        
    elseif strcmp(NFile,'labels4')
        enabled = get(REMORA.lt.lVis_labels.label4Check,'Enable');
        if strcmp (enabled,'on')
            checked = get(REMORA.lt.lVis_labels.label4Check,'Value');
            if checked
                REMORA.lt.lVis_det.detection4.PlotLabels = true;
            else
                REMORA.lt.lVis_det.detection4.PlotLabels = false;
            end
        else
            return
        end
        
    elseif strcmp(NFile,'labels5')
        enabled = get(REMORA.lt.lVis_labels.label5Check,'Enable');
        if strcmp (enabled,'on')
            checked = get(REMORA.lt.lVis_labels.label5Check,'Value');
            if checked
                REMORA.lt.lVis_det.detection5.PlotLabels = true;
            else
                REMORA.lt.lVis_det.detection5.PlotLabels = false;
            end
        else
            return
        end
    elseif strcmp(NFile,'labels6')
        enabled = get(REMORA.lt.lVis_labels.label6Check,'Enable');
        if strcmp (enabled,'on')
            checked = get(REMORA.lt.lVis_labels.label6Check,'Value');
            if checked
                REMORA.lt.lVis_det.detection6.PlotLabels = true;
            else
                REMORA.lt.lVis_det.detection6.PlotLabels = false;
            end
        else
            return
        end
    elseif strcmp(NFile,'labels7')
        enabled = get(REMORA.lt.lVis_labels.label7Check,'Enable');
        if strcmp (enabled,'on')
            checked = get(REMORA.lt.lVis_labels.label7Check,'Value');
            if checked
                REMORA.lt.lVis_det.detection7.PlotLabels = true;
            else
                REMORA.lt.lVis_det.detection7.PlotLabels = false;
            end
        else
            return
        end
    elseif strcmp(NFile,'labels8')
        enabled = get(REMORA.lt.lVis_labels.label8Check,'Enable');
        if strcmp (enabled,'on')
            checked = get(REMORA.lt.lVis_labels.label8Check,'Value');
            if checked
                REMORA.lt.lVis_det.detection8.PlotLabels = true;
            else
                REMORA.lt.lVis_det.detection8.PlotLabels = false;
            end
        else
            return
        end
    end
    
    %refresh window
    plot_triton
    %which labels to display
    if HANDLES.display.ltsa.Value
        lt_lVis_plot_LTSA_labels
    end
    
    if HANDLES.display.specgram.Value
        lt_lVis_plot_WAV_labels
    end
    
    if HANDLES.display.timeseries.Value
        lt_lVis_plot_TS_labels
    end
    
    
    % back buttons
elseif strcmp(action, 'TakeItBack')
    motion_ltsa('back');
    lt_lVis_plot_LTSA_labels
    
    if HANDLES.display.specgram.Value
        lt_lVis_plot_WAV_labels
    end
    
    if HANDLES.display.timeseries.Value
        lt_lVis_plot_TS_labels
    end
    
elseif strcmp(action, 'SmallStepBack')
    motion('back');
    if HANDLES.display.specgram.Value
        lt_lVis_plot_WAV_labels
    end
    if HANDLES.display.timeseries.Value
        lt_lVis_plot_TS_labels
    end
    if HANDLES.display.ltsa.Value
        lt_lVis_plot_LTSA_labels
    end
    
elseif strcmp(action, 'PrevDetection')
    motion('prevDet');
    if HANDLES.display.specgram.Value
        lt_lVis_plot_WAV_labels
    end
    if HANDLES.display.timeseries.Value
        lt_lVis_plot_TS_labels
    end
    if HANDLES.display.ltsa.Value
        lt_lVis_plot_LTSA_labels
    end
    
    % forward buttons
elseif strcmp(action, 'MoveAlong')
    motion_ltsa('forward');
    lt_lVis_plot_LTSA_labels
    if HANDLES.display.specgram.Value
        lt_lVis_plot_WAV_labels
    end
    if HANDLES.display.timeseries.Value
        lt_lVis_plot_TS_labels
    end
    
elseif strcmp(action, 'OneStepForward')
    motion('forward');
    if HANDLES.display.specgram.Value
        lt_lVis_plot_WAV_labels
    end
    if HANDLES.display.timeseries.Value
        lt_lVis_plot_TS_labels
    end
    if HANDLES.display.ltsa.Value
        lt_lVis_plot_LTSA_labels
    end
    
elseif strcmp(action, 'NextDetection')
    motion('nextDet');
    if HANDLES.display.specgram.Value
        lt_lVis_plot_WAV_labels
    end
    if HANDLES.display.timeseries.Value
        lt_lVis_plot_TS_labels
    end
    if HANDLES.display.ltsa.Value
        lt_lVis_plot_LTSA_labels
    end
    
elseif strcmp(action, 'NextLTSADetection')
    motion_ltsa('nextDet');
    if HANDLES.display.specgram.Value
        lt_lVis_plot_WAV_labels
    end
    if HANDLES.display.timeseries.Value
        lt_lVis_plot_TS_labels
    end
    if HANDLES.display.ltsa.Value
        lt_lVis_plot_LTSA_labels
    end
    
    
elseif strcmp(action, 'PrevLTSADetection')
    motion_ltsa('prevDet');
    if HANDLES.display.specgram.Value
        lt_lVis_plot_WAV_labels
    end
    if HANDLES.display.timeseries.Value
        lt_lVis_plot_TS_labels
    end
    if HANDLES.display.ltsa.Value
        lt_lVis_plot_LTSA_labels
    end
    
    %refresh buttons
elseif strcmp(action, 'Refresh')
    %which labels to display
    if HANDLES.display.ltsa.Value
        lt_lVis_plot_LTSA_labels
    end
    
    if HANDLES.display.specgram.Value
        lt_lVis_plot_WAV_labels
    end
    
    if HANDLES.display.timeseries.Value
        lt_lVis_plot_TS_labels
    end
end

% update enabling of fwd/back buttons
set(REMORA.lt.lVis_labels.LTSAfwd, 'Enable', ...
    get(HANDLES.ltsa.motion.fwd, 'Enable'));
set(REMORA.lt.lVis_labels.LTSAback, 'Enable', ...
    get(HANDLES.ltsa.motion.back, 'Enable'));
set(REMORA.lt.lVis_labels.nextF_LTSA, 'Enable', ...
    get(HANDLES.ltsa.motion.fwd, 'Enable'));
set(REMORA.lt.lVis_labels.prevF_LTSA, 'Enable', ...
    get(HANDLES.ltsa.motion.back, 'Enable'));

if ~isempty(PARAMS.infile)
    set(REMORA.lt.lVis_labels.RFfwd,'Enable',...
        get(HANDLES.motion.fwd,'Enable'));
    set(REMORA.lt.lVis_labels.nextF,'Enable',...
        get(HANDLES.motion.nextfile,'Enable'));
    set(REMORA.lt.lVis_labels.RFback,'Enable',...
        get(HANDLES.motion.back,'Enable'));
    set(REMORA.lt.lVis_labels.prevF,'Enable',...
        get(HANDLES.motion.prevfile,'Enable'));
end

