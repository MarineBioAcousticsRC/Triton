function kernel_gen(buttonH, varargin)
% kernel_gen(buttonH)
% Generate a kernel blah blah blah

global handles PARAMS HANDLES

% Retrieve time/freq picks of last bounding box.
for idx = 1:2
    tf(idx) = get(handles.timefreq(idx), 'UserData');
end

% Check for emtpy time/freq box....
% to do, return error or do nothing...

% keyboard

%PARAMS.t = every time bin
%PARAMS.f = every freq bin
%PARAMS.pwr = matrix of amplitudes...right?
for t = 1:2
specstart = PARAMS.plot.dnum+dateoffset;
picktime = tf(t).time-specstart;
timesec = picktime/1.1574e-05;
timesecR = round(timesec,1);
timeidx(t)=find(PARAMS.t == timesecR);
end

boxTimeIdx = timeidx(1):timeidx(2);
%boxTime = PARAMS.t(boxTimeIdx);
boxFreqIdx = find(tf(2).freq==PARAMS.f):find(tf(1).freq==PARAMS.f);
boxFreq = PARAMS.f(boxFreqIdx);

boxFreqIdx2 = boxFreqIdx';

box = PARAMS.pwr(boxFreqIdx2,boxTimeIdx); %is this where amp is?
% box = abs(box);

%for a = 1:length(box)
for a = 1:size(box,2)
    [C, I] = max(box(:,a)); %where I is the row Index, C is the value
    Freq(a) = boxFreq(I);    
end

%Now pick out time indices of interest....
%Find the max of the first 5 points...make that the start.

firstM = max(Freq(1:10));
where = find(Freq == firstM);
%Figure out time step based on FFT parameters
timestep = PARAMS.nfft/PARAMS.fs*(100-PARAMS.overlap)/100;
FreqNew = Freq(where:end);

Call(1) = firstM;
Call(2) = nanmean(FreqNew(floor(1.5/timestep):ceil(1.5/timestep))); %1.5s
Call(3) = nanmean(FreqNew(floor(3/timestep):ceil(3/timestep))); %3s
Call(4) = nanmean(FreqNew(floor(4.5/timestep):ceil(4.5/timestep))); %4.5s
Call(5) = nanmean(FreqNew(floor(10/timestep):ceil(10/timestep))); %10s

SiteDep = [handles.Meta.Site '_' num2str(handles.Meta.Deployment)];
newMatFile = [SiteDep '_Bcall.mat'];
save(newMatFile,'Call');
disp(['B call characteristics calculated and saved.']);








