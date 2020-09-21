inDir = 'J:\DCL_TPWS\WAT_HZ';
binInMins = 5;
inFileList = dir(fullfile(inDir,'*TPWS*.mat'));
mergedSet = {};
mergedSet.thisType.clickTimes = [];
mergedSet.thisType.tIntMat = [];
mergedSet.thisType.fileNumExpand = [];
mergedSet.thisType.Tfinal = cell(1,10);

%%% get these from gui.
outDir='J:\DCL_TPWS\WAT_HZ\Test';
p.barInt = 0:.001:1;
s.maxICI = 1;
s.minICI = 0;
s.startFreq = 5;
s.endFreq = 100;
s.correctForSaturation = 1;
s.outputName = 'HZmanual';
binInMins = 5;
p.maxDur = 200;
%%%
if ~isdir(outDir)
    mkdir(outDir);
end
[~,s.maxICIidx] = min(abs(p.barInt-s.maxICI));
[~,s.minICIidx] = min(abs(p.barInt-s.minICI));
nTPWS = length(inFileList);
for iFile = 1:nTPWS
    fprintf('Loading data for file %0.0f of %0.0f\n', iFile,nTPWS)
    load(fullfile(inFileList(iFile).folder,inFileList(iFile).name),'MTT','MSP','MSN','f')
    load(fullfile(inFileList(iFile).folder,strrep(inFileList(iFile).name,...
       'TPWS','ID')))
    %%% need to add throw error if f changes size.
    [~,s.stIdx] = min(abs(f-s.startFreq));
    [~,s.edIdx] = min(abs(f-s.endFreq));

    binAdjust = 24*60/binInMins;
    binsStart = floor((min(MTT)*binAdjust))/binAdjust;
    binsEnd = ceil((max(MTT)*binAdjust))/binAdjust;
    myBins = binsStart:(1/binAdjust):binsEnd;
    [C,I] = histc(zID(:,1),myBins);
    for iID = 1:length(C)
        if C(iID)>0
            myIDset = zID(I == iID,:);
            uSet = unique(myIDset(:,2));
            if size(mergedSet,1)<max(uSet)
                while size(mergedSet,1) < max(uSet)
                    newIdx = size(mergedSet,1)+1;
                    mergedSet(newIdx,1).thisType.clickTimes = [];
                    mergedSet(newIdx,1).thisType.tIntMat = [];
                    mergedSet(newIdx,1).thisType.fileNumExpand = [];
                    mergedSet(newIdx,1).thisType.Tfinal = cell(1,10);
                end
            end
              
            for iU = 1:length(uSet)
                subsetIndices = find(myIDset(:,2)==uSet(iU));
                clickTimes = myIDset(subsetIndices,1);
                
                mergedSet(uSet(iU)).thisType.clickTimes = ...
                    [mergedSet(uSet(iU)).thisType.clickTimes;clickTimes];
                mergedSet(uSet(iU)).thisType.tIntMat = ...
                    [mergedSet(uSet(iU)).thisType.tIntMat;myBins(iID)];
                mergedSet(uSet(iU)).thisType.fileNumExpand = ...
                    [mergedSet(uSet(iU)).thisType.fileNumExpand;iFile];
                
           
                [~,TPWSidx,~] = intersect(MTT,clickTimes);
                % 1: spectra
                mySpectra = MSP(TPWSidx,:);
                specMean = nn_norm_mean_spec(mySpectra,s.stIdx,s.edIdx);
                mergedSet(uSet(iU)).thisType.Tfinal{1} = [mergedSet(uSet(iU)).thisType.Tfinal{1};specMean];
                % 2: ici distribution
                iciDist = nn_compute_ici_distribution(clickTimes,p.barInt);
                mergedSet(uSet(iU)).thisType.Tfinal{2} = [mergedSet(uSet(iU)).thisType.Tfinal{2};iciDist];
                % 3: diff spectra % not implemented
                
                % 4: ici mode
                [~,iciModeIdx] = max(iciDist(:,s.minICIidx:end),[],2);
                
                % find secondary ICI peak in saturated ICI distributions
                if s.correctForSaturation
                    iciModeIdx = ct_correct_for_saturation(p,s.maxICIidx,iciDist,iciModeIdx);
                end
                iciMode = p.barInt(iciModeIdx) + p.barInt(2)./2;
                mergedSet(uSet(iU)).thisType.Tfinal{4} = [mergedSet(uSet(iU)).thisType.Tfinal{4};iciMode];
                % 5: mean spectrum??
                
                % 6: fileNumExpand(nodeSet{iTF}); % file it came from, redundant w/above
                mergedSet(uSet(iU)).thisType.Tfinal{8} = [mergedSet(uSet(iU)).thisType.Tfinal{8};...
                    iID]; % primart Index of bin
                mergedSet(uSet(iU)).thisType.Tfinal{9} = [mergedSet(uSet(iU)).thisType.Tfinal{9};...
                    iU]; % subIndex of bin
                
                % 10: mean envelope
                envMean = mean(MSN(TPWSidx,:)./max(MSN(TPWSidx,:),[],2),1);
                mergedSet(uSet(iU)).thisType.Tfinal{10} = [mergedSet(uSet(iU)).thisType.Tfinal{10};...
                    envMean]; % subIndex of bin
            end
        end

    end
    fprintf('done with file %0.0f of %0.0f\n', iFile,nTPWS)
end  
% then save one file for each merged set thing
for iType = 1:size(mergedSet,1)
    if ~isempty(mergedSet(iType).thisType.clickTimes)
        mergedSet(iType).thisType.Tfinal{6} = mergedSet(iType,1).thisType.fileNumExpand;
        mergedSet(iType).thisType.Tfinal{7} = mergedSet(iType,1).thisType.tIntMat;
        thisType = mergedSet(iType).thisType;
        save(fullfile(outDir,[s.outputName,'_type',num2str(iType)]),'thisType','inFileList','-v7.3');
        s.saveOutput = 1;
        nn_individual_click_plots(p,s,f,mergedSet(iType).thisType.Tfinal,outDir,iType)
    end
end

function specMean = nn_norm_mean_spec(mySpectra,stIdx,edIdx)

    minSSsection = min(mySpectra(:,stIdx:edIdx),[],2);
    mySpectra_minNorm = (mySpectra - ...
        minSSsection(:,ones(1,size(mySpectra,2))));
    maxSSsection = max(mySpectra_minNorm(:,stIdx:edIdx),[],2);
    mySpectra_norm = mySpectra_minNorm./maxSSsection(:,ones(1,size(mySpectra_minNorm,2)));
    linearSpec = 10.^(mySpectra_norm./20);
    specMeanTemp = 20*log10(nanmean(linearSpec,1));
    
    specMeanTemp_minNorm = specMeanTemp - min(specMeanTemp);
    specMean = specMeanTemp_minNorm/max(specMeanTemp_minNorm);
end

function iciDist = nn_compute_ici_distribution(ttSet,barInt)

    % deals with weird behavior of histc when there are few/no data points in
    % ttSet
    iciDist =  histc(diff(sort(ttSet))*24*60*60,barInt);
    if isempty(iciDist)
        iciDist = zeros(size(barInt));
    elseif size(iciDist,1)>size(iciDist,2)
        iciDist = iciDist';
    end
end