function dt_gui

global PARAMS REMORA DATA
REMORA.spice_dt.guiDets = [];

if isempty(REMORA.spice_dt.detParams.tfFullFile)
    disp_msg('loading transfer function')
    REMORA.spice_dt.detParams.tfFullFile = PARAMS.tf.filename;
    % if the user changes the tf, this will not update it.
end

if isfield(REMORA.spice_dt.detParams,'rebuildFilter')&&(REMORA.spice_dt.detParams.rebuildFilter)
    % triggers if band pass is changed
    [~,REMORA.spice_dt.detParams] = fn_buildFilters(REMORA.spice_dt.detParams,PARAMS.fs);
    REMORA.spice_dt.detParams.rebuildFilter = 0;
    
end

p = REMORA.spice_dt.detParams;

p = fn_interp_tf(p);

if ~isfield(p,'countThresh') || isempty(p.countThresh)
    p.countThresh = (10^((p.dBppThreshold - median(p.xfrOffset))/20))/2;
end
cParams = dt_init_cParams(p); % set up storage for HR output.
sIdx = 1;
buffSamples = p.LRbuffer*PARAMS.fs;
if size(DATA,1)> size(DATA,2)
    filtData = filtfilt(p.fB,p.fA,DATA(:,PARAMS.ch));
    filtData = filtData';
else
    filtData = filtfilt(p.fB,p.fA,DATA(PARAMS.ch,:)');
end
energy = filtData.^2;

[detectionsSample,detectionsSec] =  dt_LR(energy,PARAMS,buffSamples,...
    0,length(energy),p);

%%% start HR detection on candidates
if ~isempty(detectionsSample)
    for iD = 1:size(detectionsSample,1)
        filtSegment = filtData(detectionsSample(iD,1):detectionsSample(iD,2));
        [clicks, noise] = dt_HR(p, PARAMS, filtSegment);
        
        if ~ isempty(clicks)
            % if we're in here, it's because we detected one or more possible
            % clicks in the kth segment of data
            % Make sure our click candidates aren't clipped
            validClicks = dt_pruneClipping(clicks,p,PARAMS,filtSegment);
            
            % Look at power spectrum of clicks, and remove those that don't
            % meet peak frequency and bandwidth requirements
            clicks = clicks(validClicks==1,:);
            % Compute click parameters to decide if the detection should be kept
            [clickDets,f] = dt_parameters(noise,filtSegment,p,clicks,PARAMS);
            if ~isempty(clickDets.clickInd)
                [cParams,sIdx] = dt_populate_cParams(clicks,p,clickDets,...
                    detectionsSample(iD,1)./PARAMS.fs,PARAMS,sIdx,cParams);
                
            end
        end
    end
    % Run post processing to remove rogue loner clicks, prior to writing
    % the remaining output files.
    if sIdx == 1
        disp_msg('No detections found in current Triton window');
    else
        cParams = dt_prune_cParams_byIdx(cParams,1:sIdx-1);
        
        clickTimes = sortrows(cParams.clickTimes);
        
        keepFlag = dt_postproc([],clickTimes,p,PARAMS,[]);
        keepIdx = find(keepFlag==1);
        
        cParams = dt_prune_cParams_byIdx(cParams,keepIdx);
        REMORA.spice_dt.guiDets = cParams;
        %plot(REMORA.spice_dt.guiDets.clickTimes*PARAMS.fs)
        %  plotClicks somehow
    end
else
    disp_msg('No detections in current window')
    REMORA.spice_dt.guiDets = [];
end

