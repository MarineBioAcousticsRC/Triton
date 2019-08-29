function sh_detector_motion

global REMORA PARAMS

REMORA.sh.motionDets = [];

% store current ltsa window parameters
sh_get_ltsa_params

% get detection parameters from current window
sec2dnum = 60*60*24; % conversion factor to get from seconds to matlab datenum
dnumSnippet = REMORA.sh.ltsa.dnumSnippet;
durWind = REMORA.sh.settings.durWind;
tave = REMORA.sh.ltsa.tave;
minPassage = REMORA.sh.settings.minPassage;

%%% Detect ships
% Get spectral data from current window
pwr = PARAMS.ltsa.pwr;
% Apply detector
[ships,labels,~] = sh_passage_detector(pwr,1);
% Convert to actual times
dnumShips = (ships./sec2dnum)*tave + dnumSnippet;