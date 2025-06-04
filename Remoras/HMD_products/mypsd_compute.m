function mypsd_compute(inputDir, outputDir, filename, deployment, site)
% Placeholder for the actual spectra calculation and NetCDF writing
% This is where your sm_calc_daily_1min_psd-like function goes

% Example: loop WAVs, compute PSD, aggregate, write NetCDF


%% Load global parameters from GUI
global PARAMS

% Create output directory if needed
if ~exist(PARAMS.ltsa.outputDir, 'dir')
    mkdir(PARAMS.ltsa.outputDir);
end

sm_get_ltsadir;


if PARAMS.ltsa.gen == 0
    disp_msg('Canceled making ltsa')
    return
end

% read data file headers
sm_get_headers;

if PARAMS.ltsa.gen == 0 % could not read wav file metadata
    return
end

% check some ltsa parameters and other stuff
sm_ck_ltsaparams;

% split the data into # days defined before
%sm_split_ltsa;


% calculated averaged spectra
sm_calc_HMD

end