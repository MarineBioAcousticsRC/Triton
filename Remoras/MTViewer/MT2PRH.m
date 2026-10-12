  function MT2PRH
% Opens and reads .MT files, calculates Euler angles, and turns data into a PRH file. 
% 
% Must complete this step before opening MTViewer! Run this code in
% sections!
% 
% Opens .MT auxillary files and uses DTAG orientation software to calculate angles. 
% Saves information as PRH file, infor struct, and saves OTAB & PRH
% matrices for orietnation
% 
% 
%  INPUTS:
%           input1	   MT files chosen by user
%
% OUTPUTS:
%           press     pressure
%           temp	  temperature
%           fs        sample rate
%           A         triaxial accelerometer reading
%           M         triaxial magnetometer reading
%           Aw        acceleration of whale mvmt
%           Mw        magentic flux reading of whale mvmnt
%           P         pitch of whale
%           R         roll of whale
%           H         heading (azimuth) of whale
%
% FUNCTIONS REQ'D:
%           MTREAD_mfm.m    Extract individual parameters from MT files
%                           while running MT2MAT_PC.m
%           mtViewer.m      Use before this function to convert raw data
%                           files into MT files
%           
%           prhpredictor.m  
%           
%           tag2whale.m     Converts tag frame A & M to whale frame Aw, Mw
%           (can also be downloaded from St. Andrews website: 
% https://soundtags.wp.st-andrews.ac.uk/dtags/dtag-toolbox/)
%  MODIFICATION HISTORY:
%
%  MM/DD/YYYY INITIALS  Modification details:
%
%   04/15/16 VEL    Plotted x-axis was static when scrolling/zooming in plot.
%                   Fixed with datetick() function added after plot, but
%                   axes must be updated after every scroll or zoom action!
%                       plot(out(:,9),out(:,2));
%                       datetick('x','HH:MM:SS.FFF')
%                   http://www.mathworks.com/matlabcentral/answers/?term=tag%3A%22xticklabel%22
%
%
%   06/21/2011 MFM  run this after the data is downloaded and split using mtViewer
%
%   2025: Added tag2whale.m and prhpredictor.m into script to calc
%   orientation
% Ainsleigh Lloyd & John Hildebrand, Sep 2025

% todoList


%     prompt1={'Enter tag type (1=Acousonde, 2=Bprobe)'};
%     inl = inputdlg(prompt1); flag = str2num(inl{1});
% Adapted from Mark Johnson's DTAG software: 
% E:\AcousticTags\code\tagmatlab_20aug14\matlab 
%
% 
%
% 
% 

%% MAKE SURE TO RUN IN CHUNKS!
%% 1. Set PRH file name

% -------------------Adjust as Needed ----------------------------
spec = 'mm'; % latin initials (mm)
yr = '17'; % two-digit year (17)
day = '242'; % Julian day. use jday([YYYY, MM, DD])
% ----------------------------------------------------------------
depname= [spec, yr, '_', day];


%% 2. READ IN .MT DATA (Hildebrand)
% 1. Read acousonde data, adopted from Acousonderead.m
%     if flag==1;

currentFolder = pwd ; %Save current directory before running PlotMTdata.m
global PARAMS HANDLES all
clc
fprintf('[\bRunning[|         ] ]\b\n');
auxALL = [];
startdir = '/Users/HARP/Desktop/AcousticTags/deployments_downloads/';
%startdir = PARAMS.ltsa.inpath ;
path = uigetdir(startdir,'Choose acousonde .MT file directory');
cd(path); d=dir('*.MT'); mn=char(d.name);

p=1; tmp=0; t=1; a=1; b=1; c=1; d=1; e=1; j=1; k=1;

% 2. loop through files and combine multiple files together
while p <= size(mn,1)
    if mn(p,3) == 'T'
        tmp = 1;
        tn(t,:) = mn(p,:);
        t = t+1;
    elseif mn(p,3) == 'X'
        anX(a,:) = mn(p,:);
        a = a+1;
    elseif mn(p,3) == 'Y'
        anY(b,:) = mn(p,:);
        b = b+1;
    elseif mn(p,3) == 'Z'
        anZ(c,:) = mn(p,:);
        c = c+1;
    elseif mn(p,3) == 'P'
        pn(d,:) = mn(p,:);
        d = d+1;
    elseif mn(p,3) == 'I'
        anI(e,:) = mn(p,:);
        e = e+1;
    elseif mn(p,3) == 'J'
        anJ(j,:) = mn(p,:);
        j = j+1;
    elseif mn(p,3) == 'K'
        anK(k,:) = mn(p,:);
        k = k+1;
    end %end if
    p = p+1;
end %end while


% 3. READ auxillary files
if exist('pn','var')
    [x,y] = size(pn);
end
press=[];temp=[];
xaccel=[];yaccel=[];zaccel=[];
iaccel=[];jaccel=[];kaccel=[];
i = 1;

% 4. Loop each parameter using MTRead_mfm to extract individual parameters
while i <= x
    if exist('pn')                                  %VL: Pressure data
        pnT = strtrim(pn(i,:));
        [pdata,header,infor]=MTRead_mfm(pnT);
        strt = infor.datenumber ;
        psamp = 1 / infor.srate;
        pp = 0 : psamp  : (infor.nsamp-1)*psamp ;
        pp = (pp ./ (24*60*60)) + strt;
        ptp = [pdata,pp'];
        all.press=[press;ptp];
    end
    if exist('tn')                                  %VL: Temp data
        tnT= strtrim(tn(i,:));
        [tdata,header,infor]=MTRead_mfm(tnT);
        strt = infor.datenumber ;
        tsamp = 1 / infor.srate;
        tp = 0 : tsamp  : (infor.nsamp-1)*tsamp ;
        tp = (tp ./ (24*60*60)) + strt;
        ttp = [tdata,tp'];
        all.temp=[temp;ttp];
    end
    if exist('anX') && exist('anY') && exist('anZ') %VL: Magnetic/Compass data
        anXT = strtrim(anX(i,:));
        anYT = strtrim(anY(i,:));
        anZT = strtrim(anZ(i,:));
        [xdata,~,infor]=MTRead_mfm(anXT);
        [ydata,header,infor]=MTRead_mfm(anYT);
        [zdata,header,infor]=MTRead_mfm(anZT);
        strt = infor.datenumber ;
        xsamp = 1 / infor.srate;
        xp = 0 : xsamp  : (infor.nsamp-1)*xsamp ;
        xp = (xp ./ (24*60*60)) + strt;
        xtp = [xdata,xp']; ytp = [ydata,xp']; ztp = [zdata,xp'];
        all.xaccel=[xaccel;xtp]; all.yaccel=[yaccel;ytp]; all.zaccel=[zaccel;ztp];
    end
    if exist('anI') && exist('anJ') && exist('anK') %VL: Accelerometer Data
        anIT = strtrim(anI(i,:));
        anJT = strtrim(anJ(i,:));
        anKT = strtrim(anK(i,:));
        [idata,header,infor]=MTRead_mfm(anIT);
        [jdata,header,infor]=MTRead_mfm(anJT);
        [kdata,header,infor]=MTRead_mfm(anKT);
        strt = infor.datenumber ;
        %isamp = 5; % CHANGE LATER
        isamp = 1 / infor.srate;
        ip = 0 : isamp  : (infor.nsamp-1)*isamp ;
        %                 ip = 0 : isamp  : (length(idata)-1)*isamp ; % jah hack
        ip = (ip ./ (24*60*60)) + strt;
        itp = [idata(1:length(ip)),ip'];
        jtp = [jdata(1:length(ip)),ip'];
        ktp = [kdata(1:length(ip)),ip'];
        all.iaccel=[iaccel;itp]; all.jaccel=[jaccel;jtp]; all.kaccel=[kaccel;ktp];
    end
    i = i+1;
end


%% 2.5a. OPTIONAL: Upsample to highest fs if vector lengths mismatch
    % Important for all vectors to match during orientation!

% Ex: mm17_242. upsampling to accelerometer fs=800, N=35901181

% --------------Adjust as needed -------------------------
N = 35901181; % length of longest vector
fs = 800;
% -------------------------------------------------------
t0 = infor.datenumber;

pup = interp1(pp,pdata,ip,'pchip',NaN);
pup = pup(:);

tup = interp1(tp,tdata,ip,'pchip',NaN);
tup  = tup(:);

xup = interp1(xp,xdata,ip,'pchip',NaN);
xup = xup(:);

ydwn = interp1(xp,ydata,ip,'pchip',NaN);
ydwn = ydwn(:);

zup = interp1(xp,zdata,ip,'pchip',NaN);
zup = zup(:);

all.press = [pup ip']; 
all.temp = [tup ip']; 
all.xaccel = [xup ip']; 
all.yaccel = [ydwn ip']; 
all.zaccel = [zup ip'];

%% 2.5b ...Or Decimate!

% Ex: mm17_242. decimating to temp fs=5, N= 224383 

% --------------Adjust as needed -------------------------
N = 224383; % length of longest vector
fst = 5;
fsp = 10;
fsi = 800;
fsx = 40;
% -------------------------------------------------------
t0 = infor.datenumber;

% decimation factors
dfp = round(fsp/fst);
dfi = round(fsi/fst);
dfx = round(fsx/fst);

pdwn = decimate(pdata,dfp,'FIR');
pdwn= pdwn(:);

xdwn = decimate(xdata,dfx,'FIR');
xdwn = xdwn(:);

ydwn = decimate(ydata,dfx,'FIR');
ydwn = ydwn(:);

zdwn = decimate(zdata,dfx,'FIR');
zdwn = zdwn(:);

idwn = decimate(idata,dfi,'FIR');
idwn = idwn(:);

jdwn = decimate(jdata,dfi,'FIR');
jdwn = jdwn(:);

kdwn = decimate(kdata,dfi,'FIR');
kdwn = kdwn(:);
  
all.press = [pdwn tp']; 
all.temp = [tdata tp']; 
all.xaccel = [xdwn tp']; 
all.yaccel = [ydwn tp']; 
all.zaccel = [zdwn tp'];
all.iaccel = [idwn tp'];
all.jaccel = [jdwn tp'];
all.kaccel = [kdwn tp'];


%% 3a. Save variables needed for PRH file output and orientation calc

% ------------------ Adjust as needed --------------------------
fs = 5;
% -------------------------------------------------------------

press = all.press(:,1); % isolate pressure col for angle calculation
tempr = all.temp;

% Convert Acousonde mag and acc to match DTAG units (A=gal, M=uT)
A = [all.iaccel(:,1)/1000,all.jaccel(:,1)/1000,all.kaccel(:,1)/1000]; % convert from mgal to gal
M = [all.xaccel(:,1)*0.1,all.yaccel(:,1)*0.1,all.zaccel(:,1)*0.1  ]; % convert from milligauss (mG) to microTesla (uT) (1 T = 1e04 G; 1mG = 0.1 uT)

%% 4. Calculate Orientation with GUI

% ------------------ Adjust as needed ------------------------------------
TH = 175; % minimum threshold depth for PRH. Deep dives are best
mthd = 1; % 1 or 2. 1 = animal logs at surface; 2 = animal does surface dives
DIR = 'both'; % 'descent', 'ascent' or 'both' (default).
% ------------------------------------------------------------------------

PRH = prhpredictor(press,A,fs,TH,mthd,DIR);
% PRH instructions:
    % 1. A gui will pop up with crosshairs. 
        % R click on box that has surfacing portions of the dive
        % L click to adjust window
    % 2. Idenfity any tag slips (big changes in PRH in bottom gui). Index in
    % OTAB:


    % NOTES 9/2025:
    %NOTES ABT PRH GUI:
	% - only picking one point, not everything in rubber band
    % - pick matches to descents and ascents of each dive 

%% 5. Look at Figure 2 from 3b for slips > 15 deg (NOTE DEG). Create OTAB noting large chages

% --------------------- Adjust as needed ---------------------------------
OTAB = [PRH(1,1) 0 PRH(1,2) PRH(1,3) PRH(1,4);
    PRH(10,1) PRH(19,1), PRH(19,2), PRH(19,3), PRH(19,4);
    PRH(20,1) PRH(end,1) PRH(end,2) PRH(end,3) PRH(end,4)]; 
% -----------------------------------------------------------------------

[Aw, Mw] = tag2whale(A(:,:),M(:,:),OTAB,fs);

[P, R] =a2pr(Aw);

[H, mm, inc] = m2h(Mw, P, R);

% Convert from radians to degrees
R = rad2deg(R);   
P = rad2deg(P);
H = rad2deg(H);


%% 6. Save Variables
save([depname,'_prh.mat'],'press','tempr','fs','M','A','Mw','Aw','P','R','H'); % saves PRH file
save(['infor_',depname,'.mat'], 'infor'); % saves metadata
save([depname,'_OTAB.mat'], 'OTAB'); % saves OTAB
save([depname, '_PRHpredictor.mat'],'PRH');  % saves PRH matrix used for OTAB

end


%% FIND A WAY TO PAUSE CODE! SO THAT USER CAN TAKE A LOOK AND ADJUST OTAB AS NEEDED.
% 
% % FINISH THIS
% checkOTAB = questdlg('Have you done a tag slip calibration in the OTAB?', 'Calibrate for Tag Slips');
% switch checkPRH
%     case 'Yes'
%     case 'No'
%         error('.MT must be converted to PRH using MT2PRH.m') % swap error for pausing code?
%     case 'Cancel'
%         error('.MT must be converted to PRH using MT2PRH.m') % swap error for pausing code?
% 
%  % notes for improvement nadbot 5/7
%     % add readme/wiki about how to id tag slips
%         % ask if photos of deployment/recovery are available, if extra
%             % documents about deployment are available
% 
%         % add into wiki about finding rotation matrix, and can plot with
%             % poseplot() 
% 
% 
%  % notes for improvement 8/26
%     % can also add in an error 
%     % find a way to make OTAB writing automatic
%     % or maybe export everything else as a struct and then write OTAB and
%     % everything else as a new struct, input into new script
% end