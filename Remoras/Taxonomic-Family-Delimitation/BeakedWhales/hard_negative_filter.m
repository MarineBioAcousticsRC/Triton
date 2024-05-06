% Beaked whale discrimination process 
% Prune out detections that do not meet the requirements of a beaked whale
% click:
%1) eliminate clicks with peak frequency below 32.0313 kHz
%2) eliminate clicks with center frequency below 25kHz
%3) eliminate clicks with duration <0.355 ms
%4) eliminate clicks with slope below 23.0384
%5) eliminate clicks with slope duration samples below 34 (nSamples, -8dB limit)
%6) eliminate 75s-segments with less than 7 clicks
%7) eliminate 75s-segments with less than 13% of valid clicks
% Extra discrimination:
%8) eliminate clicks with maximum envelope (in first 20 points) higher than
%max envelope (in 30-40 points)
%9) eliminate clicks with duration envelope above 50% of less than 0.095 ms
% (200kHz-19samples)and higher than 0.35 ms (200kHz-70samples)
% 
clearvars

% Define input/output locations.REQUIRED
baseDir = 'D:\Site_MetaData'; % specify folder containing SPICE detector output
subDir = 1; % search for subfolders in base folder (1-yes, 0-no). Subfolders only one layer down
outDir = 'D:\TPWS'; % folder where TPWS files will be stored

%%%%%%%%%%%%%%%%%%%%%%%% MODIFY WITH PRECAUTION %%%%%%%%%%%%%%%%%%%%%%%%%%%
% detector parameters
p.HRbuffer = 0.00025; % buffer used in de_detector
p.maxRows = 1800000; % maximum detections per TPWS file
p.ppThresh = 110; % RLpp threshold
p.tsWin = 1; % timeseries click size (in miliseconds) for TPWS file

% discrimination thresholds
thr.peakFreq = 32.0313; % kHz
thr.centerFreq = 25; % kHz
thr.durClick = 0.355; % miliseconds
thr.slope = 23.0384;
thr.nSamples = 34; % min samples slope at  -8dB limit
thr.minClickSeg = 7; % min clicks per 75s-segment
thr.percValidSeg = 0.13; % 13% of valid clicks per 75s-segment
thr.extraPrune = 1; % prune more - Joy's section. 1-yes,0-no
thr.energyThr = 0.5; %percentage
thr.deltaEnv = 0;
thr.shortDurEnv = 0.095; % miliseconds
thr.longDurEnv = 0.35; %miliseconds

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% DO NOT MODIFY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist(outDir,'dir')
    fprintf('Creating output directory %s\n',outDir)
    mkdir(outDir)
end
letterCode = 97:122;
fprintf('Reading files from base folder: %s\n', baseDir)

if ~subDir
    % if run on folder of files
    [~,outName] = fileparts(baseDir);
    
else
    % run on subfolders (only one layer down)
    dirSet = dir(baseDir);
    if isempty(dirSet)
       error('Folder without subfolders. Modify subDir to 0.') 
    end
    for itr0 = 1:length(dirSet)
        if dirSet(itr0).isdir &&~strcmp(dirSet(itr0).name,'.')&&...
                ~strcmp(dirSet(itr0).name,'..')
            inDir = fullfile(dirSet(itr0).folder,dirSet(itr0).name);
            outName = dirSet(itr0).name;
            fn_prune_dolphins_oneDir_pool(inDir,letterCode,outDir,outName,thr,p)
            fprintf('Done with directory %d of %d \n',itr0,length(dirSet))
        end
    end
end


