global REMORA PARAMS


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% initialize recording params
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
R.rec.sr = 200;
PARAMS.rec.int = 0;
PARAMS.rec.dur = 0;

% Default spectrogram detection parameters
REMORA.dt.params.WhistlePos = 1;
REMORA.dt.params.ClickPos = 2;
REMORA.dt.params.Ranges = [5500 22000          % whistles
    10000 100000];      % clicks
REMORA.dt.params.MinClickSaturation = 10000; 
REMORA.dt.params.MaxClickSaturation = diff(REMORA.dt.params.Ranges(REMORA.dt.params.ClickPos,:));
REMORA.dt.params.WhistleMinLength_s = 0.25; 
REMORA.dt.params.WhistleMinSep_s = .0256;
REMORA.dt.params.Thresholds = [12,12]; % TODO take this out; replaced by BBThresh
REMORA.dt.params.MeanAve_s = Inf;

% Default label parameters
REMORA.dt.class.ValidLabels = false;  % available labels to plot?
REMORA.dt.class.PlotLabels = false;   % plot control