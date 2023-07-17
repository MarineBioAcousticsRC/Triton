function sh_settings_to_sec
% convert values to seconds for the first time
global REMORA

if ~exist('REMORA.sh.settings.minPassage','var')
    REMORA.sh.settings.minPassage = REMORA.sh.settings.minPassage * 60*60;
end
if ~exist('REMORA.sh.settings.buffer','var')
    REMORA.sh.settings.buffer = REMORA.sh.settings.buffer * 60;
end
if ~exist('REMORA.sh.settings.durWind','var')
    REMORA.sh.settings.durWind = REMORA.sh.settings.durWind * 60*60;
end
if ~exist('REMORA.sh.settings.slide','var')
    REMORA.sh.settings.slide = REMORA.sh.settings.slide * 60*60;
end