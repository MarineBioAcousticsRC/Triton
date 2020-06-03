function kernel_gen(buttonH, varargin)
% kernel_gen(buttonH)
% Generate a kernel blah blah blah

global handles PARAMS

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

boxTimeIdx = tf(1).timeidx:tf(2).timeidx;
boxTime = PARAMS.t(boxTimeIdx);
boxFreqIdx = tf(2).freqidx:tf(1).freqidx;
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

SiteDep = [handles.site.disp.String handles.deploy.disp.String];
newMatFile = [SiteDep '_Bcall.mat'];
save(newMatFile,'Call');
disp(['B call characteristics calculated and saved.']);








