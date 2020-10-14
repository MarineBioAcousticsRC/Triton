nCorrectMat = [];
nClassifiedMat = [];
nCorrectMat125 = [];
nClassifiedMat125 = [];
totalClicks = [];
totalClicks125 = [];

IDFileList = dir('H:\SoCal_800_ClustBins_95\DetLabels\SOCAL_E_65*ID1.mat');
daysSet = [];
for iFile = 1:length(IDFileList)
    autoZID = load(fullfile(IDFileList(iFile).folder,IDFileList(iFile).name));
    autoMPP = load(fullfile('K:\SoCal_800_TPWS_done\',strrep(IDFileList(iFile).name,'ID1.mat','TPWS1.mat')),'MPP','MTT');
    daysSet = [daysSet;unique(round(autoMPP.MTT))];
    manualZID = load(fullfile('H:\SoCal_800_ClustBins_95\BinLabels\manualZID_socal_E_65\',IDFileList(iFile).name));
    totalClicks(iFile,1) = length(autoMPP.MTT);
    totalClicks125(iFile,1) = length(autoMPP.MTT(autoMPP.MPP>=125));

    manualZID.typeNames{8} = 'MFA';
    manualZID.typeNames{9} = 'other';
    manualZID.typeNames{10} = 'other';
    
    
    percClassifiedbyBin = [];
    percClassifiedbyRow = [];
    accuracyWhole = [];
    nClassified = [];
    nCorrect = [];
    accuracyCutoffs = [0,25,50,75,85,90,95,98,99]./100;
    for iA = 1:length(accuracyCutoffs)
        autoSet = find(autoZID.zID(:,3)>accuracyCutoffs(iA));
        [C,ia,ib] = intersect(autoZID.zID(autoSet,1),manualZID.zID(:,1));
        nCorrectTF = strcmp(autoZID.typeNames(autoZID.zID(autoSet(ia),2)),manualZID.typeNames(manualZID.zID(ib,2)));
        nClassified(iA) = length(autoSet);
        nCorrect(iA) = length(nCorrectTF);
        %     percClassifiedbyBin(iA) = sum(autoScoreVec>accuracyCutoffs(iA))/totalBins;
        %     percClassifiedbyRow(iA) = sum(autoScoreVec>accuracyCutoffs(iA))/size(autoScoreVec,1);
        %     nCorrect = sum(strcmp(autoLabelVec(autoScoreVec>accuracyCutoffs(iA)),manualLabelVec(autoScoreVec>accuracyCutoffs(iA))));
        accuracyWhole(iA) = sum(nCorrectTF)/nClassified(iA);
    end
    nCorrectMat = [nCorrectMat;nCorrect];
    nClassifiedMat = [nClassifiedMat;nClassified];
    
    
    [~,highAmpIdx,~] = intersect(autoZID.zID(:,1),autoMPP.MTT(autoMPP.MPP>=125));
    percClassifiedbyBin125 = [];
    percClassifiedbyRow125 = [];
    accuracyWhole125 = [];
    nClassified125 = [];
    nCorrect125 = [];
    accuracyCutoffs = [0,25,50,75,85,90,95,98,99]./100;
    autoZID.zID125 = autoZID.zID(highAmpIdx,:);
    for iA = 1:length(accuracyCutoffs)
        autoSet = find(autoZID.zID125(:,3)>accuracyCutoffs(iA));
        [C,ia,ib] = intersect(autoZID.zID125(autoSet,1),manualZID.zID(:,1));
        nCorrectTF125 = strcmp(autoZID.typeNames(autoZID.zID125(autoSet(ia),2)),manualZID.typeNames(manualZID.zID(ib,2)));
        nClassified125(iA) = length(autoSet);
        nCorrect125(iA) = sum(nCorrectTF125);

        %     percClassifiedbyBin(iA) = sum(autoScoreVec>accuracyCutoffs(iA))/totalBins;
        %     percClassifiedbyRow(iA) = sum(autoScoreVec>accuracyCutoffs(iA))/size(autoScoreVec,1);
        %     nCorrect = sum(strcmp(autoLabelVec(autoScoreVec>accuracyCutoffs(iA)),manualLabelVec(autoScoreVec>accuracyCutoffs(iA))));
        accuracyWhole125(iA) = sum(nCorrectTF125)/nClassified125(iA);
    end
    nCorrectMat125 = [nCorrectMat125;nCorrect125];
    nClassifiedMat125 = [nClassifiedMat125;nClassified125];
end

% figure;
% plot(accuracyCutoffs,sum(nCorrectMat,1)./sum(nClassifiedMat,1))
% 
percClassified = sum(nClassifiedMat,1)./sum(totalClicks,1);
percAccuracy = sum(nCorrectMat,1)./sum(nClassifiedMat,1);

percClassified125 = sum(nClassifiedMat125,1)./sum(totalClicks125,1);
percAccuracy125 = sum(nCorrectMat125,1)./sum(nClassifiedMat125,1);

figure(19);

clf;plot(percClassified(2:end-1),percAccuracy(2:end-1),'ok')
hold on
%plot(percClassified125,percAccuracy125,'xk')
xlim([floor(min(percClassified)*100)/100,1]);
ylim([floor(min(percAccuracy)*100)/100,1]);
hold on
myY = get(gca,'ylim');
yLimExtent = myY(2)-myY(1);
for iA = 2:length(accuracyCutoffs)-1
    text((percClassified(iA)+yLimExtent*(.01)),percAccuracy(iA),num2str(accuracyCutoffs(iA)),...
        'HorizontalAlignment','Left','VerticalAlignment','bottom')
%     text((percClassified125(iA)+yLimExtent*(.01)),percAccuracy125(iA),num2str(accuracyCutoffs(iA)),...
%         'HorizontalAlignment','Left','VerticalAlignment','bottom')
end
xlabel('Proportion of Data Classified')
ylabel('Classification Accuracy')
grid on
legend('Minimum Classification Score','location','southwest')
