function [prefix,ltsa_file,dirdat] = batchLTSA_gen_prefix()

%create a prefix and an outfile name for ltsas generated
% this was originally in batchLTSA_mk_ltsa_batch but extracted to run as
% own function because it used there and in precheck

global PARAMS REMORA

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