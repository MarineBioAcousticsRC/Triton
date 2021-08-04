function mk_ltsa_batch()

global PARAMS REMORA

PARAMS.ltsa.multidir = 1;

% if we're coming from the processing code, just use the LTSA data from
% that. if not, use user input
% also can be used with other predefined LTSA processing information
% if isfield(REMORA, 'hrp')
%     indirs = {};
%     outdirs = {};
%     outfiles = {};
%     dfreqs = [];
%     taves = [];
%     for k = 1:size(REMORA.hrp.xwavPaths, 2)
%         if REMORA.hrp.ltsas(k)
%             % only populate if we're making an ltsa for this
%             indirs{end+1} = REMORA.hrp.xwavPaths{1,k};
%             outdirs{end+1} = REMORA.hrp.xwavPaths{1,k};
%             outfiles{end+1} = REMORA.hrp.ltsaNames(k, :);
%             dfreqs = [dfreqs, REMORA.hrp.dfreq(k)];
%             taves = [taves, REMORA.hrp.tave(k)];
%         end
%     end
%     PARAMS.ltsa.rf_skip = [];
% else
    % manual entry - pick a directory that contains the xwav dirs where
    % LTSA creation is desired
    dir_name = REMORA.mdLTSA.settings.inDir;
%     dir_name = uigetdir('D:\');
    if dir_name == 0; disp_msg('Window closed. Exiting.'); return; end
    
    a = REMORA.mdLTSA.settings.dataType;
%     a = questdlg('WAV or XWAV?', 'File type', 'WAV', 'XWAV', 'XWAV');
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
    
    % save output files in same locations
    outdirs = indirs;
    
    % LTSA parameters
    % default is same for all directories as set in initial window, but can
    % modify by directory if desired
    mdLTSA_ltsa_params(indirs); % set taves and dfreqs
    taves = PARAMS.ltsa.taves;
    dfreqs = PARAMS.ltsa.dfreqs;
    
    %     taves = 5;
    %     dfreqs = [100, 1, 10];
    
    PARAMS.ltsa.ch = 1; % which channel do you want to process?
    %     PARAMS.ltsa.ftype = 2; % 2 for xwavs, 1 for wavs
    if PARAMS.ltsa.ftype == 2
        % specify data type -1 HRP, 2 ARP, 3 OBS? Pulling these nums from
        % ck_ltsaparams.m
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
    
% end


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
    mdLTSA_mk_ltsa_dir;
    fprintf('\nFinished LTSA for directory %s\n', PARAMS.ltsa.indir) 
    % fprintf('Press any key to continue...\n')
%     pause
end % all directories

end

% check to see if the xwav/wav names are compatible with ltsa format
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

% create a prefix and an outfile name for ltsas generated
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

% concatenate two cell arrays cause APPARENTLY THIS ISN'T EASY IN MATLAB
function c1 = cat_cell(c1, c2)

for k = 1:size(c2, 2)
    c1{end+1} = c2{k};
end
end

% function ltsa_params(dirs) % creates gui window to define ltsa settings
% mycolor = [.8,.8,.8];
% r = length(dirs) + 2;
% c = 3;
% h = 0.025*r;
% w = 0.09*c;
% 
% bh = 1/r;
% bw = 1/c;
% 
% y = zeros(1, r);
% for ri = 2:r
%     y(ri) = 1/r + y(ri-1);
% end
% 
% x = zeros(1, r);
% for ci = 2:c
%     x(ci) = 1/c + x(ci-1);
% end
% 
% btnPos = [0,0,w,h];
% fig = figure('Name', 'Choose taves & dfreqs', 'Units', 'normalized', ...
%     'Position', btnPos, 'MenuBar', 'none', 'NumberTitle', 'off');
% movegui(gcf, 'center');
% 
% % entry labels
% labelStr = 'Directory Name';
% btnPos = [x(1), y(end), 2*bw, bh];
% uicontrol(fig, 'Units', 'normalized', 'BackgroundColor', mycolor,...
%     'Position', btnPos, 'Style', 'text', 'String', labelStr);
% 
% labelStr = 'tave';
% btnPos = [x(3), y(end), 0.5*bw, bh];
% uicontrol(fig, 'Units', 'normalized', 'BackgroundColor', mycolor,...
%     'Position', btnPos, 'Style', 'text', 'String', labelStr);
% 
% labelStr = 'dfreq';
% btnPos = [x(3)+x(2)*0.5, y(end), 0.5*bw, bh];
% uicontrol(fig, 'Units', 'normalized', 'BackgroundColor', mycolor,...
%     'Position', btnPos, 'Style', 'text', 'String', labelStr);
% 
% fig_taves = {};
% fig_dfreqs = {};
% 
% % directory names and ed txt
% for d = 1:length(dirs)
%     labelStr = dirs(d);
%     btnPos = [x(1), y(end-d), 2*bw, bh];
%     uicontrol(fig, 'Units', 'normalized', 'BackgroundColor', mycolor,...
%         'Position', btnPos, 'Style', 'text', 'String', labelStr,...
%         'HorizontalAlign', 'left');
%     
%     % tave
%     labelStr = '5';
%     btnPos = [x(3), y(end-d), 0.5*bw, bh];
%     fig_taves{end+1} = uicontrol(fig, 'Units', 'normalized', 'Position', btnPos,...
%         'Style', 'edit', 'String', labelStr);
%     
%     % dfreq
%     labelStr = '100';
%     btnPos = [x(3)+x(2)*0.5, y(end-d), 0.5*bw, bh];
%     fig_dfreqs{end+1} = uicontrol(fig, 'Units', 'normalized', 'Position', btnPos,...
%         'Style', 'edit', 'String', labelStr);
% end
% 
% % go button
% labelStr = 'Okay';
% btnPos = [x(3), y(1), bw, bh];
% uicontrol(fig, 'Units', 'normalized', 'Position', btnPos,...
%     'Style', 'push', 'String', labelStr, 'Callback', {@okay, fig, fig_taves, fig_dfreqs});
% uiwait;
% end



