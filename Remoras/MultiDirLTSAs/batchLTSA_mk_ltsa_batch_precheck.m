function batchLTSA_mk_ltsa_batch_precheck()

global PARAMS REMORA

PARAMS.ltsa.multidir = 1;

dir_name = REMORA.batchLTSA.settings.inDir;
if dir_name == 0; disp_msg('Window closed. Exiting.'); return; end

a = REMORA.batchLTSA.settings.dataType;
if strcmp(a, 'WAV')
    PARAMS.ltsa.ftype = 1;
    indirs = find_dirs(dir_name, '*.wav');
elseif strcmp(a, 'FLAC')
    PARAMS.ltsa.ftype = 3;
    indirs = find_dirs(dir_name, '*.flac');
elseif strcmp(a, 'XWAV')
    PARAMS.ltsa.ftype = 2;
    indirs = find_dirs(dir_name, '*.x.wav');
else
    disp_msg('Window closed. Exiting.');
    return
end

% if there is no files...abort. 
if isempty(indirs)
    disp_msg('No files in directory. Exiting.');
    return
end
% save output files in same locations
outdirs = indirs;

% LTSA parameters
% default is same for all directories as set in initial window, but can
% modify by directory if desired
batchLTSA_ltsa_params(indirs); % set taves and dfreqs
taves = PARAMS.ltsa.taves;
dfreqs = PARAMS.ltsa.dfreqs;

%     taves = 5;
%     dfreqs = [100, 1, 10];

PARAMS.ltsa.ch = 1; % which channel do you want to process?
%     PARAMS.ltsa.ftype = 2; % 2 for xwavs, 1 for wavs

% set data type based on file type 2 = XWAV/HARP, 1 or 3 = WAV/FLAC
if PARAMS.ltsa.ftype == 2
    PARAMS.ltsa.dtype =  1; % 1 for HRP data
elseif PARAMS.ltsa.ftype == 1 || PARAMS.ltsa.ftype == 3 % wav or flac
    PARAMS.ltsa.dtype = 4; % standard wav/ishmael format?
end

% raw files to skip.
% * this is specific to HRPs?
% leave this empty if no rfs wanted to skip
%PARAMS.ltsa.rf_skip = [47957  47986  47989  48016  48019  48045  48048  48051  48081  48541];
%     PARAMS.ltsa.rf_skip = [11716  11715];
PARAMS.ltsa.rf_skip = [];

% loop through each of the sets of directories for PRE-CHECK
prefixes = cell(1, length(indirs));
outfiles = cell(1, length(indirs));
dirdata = cell(1, length(indirs));
for k = 1:length(indirs)
    % if we have different parameters for each of the dirs, adjust
    % accordingly
    if length(dfreqs) > 1
        dfreq = dfreqs(k);
    else
        dfreq = dfreqs;
    end
    if length(taves) > 1
        tave = taves(k);
    else
        tave = taves;
    end
    
    PARAMS.ltsa.indir = char(indirs{k});
    PARAMS.ltsa.outdir = char(outdirs{k});
    PARAMS.ltsa.tave = tave;
    PARAMS.ltsa.dfreq = dfreq;
    
    % create the outfile and prefix
    [prefixes{k}, outfiles{k}, dirdata{k}] = batchLTSA_gen_prefix();
    
    % make sure filenames will work
    success = ck_names(prefixes{k});
    
    % check to see if the ltsa file already exists
    PARAMS.ltsa.indir = indirs{k};
    if exist(fullfile(PARAMS.ltsa.indir, outfiles{k}), 'file')
        choice = questdlg('LTSA file already found', 'LTSA creation', ...
            'Overwrite', 'Continue, don''t overwrite', 'Skip', 'Skip');
        if strcmp(choice, 'Continue, don''t overwrite')
            outfiles{k} = sprintf('%s_copy.ltsa', PARAMS.ltsa.outfile(1:end-5));
            ltsa_bools(k) = 1;
            % remove parameters for this LTSA
        elseif strcmp(choice, 'Skip') % this throws error because removes and shortens lenght of indir
            indirs(k) = {[]};
            outdirs(k) = {[]};
            prefixes(k) = {[]};
            outfiles(k) = {[]};
            dirdata(k) = {[]};
            taves(k) = nan;
            dfreqs(k) = nan;
        end
    end
    
    %         if strcmp(ans, 'Skip') || ~success
    if ~success
        disp_msg(sprintf('Skipping LTSA creation for %s\n', prefixes{k}));
        indirs(k) = {[]};
        outdirs(k) = {[]};
        prefixes(k) = {[]};
        outfiles(k) = {[]};
        dirdata(k) = {[]};
        taves(k) = nan;
        dfreqs(k) = nan;
    end
end

% remove any nans
indirs = indirs(~cellfun(@isempty, indirs));
outdirs = outdirs(~cellfun(@isempty, outdirs));
prefixes = prefixes(~cellfun(@isempty, prefixes));
outfiles = outfiles(~cellfun(@isempty, outfiles));
dirdata = dirdata(~cellfun(@isempty, dirdata));
taves = taves(~isnan(taves));
dfreqs = dfreqs(~isnan(dfreqs));



end

%% find dirs function

function dirs = find_dirs(d, ftype)

cd(d);
dirs = {};

% find each of the subdirectories
files = dir;
inds = find(vertcat(files.isdir));
subdirs = {};
subdirs_xwav = {};
for k = 1:length(inds)
    ind = inds(k);
    if ~strcmp(files(ind).name, '.') && ~strcmp(files(ind).name, '..')
        subdirs{end+1} = fullfile(d, files(ind).name);
    end
end

% for each subdirectory, check for xwavs and append to list of indirs
for k = 1:size(subdirs, 2)
    subdirs_xwav = find_dirs(subdirs{k}, ftype);
    dirs = cat_cell(dirs, subdirs_xwav);
end
cd(d);
if ~isempty(dir(ftype))
    dirs{end+1} = d;
end

end



%% concatenate two cell arrays cause APPARENTLY THIS ISN'T EASY IN MATLAB
function c1 = cat_cell(c1, c2)

for k = 1:size(c2, 2)
    c1{end+1} = c2{k};
end
end



%% check to see if the xwav/wav names are compatible with ltsa format
function success = ck_names(prefix)

global PARAMS

success = 1;

% find filenames for xwav/wav
if PARAMS.ltsa.ftype == 1
    files = dir(fullfile(PARAMS.ltsa.indir, '*.wav'));
elseif PARAMS.ltsa.ftype == 2
    files = dir(fullfile(PARAMS.ltsa.indir, '*.x.wav'));
end

% check to see if filenames are the same length
prev_fname = files(1).name;
for x = 1:length(files)
    curr_fname = files(x).name;
    if length(prev_fname) ~= length(curr_fname)
        success = 0;
        break;
    end
end

% check to see if filenames contain timestamps (wavs only! xwavs have
% timing info in headers)
if PARAMS.ltsa.ftype == 1
    fname = files(1).name;
    dnum = wavname2dnum(fname);
    
    % datenumber isn't in filenames
    if isempty(dnum); success = 0; end
end

% if we don't like the format, offer to change wav/xwav filenames
if ~success; success = rename_wavs(prefix); end

% either continue with ltsa creation or return
if success; success = 1; return; end;
end


