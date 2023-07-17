function compDetOutput

%load true explosions
[infile,inpath]=uigetfile('*.xls','Please select TRUE detections');%get excel file to read
if isequal(infile,0)
    disp('Cancel button pushed');
    return
end

%read the file into 3 matrices-- numeric, text, and raw cell array
[excelDates, txt, raw] = xlsread(fullfile(inpath,infile));

%convert excel datenums to matlab datenums (different pivot year)
trueStart = ones(size(excelDates)).*datenum('30-Dec-1899') ...
    + excelDates;
%fix incorrect years due to mess up with xls mat conversion
trueStart = datevec(trueStart);
wrong = find(trueStart(:,1)>2014);
trueStart(wrong,1) = trueStart(wrong,1)-1900;
trueStart = datenum(trueStart);

%load detector output
BaseDir = uigetdir('G:\','Please select disk with detector output');

SearchFileMask = {'*.txt'};
SearchPathMask = {BaseDir};
SearchRecursiv = 0;

[PathFileList, FileList, PathList] = ...
    utFindFiles(SearchFileMask, SearchPathMask, SearchRecursiv);

%put all detections and their values in one large matrix
allDetections = [];
for fidx = 1:size(FileList,1)
    file = PathFileList{fidx};
    delimiterIn = ' ';
    headerlinesIn = 1;
    A = importdata(file,delimiterIn,headerlinesIn);
    allDetections = [allDetections;A.data];
end
col = A.colheaders;
detStart = allDetections(:,1);
% detStart = ones(size(detStart)).*datenum('30-Dec-1899') ...
%     + detStart;
%eliminate trueStart after end of detections
i = find(trueStart > detStart(end),1,'first');
trueStart(i:end) = [];

%check if there is a detection +/- offset from the true explosions
offset = datenum([0 0 0 0 0 1]);
allDetections(:,end+1) = 0;
for tidx = 1:length(trueStart)
    match = find(detStart > trueStart(tidx)-offset & ...
        detStart < trueStart(tidx)+offset);
    if ~isempty(match)
        allDetections(match(1),end) = 1;
        trueStart(tidx,2) = 1;
    else
        trueStart(tidx,2) = 0;
    end
end

nMatch = find(allDetections(:,end) == 1);
NoMatch = find(trueStart(:,2) == 0);
NoMatchDates = trueStart(NoMatch,1);

% excelStart = trueStart(:,1) - ones(size(trueStart(:,1))).*datenum('30-Dec-1899');
% excelStart(:,2) = trueStart(:,2);


%eliminate and/or determine false detections
%1) eliminate detections on 8/28, something wrong with LTSA, file missing
delDate = find(detStart > datenum([2012 8 28 0 0 0]) & ...
    detStart < datenum([2012 8 29 0 0 0]));
allDetections(delDate,:) = [];

%2) compute delta rms and pp after each segment, plot histogram to
%determine cut
drmsAS = allDetections(:,9) - allDetections(:,10);
dppAS = allDetections(:,6) - allDetections(:,7);
drmsBS = allDetections(:,9) - allDetections(:,11);
dppBS = allDetections(:,6) - allDetections(:,8);
dur = allDetections(:,3);
corrVal = allDetections(:,4);
medianC2 = allDetections(:,5);

trueIdx = find(allDetections(:,end) == 1);
falseIdx = find(allDetections(:,end) == 0);

true_drmsAS = drmsAS(trueIdx);
false_drmsAS = drmsAS(falseIdx);

true_dppAS = dppAS(trueIdx);
false_dppAS = dppAS(falseIdx);

true_drmsBS = drmsBS(trueIdx);
false_drmsBS = drmsBS(falseIdx);

true_dppBS = dppBS(trueIdx);
false_dppBS = dppBS(falseIdx);

true_corrVal = corrVal(trueIdx);
false_corrVal = corrVal(falseIdx);

true_medianC2 = medianC2(trueIdx);
false_medianC2 = medianC2(falseIdx);

true_dur = dur(trueIdx);
false_dur = dur(falseIdx);

figure(1)
vecRms = -50:0.1:100;
subplot(2,1,1)
hist(true_drmsAS,vecRms)
title('true drmsAS')
xlim([-5 5])
subplot(2,1,2)
hist(false_drmsAS,vecRms)
title('false drmsAS')
xlim([-5 5])

figure(2)
vecRms = -50:0.1:100;
subplot(2,1,1)
hist(true_dppAS,vecRms)
title('true dppAS')
xlim([-5 5])
subplot(2,1,2)
hist(false_dppAS,vecRms)
title('false dppAS')
xlim([-5 5])

figure(3)
vecRms = -50:0.1:100;
subplot(2,1,1)
hist(true_drmsBS,vecRms)
title('true drmsBS')
xlim([-10 10])
subplot(2,1,2)
hist(false_drmsBS,vecRms)
title('false drmsBS')
xlim([-10 10])

figure(4)
vecRms = -50:0.1:100;
subplot(2,1,1)
hist(true_dppBS,vecRms)
title('true dppBS')
xlim([-10 10])
subplot(2,1,2)
hist(false_dppBS,vecRms)
title('false dppBS')
xlim([-10 10])

figure(5)
vecDur = 0:0.001:0.7;
subplot(2,1,1)
hist(true_dur,vecDur)
title('true dur')
xlim([0 0.7])
subplot(2,1,2)
hist(false_dur,vecDur)
title('false dur')
xlim([0 0.7])

figure(6)
vecCorr = 0:0.0000001:0.003;
subplot(2,1,1)
hist(true_corrVal,vecCorr)
title('true corrVal')
xlim([0 0.00005])
subplot(2,1,2)
hist(false_corrVal,vecCorr)
title('false corrVal')
xlim([0 0.00005])

figure(7)
vecMC2 = 0:0.0000001:0.0006;
subplot(2,1,1)
hist(true_medianC2,vecMC2)
title('true medianC2')
xlim([0 0.00003])
subplot(2,1,2)
hist(false_medianC2,vecMC2)
title('false medianC2')
xlim([0 0.00003])


% %eliminate for signal vs. noise after signal and duration
% rmsAS = 1.5; %rms noise after signal <rmsAS (dB) difference will be eliminated
% ppAS = 4; %pp noise after singal <ppAS (dB) difference will be eliminated
% dur_s = 0.625; %duration >= dur_s (s) will be eliminated
% mc2 = 0.00002; %median square correlation coefficient >= mc2 will be eliminated

%eliminate for signal vs. noise after signal and duration
rmsAS = 1.5; %rms noise after signal <rmsAS (dB) difference will be eliminated
ppAS = 4; %pp noise after singal <ppAS (dB) difference will be eliminated
durLong_s = 0.55; %duration >= durAfter_s (s) will be eliminated
durShort_s = 0.03; %duration >= dur_s (s) will be eliminated
rmsBS = 1;
ppBS = 3;


% allDetections_bkp = allDetections;
delRmsAS = find(drmsAS<rmsAS); %239,028
delPpAS = find(dppAS<ppAS); %249,166
delRmsBS = find(drmsBS<rmsBS); %214,914
delPpBS = find(dppBS<ppBS); %230,409
delDur = find(dur>=durLong_s | dur<=durShort_s); %230,729

delUnion = unique([delRmsAS;delPpAS;delRmsBS;delPpBS;delDur]); %276,145

%missed detections
%8329 original, 7430 after elimination -> 89.21% remained

%delete false detections
%301,675 original, 26429 after elimination -> 8.76% remained, a lot of
%those being impulsive sounds similar to explosions, ~5% real explosions,
%~13% disk writes

allDetections(delUnion,:) = [];
falseIdx = find(allDetections(:,end)==0);
trueIdx = find(allDetections(:,end)==1);
falseStart = allDetections(falseIdx,1);
falseDur = allDetections(falseIdx,3);

excelStart = falseStart(:,1) - ones(size(falseStart(:,1))).*datenum('30-Dec-1899');

true_drmsBS = drmsBS(trueIdx);
false_drmsBS = drmsBS(falseIdx);

true_dppBS = dppBS(trueIdx);
false_dppBS = dppBS(falseIdx);

true_dur = dur(trueIdx);
false_dur = dur(falseIdx);


1;