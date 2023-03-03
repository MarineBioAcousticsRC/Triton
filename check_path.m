function check_path
% gets Triton path in MATLAB mode and deployed (compiled) mode
% only in MATLAB mode, are paths to various subfolders checked, if not
% present make the subfolders.
% subfolders check here are Remoras and Settings
% other subfolders not used here are Extras, ExampleRemoras
% java subfolder was for old logger and will be removed
%
% Above not executed for deployed (compiled) Triton
%
%

%if settings and java folder are in the search path for Matlab. If
% it is not in there, it is added in
% should also clear remoras to be added when installedRemoras.txt is read
% in...remove this comment when done
global PARAMS

% root directory
if ~isdeployed % standard in MATLAB mode
    PARAMS.path.Triton = fileparts(which('triton'));
else
    PARAMS.path.Triton = pwd;    % for compiled (deployed) version
end

% Settings folder
PARAMS.path.Settings = fullfile(PARAMS.path.Triton,'Settings');
if ~exist(PARAMS.path.Settings, 'dir')
    disp(' ')
    disp('Settings directory is missing, creating it ...')
    mkdir(PARAMS.path.Settings);
    if ~isdeployed % standard in MATLAB mode
        addpath(PARAMS.path.Settings)
    end
end


% Extras folder
PARAMS.path.Extras = fullfile(PARAMS.path.Triton,'Extras');
if ~exist(PARAMS.path.Extras, 'dir')
    disp(' ')
    disp('Extras directory is missing, creating it ...')
    mkdir(PARAMS.path.Extras);
    if ~isdeployed % standard in MATLAB mode
        addpath(PARAMS.path.Extras)
    end
end

% Remoras folder
if ~isdeployed % standard in MATLAB mode
    PARAMS.path.Remoras = fullfile(PARAMS.path.Triton, 'Remoras');
    RemoraConfFile = fullfile(PARAMS.path.Settings,'InstalledRemoras.cnf');
    
    %remove all Remoras before adding them in again later down in this code
    rem_dir = rmpath(genpath(PARAMS.path.Remoras));
    
    % check that remora dir and cnf file haven't been deleted
    if exist(PARAMS.path.Remoras) ~= 7
        %         remoraHome = TritonRemoraDir;
        disp(' ')
        disp('Remoras directory is missing, creating it ...')
        mkdir(PARAMS.path.Remoras);
    end
    if exist(RemoraConfFile) == 0
        % if InstalledRemoras.cnf file doesn't exist, make it
        disp(' ')
        disp('Remora .cnf file missing, creating it ...');
        fid = fopen(RemoraConfFile, 'w+');
        fclose(fid);
    end
    
    fid = fopen(RemoraConfFile);
    remorapath = fgetl(fid);
    while ischar(remorapath)
        addpath(genpath(remorapath));
        remorapath = fgetl(fid);
    end
    fclose(fid);   
end

end