function [out, strt] = XLS2MAT_PC()
% read DTAG but from XLS 
%function [output1=data, output2=start time] = PRH2MAT_PC
% code opens auxillary files, plots dive profile and saves information
% in variables out and strt
%
%  INPUTS:
%           input1	   XLS files chosen by user
%
% OUTPUTS:
%           out        An nx8 matrix of auxillery data
%           strt	   A datevector of start time
%

% 1. Read acousonde data, adopted from Acousonderead.m
%     if flag==1; 

currentFolder = pwd ; %Save current directory before running PlotMTdata.m
global PARAMS HANDLES all
clc
fprintf('[\bRunning[|         ] ]\b\n');
auxALL = [];
startdir = PARAMS.ltsa.inpath ;
path = uigetdir(startdir,'Choose acousonde XLS file directory');
cd(path); d=dir('*csv*'); mn=char(d.name);
dTable = readtable(fullfile(path,mn));%loads p M and A
% t, z, Ax_tag, Ay_tag, Az_tag, Mx_tag, My_tag, Mz_tag

disp('Start Time:');
timeNum = 2000; % assume jan 1, 2000
disp(timeNum);
strt = datenum([timeNum 1 1 0 0 0]);
fs = 1 / (dTable.t(2) - dTable.t(1));

% 2. Makes time
lenp = size(dTable);
psamp = 1 / fs;
        pp = 0 : psamp  : (lenp-1)*psamp ;
        pp = (pp ./ (24*60*60)) + strt;
 % 3. Loop each parameter 
        all.press = [-dTable.z,pp'];
        all.temp= [dTable.z,pp']; % no temp so use pressure
        all.xaccel= [dTable.Mx_tag,pp'];
        all.yaccel= [dTable.My_tag,pp'];
        all.zaccel= [dTable.Mz_tag,pp'];
        all.iaccel= [dTable.Ax_tag,pp'];
        all.jaccel= [dTable.Ay_tag,pp'];
        all.kaccel= [dTable.Az_tag,pp'];

% 4. Save data

        out={(all.press) (all.temp) (all.xaccel) (all.yaccel) (all.zaccel)...
            (all.iaccel) (all.jaccel) (all.kaccel)};

% 5. Plot data into four figures
        global REMORA
        REMORA.MT2MAT.out = out ;

cd(currentFolder) %Change directory back to original folder.
end