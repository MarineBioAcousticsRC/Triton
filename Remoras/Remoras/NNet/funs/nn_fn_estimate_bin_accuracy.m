% labelList = dir('H:\SoCal_800_ClustBins_95\BinLabels\*_labels.mat');
labelList = dir('F:\Data\Papers\AI_classification\Set used for manuscript\noPm_bin\labels\*_labels.mat');

IDDir = 'G:\SoCal_800_ClustBins_95\BinLabels\manualZID_socal_E_65';
IDList = dir('G:\SoCal_800_ClustBins_95\BinLabels\manualZID_socal_E_65\*ID1.mat');
saveDir ='F:\Data\Papers\AI_classification\Set used for manuscript\noPm_bin\labels\';

typesInBin = {};
autoLabelVec = {};
autoLabelVecSingles = {};
manualLabelVec = {};
manualLabelVecSingles = {};
autoScoreVec = [];
autoScoreVecSingles = [];
totalBins= 0;
nEventsAll = [];
for iFile = 1:length(labelList)
    IDFile = fullfile(IDDir,strrep(labelList(iFile).name,'clusters_PR95_PPmin120_labels.mat','ID1.mat'));
    if ~exist(IDFile,'file')
        continue
    end
    load(fullfile(IDDir,strrep(labelList(iFile).name,'clusters_PR95_PPmin120_labels.mat','ID1.mat')))
    autoLabels = load(fullfile(labelList(iFile).folder,labelList(iFile).name));

    timeEdges = vertcat(autoLabels.binData.tInt);
    totalBins = totalBins+size(timeEdges,1);

    typeNames{8} = 'MFA';
    typeNames{9} = 'other';
    typeNames{10} = 'other';
    for iTime = 1:size(timeEdges,1)
        inBin = (zID(:,1)>=timeEdges(iTime,1)& zID(:,1)<timeEdges(iTime,2));
        typesInBin = unique(zID(inBin,2));
        
        if isempty(typesInBin)
            manualType = {};
        else
            manualType = {(typeNames{typesInBin})}';
            nEvents = [];
            for iN = 1:size(typesInBin,1)
                nEvents(iN,1) = sum(zID(inBin,2)== typesInBin(iN));
                1;
            end
        end
        
        if isnan(autoLabels.binData(iTime).predLabels)
            autoType = {};
        else
            autoType = autoLabels.typeNames(autoLabels.binData(iTime).predLabels);
        end
        if isempty(manualType) && isempty(autoType)
            continue
        end
        
        if size(autoType,1) == 1 && size(manualType,1) ==1
            autoLabelVec = [autoLabelVec;autoType];
            autoLabelVecSingles = [autoLabelVecSingles;autoType];
            nEventsAll = [nEventsAll;nEvents];
            manualLabelVec = [manualLabelVec;manualType];
            manualLabelVecSingles = [manualLabelVecSingles;manualType];
            autoScoreVec = [autoScoreVec; autoLabels.binData(iTime).predLabelScore(1)];
            autoScoreVecSingles = [autoScoreVecSingles; autoLabels.binData(iTime).predLabelScore(1)];
        elseif (size(autoType,1) == 1 && size(manualType,1) ==0)
            autoLabelVec = [autoLabelVec;autoType];
            autoLabelVecSingles = [autoLabelVecSingles;autoType];
            manualLabelVec = [manualLabelVec;'None'];
            nEventsAll = [nEventsAll;0];

            manualLabelVecSingles = [manualLabelVecSingles;'None'];
            autoScoreVec = [autoScoreVec; autoLabels.binData(iTime).predLabelScore(1)];
            autoScoreVecSingles = [autoScoreVecSingles; autoLabels.binData(iTime).predLabelScore(1)];

        elseif size(autoType,1) == 0 && size(manualType,1) ==1
            autoLabelVec = [autoLabelVec;'None'];
            autoLabelVecSingles = [autoLabelVecSingles;'None'];
            manualLabelVec = [manualLabelVec;manualType];
            nEventsAll = [nEventsAll;nEvents];
            manualLabelVecSingles = [manualLabelVecSingles;manualType];
            autoScoreVec = [autoScoreVec; NaN];
            autoScoreVecSingles = [autoScoreVecSingles; NaN];
        else
            %Tally up intersections and diffs
            [C,iA,iB] = intersect(autoType,manualType);
            myScore = autoLabels.binData(iTime).predLabelScore(iA);
            autoLabelVec = [autoLabelVec;C];
            manualLabelVec = [manualLabelVec;C];
            autoScoreVec = [autoScoreVec;myScore];
            nEventsAll = [nEventsAll;nEvents(iB)];

            [C1,iA1] = setdiff(autoType,manualType);
            if ~isempty(C1)
                % bad ID in auto
                myScore = autoLabels.binData(iTime).predLabelScore(iA1);
                autoLabelVec = [autoLabelVec;C1];
                manualLabelVec = [manualLabelVec;repmat({'None'},size(C1,1),1)];
                autoScoreVec = [autoScoreVec;myScore];
                nEventsAll = [nEventsAll;zeros(size(C1))];

            end
            [C2,iA2] = setdiff(manualType,autoType);
            if ~isempty(C2)
                % missed ID in auto
                autoLabelVec = [autoLabelVec;repmat({'None'},size(C2,1),1)];
                manualLabelVec = [manualLabelVec;C2];
                autoScoreVec = [autoScoreVec;repmat(NaN,size(C2,1),1)];
                nEventsAll = [nEventsAll;nEvents(iA2)];

            end
        end
        if size(autoLabelVec,1)~=size(manualLabelVec,1)
            1;
        end
    end
    fprintf('done with file %0.0f of %0.0f\n',iFile,length(labelList))
end
percClassifiedbyBin = [];
percClassifiedbyRow = [];
accuracyWhole = [];
accuracyCutoffs = [0,50,75,85,90,95,98,99]./100;
for iA = 1:length(accuracyCutoffs)
    percClassifiedbyBin(iA) = sum(autoScoreVec>accuracyCutoffs(iA))/totalBins;
    percClassifiedbyRow(iA) = sum(autoScoreVec>accuracyCutoffs(iA))/size(autoScoreVec,1);
    nCorrect = sum(strcmp(autoLabelVec(autoScoreVec>accuracyCutoffs(iA)),manualLabelVec(autoScoreVec>accuracyCutoffs(iA))));
    accuracyWhole(iA) = nCorrect/sum(autoScoreVec>accuracyCutoffs(iA));
end

figure
clf;plot(percClassifiedbyBin,accuracyWhole,'ok')
xlim([floor(min(percClassifiedbyBin)*100)/100,1]);
ylim([floor(min(accuracyWhole)*100)/100,1]);
hold on
myY = get(gca,'ylim');
yLimExtent = myY(2)-myY(1);
for iA = 1:length(accuracyCutoffs)
    text((percClassifiedbyBin(iA)+yLimExtent*(.01)),accuracyWhole(iA),num2str(accuracyCutoffs(iA)),...
        'HorizontalAlignment','Left','VerticalAlignment','bottom')
end
xlabel('Proportion of Data Classified')
ylabel('Classification Accuracy')
grid on
% saveas(gca,fullfile(saveDir,'BinAccuracy.fig'))
% saveas(gca,fullfile(saveDir,'BinAccuracy.png'))
% saveName = fullfile(saveDir,'binAccuracy.mat');
% save(saveName,'autoLabelVec','manualLabelVec','autoScoreVec',...
%     'autoLabelVecSingles','manualLabelVecSingles','autoScoreVecSingles',...
%     'totalBins','labelList','IDDir');
    
noLabel = ~strcmp(manualLabelVec,'Pm')&~strcmp(manualLabelVec,'other')&~strcmp(manualLabelVec,'other1'); 
    %...~strcmp(manualLabelVec,'None')&~strcmp(autoLabelVec,'None')&
plotconfusion(categorical(manualLabelVec(noLabel&(nEventsAll>=25))),categorical(autoLabelVec(noLabel&(nEventsAll>=25))))
% saveas(gca,fullfile(saveDir,'BinConfusion.fig'))
% saveas(gca,fullfile(saveDir,'BinConfusion.png'))

percClassifiedbyBinSingles = [];
percClassifiedbyRowSingles = [];
accuracyWholeSingles = [];
accuracyCutoffs = [0,50,75,85,90,95,98,99]./100;
for iA = 1:length(accuracyCutoffs)
    percClassifiedbyBinSingles(iA) = sum(autoScoreVecSingles>accuracyCutoffs(iA))/totalBins;
    percClassifiedbyRowSingles(iA) = sum(autoScoreVecSingles>accuracyCutoffs(iA))/size(autoScoreVecSingles,1);
    nCorrect = sum(strcmp(autoLabelVecSingles(autoScoreVecSingles>accuracyCutoffs(iA)),manualLabelVecSingles(autoScoreVecSingles>accuracyCutoffs(iA))));
    accuracyWholeSingles(iA) = nCorrect/sum(autoScoreVecSingles>accuracyCutoffs(iA));
end



figure
clf;plot(percClassifiedbyBinSingles,accuracyWholeSingles,'ok')
xlim([floor(min(percClassifiedbyBinSingles)*100)/100,1]);
ylim([floor(min(accuracyWholeSingles)*100)/100,1]);
hold on
myY = get(gca,'ylim');
yLimExtent = myY(2)-myY(1);
for iA = 1:length(accuracyCutoffs)
    text((percClassifiedbyBinSingles(iA)+yLimExtent*(.01)),accuracyWholeSingles(iA),num2str(accuracyCutoffs(iA)),...
        'HorizontalAlignment','Left','VerticalAlignment','bottom')
end
xlabel('Proportion of Data Classified')
ylabel('Classification Accuracy')
grid on
% saveas(gca,fullfile(saveDir,'BinAccuracySingleLabels.fig'))
% saveas(gca,fullfile(saveDir,'BinAccuracySingleLabels.png'))
noLabelSingles = ~strcmp(manualLabelVecSingles,'None')&~strcmp(autoLabelVecSingles,'None');
plotconfusion(categorical(manualLabelVecSingles(noLabelSingles)),categorical(autoLabelVecSingles(noLabelSingles)))
% saveas(gca,fullfile(saveDir,'BinConfusionSingleLabels.fig'))
% saveas(gca,fullfile(saveDir,'BinConfusionSingleLabels.png'))


figure(20);clf
myScoreDistrib = [];
xVec = 0:.01:1;
for iSP = 1:size(autoLabels.typeNames,1)
    
    thisSet = strcmp(autoLabelVec,autoLabels.typeNames{iSP});
    myScoreDistrib(iSP,:) = hist(autoScoreVec(thisSet), xVec);
    
    subplot(2,4,iSP)
    bar(xVec,myScoreDistrib(iSP,:),'BarWidth',1,'FaceColor','k')
    title(autoLabels.typeNames{iSP})
    set(gca,'YScale','log')
    %set(gca,'ytick',[10,100,1000,10000,100000,1000000,10000000])
    grid on
    xlim([0.4,1])
    ylim([0,10^(4)])
end
mxlabel('Classification confidence')
mylabel('Counts')


figure(26);clf
recallSP = [];
precisionSP = [];
manualLabelVecNEvents = manualLabelVec(nEventsAll>25|nEventsAll==0);
autoLabelVecNEvents = autoLabelVec(nEventsAll>25|nEventsAll==0);
autoScoreVecNEvents = autoScoreVec(nEventsAll>25|nEventsAll==0);
for iSP = 1:size(autoLabels.typeNames,1)
    thisManualSet = find(strcmp(manualLabelVecNEvents,autoLabels.typeNames{iSP}));
    thisAutoSet = find(strcmp(autoLabelVecNEvents,autoLabels.typeNames{iSP}));
    nC = 1;
    for iAc = [1,2:length(accuracyCutoffs)]
        myThresh = accuracyCutoffs(iAc);
        autoMatchScores = autoScoreVecNEvents(thisAutoSet);
%         autoMatchScores(isnan(autoMatchScores)) = [];
        [C,ia,ib] = intersect(thisAutoSet,thisManualSet);
        recallNum = sum(autoMatchScores(ia)>=myThresh);
        recallDnum = length(thisManualSet);
       
        precisionDnum = sum(autoMatchScores>=myThresh);
        recallSP(iSP,nC) = recallNum/recallDnum;
        precisionSP(iSP,nC) = recallNum/precisionDnum;
        
        nC = nC+1;
    end
    subplot(2,4,iSP)
    plot(recallSP(iSP,:),precisionSP(iSP,:),'.')
    grid on
    xExtent = diff(get(gca,'xlim'));
    nC = 1;
    for iP = [1,2:length(accuracyCutoffs)]
        
        text((recallSP(iSP,nC)+xExtent*(.01)),precisionSP(iSP,nC),num2str(accuracyCutoffs(iP)),...
            'HorizontalAlignment','left','VerticalAlignment','bottom','FontSize',8)
        nC = nC+1;
    end

end



figure(24);clf
recallSPSingles = [];
precisionSPSingles = [];
for iSP = 1:size(autoLabels.typeNames,1)
    thisManualSet = find(strcmp(manualLabelVecSingles,autoLabels.typeNames{iSP}));
    thisAutoSet = find(strcmp(autoLabelVecSingles,autoLabels.typeNames{iSP}));
    for iAc = 1:length(accuracyCutoffs)
        myThresh = accuracyCutoffs(iAc);
        autoMatchScores = autoScoreVecSingles(thisAutoSet);
%         autoMatchScores(isnan(autoMatchScores)) = [];
        [C,ia,ib] = intersect(thisAutoSet,thisManualSet);
        recallNum = sum(autoMatchScores(ia)>=myThresh);
        recallDnum = length(thisManualSet);
       
        precisionDnum = sum(autoMatchScores>=myThresh);
        recallSPSingles(iSP,iAc) = recallNum/recallDnum;
        precisionSPSingles(iSP,iAc) = recallNum/precisionDnum;
    end
    subplot(2,4,iSP)
    plot(recallSPSingles(iSP,:),precisionSPSingles(iSP,:),'o')
    grid on
end