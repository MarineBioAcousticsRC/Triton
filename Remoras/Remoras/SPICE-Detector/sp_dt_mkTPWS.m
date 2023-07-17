function sp_dt_mkTPWS

global REMORA
% Script takes output from de_detector.m and put it into a format for use in
% detEdit.
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
if isfield(REMORA,'spice_dt') && isfield(REMORA.spice_dt,'mkTPWS')
    if  isfield(REMORA.spice_dt.mkTPWS,'baseDir')
        baseDir = REMORA.spice_dt.mkTPWS.baseDir;
    else
        baseDir = uigetdir('','Please select folder of detection files or file folders');
    end
    fprintf('Base Folder: %s\n', baseDir)
    if isfield(REMORA.spice_dt.mkTPWS,'outDir')
        outDir = REMORA.spice_dt.mkTPWS.outDir;
    else
        outDir = uigetdir('','Please select folder of detection files or file folders');
    end
    fprintf('Output Folder: %s\n', outDir)

    if isfield(REMORA.spice_dt.mkTPWS,'filterString')
        siteName = REMORA.spice_dt.mkTPWS.filterString;
    else
        siteName = '';% site name wildcard, used to restrict input files
    end
    fprintf('Wildcard: %s\n', siteName)
    
    if isfield(REMORA.spice_dt.mkTPWS,'spName')
        spName = REMORA.spice_dt.mkTPWS.spName;
    else
        spName = '';% species name specified in TPWS file name
    end
    fprintf('Species name for TPWS file name: %s\n', spName)

    if isfield(REMORA.spice_dt.mkTPWS,'minDBpp')
        % minimum RL in dBpp. If detections have RL below this
        % threshold, they will be excluded from the output file. Useful if you have
        % an unmanageable number of detections.
        ppThresh = REMORA.spice_dt.mkTPWS.minDBpp;
        if isempty(ppThresh)
            ppThresh = -inf;
        end
    else
        ppThresh = -inf;
    end
    fprintf('Min. RL: %0.0f\n', ppThresh)

    if isfield(REMORA.spice_dt.mkTPWS,'subDirTF')
        subDir = REMORA.spice_dt.mkTPWS.subDirTF;
    else
        subDir = 1;
    end 
    fprintf('Search Subfolders: %0.0f\n', subDir)

    if isfield(REMORA.spice_dt.mkTPWS,'maxRows')
        maxRows = REMORA.spice_dt.mkTPWS.maxRows;
    else
        maxRows = 1800000;
    end 
    fprintf('Max Dets per File: %0.0f\n', maxRows)

    if isfield(REMORA.spice_dt.mkTPWS,'tsWin')
        tsWin = REMORA.spice_dt.mkTPWS.tsWin;
    else
        tsWin = 200;
    end 
    fprintf('Waveform Samples: %0.0f\n', tsWin)

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check if the output file exists, if not, make it
if ~exist(outDir,'dir')
    fprintf('Creating output directory %s\n',outDir)
    drawnow
    mkdir(outDir)
end
letterCode = 97:122;


% if run on folder of files
if ~subDir
    [~,outName] = fileparts(baseDir);
    outName = strrep(outName,'_metadata','');
    
    sp_dt_makeTPWS_oneDir(baseDir,letterCode,ppThresh,outDir,outName,spName,maxRows,tsWin)
    disp_msg(sprintf('Done with directory %s',baseDir))

else 
    % run on subfolders (only one layer down).
    dirSet = dir(fullfile(baseDir,[siteName,'*']));
    if isempty(dirSet)
        error('No files matching criteria %s found.',....
            fullfile(baseDir,[siteName,'*']))
    end
    for itr0 = 1:length(dirSet)

        if dirSet(itr0).isdir &&~strcmp(dirSet(itr0).name,'.')&&...
                ~strcmp(dirSet(itr0).name,'..')
            inDir = fullfile(dirSet(itr0).folder,dirSet(itr0).name);
            outName = dirSet(itr0).name;
            sp_dt_makeTPWS_oneDir(inDir,letterCode,ppThresh,outDir,outName,spName,maxRows,tsWin)
            disp_msg(sprintf('Done with directory %d of %d \n',itr0,length(dirSet)))
            drawnow
        end
    end
end
    
