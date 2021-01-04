%%%%original settings for echosounder detector

p.templateFilePath = 'G:\code\misc_code\echosounderTemplate.mat';
p.dataFilePath = 'F:\';
p.depName = 'HAWAII01';
p.outDir = 'E:\HI01_echosounder';

%%%%%thresholds
p.lowF = 20000; %lower cutoff in Hz
p.highF = 80000; %high cutoff in Hz
p.prcTh = 50; %percent threshold for correlation calcuation
p.gapT = 0.05; %gap time in seconds for between detections
p.thresholdC = 50^2; %base threshold for c2 for keeping detections from correlation
p.threshPP = -500; %threshold for ddPP difference between noise sample and signal
p.lowICI = 0.2; %allowable ICI range, remove detections outside of this
p.highICI = 5;
p.TFpath = 'G:\TFs\newVersions\406_090417_A_HARP.tf';
p.ICIpad = 0.1; %time in seconds for padding around ICI mode for allowable ICI range
p.fftLength = 400; %length of fft for spectral calculation. Would not recommend modification!
