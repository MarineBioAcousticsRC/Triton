function dt_mkTPWS

global REMORA
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

% get folder of files
if isfield(REMORA,'dt') && isfield(REMORA.dt,'mkTPWS')
    if  isfield(REMORA.dt.mkTPWS,'detDir')
        detDir = REMORA.dt.mkTPWS.detDir;
    else
        detDir = uigetdir('','Please select folder of detection files or file folders');
    end
    if isfield(REMORA.dt.mkTPWS,'xwavDir')
        xwavDir = REMORA.dt.mkTPWS.xwavDir;
    else
        xwavDir = uigetdir('','Please select folder of xwav or wav files or file folders');
    end
    if isfield(REMORA.dt.mkTPWS,'outDir')
        outDir = REMORA.dt.mkTPWS.outDir;
    else
        outDir = uigetdir('','Please select folder to store TPWS files');
    end
    if isfield(REMORA.dt.mkTPWS,'tfFullFile')
        tfFullFile = REMORA.dt.mkTPWS.tfFullFile;
    else
        tfFullFile = 0;
        sprintf('Transfer function is not applied')
    end
    if isfield(REMORA.dt.mkTPWS,'filterString')
        siteName = REMORA.dt.mkTPWS.filterString;
    else
        siteName = '';% site name wildcard, used to restrict input files
    end
    if isfield(REMORA.dt.mkTPWS,'ppThresh')
        % minimum RL in dBpp. If detections have RL below this
        % threshold, they will be excluded from the output file. Useful if you have
        % an unmanageable number of detections.
        ppThresh = REMORA.dt.mkTPWS.ppThresh;
        if isempty(ppThresh)
            ppThresh = -inf;
        end
    else
        ppThresh = -inf;
    end
    if isfield(REMORA.dt.mkTPWS,'subDirTF')
        subDir = REMORA.dt.mkTPWS.subDirTF;
    else
        subDir = 0;
    end 
    if isfield(REMORA.dt.mkTPWS,'fileExt')
        labelStr = {'.cTg','.pgdf','.cHR'};
        idxExt = REMORA.dt.mkTPWS.fileExt;
        fileExt = labelStr(idxExt);      
    else
        prompt = 'Specify detection file extension (e.g. cTg): ';
        fileExt = input(prompt,'s');
        fileExt = ['.',fileExt];
    end 
    if isfield(REMORA.dt.mkTPWS,'saveFeat')
        saveFeat = REMORA.dt.mkTPWS.saveFeat;
    else
        saveFeat = 0;
    end 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check if the output file exists, if not, make it
if ~exist(outDir,'dir')
    fprintf('Creating output directory %s\n',outDir)
    mkdir(outDir)
end
letterCode = 97:122;


% if run on folder of files
if ~subDir
    dt_mkTPWS_oneDir(detDir,fileExt,letterCode,ppThresh)
else 
    % run on subfolders (only one layer down).
    dirSet = dir(fullfile(detDir,[siteName,'*']));
    if isempty(dirSet)
        error('No files matching criteria %s found.',....
            fullfile(detDir,[siteName,'*']))
    end
    for itr0 = 1:length(dirSet)

        if dirSet(itr0).isdir &&~strcmp(dirSet(itr0).name,'.')&&...
                ~strcmp(dirSet(itr0).name,'..')
            detDir = fullfile(dirSet(itr0).folder,dirSet(itr0).name);
            
            dt_mkTPWS_oneDir(detDir,fileExt,letterCode,ppThresh)
            
        end
    end
end
    
