function lt_lVis_control(action,NFile)

%updates in response to GUI changes

global REMORA HANDLES


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
        
    elseif strcmp(Nfile,'labels4')
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
    end
    
    %refresh window
    plot_triton
    lt_lVis_plotLabels_options
    
elseif strcmp(action,'Display')
    if strcmp(NFile,'labels1')
        enabled = get(REMORA.lt.lVis_labels.label1Check,'Enable');
        if strcmp(enabled,'on')
            checked = get(REMORA.lt.lVis_labels.label1Check,'Value');
            if checked
                REMORA.lt.lVis_det.detection1.PlotLabels = true;
            else
                REMORA.lt.lVis_det.detection1.PlotLabels = false;
            end
        else
            return
        end
        
    elseif strcmp(Nfile,'labels2')
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
        
    elseif strcmp(Nfile,'labels3')
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
        
    elseif strcmp(Nfile,'labels4')
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
    end

%refresh window
plot_triton
lt_lVis_plotLabels_options
        
% back button
elseif strcmp(action, 'TakeItBack')
    motion_ltsa('back');
    lt_lVis_plotLabels_options
    
% forward button
elseif strcmp(action, 'MoveAlong')
    motion_ltsa('forward');
    lt_lVis_plotLabels_options
end

% update enabling of fwd/back buttons
set(REMORA.lt.lVis_labels.fwd, 'Enable', ...
    get(HANDLES.ltsa.motion.fwd, 'Enable'));
set(REMORA.lt.lVis_labels.back, 'Enable', ...
    get(HANDLES.ltsa.motion.back, 'Enable'));

end
    