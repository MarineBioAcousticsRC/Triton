function sm_cmpt_metrics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sm_cmpt_metrics.m
%
% compute soundscape metrics from LTSA files in a directory
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS REMORA

REMORA.sm.cmpt.tic = tic;

% get ltsa files in directory
[REMORA.sm.cmpt.PathFileList, REMORA.sm.cmpt.FileList, REMORA.sm.cmpt.PathList] = ...
    utFindFiles('*.ltsa', REMORA.sm.cmpt.indir, 0);

% initiate matrix for octaves if "TOL" or "OL" are checked
if REMORA.sm.cmpt.ol || REMORA.sm.cmpt.tol
    sm_cmpt_octaves
end

% initiate output files
sm_cmpt_outfiles

% initiate output time increments over deployment
sm_cmpt_timeinc

% initiate diary file
diaryfile = fullfile(REMORA.sm.cmpt.outdir,'logfile.txt');
diary(diaryfile)
sm_cmpt_diary;

n = 1; %keep track of which file is being computed, needed if start is not first LTSA
% loop through all the LTSA files
for fidx = REMORA.sm.cmpt.fstart:length(REMORA.sm.cmpt.FileList)
    % read ltsa headers
    PARAMS.ltsa = [];
    PARAMS.ltsa.inpath = REMORA.sm.cmpt.PathList{fidx};
    PARAMS.ltsa.infile = REMORA.sm.cmpt.FileList{fidx};
    sm_read_ltsahead;

    % set up header matrix of LTSA averages: timestamp and byte location 
    % in file for each average and whether or not to keep it
    sm_cmpt_setup;
    
    % compute average and keep remainder
    sm_cmpt_avgs(fidx,n);
    n = n+1;
end

% close files
sm_cmpt_closeout

% display full computation time
REMORA.sm.cmpt.toc = toc(REMORA.sm.cmpt.tic);
disp(['Elapsed time to compute soundscape metrics (h): ',...
    num2str(REMORA.sm.cmpt.toc/60/60)])

disp('---')
disp('Analysis finished')

diary off