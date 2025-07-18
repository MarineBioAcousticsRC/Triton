function mypsd_compute



%% Load global parameters from GUI
global PARAMS

% Create output directory if needed
if ~exist(PARAMS.metadata.outputDir, 'dir')
    mkdir(PARAMS.metadata.outputDir);
end

disp('Compiling xwav files...')
%getXWAVTimes_recur

% get xwav directory to compute HMD
%sm_get_xwav_dir_recur;

% read data file headers
sm_get_headers_recur;

% check some ltsa parameters and other stuff
%sm_ck_ltsaparams;

% calculated averaged spectra
profile on
sm_calc_HMD
profile viewer

end