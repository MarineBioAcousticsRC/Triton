function ct_cb_load_settings

global REMORA
[~,~,fileType] = fileparts(REMORA.ct.CB_settings.paramFile);
% Input could be a .m file or a .mat file
if strcmp(fileType,'.mat')
    % it's a mat file, so load it
    loadedVars = load(fullfile(REMORA.ct.CB_settings.paramPath,REMORA.ct.CB_settings.paramFile));
    if isfield(loadedVars,'p')
        REMORA.ct.CB_params = loadedVars.p;
    else
        error('file does not contain the expected parameters')
    end
    ct_init_clusterbins_batch_window

elseif strcmp(fileType,'.m')
    currentFolder = pwd; % store original dir
    cd(fullfile(REMORA.ct.CB_settings.paramPath)) %change just to run
    run(REMORA.ct.CB_settings.paramFile)
    REMORA.ct.CB_params = p;
    cd(currentFolder) % point back to original dir
    ct_init_clusterbins_batch_window
else
    error('Unknown input file type. Expecting .mat or .m')
end

