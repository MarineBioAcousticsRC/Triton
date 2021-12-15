function ct_cluster_bins(varargin)

% Cluster clicks in n-minute bins by spectral similarities 
if nargin == 1
    % Check if settings file was passed in function call
    if ischar(varargin{1})
        % a file name was passed in, assume it is a script for generating
        % cluster params "p"
        clusterBinsParamsFile = varargin{1};
        % If so, load it
        fprintf('Loading settings file %s\n\n',clusterBinsParamsFile)
        run(clusterBinsParamsFile);
    elseif isstruct(varargin{1})
        % a struct was passed in, assume it contains the detection
        % parameters detParams
        p = varargin{1};
    end

else
    % If no settings file provided, prompt for input
    currentDir = mfilename('fullpath');
    expectedSettingsDir = fullfile(fileparts(currentDir),'settings');
    [settingsFileName,settingsFilePath , ~] = uigetfile(expectedSettingsDir);
    if ~isempty(settingsFileName)
        clusterBinsParamsFile = fullfile(settingsFilePath,settingsFileName);
        fprintf('Loading settings file %s\n\n',clusterBinsParamsFile)
        run(clusterBinsParamsFile);

    else 
        error('No settings file selected')
    end
end

%%% INPUT:
% Directory of TPWS files. These need to include frequency vector
% associated with spectra, or add your freq vector to script.
%%% OUTPUT:
% One (large) mat file containing dominant click type(s) in each N minute bin
% during the period spanned by the TPWS files. Includes
%   sumSpec   - mean spectrum/spectra for each bin,
%   nSpec     - # of clicks in bin associated with each summary spec,
%   percSpec  - percentage of clicks in bin associated with each summary spec,
%   clickRate - click rate distribution(s) per bin,
%   dTT       - ICI distribution(s) per bin,
%   cInt      - # clicks per bin,
%   tInt      - bin start and end times,
% Also includes setting values described below.

%%% NOTE: Output is saved after each TPWS file is processed in case of crash,
% but data is stored cumulatively, so if all goes well, you only need the
% last (biggest) file.
% kef 10/14/2016

% modify cluster_bins_settings.m to import your site-specific preferences.
% you can save different versions of cluster_bins_settings, so you don't
% have to overwrite old settings.

if ~isempty(p.TPWSitr) && isnumeric(p.TPWSitr)
    p.TPWSitr = num2str(p.TPWSitr);
end
if p.recursSearch
    inFileList = dir(fullfile(p.inDir,'**',[p.siteName,'*TPWS',...
    	p.TPWSitr,'*.mat']));
    
    inDirList = unique({inFileList(:).folder})';
else
    inDirList = cellstr(p.inDir);
end

p.barInt = 0:.01:p.barIntMax;
p.barRate = floor((1/p.barIntMax):1/.01);    
for iDir = 1:length(inDirList)
    inDir = inDirList{iDir};
    % reconstruct input folder structure if recursive directories are used
    outDir = strrep(inDir,p.inDir,p.outDir);
    
    % check if outdir exists, make it if not.
    if ~isdir(outDir)
        mkdir(outDir)
    end
%     if p.diary % turn diary on if desired
%     	diary(fullfile(outDir,sprintf('diary_%s.txt',datestr(now,'YYYYMMDD'))))
%     end
    
    fprintf('Beginning clustering on files in\n%s\n',inDir)
    
    % Find the TPWS and FD files to be clustered
    tpwsNames = dir(fullfile(inDir,[p.siteName,'*_TPWS',...
        p.TPWSitr,'.mat']));
    
    if isempty(tpwsNames) % warn user if no TPWS files were found
        fprintf('No TPWS files matching %s found in\n%s\nSkipping to next folder.\n',...
            [p.siteName,'*_TPWS',p.TPWSitr,'.mat'],inDir)
    end
    
    fdNames = dir(fullfile(inDir,[p.siteName,'*_FD',...
        p.TPWSitr,'.mat']));
    
    % Load all FD files, in case for some reason they don't line up with TPWS
    % files. This may be unnecessary now, and it's slower (input to setdiff)
    p.falseStr = '_FPincl';
    fdAll = [];
    
    if p.falseRM
        for i0 = 1:length(fdNames)
            zFD = [];
            load(fullfile(fdNames(i0).folder,fdNames(i0).name),'zFD');
            fdAll = [fdAll;zFD];
        end
        p.falseStr = '_FPremov';
    end
    
    % Iterate over TPWS files, running clustering process on each time bin
    if p.parpoolSize>1    
        poolObj = gcp('nocreate');
        if isempty(poolObj)
            parpool(p.parpoolSize);
        else poolObj.NumWorkers~=p.parpoolSize;
            disp(sprintf('Found parpool of %0.0f workers, destroying to create new pool of %0.0f workers\n',...
                poolObj.NumWorkers,p.parpoolSize))
            delete(gcp('nocreate'))
            parpool(p.parpoolSize);
        end
        parfor itr = 1:length(tpwsNames) 
            thisFile = fullfile(tpwsNames(itr).folder,tpwsNames(itr).name);        
            fprintf('Beginning file %s\n',thisFile)
            % Run clustering 
            ct_cluster_TPWS(thisFile,fdAll,p,outDir)   
        end
    else
        for itr = 1:length(tpwsNames)
            thisFile = fullfile(tpwsNames(itr).folder,tpwsNames(itr).name);        
            fprintf('Beginning file %s\n',thisFile)
            outFile = fullfile(p.outDir,strrep(tpwsNames(itr).name,'TPWS1.mat','clusters_PR95_PPmin125.mat'));
            if exist(outFile,'file')
                continue
            end
            % Run clustering 
            ct_cluster_TPWS(thisFile,fdAll,p,outDir) 
        end
    end
%     if p.diary
%         diary('off')
%     end
end
