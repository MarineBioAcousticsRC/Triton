% example simple implementation of TagJiggle.m & SpeedFromRMS.m

% Step 1- set up variables and calculate tag jiggle RMS amplitude for each axis

% load calibrated acceleration data (in tag frame).  Example units are in g but could be anything
%load('mn160727-11Adata.mat'); % loads A and Afs

% load downsampled whale data with pitch, roll, p, fs, etc.
%load('mn160727-11 10Hzprh.mat'); 

global all

Afs = all.srate;
fs = 10;
p = all.press(:,1);
A = [all.iaccel(:,1), all.jaccel(:,1), all.kaccel(:,1)];
% Afs if the sample rate of the accelerometer data, fs is the (usually downsampled) sample rate of the tag data at which you will want the final speed values to match.
JX = TagJiggle(all.iaccel(:,1),Afs,fs,[10 90],.5); %[10 90] and 0.5 are default choices, can also input [].  If Afs<180, only a high pass filter at 10 Hz is used.
JY = TagJiggle(all.jaccel(:,1),Afs,fs,[10 90],.5);
JZ = TagJiggle(all.kaccel(:,1),Afs,fs,[10 90],.5);
J = TagJiggle(A,Afs,fs,[10 90],.5);

% if you've calculated flownoise RMS values, speedFromRMS can compare the speed from jiggle method to the speed from the flownoise method.
if exist('flownoise','var') && sum(isnan(flownoise)) ~= length(flownoise) 
    RMS = [JX JY JZ flownoise];
else
    RMS = [JX JY JZ J];
end

if exist('all.tagslip','var') 
tagslips = [INFO.tagslip.Wchange; length(p)]; % creates a vector of indices indicating the end of periods when the tag was in different orientations
% see SpeedFromRMS for info on the following optional parameters.
else
    tagslips = [];
end
binSize = 0.5;
filterSize = 0.5; 
minDepth = 10; 
minPitch = 45;
minSpeed = 0.5; 
minTime = 0.2;
% tagon is an index indicating data points that are on the animal.
%plot data to find tag on and tag off time
figure; plot(p)
title('Find start and end time of tag on animal');
pos = ginput(2);
tagon = zeros(length(p),1);
tagon(pos(1,1):pos(2,1),:) = 1;
tagon = logical(tagon);
df=800/10;
y = decdc(A,df); %This leads to an array that is one shorter than the resampled accelerometer data...
[pitch, roll] = a2pr(y);
p=p(1:(end-1),:);
RMS = RMS(1:(end-1),:);
%% Now everything is set up to run SpeedFromRMS.  On the first graph you can
% further threshold the parameters minDepth, minPitch and maxRoll by
% clicking on the colorbar for each axis.  For instance, click at 60 to set
% the minPitch to 60 degrees and watch how points disappear.  Since OCDR
% increases in accuracy with higher pitch, the goal is to use the highest
% pitch angle possible that still leaves enough points to create a nice
% exponential relationship between OCDR and jiggle RMS amplitude.  The
% other thresholds (roll and depth) are mostly useful if you have a lot of
% outliers near the surface or at high roll rate (uncommon).

% of the following output variables, the "speed" table is the most important one.  The rest of the outputs are for documenting the fit of the speed curve
[~,speed,sectionsendindex,fits,speedModels,modelsFit,speedThresh,multiModels] = SpeedFromRMS(RMS,fs,p,pitch,roll,[],tagslips,tagon,binSize,filterSize,minDepth,minPitch,minSpeed,minTime);

%% The following section is optional, but it can help organize the data into a couple of simple structures:
% 1) speed (a speed table with speed as well as prediction and confidence
% intervals).  speed.JJ will be the speed from tag jiggle in m/s.  
% 2) speedstats (a structure with information about the models used to
% create the speed curves)
% 3) JigRMS (a table with the raw (unadjusted) jiggle RMS values for each axis

speed.Properties.VariableNames{'RMS2'} = 'FN';
speed.Properties.VariableNames{'P68_2'} = 'FNP68';
speed.Properties.VariableNames{'P95_2'} = 'FNP95';
speed.Properties.VariableNames{'C95_2'} = 'FN95';
speed.Properties.VariableNames{'r2_2'} = 'FNr2';
fits.Properties.VariableNames{'RMS2r2'} = 'FNr2';

if ~exist('flownoise','var') || sum(isnan(flownoise)) == length(flownoise) % if there is no flownoise variable, get rid of those parts of the table.
    speed.FN = nan(size(speed.JJ));
    speed.FNP68 = []; speed.FNP95 = []; speed.FN95 = []; speed.FNr2 = [];
    try speedModels(:,2) = []; catch; end
    try ModelFits(:,2) = []; catch; end
end
speedstats = struct();
speedstats.Models = speedModels;
speedstats.ModelFits = modelsFit;
speedstats.r2used = fits;
speedstats.sections_end_index = sectionsendindex;
speedstats.info = 'Each row is the model for a tag orientation section.  The last row in Models is the regression on all data.  The r2 used is the r2 for each section (sometimes the whole data section was used if there was not enough data to get a good regression for an individual section';

for ii = 1:length(multiModels);
    speedstats.multiModels{ii} = multiModels{ii}.Coefficients;
end
speedstats.Thresh = speedThresh;
X = JX; Y = JY; Z = JZ; Mag = J;
JigRMS = table(X, Y, Z, Mag);

if ~exist('SpeedPlots\','dir'); mkdir('SpeedPlots\'); end
for fig = [1 301:300+size(speedstats.r2used,1)]
    saveas(fig,['SpeedPlots\fig' num2str(fig) '.bmp']);
end

whaleID = INFO.whaleName;
save([whaleID 'speed.mat'],'speed','speedstats','JigRMS'); % or save the values within your prh file;

% check your values;
figure; ax =  plotyy(1:length(p),p,1:length(p),speed.JJ); set(ax(1),'ydir','rev');