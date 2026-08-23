%dt_TPWS_initSettings

default.bpRanges = [5000 95000];
default.frameLength = 2.56; % miliseconds for fft window
default.filterOrder = 5;
default.overlap = .5;

default.timeseriesLength = 4; % timeseries length in mileseconds

default.framebuffer = 2.5; % miliseconds to add before and after area of interest
default.clickbuffer = .15; % miliseconds to add before and after click start end times

default.saveNoise = false; % save noise

default.exclDetections = false; % compute discriminative features to exclude
% non target species 
default.badClicks = false; % remove clicks that do not fall in desired ranges

