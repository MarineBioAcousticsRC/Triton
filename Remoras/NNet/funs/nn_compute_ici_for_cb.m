inDir = 'I:\USWTR_clusterBins';
files = dir(fullfile(inDir, '\*clusterBins_ici', '*.mat'));
iciVec = 0:.01:1;
for k = 1:length(files)
    filePath = fullfile(files(k).folder, files(k).name);
    data = load(filePath);
    % Process the data as needed
    nBins = size(data.binData,1);
    if ~isdir([files(k).folder,'_ici'])
        mkdir([files(k).folder,'_ici'])
    end
    for iB = 1:nBins
        nTypes = size(data.binData(iB).clickTimes,2);
        
        for iT = 1:nTypes
            nClicks = size(data.binData(iB).clickTimes{1,iT},1);
            if nClicks<=1
                if iT ==1
                    data.binData(iB).dTT = [];
                end
                data.binData(iB).dTT(iT,:) = zeros(size(iciVec));
            else
                if iT ==1
                    data.binData(iB).dTT = [];
                end
                [C,~] = histc(diff(data.binData(iB).clickTimes{1,iT})*24*60*60, iciVec);
                data.binData(iB).dTT(iT,:) = C';
            end
        end
    end
    outName = fullfile([(files(k).folder),'_ici'],files(k).name);
    if strcmp(outName,filePath)
        error('input and output files are the same')
    else
        save(outName, '-struct','data', '-v7.3');
    end
end
