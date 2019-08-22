function dt_mkTPWS (settings)

% Script takes output from text files (.cTg - Triton detector or 
% .pgdf - Pamguard detector) and put it into a format for use in detEdit.
% Output:
% A TPWS.m file containing 4 variables:
%   MTT: An Nx2 vector of detection start and end times, where N is the
%   number of detections
%   MPP: An Nx1 vector of recieved level (RL) amplitudes.
%   MSP: An NxF vector of detection spectra, where F is dictated by the
%   parameters of the fft used to generate the spectra and any
%   normalization preferences.
%   f = An Fx1 frequency vector associated with MSP

% get folder of files and chech that exist
if  ~isfield(settings,'detDir')
    settings.detDir = uigetdir('','Please select folder of detection files or file folders');
end
if ~exist(settings.detDir,'dir'); error('Folder (%s) not found',settings.detDir); end

if ~isfield(settings,'recDir')
    settings.recDir = uigetdir('','Please select folder of xwav or wav files or file folders');
end
if ~exist(settings.recDir,'dir'); error('Folder (%s) not found',settings.recDir); end

if ~isfield(settings,'outDir')
    settings.outDir = uigetdir('','Please select folder to store TPWS files');
end
if ~exist(settings.outDir,'dir') % check if the output file exists, if not, make it
    fprintf('Creating output directory %s\n',settings.outDir)
    mkdir(settings.out)
end

if isfield(settings,'tfFullFile')
    if ~exist(settings.tfFullFile,'file'); error('File (%s) not found',settings.tfFullFile);end
else
    settings.tfFullFile = [];
    sprintf('Transfer function is not applied')
end

if ~isfield(settings,'filterString')
    settings.siteName = '';% site name wildcard, used to restrict input files
end

if ~isfield(settings,'ppThresh')
    settings.ppThresh = -inf;
end

if ~isfield(settings,'byFolder')
    settings.byFolder = 0;
end

if isfield(settings,'detFileExt')
    if strcmp(settings.detFileExt,'other')
        prompt = 'Specify detection file extension (e.g. cTg): ';
        settings.detFileExt = input(prompt,'s');
        settings.detFileExt = ['.',settings.detFileExt];
    end
else
    settings.detFileExt = '.cTg';
end

if ~isfield(settings,'recFileExt')
    settings.recFileExt  = '.x.wav';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

letterCode = 97:122;

% Build list of cTg files in the directory
[fullDetFileNames,detFilePaths,detFileBytes] = dt_TPWS_findDetFile(settings);

% Build list of (x)wav files in the directory that match detection files name.
% Right now only wav and xwav files are looked for.
fullRecFileNames = dt_TPWS_findXWAV(settings,fullDetFileNames);

settings.previousFs = 0; % make sure we build filters on first pass

% More than 3 miliion clicks will create to large files, so store TPWS per
% subfolder (disk) instead
settings.estimSize = ceil(sum(detFileBytes)/30); % estimated size of TPWS variables
largeFile = settings.estimSize >= 3E6;

% if run on folder of files
if ~settings.byFolder && largeFile
    dt_mkTPWS_oneDir(fullDetFileNames,fullRecFileNames,settings)
else 
    % Find how many folders to create a TPWS file per folder.
    % Otherwise, if specified by the user, create one TPWS file for all the
    % detections.
    folders = unique(detFilePaths);

    for itr1 = 1:length(folders)
        selec = strcmp(detFilePaths,folders(itr1)); % select files for this folder
        settings.estimSize = ceil(sum(detFileBytes(selec))/30);
        dt_mkTPWS_oneDir(fullDetFileNames(selec),fullRecFileNames(selec),settings)
    end
end
    
