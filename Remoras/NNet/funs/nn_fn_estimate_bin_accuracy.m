% labelList = dir('H:\SoCal_800_ClustBins_95\BinLabels\*_labels.mat');
labelList = dir('F:\Data\Papers\AI_classification\Set used for manuscript\After_rounding_fix_bin2\Labels\*_labels.mat');

IDDir = 'G:\SoCal_800_ClustBins_95\BinLabels\manualZID_socal_E_65';
IDList = dir('G:\SoCal_800_ClustBins_95\BinLabels\manualZID_socal_E_65\*ID1.mat');
saveDir = 'F:\Data\Papers\AI_classification\Set used for manuscript\After_rounding_fix_bin2\Labels\';

typesInBin = {};
autoLabelVec = {};
autoLabelVecSingles = {};
manualLabelVec = {};
manualLabelVecSingles = {};
autoScoreVec = [];
autoScoreVecSingles = [];
totalBins= 0;
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
    typeNames{10} = 'other1';
    for iTime = 1:size(timeEdges,1)
        inBin = (zID(:,1)>=timeEdges(iTime,1)& zID(:,1)<timeEdges(iTime,2));
        typesInBin = unique(zID(inBin,2));
        if isempty(typesInBin)
            manualType = {};
        else
            manualType = {(typeNames{typesInBin})}';
            if strcmp(manualType,'MFA')
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
            manualLabelVec = [manualLabelVec;manualType];
            manualLabelVecSingles = [manualLabelVecSingles;manualType];
            autoScoreVec = [autoScoreVec; autoLabels.binData(iTime).predLabelScore(1)];
            autoScoreVecSingles = [autoScoreVecSingles; autoLabels.binData(iTime).predLabelScore(1)];
        elseif (size(autoType,1) == 1 && size(manualType,1) ==0)
            autoLabelVec = [autoLabelVec;autoType];
            autoLabelVecSingles = [autoLabelVecSingles;autoType];
            manualLabelVec = [manualLabelVec;'None'];
            manualLabelVecSingles = [manualLabelVecSingles;'None'];
            autoScoreVec = [autoScoreVec; autoLabels.binData(iTime).predLabelScore(1)];
            autoScoreVecSingles = [autoScoreVecSingles; autoLabels.binData(iTime).predLabelScore(1)];

        elseif size(autoType,1) == 0 && size(manualType,1) ==1
            autoLabelVec = [autoLabelVec;'None'];
            autoLabelVecSingles = [autoLabelVecSingles;'None'];
            manualLabelVec = [manualLabelVec;manualType];
            manualLabelVecSingles = [manualLabelVecSingles;manualType];
            autoScoreVec = [autoScoreVec; NaN];
            autoScoreVecSingles = [autoScoreVecSingles; NaN];
        else
            %Tally up intersections and diffs
            [C,iA,~] = intersect(autoType,manualType);
            myScore = autoLabels.binData(iTime).predLabelScore(iA);
            autoLabelVec = [autoLabelVec;C];
            manualLabelVec = [manualLabelVec;C];
            autoScoreVec = [autoScoreVec;myScore];
            [C1,iA1] = setdiff(autoType,manualType);
            if ~isempty(C1)
                % bad ID in auto
                myScore = autoLabels.binData(iTime).predLabelScore(iA1);
                autoLabelVec = [autoLabelVec;C1];
                manualLabelVec = [manualLabelVec;repmat({'None'},size(C1,1),1)];
                autoScoreVec = [autoScoreVec;myScore];
            end
            [C2,iA2] = setdiff(manualType,autoType);
            if ~isempty(C2)
                % missed ID in auto
                autoLabelVec = [autoLabelVec;repmat({'None'},size(C2,1),1)];
                manualLabelVec = [manualLabelVec;C2];
                autoScoreVec = [autoScoreVec;repmat(NaN,size(C2,1),1)];
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
saveas(gca,fullfile(saveDir,'BinAccuracy.fig'))
saveas(gca,fullfile(saveDir,'BinAccuracy.png'))
saveName = fullfile(saveDir,'binAccuracy.mat');
save(saveName,'autoLabelVec','manualLabelVec','autoScoreVec',...
    'autoLabelVecSingles','manualLabelVecSingles','autoScoreVecSingles',...
    'totalBins','labelList','IDDir');
    
noLabel = ~strcmp(manualLabelVec,'None')&~strcmp(autoLabelVec,'None');
plotconfusion(categorical(manualLabelVec(noLabel)),categorical(autoLabelVec(noLabel)))
saveas(gca,fullfile(saveDir,'BinConfusion.fig'))
saveas(gca,fullfile(saveDir,'BinConfusion.png'))

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
saveas(gca,fullfile(saveDir,'BinAccuracySingleLabels.fig'))
saveas(gca,fullfile(saveDir,'BinAccuracySingleLabels.png'))
noLabelSingles = ~strcmp(manualLabelVecSingles,'None')&~strcmp(autoLabelVecSingles,'None');
plotconfusion(categorical(manualLabelVecSingles(noLabelSingles)),categorical(autoLabelVecSingles(noLabelSingles)))
saveas(gca,fullfile(saveDir,'BinConfusionSingleLabels.fig'))
saveas(gca,fullfile(saveDir,'BinConfusionSingleLabels.png'))

