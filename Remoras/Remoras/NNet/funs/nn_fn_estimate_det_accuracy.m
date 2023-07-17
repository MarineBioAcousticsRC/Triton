nCorrectMat = [];
nClassifiedMat = [];
nCorrectMat125 = [];
nClassifiedMat125 = [];
totalClicks = [];
totalClicks125 = [];
zIDComparison = [];
%IDFileList = dir('G:\SoCal_800_ClustBins_95\DetLabels\SOCAL_E_65*ID1.mat');
IDFileList = dir('F:\Data\Papers\AI_classification\Set used for manuscript\det_noPm_prune_staticNorm\labels\SOCAL_E_65*ID1.mat');
%IDFileList = dir('F:\Data\Papers\AI_classification\Set used for manuscript\After_rounding_fix_det2\Train_withNormalization_v3\Labels\SOCAL_E_65*ID1.mat')
daysSet = [];
procFileList = {};
myCertAll = [];
accuracyWholeMat = [];
accuracyNum = [];
accuracyDnum = [];
precisionDnum = [];
recallDnum = [];
accuracySP ={};
precisionSP = {};
recallSP = {};
for iFile = 1:length(IDFileList)
    
    autoZID = load(fullfile(IDFileList(iFile).folder,IDFileList(iFile).name));
    autoMPP = load(fullfile('K:\SoCal_800_TPWS_done\',strrep(IDFileList(iFile).name,'ID1.mat','TPWS1.mat')),'MTT');
    daysSet = [daysSet;unique(round(autoMPP.MTT))];
    thisGroundtruth = fullfile('G:\SoCal_800_ClustBins_95\BinLabels\manualZID_socal_E_65\',IDFileList(iFile).name);
    if ~isfile(thisGroundtruth)
        fprintf('No groundtruth file matching %s\n',IDFileList(iFile).name)
        continue
    else
        fprintf('Processing file %s\n',IDFileList(iFile).name)
        procFileList = [procFileList;IDFileList(iFile).name];
    end
    
    manualZID = load(thisGroundtruth);
    if ~isfield(manualZID,'typeNames')
        manualZID.typeNames = oldTypeNames;
    end
    totalClicks(iFile,1) = length(autoMPP.MTT);
    % totalClicks125(iFile,1) = length(autoMPP.MTT(autoMPP.MPP>=125));

    %manualZID.typeNames{5} = 'other';

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
        nCorrect(iA) = sum(nCorrectTF);
        accuracyWhole(iA) = nCorrect(iA)/nClassified(iA);

        for iSP = 1:length(autoZID.typeNames)
            thisTypeAndConf = find(strcmp(autoZID.typeNames(autoZID.zID(autoSet,2)),autoZID.typeNames{iSP}));

            thisTypeTrue = find(strcmp(manualZID.typeNames(manualZID.zID(:,2)),autoZID.typeNames{iSP}));
            trueTimes = manualZID.zID(thisTypeTrue,1);
            detectedTimes = autoZID.zID(autoSet(thisTypeAndConf),1);
%             [C,ia,ib] = intersect(autoZID.zID(autoSet(thisTypeAndConf),1),manualZID.zID(:,1));
%             nCorrectTFSP = strcmp(autoZID.typeNames(autoZID.zID(autoSet(thisTypeAndConf(ia)),2)),manualZID.typeNames(manualZID.zID(ib,2)));
%             nClassifiedSP{iSP}(iA) = length(thisTypeAndConf);
%             nCorrectSP{iSP}(iA) = sum(nCorrectTFSP);
%             accuracySP{iSP}(iA) = nCorrectSP{iSP}(iA)/nClassifiedSP{iSP}(iA);
            [~,ia2,ib2] = intersect(detectedTimes,trueTimes);
            
            precisionNum{iSP,iFile}(iA) = length(ia2);
            precisionDnum{iSP,iFile}(iA) = length(thisTypeAndConf); 
            recallDnum {iSP,iFile}(iA) = length(thisTypeTrue);
            precisionSP{iSP,iFile}(iA) = length(ia2)/length(thisTypeAndConf);
            recallSP{iSP,iFile}(iA) =  length(ia2)/length(thisTypeTrue);
        end
        %     percClassifiedbyBin(iA) = sum(autoScoreVec>accuracyCutoffs(iA))/totalBins;
        %     percClassifiedbyRow(iA) = sum(autoScoreVec>accuracyCutoffs(iA))/size(autoScoreVec,1);
        %     nCorrect = sum(strcmp(autoLabelVec(autoScoreVec>accuracyCutoffs(iA)),manualLabelVec(autoScoreVec>accuracyCutoffs(iA))));
    end
    nCorrectMat = [nCorrectMat;nCorrect];
    nClassifiedMat = [nClassifiedMat;nClassified];
    accuracyWholeMat = [accuracyWholeMat;accuracyWhole];
    [C,ia,ib] = intersect(autoZID.zID(:,1),manualZID.zID(:,1));

    zIDComparison = [zIDComparison;[autoZID.typeNames(autoZID.zID(ia,2)),manualZID.typeNames(manualZID.zID(ib,2))]];
    
    CMat{iFile} = confusionmat(categorical(manualZID.typeNames(manualZID.zID(ib,2))),categorical(autoZID.typeNames(autoZID.zID(ia,2))));

%     [~,highAmpIdx,~] = intersect(autoZID.zID(:,1),autoMPP.MTT(autoMPP.MPP>=125));
%     percClassifiedbyBin125 = [];
%     percClassifiedbyRow125 = [];
%     accuracyWhole125 = [];
%     nClassified125 = [];
%     nCorrect125 = [];
%     accuracyCutoffs = [0,25,50,75,85,90,95,98,99]./100;
%     autoZID.zID125 = autoZID.zID(highAmpIdx,:);
%     for iA = 1:length(accuracyCutoffs)
%         autoSet = find(autoZID.zID125(:,3)>accuracyCutoffs(iA));
%         [C,ia,ib] = intersect(autoZID.zID125(autoSet,1),manualZID.zID(:,1));
%         nCorrectTF125 = strcmp(autoZID.typeNames(autoZID.zID125(autoSet(ia),2)),manualZID.typeNames(manualZID.zID(ib,2)));
%         nClassified125(iA) = length(autoSet);
%         nCorrect125(iA) = sum(nCorrectTF125);
% 
%         %     percClassifiedbyBin(iA) = sum(autoScoreVec>accuracyCutoffs(iA))/totalBins;
%         %     percClassifiedbyRow(iA) = sum(autoScoreVec>accuracyCutoffs(iA))/size(autoScoreVec,1);
%         %     nCorrect = sum(strcmp(autoLabelVec(autoScoreVec>accuracyCutoffs(iA)),manualLabelVec(autoScoreVec>accuracyCutoffs(iA))));
%         accuracyWhole125(iA) = sum(nCorrectTF125)/nClassified125(iA);
%     end
%     nCorrectMat125 = [nCorrectMat125;nCorrect125];
%     nClassifiedMat125 = [nClassifiedMat125;nClassified125];
    oldTypeNames = manualZID.typeNames;
    
    xVec = 0:.01:1;
    myCert = [];
    for iSP = 1:length(autoZID.typeNames)
        thisIdx = (autoZID.zID(:,2)==iSP);
        myCert(iSP,:) = hist(autoZID.zID(thisIdx,3),xVec);
    end
    if ~isempty(myCertAll)
        myCertAll = myCertAll+myCert;
    else
        myCertAll = myCert;
    end
end

figure(20)
% plot(accuracyCutoffs,sum(nCorrectMat,1)./sum(nClassifiedMat,1))
% confusionmat(categorical(zIDComparison(:,2)),categorical(zIDComparison(:,1)))

percClassified = sum(nClassifiedMat,1)./sum(totalClicks,1);
percAccuracy = sum(nCorrectMat,1)./sum(nClassifiedMat,1);
% 
% percClassified125 = sum(nClassifiedMat125,1)./sum(totalClicks125,1);
% percAccuracy125 = sum(nCorrectMat125,1)./sum(nClassifiedMat125,1);

figure(19);

clf;plot(percClassified(2:end-1),percAccuracy(2:end-1),'ok')
hold on
% plot(percClassified125,percAccuracy125,'xk')
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


figure(20);clf
myCertNorm = myCertAll./max(myCertAll,[],2);
for iSP = 1:size(autoZID.typeNames,1)
    subplot(2,4,iSP)
    semilogy(xVec*100,myCertAll(iSP,:));
    %set(gca,'xticklabel',str2double(get(gca,'xTickLabel'))/100)
    title(autoZID.typeNames{iSP})
    set(gca,'ytick',[10,100,1000,10000,100000,1000000,10000000])
    grid on
    ylim([0,10^(6.3)])
end
mxlabel('Classification confidence')
mylabel('Counts')
grid on

recallDnumSum = zeros(size(autoZID.typeNames,1),length(accuracyCutoffs));
precisionDnumSum = zeros(size(autoZID.typeNames,1),length(accuracyCutoffs));
precisionNumSum = zeros(size(autoZID.typeNames,1),length(accuracyCutoffs));
for J1 = 1:length(accuracyCutoffs)
    for K1 = 1:size(autoZID.typeNames,1)
        for L1= 1:size(recallDnum,2)
            if ~isempty(recallDnum{K1,L1})
                recallDnumSum(K1,J1) = recallDnumSum(K1,J1) +recallDnum{K1,L1}(J1);
                precisionDnumSum(K1,J1) = precisionDnumSum(K1,J1) +precisionDnum{K1,L1}(J1);
                precisionNumSum(K1,J1) = precisionNumSum(K1,J1) +precisionNum{K1,L1}(J1);
            end
        end
    end
end
figure(62)
recallBySp = precisionNumSum./recallDnumSum;
precisionBySp = precisionNumSum./precisionDnumSum;
for P1 = 1:size(autoZID.typeNames,1)
    
    subplot(2,4,P1)
    plot(recallBySp(P1,[1,3:8]),precisionBySp(P1,[1,3:8]),'.')
    xExtent = diff(get(gca,'xlim'));
    for iP = [1,3:8]
        
        text((recallBySp(P1,iP)+xExtent*(.01)),precisionBySp(P1,iP),num2str(accuracyCutoffs(iP)),...
            'HorizontalAlignment','left','VerticalAlignment','bottom','FontSize',8)
    end
    grid on
%     xOrigLim = get(gca,'xlim');
%     xlim([min(xOrigLim(1),.9),1])
%     yOrigLim = get(gca,'ylim');
%     ylim([min(yOrigLim(1),.9),1])
% 
% %     ylim([0,1])    
% %     title(autoZID.typeNames{P1})
%     xOrigLim = get(gca,'xlim');
%     yOrigLim = get(gca,'ylim');
%     set(gca,'xtick',xOrigLim(1):(xOrigLim(2)-xOrigLim(1))/5:xOrigLim(2))
% 
%     set(gca,'ytick',yOrigLim(1):(yOrigLim(2)-yOrigLim(1))/5:yOrigLim(2))
end
mxlabel('Recall')
mylabel('Precision')
% 
% confusionByHand = [];
% for IB = 1:size(autoZID.typeNames,1)
%     myType = strcmp(zIDComparison(:,2),autoZID.typeNames{IB});
%     [C,~,ic] = unique(zIDComparison(find(myType),1));
%     [myCounts,edges] = histcounts(ic,1:8);
%     confusionByHand(IB,:) = myCounts./sum(myCounts);
%     nCounted(IB,:) = sum(myCounts);
% end
% confusionByHand = confusionByHand*100;
zIDComparison(strcmp(zIDComparison(:,2),'Pm'),:)=[];
zIDComparison(strcmp(zIDComparison(:,2),'other'),:)=[];

nS = 1;
nE = 100000;
cumMat = zeros(7,7);
nSteps = ceil(length(zIDComparison)/100000);
for iS = 1:nSteps
    myMat = confusionmat(zIDComparison(nS:min(nE,length(zIDComparison)),2),zIDComparison(nS:min(nE,length(zIDComparison)),1),'order',autoZID.typeNames);
    cumMat = myMat+cumMat;
    nS = nS + 100000;
    nE = nE + 100000;
    disp(sprintf('Done with confusion increment %0.0f of %0.0f',iS,nSteps))
end

cumMatPerc = round(10000*(100*(cumMat/length(zIDComparison))))/10000;
totalCorrect = 0;
MatSide = [];
MatBottom = [];
for i7 = 1:7
MatSide(i7) = cumMat(i7,i7)/sum(cumMat(i7,:));
MatBottom(i7) = cumMat(i7,i7)/sum(cumMat(:,i7));
totalCorrect = totalCorrect+cumMat(i7,i7);
end

myMat = [[cumMat,100*MatSide'];100*([MatBottom,totalCorrect/sum(sum(cumMat))])];