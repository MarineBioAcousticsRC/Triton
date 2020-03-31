function explosion_evaluation

%get excel file to read
[infile,inpath]=uigetfile('*.xls','Select file with true detections');
if isequal(infile,0)
    disp('Cancelled button pushed');
    return
end

cd(inpath)

%read the file into 3 matrices-- numeric, text, and raw cell array
[num, txt, raw] = xlsread([inpath '\' infile]);
hdr = raw(1,:);         %column headers, not used later
excelDates = num(:,1:2);                %numeric array contains datenums

%convert excel datenums to matlab datenums (different pivot year)
trueDet = ones(size(excelDates)).*datenum('30-Dec-1899') ...
    + excelDates;

trueDur = num(:,3);
trueIei = num(:,4);
truePpDet = num(:,5);
truePpNAfter = num(:,6);
truePpNBefore = num(:,7);
trueRmsDet = num(:,8);
trueRmsNAfter = num(:,9);
trueRmsNBefore = num(:,10);

%get excel file to read
[infile,inpath]=uigetfile('*.xls','Select file with false detections');
if isequal(infile,0)
    disp('Cancelled button pushed');
    return
end

cd(inpath)

%read the file into 3 matrices-- numeric, text, and raw cell array
[num, txt, raw] = xlsread([inpath '\' infile]);
hdr = raw(1,:);         %column headers, not used later
excelDates = num(:,1:2);                %numeric array contains datenums

%convert excel datenums to matlab datenums (different pivot year)
falseDet = ones(size(excelDates)).*datenum('30-Dec-1899') ...
    + excelDates;

falseDur = num(:,3);
falseIei = num(:,4);
falsePpDet = num(:,5);
falsePpNAfter = num(:,6);
falsePpNBefore = num(:,7);
falseRmsDet = num(:,8);
falseRmsNAfter = num(:,9);
falseRmsNBefore = num(:,10);

%compute histogram duration
vecDur = 0:0.001:0.7;
figure(1)
subplot(2,1,1)
hist(trueDur,vecDur)
title('true duration')
xlabel('duration (s)')
xlim([0 0.7])
subplot(2,1,2)
hist(falseDur,vecDur)
title('false duration')
xlabel('duration (s)')
xlim([0 0.7])

%eliminate dur>0.625
nfalseDur = find(falseDur>0.625); %n=7172; ~52%
ntrueDur = find(trueDur>0.625); %n=15; ~1% (echos?)

%compute histogram "inter-explosion" interval
falseStart = sort(falseDet(:,1));
trueStart = sort(trueDet(:,1));
falseIei = (diff(falseStart))*24*60*60;
trueIei = (diff(trueStart))*24*60*60;
p = [10 50 90];
percIei = prctile(falseIei,p);

vecIei = 0:0.1:20;
figure(2)
subplot(2,1,1)
hist(trueIei,vecIei)
title('true duration')
xlabel('duration (s)')
xlim([0 2])
subplot(2,1,2)
hist(falseIei,vecIei)
title('false duration')
xlabel('duration (s)')
xlim([0 2])

%eliminate iei<=0.6
nfalseIei = find(falseIei<=0.6); %n=8669; ~63%
ntrueIei = find(trueIei<=0.6); %n=74; ~6% (echos?)

nfalseUnion = union(nfalseIei,nfalseDur); %n=11315; ~82%
ntrueUnion = union(ntrueIei,ntrueDur); %n= 88; ~7%

trueElimDates = trueDet(ntrueUnion,:);
for idx = 1:size(ntrueUnion)
    trueElimAll{idx} = raw{ntrueUnion(idx)+1,11};
end
excelStart = trueElimDates(:,1) - ones(size(trueElimDates(:,1))).*datenum('30-Dec-1899');
excelEnd =  trueElimDates(:,2) - ones(size(trueElimDates(:,1))).*datenum('30-Dec-1899');

%evaluate amplitude changes between signal and noise before and after
trueDppBS = truePpDet - truePpNBefore;
trueDppAS = truePpDet - truePpNAfter;
trueDppBA = truePpNAfter - truePpNBefore;
trueDrmsBS = trueRmsDet - trueRmsNBefore;
trueDrmsAS = trueRmsDet - trueRmsNAfter;
trueDrmsBA = trueRmsNAfter - trueRmsNBefore;

falseDppBS = falsePpDet - falsePpNBefore;
falseDppAS = falsePpDet - falsePpNAfter;
falseDppBA = falsePpNAfter - falsePpNBefore;
falseDrmsBS = falseRmsDet - falseRmsNBefore;
falseDrmsAS = falseRmsDet - falseRmsNAfter;
falseDrmsBA = falseRmsNAfter - falseRmsNBefore;

%plot and calculate pp values
vecamp = -50:1:50;
figure(3)
subplot(2,1,1)
hist(trueDppBS,vecamp)
title('diff signal and noise before')
xlabel('duration (s)')
% xlim([0 2])
subplot(2,1,2)
hist(falseDppBS,vecamp)
title('false duration')
xlabel('diff signal and noise before')
% xlim([0 2])

figure(4)
subplot(2,1,1)
hist(trueDppAS,vecamp)
title('diff signal and noise after')
xlabel('duration (s)')
% xlim([0 2])
subplot(2,1,2)
hist(falseDppAS,vecamp)
title('false duration')
xlabel('diff signal and noise after')
% xlim([0 2])

figure(5)
subplot(2,1,1)
hist(trueDppBA,vecamp)
title('diff noise before and noise after')
xlabel('duration (s)')
% xlim([0 2])
subplot(2,1,2)
hist(falseDppBA,vecamp)
title('false duration')
xlabel('diff noise before and noise after')
% xlim([0 2])

%finer scale for noise before and after in comparison to signal
vecamp = -50:0.1:50;
figure(6)
subplot(2,1,1)
hist(trueDppBS,vecamp)
title('diff signal and noise before')
xlabel('duration (s)')
xlim([-10 10])
subplot(2,1,2)
hist(falseDppBS,vecamp)
title('false duration')
xlabel('diff signal and noise before')
xlim([-10 10])

figure(7)
subplot(2,1,1)
hist(trueDppAS,vecamp)
title('diff signal and noise after')
xlabel('duration (s)')
xlim([-10 10])
subplot(2,1,2)
hist(falseDppAS,vecamp)
title('false duration')
xlabel('diff signal and noise after')
xlim([-10 10])

%eliminate dppAS<2dB
nfalseDppAS = find(falseDppAS<2); %n=12777; ~92%
ntrueDppAS = find(trueDppAS<2); %n=52; ~4%

nfalseDppBS = find(falseDppBS<2); %n=12800; ~93%
ntrueDppBS = find(trueDppBS<2); %n=85; ~7%

%plot and calculate rms values
vecamp = -50:1:50;
figure(3)
subplot(2,1,1)
hist(trueDrmsBS,vecamp)
title('diff signal and noise before')
xlabel('duration (s)')
% xlim([0 2])
subplot(2,1,2)
hist(falseDrmsBS,vecamp)
title('false duration')
xlabel('diff signal and noise before')
% xlim([0 2])

figure(4)
subplot(2,1,1)
hist(trueDrmsAS,vecamp)
title('diff signal and noise after')
xlabel('duration (s)')
% xlim([0 2])
subplot(2,1,2)
hist(falseDrmsAS,vecamp)
title('false duration')
xlabel('diff signal and noise after')
% xlim([0 2])

figure(5)
subplot(2,1,1)
hist(trueDrmsBA,vecamp)
title('diff noise before and noise after')
xlabel('duration (s)')
% xlim([0 2])
subplot(2,1,2)
hist(falseDrmsBA,vecamp)
title('false duration')
xlabel('diff noise before and noise after')
% xlim([0 2])

%finer scale for noise before and after in comparison to signal
vecamp = -50:0.1:50;
figure(6)
subplot(2,1,1)
hist(trueDrmsBS,vecamp)
title('diff signal and noise before')
xlabel('duration (s)')
xlim([-10 10])
subplot(2,1,2)
hist(falseDrmsBS,vecamp)
title('false duration')
xlabel('diff signal and noise before')
xlim([-10 10])

figure(7)
subplot(2,1,1)
hist(trueDrmsAS,vecamp)
title('diff signal and noise after')
xlabel('duration (s)')
xlim([-10 10])
subplot(2,1,2)
hist(falseDrmsAS,vecamp)
title('false duration')
xlabel('diff signal and noise after')
xlim([-10 10])

%eliminate drmsAS<2dB
nfalseDrmsAS = find(falseDrmsAS<1.5); %n=13167; ~95%
ntrueDrmsAS = find(trueDrmsAS<1.5); %n=49; ~4%

nfalseDrmsBS = find(falseDrmsBS<1.3); %n=12970; ~94%
ntrueDrmsBS = find(trueDrmsBS<1.3); %n=67; ~5%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%eliminate all detections with rms noise after signal being less than 1.5
%dB quieter than signal

falseDet(nfalseDrmsAS) = [];
falseDppAS(nfalseDrmsAS) = [];
falseDppBA(nfalseDrmsAS) = [];
falseDppBS(nfalseDrmsAS) = [];
falseDrmsAS(nfalseDrmsAS) = [];
falseDrmsBA(nfalseDrmsAS) = [];
falseDrmsBS(nfalseDrmsAS) = [];
falseDur(nfalseDrmsAS) = [];
falsePpDet(nfalseDrmsAS) = [];
falsePpNAfter(nfalseDrmsAS) = [];
falsePpNBefore(nfalseDrmsAS) = [];
falseRmsDet(nfalseDrmsAS) = [];
falseRmsNAfter(nfalseDrmsAS) = [];
falseRmsNBefore(nfalseDrmsAS) = [];

trueDet(ntrueDrmsAS) = [];
trueDppAS(ntrueDrmsAS) = [];
trueDppBA(ntrueDrmsAS) = [];
trueDppBS(ntrueDrmsAS) = [];
trueDrmsAS(ntrueDrmsAS) = [];
trueDrmsBA(ntrueDrmsAS) = [];
trueDrmsBS(ntrueDrmsAS) = [];
trueDur(ntrueDrmsAS) = [];
truePpDet(ntrueDrmsAS) = [];
truePpNAfter(ntrueDrmsAS) = [];
truePpNBefore(ntrueDrmsAS) = [];
trueRmsDet(ntrueDrmsAS) = [];
trueRmsNAfter(ntrueDrmsAS) = [];
trueRmsNBefore(ntrueDrmsAS) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%compute histogram duration
vecDur = 0:0.001:0.7;
figure(1)
subplot(2,1,1)
hist(trueDur,vecDur)
title('true duration')
xlabel('duration (s)')
xlim([0 0.7])
subplot(2,1,2)
hist(falseDur,vecDur)
title('false duration')
xlabel('duration (s)')
xlim([0 0.7])

%eliminate dur>0.625
nfalseDur = find(falseDur>0.625); %n=195; ~29%
ntrueDur = find(trueDur>0.625); %n=10; ~0.8%

%plot and calculate pp values
vecamp = -50:1:50;
figure(3)
subplot(2,1,1)
hist(trueDppBS,vecamp)
title('diff signal and noise before')
xlabel('duration (s)')
% xlim([0 2])
subplot(2,1,2)
hist(falseDppBS,vecamp)
title('false duration')
xlabel('diff signal and noise before')
% xlim([0 2])

figure(4)
subplot(2,1,1)
hist(trueDppAS,vecamp)
title('diff signal and noise after')
xlabel('duration (s)')
% xlim([0 2])
subplot(2,1,2)
hist(falseDppAS,vecamp)
title('false duration')
xlabel('diff signal and noise after')
% xlim([0 2])

figure(5)
subplot(2,1,1)
hist(trueDppBA,vecamp)
title('diff noise before and noise after')
xlabel('duration (s)')
% xlim([0 2])
subplot(2,1,2)
hist(falseDppBA,vecamp)
title('false duration')
xlabel('diff noise before and noise after')
% xlim([0 2])

%finer scale for noise before and after in comparison to signal
vecamp = -50:0.1:50;
figure(6)
subplot(2,1,1)
hist(trueDppBS,vecamp)
title('diff signal and noise before')
xlabel('duration (s)')
xlim([-10 10])
subplot(2,1,2)
hist(falseDppBS,vecamp)
title('false duration')
xlabel('diff signal and noise before')
xlim([-10 10])

figure(7)
subplot(2,1,1)
hist(trueDppAS,vecamp)
title('diff signal and noise after')
xlabel('duration (s)')
xlim([-10 10])
subplot(2,1,2)
hist(falseDppAS,vecamp)
title('false duration')
xlabel('diff signal and noise after')
xlim([-10 10])

%eliminate dppAS<4dB
nfalseDppAS = find(falseDppAS<4); %n=451; ~68%
ntrueDppAS = find(trueDppAS<4); %n=50; ~4%

nfalseDppBS = find(falseDppBS<2.5); %n=459; ~68%
ntrueDppBS = find(trueDppBS<2.5); %n=77; ~6%

%plot and calculate rms values
vecamp = -50:1:50;
figure(3)
subplot(2,1,1)
hist(trueDrmsBS,vecamp)
title('diff signal and noise before')
xlabel('duration (s)')
% xlim([0 2])
subplot(2,1,2)
hist(falseDrmsBS,vecamp)
title('false duration')
xlabel('diff signal and noise before')
% xlim([0 2])

figure(4)
subplot(2,1,1)
hist(trueDrmsAS,vecamp)
title('diff signal and noise after')
xlabel('duration (s)')
% xlim([0 2])
subplot(2,1,2)
hist(falseDrmsAS,vecamp)
title('false duration')
xlabel('diff signal and noise after')
% xlim([0 2])

figure(5)
subplot(2,1,1)
hist(trueDrmsBA,vecamp)
title('diff noise before and noise after')
xlabel('duration (s)')
% xlim([0 2])
subplot(2,1,2)
hist(falseDrmsBA,vecamp)
title('false duration')
xlabel('diff noise before and noise after')
% xlim([0 2])

%finer scale for noise before and after in comparison to signal
vecamp = -50:0.1:50;
figure(6)
subplot(2,1,1)
hist(trueDrmsBS,vecamp)
title('diff signal and noise before')
xlabel('duration (s)')
xlim([-10 10])
subplot(2,1,2)
hist(falseDrmsBS,vecamp)
title('false duration')
xlabel('diff signal and noise before')
xlim([-10 10])

figure(7)
subplot(2,1,1)
hist(trueDrmsAS,vecamp)
title('diff signal and noise after')
xlabel('duration (s)')
xlim([-10 10])
subplot(2,1,2)
hist(falseDrmsAS,vecamp)
title('false duration')
xlabel('diff signal and noise after')
xlim([-10 10])

%eliminate drmsBS<2dB
nfalseDrmsBS = find(falseDrmsBS<1.3); %n=413; ~62%
ntrueDrmsBS = find(trueDrmsBS<1.3); %n=54; ~4%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %eliminate dppAS<4dB
% nfalseDppAS = find(falseDppAS<4); %n=451; ~68%
% ntrueDppAS = find(trueDppAS<4); %n=50; ~4%

falseDet(nfalseDppAS) = [];
falseDppAS(nfalseDppAS) = [];
falseDppBA(nfalseDppAS) = [];
falseDppBS(nfalseDppAS) = [];
falseDrmsAS(nfalseDppAS) = [];
falseDrmsBA(nfalseDppAS) = [];
falseDrmsBS(nfalseDppAS) = [];
falseDur(nfalseDppAS) = [];
falsePpDet(nfalseDppAS) = [];
falsePpNAfter(nfalseDppAS) = [];
falsePpNBefore(nfalseDppAS) = [];
falseRmsDet(nfalseDppAS) = [];
falseRmsNAfter(nfalseDppAS) = [];
falseRmsNBefore(nfalseDppAS) = [];

trueDet(ntrueDppAS) = [];
trueDppAS(ntrueDppAS) = [];
trueDppBA(ntrueDppAS) = [];
trueDppBS(ntrueDppAS) = [];
trueDrmsAS(ntrueDppAS) = [];
trueDrmsBA(ntrueDppAS) = [];
trueDrmsBS(ntrueDppAS) = [];
trueDur(ntrueDppAS) = [];
truePpDet(ntrueDppAS) = [];
truePpNAfter(ntrueDppAS) = [];
truePpNBefore(ntrueDppAS) = [];
trueRmsDet(ntrueDppAS) = [];
trueRmsNAfter(ntrueDppAS) = [];
trueRmsNBefore(ntrueDppAS) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%compute histogram duration
vecDur = 0:0.001:0.7;
figure(1)
subplot(2,1,1)
hist(trueDur,vecDur)
title('true duration')
xlabel('duration (s)')
xlim([0 0.7])
subplot(2,1,2)
hist(falseDur,vecDur)
title('false duration')
xlabel('duration (s)')
xlim([0 0.7])

%eliminate dur>0.625
nfalseDur = find(falseDur>0.625); %n=35; ~17%
ntrueDur = find(trueDur>0.625); %n=7; ~0.6%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% eliminate durations > 0.625s

falseDet(nfalseDur) = [];
falseDppAS(nfalseDur) = [];
falseDppBA(nfalseDur) = [];
falseDppBS(nfalseDur) = [];
falseDrmsAS(nfalseDur) = [];
falseDrmsBA(nfalseDur) = [];
falseDrmsBS(nfalseDur) = [];
falseDur(nfalseDur) = [];
falsePpDet(nfalseDur) = [];
falsePpNAfter(nfalseDur) = [];
falsePpNBefore(nfalseDur) = [];
falseRmsDet(nfalseDur) = [];
falseRmsNAfter(nfalseDur) = [];
falseRmsNBefore(nfalseDur) = [];

trueDet(ntrueDur) = [];
trueDppAS(ntrueDur) = [];
trueDppBA(ntrueDur) = [];
trueDppBS(ntrueDur) = [];
trueDrmsAS(ntrueDur) = [];
trueDrmsBA(ntrueDur) = [];
trueDrmsBS(ntrueDur) = [];
trueDur(ntrueDur) = [];
truePpDet(ntrueDur) = [];
truePpNAfter(ntrueDur) = [];
truePpNBefore(ntrueDur) = [];
trueRmsDet(ntrueDur) = [];
trueRmsNAfter(ntrueDur) = [];
trueRmsNBefore(ntrueDur) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%