function sh_control_visLabel(action,NFile)

global REMORA HANDLES

% load button
if strcmp(action,'Load')
    % Get detection label file
    [filename, path]= uigetfile('*.tlab','Select detection labels file');
    % if canceled button pushed:
    if strcmp(num2str(filename),'0')
        return
    end
    fileFullPath = fullfile(path, filename);
    
    % Read detection label file and add detection times to remora
    [Starts, Stops, Labels] = sh_read_textFile(fileFullPath, 'Binary', true);
    if strcmp(NFile,'File1')
        REMORA.sh.detection.starts = Starts;
        REMORA.sh.detection.stops = Stops;
        REMORA.sh.detection.labels = Labels;
        % set to display labels
        REMORA.sh.detection.PlotLabels = true;
        set(REMORA.sh_motionLabel.tlab1CheckBox,'Value',1)
        % add file name to gui
        REMORA.sh.detection.files = {filename};
        set(REMORA.sh_motionLabel.tlab1CheckBox,'Enable','on')
        set(REMORA.sh_motionLabel.tlab1CheckBox,'String',filename)
        set(REMORA.sh_motionLabel.tlab1CheckBox,'BackgroundColor',[1 1 1])
        
    elseif strcmp(NFile,'File2')
        REMORA.sh.detection2.starts = Starts;
        REMORA.sh.detection2.stops = Stops;
        REMORA.sh.detection2.labels = Labels;
        REMORA.sh.detection2.files = {filename}; % May want to add display
        % set to display labels
        REMORA.sh.detection2.PlotLabels = true;
        set(REMORA.sh_motionLabel.tlab2CheckBox,'Value',1)
        % add file name to gui
        REMORA.sh.detection2.files = {filename};
        set(REMORA.sh_motionLabel.tlab2CheckBox,'Enable','on')
        set(REMORA.sh_motionLabel.tlab2CheckBox,'String',filename)
        set(REMORA.sh_motionLabel.tlab2CheckBox,'BackgroundColor',[1 .6 .6])
    end
    disp_msg(sprintf('Detection file %s read', fileFullPath));
    % refresh window
    plot_triton
    sh_plot_labels

% display button
elseif strcmp(action,'Display') 
    if strcmp(NFile,'File1')
        enabled = get(REMORA.sh_motionLabel.tlab1CheckBox,'Enable');
        if strcmp(enabled,'on')
            checked = get(REMORA.sh_motionLabel.tlab1CheckBox,'Value');
            if checked
                REMORA.sh.detection.PlotLabels = true;
            else
                REMORA.sh.detection.PlotLabels = false;
            end
        else
            return
        end
    elseif strcmp(NFile,'File2')
        enabled = get(REMORA.sh_motionLabel.tlab2CheckBox,'Enable');
        if strcmp(enabled,'on')
            checked = get(REMORA.sh_motionLabel.tlab2CheckBox,'Value');
            if checked
                REMORA.sh.detection2.PlotLabels = true;
            else
                REMORA.sh.detection2.PlotLabels = false;
            end
        else
            return
        end        
    end
    % refresh window
    plot_triton
    sh_plot_labels
    
% back button
elseif strcmp(action, 'Back')
    motion_ltsa('back');
    sh_plot_labels
    
% forward button
elseif strcmp(action, 'Forward')
    motion_ltsa('forward');
    sh_plot_labels
end

% update enabling of fwd/back buttons
set(REMORA.sh_motionLabel.fwd, 'Enable', ...
    get(HANDLES.ltsa.motion.fwd, 'Enable'));
set(REMORA.sh_motionLabel.back, 'Enable', ...
    get(HANDLES.ltsa.motion.back, 'Enable'));

end