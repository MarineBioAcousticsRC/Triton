function dt_runLtsaDetector()
% dt_runLtsaDetector()
% Run Ltsa Ship Detection.

global PARAMS REMORA

% If we have an open LTSA, use the input directory to initialize the path
% to the metadata directory, save other directory in case user switches

if isempty(PARAMS.ltsa.inpath) || isempty(PARAMS.ltsa.infile)
    BaseDir = pwd;  % No LTSA, use current directory
else
    BaseDir = PARAMS.ltsa.inpath;
end


REMORA.ship_dt.ltsa.inpath = PARAMS.ltsa.inpath;
REMORA.ship_dt.ltsa.infile = PARAMS.ltsa.infile;

fn_getLTSAHeader;

dt_ship_batch;
