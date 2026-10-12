function [out, strt] = PRH2MAT_PC()
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
d = dir('*xml'); xn = char(d.name);
load(fullfile(path,mn));%loads p M and A
%
% find the start time in the xml 0001 file
% Open the file for reading
fileID = fopen(fullfile(path,xn), 'r');
% Check if file opening was successful
if fileID == -1
    error('File could not be opened');
end
% Initialize a flag to indicate if the string is found
found = false;
% Read each line of the file
while ~feof(fileID)
    line = fgets(fileID); % Read one line
    if contains(line, 'SUFFIX="wav"')
        pattern = 'TIME="(\d+,\d+,\d+,\d+,\d+,\d+)"';
        tokens = regexp(line, pattern, 'tokens');
        if ~isempty(tokens)
            timeStr = tokens{1}{1};
            timeComponents = strsplit(timeStr, ',');
            timeNum = cellfun(@str2num, timeComponents);
            % Display the time components
            disp('Start Time:');
            disp(timeNum);
            %                     timeNum(1) = timeNum(1) - 2000; % HARP time
            strt = datenum(timeNum);
        else
            disp('Time information not found in the line.');
        end
        found = true;
        break; % Exit the loop if found
    end
end
fclose(fileID);

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

% % use ecompass to convert mag and accel to euler angles JAH
% acc = [all.iaccel(:,2),all.iaccel(:,1),all.jaccel(:,1),all.kaccel(:,1)];
% mag = [all.xaccel(:,2),all.xaccel(:,1),all.yaccel(:,1),all.zaccel(:,1)];
% lp = length(all.iaccel); lq = length(all.xaccel);
% if lp ~= lq
%     if  lp > lq
%         acc = ReSamp(acc,mag);
%     else
%         mag = ReSamp(mag,acc);
%     end
% end
% q = ecompass(acc(:,2:4),mag(:,2:4));
% e = eulerd(q,'ZYX','frame'); % e(1) pitch, e(2) roll, e(3) azi
% azi= -e(:,1);  pitch = -e(:,2);  roll = -e(:,3);
% all.pitch = [pitch,acc(:,1)];
% all.roll = [roll,acc(:,1)];
% all.azi = [azi,acc(:,1)];
% 5. Save data
%         len = [length(press) length(temp) length(xaccel) length(yaccel) length(zaccel)...
%             length(iaccel) length(jaccel) length(kaccel)];
out={(all.press) (all.temp) (all.xaccel) (all.yaccel) (all.zaccel)...
    (all.iaccel) (all.jaccel) (all.kaccel) (all.pitch) (all.roll) (all.azi)};
%         ml=max(len);
% 4. Save data

%         out={(all.press) (all.temp) (all.xaccel) (all.yaccel) (all.zaccel)...
%             (all.iaccel) (all.jaccel) (all.kaccel)};

% 5. Plot data into four figures
global REMORA
REMORA.MT2MAT.out = out ;

cd(currentFolder) %Change directory back to original folder.
end