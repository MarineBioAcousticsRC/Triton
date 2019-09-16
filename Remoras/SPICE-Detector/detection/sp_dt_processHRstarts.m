function [cParams,f] = sp_dt_processHRstarts(fid,starts,stops,...
    p,hdr,recFile)

% Initialize vectors for main detector loop
cParams.clickTimes = nan(1E5,2);
cParams.ppSignalVec = nan(1E5,1);
cParams.durClickVec = nan(1E5,1);
cParams.bw3dbVec = nan(1E5,3);
cParams.specClickTfVec = nan(1E5,length(p.specRange));
cParams.peakFrVec = nan(1E5,1);
cParams.deltaEnvVec = nan(1E5,1);
cParams.nDurVec = nan(1E5,1);
% time series stored in cell arrays because length varies
cParams.yFiltVec = cell(1E5,1);
cParams.yFiltBuffVec = cell(1E5,1);

if p.saveNoise
    cParams.yNFiltVec = [];
    cParams.specNoiseTfVec = [];
end

f = [];
sIdx = 1;
eIdx = 0;

numStarts = length(starts);
for k = 1:numStarts % stepping through using the start/end points
    
    % Filter the data
    filteredData = sp_dt_getFilteredData(fid,starts(k),stops(k),hdr,...
        p,recFile);
    
    % Look for click candidates
    [clicks, noise] = sp_dt_HR(p, hdr, filteredData);
    
    if ~ isempty(clicks)
        % if we're in here, it's because we detected one or more possible
        % clicks in the kth segment of data
        % Make sure our click candidates aren't clipped
        validClicks = sp_dt_pruneClipping(clicks,p,hdr,filteredData);
        
        % Look at power spectrum of clicks, and remove those that don't
        % meet peak frequency and bandwidth requirements
        clicks = clicks(validClicks==1,:);
        
        % Compute click parameters to decide if the detection should be kept
        [clickDets,f] = sp_dt_parameters(noise,filteredData,p,clicks,hdr);
        
        if ~isempty(clickDets.clickInd)
            % Write out .cTg file
            [clkStarts,clkEnds] = sp_dt_processValidClicks(clicks,clickDets,...
                starts(k),hdr);
            
            eIdx = sIdx + size(clickDets.nDur,1)-1;
            cParams.clickTimes(sIdx:eIdx,1:2) = [clkStarts,clkEnds];
            cParams.ppSignalVec(sIdx:eIdx,1) = clickDets.ppSignal;
            cParams.durClickVec(sIdx:eIdx,1) = clickDets.durClick;
            cParams.bw3dbVec(sIdx:eIdx,:) = clickDets.bw3db;
            cParams.yFiltVec(sIdx:eIdx,:)= clickDets.yFilt';
            cParams.specClickTfVec(sIdx:eIdx,:) = clickDets.specClickTf;
            cParams.peakFrVec(sIdx:eIdx,1) = clickDets.peakFr;
            cParams.yFiltBuffVec(sIdx:eIdx,:) = clickDets.yFiltBuff';
            cParams.deltaEnvVec(sIdx:eIdx,1) = clickDets.deltaEnv;
            cParams.nDurVec(sIdx:eIdx,1) = clickDets.nDur;
            
            if p.saveNoise
                if ~isempty(clickDets.yNFilt{1})
                    cParams.yNFiltVec = [cParams.yNFiltVec;clickDets.yNFilt];
                    cParams.specNoiseTfVec = [cParams.specNoiseTfVec;...
                        clickDets.specNoiseTf];
                end
            end
            
            sIdx = eIdx+1;
        end
    end
    if rem(k,1000) == 0
        fprintf('low res period %d of %d complete \n',k,numStarts)
    end
end

% prune off any extra cells that weren't filled
cParams.clickTimes = cParams.clickTimes(1:eIdx,:);
cParams.ppSignalVec = cParams.ppSignalVec(1:eIdx,:);
cParams.durClickVec = cParams.durClickVec(1:eIdx,:);
cParams.bw3dbVec = cParams.bw3dbVec(1:eIdx,:);
cParams.yFiltVec = cParams.yFiltVec(1:eIdx,:);
cParams.specClickTfVec = cParams.specClickTfVec(1:eIdx,:);
cParams.peakFrVec = cParams.peakFrVec(1:eIdx,:);
cParams.yFiltBuffVec = cParams.yFiltBuffVec(1:eIdx,:);
cParams.deltaEnvVec = cParams.deltaEnvVec(1:eIdx,:);
cParams.nDurVec = cParams.nDurVec(1:eIdx,:);
