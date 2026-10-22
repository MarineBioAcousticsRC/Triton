function [out, strt] = D2PRH2MAT_PC()
% read DTAG PRH file
%function [output1=data, output2=start time] = PRH2MAT_PC
% code opens auxillary files, plots dive profile and saves information
% in variables out and strt
%
%  INPUTS:
%           input1	   PRH files chosen by user
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
path = uigetdir(startdir,'Choose acousonde PRH file directory');
cd(path); d=dir('*prh*'); mn=char(d.name);
load(fullfile(path,mn));%loads p temp M A Mw Aw pitch roll and head

disp('Start Time:');
disp(PARAMS.ltsa.dvecStart(1,:));

strt = datenum(PARAMS.ltsa.dvecStart(1,:)+[2000 0 0 0 0 0]);


% 2. Makes time
lenp = length(p);
psamp = 1 / fs;
pp = 0 : psamp  : (lenp-1)*psamp ;
pp = (pp ./ (24*60*60)) + strt;
% 3. Loop each parameter
all.press = [p,pp'];
all.temp= [tempr(1:lenp),pp'];
all.xaccel= [M(1:lenp,1),pp'];
all.yaccel= [M(1:lenp,2),pp'];
all.zaccel= [M(1:lenp,3),pp'];
all.iaccel= [A(1:lenp,1),pp'];
all.jaccel= [A(1:lenp,2),pp'];
all.kaccel= [A(1:lenp,3),pp'];

% PRH INPUT: AINSLEIGH LLOYD
% Convert from radians to degrees
rdeg = rad2deg(R);
hdeg = rad2deg(H);
pdeg = rad2deg(P); 

all.roll = [rdeg(1:lenp,1),pp'];
all.azi = [hdeg(1:lenp,1),pp'];
all.pitch = [pdeg(1:lenp,1),pp'];


% 5. Save data
        %         len = [length(press) length(temp) length(xaccel) length(yaccel) length(zaccel)...
        %             length(iaccel) length(jaccel) length(kaccel)];
        out={(all.press) (all.temp) (all.xaccel) (all.yaccel) (all.zaccel)...
            (all.iaccel) (all.jaccel) (all.kaccel) (all.pitch) (all.roll) (all.azi)};
%         %         ml=max(len);    
% % 4. Save data
% 
% out={(all.press) (all.temp) (all.xaccel) (all.yaccel) (all.zaccel)...
%     (all.iaccel) (all.jaccel) (all.kaccel)};

% 5. Plot data into four figures
global REMORA
REMORA.MT2MAT.out = out ;
d
cd(currentFolder) %Change directory back to original folder.
end