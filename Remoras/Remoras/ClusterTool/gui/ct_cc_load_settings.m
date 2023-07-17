function ct_cc_load_settings

global REMORA
[~,~,fileType] = fileparts(REMORA.ct.CC_settings.paramFile);
% Input could be a .m file or a .mat file
if strcmp(fileType,'.mat')
    % it's a mat file, so load it
    loadedVars = load(fullfile(REMORA.ct.CC_settings.paramPath,REMORA.ct.CC_settings.paramFile));
    REMORA.ct.CC_params = loadedVars.s;
    ct_init_compClust_window

elseif strcmp(fileType,'.m')
    currentFolder = pwd; % store original dir
    cd(fullfile(REMORA.ct.CC_settings.paramPath)) %change just to run
    run(REMORA.ct.CC_settings.paramFile)
    REMORA.ct.CC_params = s;
    cd(currentFolder) % point back to original dir
    ct_init_compClust_window
else
    error('Unknown input file type. Expecting .mat or .m')
end

