function [binDataFinal2,fileNumFinal] = ct_cc_modifyBinData(percSim,distThresh,binDataPruned,rmvClusMeanSpecs,fileNum)

%%created by MAZ on 06/09/2020 to try and remove undesirable clusters and
%%things like them before reclustering

% rmvClus = [4,5,6];
% distThresh = 0.1; %how far apart (normalized amplitude) can any one point be on the test spectra
% %and still be considered something to remove (i.e., similar)?
% percSim = 0.5; %how much similarity do you need in order to remove?

rmvCalc = [];
rmvFlag = [];
rmvCalcFinal = [];
rmvFlagFinal = [];
rmvFlagSubBin = [];

% rmvClusMeanEnv = vertcat(Tfinal{rmvClus,10});

%comparisons to everything in binDataPruned- spectra only for now
for iBin = 1:size(binDataPruned,1)
    simCount = 0;
    for iSub = 1:size(binDataPruned(iBin).sumSpec,1)
        testSpec = binDataPruned(iBin).sumSpec(iSub,:);
        specDist = abs(rmvClusMeanSpecs - testSpec);
        for iSpec= 1:size(specDist,1)
            specInt = specDist(iSpec,:);
            simCount = length(specInt(specInt<=distThresh));
            rmvCalcSpec(iSpec) = simCount./length(specInt);
            if rmvCalcSpec(iSpec)<percSim
                rmvFlag = 0;
            else
                rmvFlag = 1;
                break
                
            end
        end
        rmvFlagSub(iSub) = rmvFlag;
        rmvCalc{iSub} = rmvCalcSpec;
        %             if rmvCalc{iSub}>= percSim
        %                 rmvFlag(iSub) = 1;
        %             else
        %                 rmvFlag(iSub) = 0;
        %             end
        
    end
    rmvCalcFinal{iBin} = rmvCalc;
    if any(rmvFlagSub == 1)
        rmvFlagFinal(iBin) = 1;
        rmvFlagSubBin{iBin} = find(rmvFlagSub==1);
    else
        rmvFlagFinal(iBin) = 0;
        rmvFlagSubBin{iBin} = 0;
    end
    rmvFlagSub = [];
end

rmvFlagRemoval = find(rmvFlagFinal==1);

 %remove unwanted types from binDataPruned
binDataFinal = binDataPruned;

for iRmv = 1:size(binDataPruned,1)
    rmvFlag2(iRmv) = 0;
    if ismember(iRmv,rmvFlagRemoval)
        %if number of subBins to remove is same as number of subBins
        if length(rmvFlagSubBin{iRmv})==size(binDataPruned(iRmv).sumSpec,1)
            %get rid of everything in that bin later, once other indexing
            %has finished
            rmvFlag2(iRmv) = iRmv;
        else
            %otherwise, only get rid of data about that subBin
            binDataFinal(iRmv).sumSpec(rmvFlagSubBin{iRmv},:) = [];
            binDataFinal(iRmv).nSpec(rmvFlagSubBin{iRmv}) = [];
            binDataFinal(iRmv).percSpec(rmvFlagSubBin{iRmv}) = [];
            binDataFinal(iRmv).dTT(rmvFlagSubBin{iRmv},:) = [];
            binDataFinal(iRmv).clickRate(rmvFlagSubBin{iRmv},:) = [];
            binDataFinal(iRmv).clickTimes(rmvFlagSubBin{iRmv}) = [];
            binDataFinal(iRmv).clickClusterIds(rmvFlagSubBin{iRmv}) = [];
            binDataFinal(iRmv).envDur(rmvFlagSubBin{iRmv},:) = [];
            binDataFinal(iRmv).envMean(rmvFlagSubBin{iRmv},:) = [];
            rmvFlag2(iRmv) = 0;
        end
    end
end

rmvFlag2(rmvFlag2==0)=[];
goodOnes = setdiff([1:size(binDataPruned,1)],rmvFlag2);

binDataFinal2 = binDataFinal(goodOnes);
fileNumFinal = fileNum(goodOnes);

%just gives number of bins where something was removed from it
totalRemoved = length(rmvFlagFinal(rmvFlagFinal==1));
rmvtxt = ['Total bins removed from potential clustering = ',num2str(totalRemoved)];
disp(rmvtxt)
