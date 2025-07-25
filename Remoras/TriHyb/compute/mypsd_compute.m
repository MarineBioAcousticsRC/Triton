function mypsd_compute



%% Load global parameters from GUI
global PARAMS

% Create output directory if needed
if ~exist(PARAMS.metadata.outputDir, 'dir')
    mkdir(PARAMS.metadata.outputDir);
end

disp('Compiling xwav files...')

% read data file headers
sm_get_headers_recur;


% calculated averaged spectra
profile on
sm_calc_HMD
profile viewer

end