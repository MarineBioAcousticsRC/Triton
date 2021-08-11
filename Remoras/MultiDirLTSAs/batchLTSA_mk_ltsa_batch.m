function batchLTSA_mk_ltsa_batch()

global PARAMS REMORA


% loop through each of the sets of directories for actual ltsa creation
for k = 1:length(indirs)
    
    % if we have different parameters for each of the dirs, adjust
    % accordingly
    if length(taves) > 1
        tave = taves(k);
    else
        tave = taves;
    end
    if length(dfreqs) > 1
        dfreq = dfreqs(k);
    else
        dfreq = dfreqs;
    end
    
    PARAMS.ltsa.indir = char(indirs{k});
    PARAMS.ltsa.outdir = char(outdirs{k});
    PARAMS.ltsa.outfile = char(outfiles{k});
    PARAMS.ltsa.tave = tave;
    PARAMS.ltsa.dfreq = dfreq;
    
    %     prefix = prefixes{k};
    
    % run from matlab command line
    if ~isfield(REMORA, 'hrp')
        d = dirdata{k};
        if ~isfield(d, 'dataID') % non xwav/typical dir
            fprintf('\nMaking LTSA for directory %s\n', PARAMS.ltsa.indir)
        else
            fprintf('\nMaking LTSA for %s disk %s df %i\n', d.dataID, d.disk, d.df);
        end
        % run from procFun
    else
        fprintf('\nMaking LTSA for %s disk %s df %i\n', REMORA.hrp.dataID, REMORA.hrp.disk, REMORA.hrp.dfs(k));
    end
    
    % make the ltsa!
    batchLTSA_mk_ltsa_dir;
    fprintf('\nFinished LTSA for directory %s\n', PARAMS.ltsa.indir)
    % fprintf('Press any key to continue...\n')
    %     pause
end % all directories

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




%% create a prefix and an outfile name for ltsas generated
function [prefix,ltsa_file,dirdat] = gen_prefix()
global PARAMS

% struct to hold dataID, disk #, and df of this indir
dirdat = struct;

% check for typical xwav header format
[~, dirname, ~] = fileparts(PARAMS.ltsa.indir);
exp = '^[\w-_]+(?=_disk)';
dataID = regexp(dirname, exp, 'match');

% traditional xwav/wav filename format
if ~isempty(dataID)
    dataID = char(dataID(1,:));
    
    exp = 'disk(\d{2})[_df]*([0-9]*)';
    tokens = regexp(dirname, exp, 'tokens');
    tokens = tokens{1};
    
    disk = tokens{1};
    
    % create the prefix
    if ~isempty(tokens{2})
        df = str2num(tokens{2});
        prefix = ...
            sprintf('%s_disk%s',dataID,disk);
        ltsa_file = ...
            sprintf('%s_%ds_%dHz.ltsa',prefix,PARAMS.ltsa.tave,PARAMS.ltsa.dfreq,df);
    else
        df = 1;
        prefix = ...
            sprintf('%s_disk%s',dataID,disk);
    end
    
    dirdat.dataID = dataID;
    dirdat.disk = disk;
    dirdat.df = df;
    
    % if non-traditional format, use directory name to create prefix and
    % ltsa name
else
    % get parent directory name
    prefix = strsplit(PARAMS.ltsa.indir, '\'); % TODO issue between running on windows and mac?
    prefix = prefix{end};
    prefix = strrep(prefix, ' ', '_');
    exp = '[^\w]+';
    prefix = regexprep(prefix, exp, '');
    prefix = strrep(prefix, '__', '_');
end

% make sure that prefix isn't too long to fit into ltsa metadata
% (80 characters!)
if PARAMS.ltsa.ftype == 2 % xwavs
    lim = 60;
elseif PARAMS.ltsa.ftype == 1 % wavs
    lim = 62;
end

if length(prefix) > lim
    prefix = prefix(1:lim);
end

% create the outfile name
if ~strcmp(prefix(end), '_')
    prefix = [prefix, '_'];
end

ltsa_file = ...
    sprintf('%s%ds_%dHz.ltsa',prefix,PARAMS.ltsa.tave,PARAMS.ltsa.dfreq);
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



