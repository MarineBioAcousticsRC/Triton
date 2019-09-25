function [cParams,f] = sp_dt_interactive(displayedData,p)

global PARAMS
hdr = ??
p = sp_fn_interp_tf(p);
if ~exist('p.countThresh') || isempty(p.countThresh)
    p.countThresh = (10^((p.dBppThreshold - median(p.xfrOffset))/20))/2;
end

cParams = sp_dt_init_cParams(p); % set up storage for HR output.
buffSamples = p.LRbuffer*hdr.fs;
% Loop through search area, running short term detector


startK = xxx ; % start of window
stopK = xxx; % end of window

% data is already filtered if desired

energy = displayedData.^2;

%%% Run LR detection to identify candidates
[detectionsSample,detectionsSec] =  sp_dt_LR(energy,hdr,buffSamples,...
    startK,stopK,p);

clickDetsAll = [];
%%% start HR detection on candidates
for iD = 1:size(detectionsSample,1)
    filtSegment = displayedData(detectionsSample(iD,1):detectionsSample(iD,2));
    [clicks, noise] = sp_dt_HR(p, hdr, filtSegment);
    
    if ~ isempty(clicks)
        % if we're in here, it's because we detected one or more possible
        % clicks in the kth segment of data
        % Make sure our click candidates aren't clipped
        validClicks = sp_dt_pruneClipping(clicks,p,hdr,filtSegment);
        
        % Look at power spectrum of clicks, and remove those that don't
        % meet peak frequency and bandwidth requirements
        clicks = clicks(validClicks==1,:);
        % Compute click parameters to decide if the detection should be kept
        [clickDets,f] = sp_dt_parameters(noise,filtSegment,p,clicks,hdr);
        
        clickDetsAll = [clickDetsAll;clickDets];
    end
end

% Run post processing to remove rogue loner clicks, prior to writing
% the remaining output files.
clickTimes = sortrows(clickDetsAll.clickTimes);

keepFlag = sp_dt_postproc(labelFile,clickTimes,p,hdr,encounterTimes);
keepIdx = find(keepFlag==1);

clickDetsAll = sp_dt_prune_cParams_byIdx(clickDetsAll,keepIdx);

