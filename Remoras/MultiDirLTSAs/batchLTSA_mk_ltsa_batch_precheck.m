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
    [prefixes{k}, outfiles{k}, dirdata{k}] = gen_prefix();
    
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