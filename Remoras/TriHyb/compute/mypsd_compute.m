function mypsd_compute



%% Load global parameters from GUI
global PARAMS

% Create output directory if needed
if ~exist(PARAMS.ltsa.outputDir, 'dir')
    mkdir(PARAMS.ltsa.outputDir);
end

sm_get_ltsadir;

% read data file headers
sm_get_headers;

if PARAMS.ltsa.gen == 0 % could not read wav file metadata
    return
end

% check some ltsa parameters and other stuff
sm_ck_ltsaparams;

% calculated averaged spectra
sm_calc_HMD

end