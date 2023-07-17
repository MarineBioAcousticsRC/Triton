function combine_GPL_output(in_dir,out_dir)

input_dir = in_dir;
output_dir = out_dir;

SearchFileMaskMat = {'*mat'};
SearchPathMaskMat = {input_dir};
SearchRecursiv = 0;

[PathFileListMat, FileListMat, PathListMat] = ...
    utFindFiles(SearchFileMaskMat, SearchPathMaskMat, SearchRecursiv);
MaxandMedianCorr = [];
Duration = [];
allExpComb = [];
SPLppDetection = [];
SPLppNoiseAfter = [];
SPLppNoiseBefore = [];
SPLrmsDetection = [];
SPLrmsNoiseAfter = [];
SPLrmsNoiseBefore = [];
DetectionSamples = [];
DetectionTimes = [];


for i = 1:size(PathFileListMat)
    matfilename = FileListMat{i};
    fprintf('\nLoading %s...\n',matfilename);
    load(PathFileListMat{i});
 if exist('allPpDet','var') == 1
     SPLppDetection = vertcat(SPLppDetection,allPpDet);
SPLppNoiseAfter = vertcat(SPLppNoiseAfter,allPpNAfter);
SPLppNoiseBefore = vertcat(SPLppNoiseBefore,allPpNBefore);
 end
    MaxandMedianCorr = vertcat(MaxandMedianCorr,allCorrVal);
Duration = vertcat(Duration,allDur);
allExpComb = vertcat(allExpComb,allExp);
SPLrmsDetection = vertcat(SPLrmsDetection,allRmsDet);
SPLrmsNoiseAfter = vertcat(SPLrmsNoiseAfter,allRmsNAfter);
SPLrmsNoiseBefore = vertcat(SPLrmsNoiseBefore,allRmsNBefore);
DetectionSamples = vertcat(DetectionSamples,allSmpPts);
DetectionTimes = vertcat(DetectionTimes,bt);
end

allExpStart= dbSerialDateToISO8601(allExpComb(:,1));
allExpEnd= dbSerialDateToISO8601(allExpComb(:,2));

if ~isempty(SPLppNoiseAfter)
full_output = table(MaxandMedianCorr,Duration,allExpStart,allExpEnd,SPLppDetection,...
    SPLppNoiseBefore,SPLppNoiseAfter,SPLrmsDetection,SPLrmsNoiseBefore,...
    SPLrmsNoiseAfter,DetectionSamples);

k = find(DetectionTimes(:,3)==1);
true_output = full_output(k,:);

filename = split(FileListMat{1},'.mat');
csvname = [output_dir,'\',filename{1},'_Explosions.csv'];
else
full_output = table(MaxandMedianCorr,Duration,allExpStart,allExpEnd,...
    SPLrmsDetection,SPLrmsNoiseBefore,...
    SPLrmsNoiseAfter,DetectionSamples);

k = find(DetectionTimes(:,3)==1);
true_output = full_output(k,:);

filename = split(FileListMat{1},'.mat');
csvname = [output_dir,'\',filename{1},'_FishCalls.csv'];
end    

%varnames = {'MaxandMedianCorr','Duration','DetectionStartTime','DetectionEndTime',...
 %   'SPLppDetection','SPLppNoiseBefore','SPLppNoiseAfter','SPLrmsDetection',...
  %  'SPLrmsNoiseBefore','SPLrmsNoiseAfer','DetectionStartSamples','DetectionEndSamples'};
writetable(true_output,csvname);
end