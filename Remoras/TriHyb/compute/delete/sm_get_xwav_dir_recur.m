function sm_get_ltsadir_recur
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sm_get_ltsadir.m
%
% get directory of wave/xwav files
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this is to load PARAMS to make them visible
global PARAMS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if PARAMS.metadata.recursiveSearch == 1
    d = dir(fullfile(PARAMS.metadata.inputDir, '**', [PARAMS.metadata.FilenamePattern_ '.x.wav']));
elseif PARAMS.metadata.recursiveSearch == 0
    d = dir(fullfile(PARAMS.metadata.inputDir, '*.x.wav'));    % xwav files
end


fn = char(d.name);      % file names in directory
fnsz = size(fn);        % number of data files in directory
nfiles = fnsz(1);
disp_msg(' ')
disp_msg([num2str(nfiles),'  data files for all LTSAs'])
if fnsz(2)>80
    disp_msg('Error: filename length too long')
    disp_msg('Rename to 80 characters or less')
    disp_msg('Abort LTSA generation')
    return
end

if nfiles < 1
    disp_msg(['No data files in this directory: ',PARAMS.inputDir])
    disp_msg('Pick another directory')
    sm_ltsa_params_window; % in gui folder, related to the pop up window with all of our inputted parameters
end


% filenames
PARAMS.fname = fn;




