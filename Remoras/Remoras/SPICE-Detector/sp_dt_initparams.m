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
settings_detectorDefault
REMORA.spice_dt.xwavParams = detParams;

settings_detector_array
REMORA.spice_dt.wavParams = detParams;

% Default label parameters
REMORA.spice_dt.class.ValidLabels = false;  % available labels to plot?
REMORA.spice_dt.class.PlotLabels = false;   % plot con