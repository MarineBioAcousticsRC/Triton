function batchLTSA_mk_batch_ltsa_precheck
% BATCHLTSA_MK_BATCH_LTSA_PRECHECK  Run checks on batch LTSA settings
%
%   Syntax:
%       BATCHLTSA_MK_BATCH_LTSA_PRECHECK
%
%   Description:
%       Run a series of checks on the settings for the batch LTSA process
%       and provide the user with options to modify or confirm these
%       settings.
%
%       This calls two additional GUIs (BATCHLTSA_CHK_LTSA_PARAMS and
%       BATCHLTSA_CHK_FILENAMES) where the user can modify or confirm the
%       LTSA settings and output filenames. Each of these will be
%       predefined but the initial settings but provides flexibility if
%       some of the directories need different settings (for example if
%       some of the directories are decimated data) or if a directory
%       should be skipped (by changing settings to empty).
%
%       It also checks the format of the input audio files to confirm they
%       have valid timestamp info - if not, there is an option to batch
%       rename the audio files with BATCHLTSA_RENAME_WAVS. These checks are
%       based of similar checks in the main Triton code copied here as
%       local functions.
%
%   Inputs:
%       calls global REMORA and PARAMS
%
%	Outputs:
%       updates global REMORA and PARAMS
%
%   Examples:
%
%   See also BATCHLTSA_CHK_LTSA_PARAMS BATCHLTSA_CHK_FILENAMES
%   BATCHLTSA_RENAME_WAVS
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   Updated:   04 May 2025
%
%   Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global PARAMS REMORA

PARAMS.ltsa.multidir = 1;

dir_name = REMORA.batchLTSA.settings.inDir;
if dir_name == 0; disp_msg('Window closed. Exiting.'); return; end

% find sound files and set dtype based on file type
if strcmp(REMORA.batchLTSA.settings.dataType, 'WAV')
    PARAMS.ltsa.ftype = 1;
    indirs = find_dirs(dir_name, '*.wav');
    PARAMS.ltsa.dtype = 4; % standard wav
elseif strcmp(REMORA.batchLTSA.settings.dataType, 'FLAC')
    PARAMS.ltsa.ftype = 3;
    indirs = find_dirs(dir_name, '*.flac');
    PARAMS.ltsa.dtype = 4; % standard wav
elseif strcmp(REMORA.batchLTSA.settings.dataType, 'XWAV')
    PARAMS.ltsa.ftype = 2;
    indirs = find_dirs(dir_name, '*.x.wav');
    PARAMS.ltsa.dtype =  1; % 1 for HRP data/xwavs
else
    disp_msg('Window closed. Exiting.');
    return
end

% if there is no files...abort.
if isempty(indirs)
    disp_msg(sprintf('No %s files in directory. Exiting.', ...
        REMORA.batchLTSA.settings.dataType));
    disp_msg('Please check your input directory or file type selection.')
    if REMORA.batchLTSA.cancelled == 1; return; end
    error(['No %s files in directory. Please check your input directory ', ...
        'or file type selection. Exiting.'], REMORA.batchLTSA.settings.dataType)
end

% save output files in same locations
outdirs = indirs;

% write to REMORA
REMORA.batchLTSA.ltsa.indirs = indirs;
REMORA.batchLTSA.ltsa.outdirs = outdirs;


% Individual LTSA parameters
% default is same for all directories as set in initial window, but can
% modify by directory if desired
% these are saved in REMORA.batchLTSA.ltsa and will be pulled into PARAMS
batchLTSA_chk_ltsa_params(indirs); % set taves, dfreqs, chs
if REMORA.batchLTSA.cancelled == 1; return; end
% update if any were changed in check
taves = REMORA.batchLTSA.ltsa.taves;
dfreqs = REMORA.batchLTSA.ltsa.dfreqs;
chs = REMORA.batchLTSA.ltsa.chs;
indirs = REMORA.batchLTSA.ltsa.indirs;
outdirs = REMORA.batchLTSA.ltsa.outdirs;

% check that all chs are 1 if single channel data
if strcmp(REMORA.batchLTSA.settings.numCh, 'single') && ...
        any(REMORA.batchLTSA.ltsa.chs ~= 1)
    REMORA.batchLTSA.ltsa.chs = ones(length(REMORA.batchLTSA.ltsa.chs), 1);
    chs = REMORA.batchLTSA.ltsa.chs;
    disp_msg('Incorrect channel specified for single channel data.')
    disp_msg('Setting to channel 1.')
end

% % raw files to skip.
% % * this is specific to HRPs?
% % leave this empty if no rfs wanted to skip
% %PARAMS.ltsa.rf_skip = [47957  47986  47989  48016  48019  48045  48048  48051  48081  48541];
% %     PARAMS.ltsa.rf_skip = [11716  11715];
PARAMS.ltsa.rf_skip = [];

% loop through each of the sets of directories to set params and filenames
prefixes = cell(1, length(indirs));
outfiles = cell(1, length(indirs));
dirdata = cell(1, length(indirs));
for k = 1:length(indirs)
    % if we have different parameters for each of the dirs, adjust
    % accordingly
    if length(dfreqs) > 1
        REMORA.batchLTSA.tmp.dfreq = dfreqs(k);
    else
        REMORA.batchLTSA.tmp.dfreq = dfreqs;
    end
    if length(taves) > 1
        REMORA.batchLTSA.tmp.tave = taves(k);
    else
        REMORA.batchLTSA.tmp.tave = taves;
    end
    if length(chs) > 1
        REMORA.batchLTSA.tmp.ch = chs(k);
    else
        REMORA.batchLTSA.tmp.ch = chs;
    end

    REMORA.batchLTSA.tmp.indir = char(indirs{k});
    REMORA.batchLTSA.tmp.outdir = char(outdirs{k});

    % create the outfile and prefix
    [prefixes{k}, outfiles{k}, dirdata{k}] = batchLTSA_gen_prefix;
end

% write to REMORA
REMORA.batchLTSA.ltsa.prefixes = prefixes;
REMORA.batchLTSA.ltsa.outfiles = outfiles;
REMORA.batchLTSA.ltsa.dirdata = dirdata;

% make sure the filenames are what you want them to be
batchLTSA_chk_filenames;
if REMORA.batchLTSA.cancelled == 1; return; end
outfiles = REMORA.batchLTSA.ltsa.outfiles; % write back to outfiles for below

% loop through again to do filename checks
for k = 1:length(indirs)

    % make sure filenames will work
    PARAMS.ltsa.indir = REMORA.batchLTSA.ltsa.indirs{k};
    success = ck_names(prefixes{k});

    % check to see if the ltsa file already exists
    if exist(fullfile(indirs{k}, outfiles{k}), 'file')
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

% remove any nans and write to PARAMS
REMORA.batchLTSA.ltsa.indirs = indirs(~cellfun(@isempty, indirs));
REMORA.batchLTSA.ltsa.outdirs = outdirs(~cellfun(@isempty, outdirs));
REMORA.batchLTSA.ltsa.prefixes = prefixes(~cellfun(@isempty, prefixes));
REMORA.batchLTSA.ltsa.outfiles = outfiles(~cellfun(@isempty, outfiles));
REMORA.batchLTSA.ltsa.dirdata = dirdata(~cellfun(@isempty, dirdata));
REMORA.batchLTSA.ltsa.taves = taves(~isnan(taves));
REMORA.batchLTSA.ltsa.dfreqs = dfreqs(~isnan(dfreqs));
REMORA.batchLTSA.ltsa.chs = chs(~isnan(chs));


end

%% find dirs function
function dirs = find_dirs(d, ftype)

cd(d);
dirs = {};

% find each of the subdirectories
files = dir;
inds = find(vertcat(files.isdir));
subdirs = {};
for k = 1:length(inds)
    ind = inds(k);
    % skip hidden folders or system folders
    if strcmp(files(ind).name(1), '.') || ...
            any(strcmp(files(ind).name, {'$RECYCLE.BIN', 'System Volume Information'}))
        continue
    end
    subdirs{end+1} = fullfile(d, files(ind).name); %#ok<AGROW>
end

% for each subdirectory, check for audio files and append to list of indirs
for k = 1:size(subdirs, 2)
    subdirs_audio = find_dirs(subdirs{k}, ftype);
    dirs = cat_cell(dirs, subdirs_audio);
end
cd(d);
if ~isempty(dir(ftype))
    dirs{end+1} = d;
end

end



%% concatenate two cell arrays 'cause APPARENTLY THIS ISN'T EASY IN MATLAB
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
elseif PARAMS.ltsa.ftype == 3
    files = dir(fullfile(PARAMS.ltsa.indir, '*.flac'));
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
if PARAMS.ltsa.ftype == 1 || PARAMS.ltsa.ftype == 3
    fname = files(1).name;
    dnum = wavname2dnum(fname);

    % datenumber isn't in filenames
    if isempty(dnum); success = 0; end
end

% if we don't like the format, offer to change wav/xwav filenames
if ~success; success = batchLTSA_rename_wavs(prefix); end

% either continue with ltsa creation or return
if success; success = 1; return; end
end


