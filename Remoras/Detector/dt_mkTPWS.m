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
        folder.det = REMORA.dt.mkTPWS.detDir;
    else
        folder.det = uigetdir('','Please select folder of detection files or file folders');
    end
    if isfield(REMORA.dt.mkTPWS,'xwavDir')
        folder.audio = REMORA.dt.mkTPWS.xwavDir;
    else
        folder.audio = uigetdir('','Please select folder of xwav or wav files or file folders');
    end
    if isfield(REMORA.dt.mkTPWS,'outDir')
        folder.out = REMORA.dt.mkTPWS.outDir;
    else
        folder.out = uigetdir('','Please select folder to store TPWS files');
    end
    if isfield(REMORA.dt.mkTPWS,'tfFullFile')
        path.tf = REMORA.dt.mkTPWS.tfFullFile;
    else
        path.tf = [];
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
        labelStr = {'.cTg','.pgdf','.cHR','other'};
        idxExt = REMORA.dt.mkTPWS.fileExt;
        fileExt.det = labelStr(idxExt);
        if idxExt == 4
            prompt = 'Specify detection file extension (e.g. cTg): ';
            fileExt.det = input(prompt,'s');
            fileExt.det = ['.',fileExt.det];
        end
    else
        fileExt.det = '.cTg';
    end 
    if isfield(REMORA.dt.mkTPWS,'wavExt')
        labelStr2 = {'x.wav','.wav','other'};
        idxExt2 = REMORA.dt.mkTPWS.wavExt;
        fileExt.audio = labelStr2(idxExt2);
        if idxExt2 == 4
            prompt = 'Specify audio file extension (e.g. wav): ';
            fileExt.audio  = input(prompt,'s');
            fileExt.audio  = ['.',fileExt.audio ];
        end
        else
            fileExt.audio  = '.x.wav';
    end 
    if isfield(REMORA.dt.mkTPWS,'saveFeat')
        saveFeat = REMORA.dt.mkTPWS.saveFeat;
    else
        saveFeat = 0;
    end 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check if the output file exists, if not, make it
if ~exist(folder.out,'dir')
    fprintf('Creating output directory %s\n',outDir)
    mkdir(folder.out)
end
letterCode = 97:122;


% if run on folder of files
if ~subDir
    dt_mkTPWS_oneDir(folder,path,fileExt,letterCode,ppThresh)
else 
    % run on subfolders (only one layer down).
    dirSet = folder(fullfile(folder.det,[siteName,'*']));
    if isempty(dirSet)
        error('No files matching criteria %s found.',....
            fullfile(folder.det,[siteName,'*']))
    end
    for itr0 = 1:length(dirSet)

        if dirSet(itr0).isdir &&~strcmp(dirSet(itr0).name,'.')&&...
                ~strcmp(dirSet(itr0).name,'..')
            folder.det = fullfile(dirSet(itr0).folder,dirSet(itr0).name);
            
            dt_mkTPWS_oneDir(folder,path,fileExt,letterCode,ppThresh)
            
        end
    end
end
    
