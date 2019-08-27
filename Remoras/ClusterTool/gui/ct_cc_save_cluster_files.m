function ct_cc_save_cluster_files

% make folders

for iF = 1:nTypes
    newDir = fullfile(REMORA.ct.CC.output.clustDir,clustName{iF});
    if ~isdir(newDir) 
        mkdir(fullfile(REMORA.ct.CC.output.clustDir,clustName{iF}))
    end
    % If bin level, TPWS files are not needed
    if REMORA.ct.CC.output.saveBinLevelDataTF
        trainTimes =  Tfinal{};
        trainSpec =  Tfinal{};
        trainICI =  Tfinal{};
        trainLabel = Tfinal{};
        outFile = fullfile(newDir,someName);
        save(trainTimes,trainMSN,trainTdiff,trainLabel);
    end
end

for iT = 1:length(Tfinal)
   
end



% if click level, TPWS files ARE needed