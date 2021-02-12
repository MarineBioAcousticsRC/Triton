
%%%%%%default settings for making tlabs in triton Label Tracker remora

p.saveDir = 'H:\Hawaii_K\DCLDE\PIFSC_2\1705_ch4\TPWS1_tLabs'; %where to save
p.filePrefix = '1705'; %what do you want your file to be called?
p.filePath = 'H:\Hawaii_K\DCLDE\PIFSC_2\1705_ch4\TPWS';
p.rmvFDs = 0; %set to 1 if loading TPWS and want to remove false detections
%p.FDpath = 'H:\Hawaii_K\DCLDE\PIFSC_2\1705_ch4\TPWS\1705a_Delphin_FD1.mat'; %path to false detections file 
p.TPWSitr = '1'; %iteration of TPWS to run for

%%%what type of file are you using as input?
p.TPWStype = 0;
p.FDtype = 0;
p.IDtype = 0;
p.TDtype = 1;

%%what kind of labels do you want?
% p.trueL = 1; %create true labels
p.trueLabel = 'true'; %label name
% p.falseL = 1; %create false labels 
% p.falseLabel = 'false'; 

%%other
p.timeOffset = 2000; %set to 0 if no offset. PIFSC data originally used started with different date than triton nums
p.dur = 0.0001; %duration for click labels (sec), necessary for data coming from detEdit 
%%%%modify this later to allow for more label types?
