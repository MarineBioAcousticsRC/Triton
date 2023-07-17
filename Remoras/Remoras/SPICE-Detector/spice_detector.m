function spice_detector(varargin)

% All input parameters should be contained within a script
% See detector_settings_default.m  for default settings and descriptions.
% Make your own versions(s) with different names to modify the settings as
% you see fit.

% fclose all;

% Load detector settings
detParamsFile = [];
runMode = 'batchRun'; % default to batch. Need to implement guiRun.
if nargin == 1
    % Check if settings file was passed in function call
    if ischar(varargin{1})
        % a file name was passed in, assume it is a script for generating
        % detParams
        detParamsFile = varargin{1};
        % If so, load it
        fprintf('Loading settings file %s\n\n',detParamsFile)
        run(detParamsFile);
    elseif isstruct(varargin{1})
        % a struct was passed in, assume it contains the detection
        % parameters detParams
        detParams = varargin{1};
    end

else
    % If no settings file provided, prompt for input
    currentDir = mfilename('fullpath');
    expectedSettingsDir = fullfile(fileparts(currentDir),'settings');
    [settingsFileName,settingsFilePath , ~] = uigetfile(expectedSettingsDir);
    if ~isempty(settingsFileName)
        settingsFullFile = fullfile(settingsFilePath,settingsFileName);
        fprintf('Loading settings file %s\n\n',settingsFullFile)
        run(settingsFullFile);

    else 
        error('No settings file selected')
    end
end

if detParams.verbose
    % display settings variables
    disp(detParams)
end

if detParams.diary
    diary('on')
end

detParams = sp_dt_buildDirs(detParams);

% Build list of (x)wav names in the base directory.
% Right now only wav and xwav files are looked for.
fullFileNames = sp_fn_findXWAVs(detParams);

if detParams.guidedDetector && ~isempty(detParams.gDxls)
    [fullFileNames,encounterTimes] = sp_fn_guidedDetection(fullFileNames,detParams);
    fprintf('Using guided detections from file %s \n',detParams.gDxls')
else
    encounterTimes = [];
end

% return a list of files to be built
fullLabels = sp_fn_getFileset(detParams,fullFileNames);

% profile on
% profile clear
if ~isempty(fullFileNames)
    fprintf('Beginning detection\n\n')
    sp_dt_batch(fullFileNames,fullLabels,detParams,encounterTimes,runMode);
    disp('Detection complete.')
else
    disp('Error: No wav/xwav files found')
end

% profile viewer
% profile off
if detParams.diary
    diary('off')
end
