function sm_get_ltsadir
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
% check for empty directory
if PARAMS.ltsa.indir == 0	% if cancel button pushed
    PARAMS.ltsa.gen = 0;
    return
else
    PARAMS.ltsa.gen = 1;
end

if PARAMS.ltsa.ftype == 1
    d = dir(fullfile(PARAMS.ltsa.indir,'*.wav'));    % wav files
elseif PARAMS.ltsa.ftype == 2
    d = dir(fullfile(PARAMS.ltsa.indir,'*.x.wav'));    % xwav files
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
    disp_msg(['No data files in this directory: ',PARAMS.ltsa.indir])
    disp_msg('Pick another directory')
    sm_ltsa_params_window; % in gui folder, related to the pop up window with all of our inputted parameters
end

if PARAMS.ltsa.ftype == 1
    % sort filenames into ascending order based on time stamp of file name
    % don't rely on filename only for order
    % timing stuff:
    dnums = sm_wavname2dnum(fn);
    if isempty(dnums)
        dnumStart = datenum([0 1 1 0 0 0]);
    else
        dnumStart = dnums - datenum([2000 0 0 0 0 0]);
    end    
   
    % sort times
    [B,index] = sortrows(dnumStart');
    % put file name in PARAMS
    PARAMS.ltsa.fname = fn(index,:);
elseif PARAMS.ltsa.ftype == 2
    % filenames
    PARAMS.ltsa.fname = fn;
end


