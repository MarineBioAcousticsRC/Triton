function ct_cc_clusters_to_zID(hObject,eventdata)

global REMORA
close(REMORA.fig.ct.cc_saveID)

allClickTimes = [];
allClickLabels = [];
allFileIndices = [];

fileNumLarge = {};
for iRow = 1:size(REMORA.ct.CC.output.clickTimes,2)
    fileNumLarge{iRow,1} = repmat(REMORA.ct.CC.output.fileNumExpand(iRow),...
        size(REMORA.ct.CC.output.clickTimes{iRow},1),1);
end
    
for iT = 1:size(REMORA.ct.CC.output.Tfinal)
    % For each cluster:
    % For each bin in the cluster, you need the times of the clicks in the
    % bin. 
    
    % have to make fileNumExpand match clickTimes 

    thisNodeSet = REMORA.ct.CC.output.Tfinal{iT, 8};
     
    theseClickTimes = vertcat(REMORA.ct.CC.output.clickTimes{thisNodeSet});
    theseClickLabels = iT*ones(size(theseClickTimes));
    theseFileIndices = vertcat(fileNumLarge{thisNodeSet});
    
    allClickTimes = [allClickTimes;theseClickTimes];
    allClickLabels = [allClickLabels;theseClickLabels];
    allFileIndices = [allFileIndices;theseFileIndices];
end


REMORA.ct.CC.output.inFileList;
for iTPWS = 1:length(REMORA.ct.CC.output.inFileList)
    TPWSNameStem = regexp(REMORA.ct.CC.output.inFileList(iTPWS).name,...
        '(^.*)_clusters','tokens');
    if isempty(TPWSNameStem)
        error('Bin File name does not match expected format.')
    end
    thisIDSet = allFileIndices==iTPWS;
    zID = [allClickTimes(thisIDSet), allClickLabels(thisIDSet)];
    fNameOut = fullfile(REMORA.ct.CC.output.idDir, char(strcat(TPWSNameStem{1},...
        '_', REMORA.ct.CC.output.fileEnding)));
    labels = REMORA.ct.CC.output.labelStr;
    save(fNameOut,'zID','labels')
    fprintf('File %0.0f of %0.0f saved: %s\n',iTPWS,length(REMORA.ct.CC.output.inFileList),...
        fNameOut)
end

figure(REMORA.fig.ct.cc_postcluster)