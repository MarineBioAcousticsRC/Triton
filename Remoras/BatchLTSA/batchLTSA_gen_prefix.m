function [prefix, ltsa_file, dirdat] = batchLTSA_gen_prefix

%create a prefix and an outfile name for ltsas generated
% this was originally in batchLTSA_mk_ltsa_batch but extracted to run as
% own function because it used there and in precheck

global PARAMS REMORA

% struct to hold dataID, disk #, and df of this indir
dirdat = struct;

% check for typical xwav header format
[~, dirname, ~] = fileparts(REMORA.batchLTSA.tmp.indir);
exp = '^[\w-_]+(?=_disk)';
dataID = regexp(dirname, exp, 'match');

% build prefix based on traditional xwav or wav filename format
if ~isempty(dataID) % yes, typical xwav header
    dataID = char(dataID(1,:));

    exp = 'disk(\d{2})[_df]*([0-9]*)';
    tokens = regexp(dirname, exp, 'tokens');
    tokens = tokens{1};

    disk = tokens{1};

    % create the prefix
    if ~isempty(tokens{2})
        df = str2double(tokens{2});
        prefix = sprintf('%s_disk%s', dataID, disk);
        ltsa_file = sprintf('%s_%ds_%dHz.ltsa', prefix, PARAMS.ltsa.tave, ...
            REMORA.batchLTSA.tmp.dfreq, df);
    else
        df = 1;
        prefix = sprintf('%s_disk%s', dataID, disk);
    end

    dirdat.dataID = dataID;
    dirdat.disk = disk;
    dirdat.df = df;

    % if non-traditional format, use directory name to create prefix and
    % ltsa name - at least try this!
else
    % get parent directory name
    prefix = strsplit(REMORA.batchLTSA.tmp.indir, '\'); % TODO issue between running on windows and mac?
    prefix = prefix{end};
    prefix = strrep(prefix, ' ', '_');
    exp = '[^\w.-]+'; %any non(^) alphanumeric, numeric, underscore, .m or - character
    prefix = regexprep(prefix, exp, ''); % remove it
    prefix = strrep(prefix, '__', '_');
end

% make sure that prefix isn't too long to fit into ltsa metadata
% (80 characters!)
if PARAMS.ltsa.ftype == 2 % xwavs
    lim = 60;
elseif PARAMS.ltsa.ftype == 1 || PARAMS.ltsa.ftype == 3 % wavs
    lim = 62;
end

if length(prefix) > lim
    prefix = prefix(1:lim);
end

% assemble a name differently depending on num of channels to process
if strcmp(REMORA.batchLTSA.settings.numCh, 'single')
    % processing single channel data
    ltsa_file = sprintf('%s_%ds_%dHz.ltsa', prefix, ...
        REMORA.batchLTSA.tmp.tave, REMORA.batchLTSA.tmp.dfreq);
elseif strcmp(REMORA.batchLTSA.settings.numCh, 'multi') && REMORA.batchLTSA.tmp.ch > 0
    % processing multichannel data - either give example with chosen single
    % channel to process or use 0 as placeholder/example
    ltsa_file = sprintf('%s_%ds_%dHz_ch%i.ltsa', prefix, ...
        REMORA.batchLTSA.tmp.tave, REMORA.batchLTSA.tmp.dfreq, ...
        REMORA.batchLTSA.tmp.ch);
    if REMORA.batchLTSA.tmp.ch == 0
        disp_msg(sprintf(['%s: Multiple channels being processed, each file ', ...
            'will be named with channel number.'], REMORA.batchLTSA.tmp.indir));
    end
end
