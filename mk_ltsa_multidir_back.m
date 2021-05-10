function mk_ltsa_multidir()

global PARAMS REMORA 

PARAMS.ltsa.multidir = 1;

% if we're coming from the processing code, just use the LTSA data from
% that. if not, use user input 
% also can be used with other predefined LTSA processing information
if isfield(REMORA, 'hrp')
    indirs = {};
    outdirs = {};
    outfiles = {};
    dfreqs = [];
    taves = [];
    for k = 1:size(REMORA.hrp.xwavPaths, 2)
        if REMORA.hrp.ltsas(k)
            % only populate if we're making an ltsa for this
            indirs{end+1} = REMORA.hrp.xwavPaths{1,k};
            outdirs{end+1} = REMORA.hrp.xwavPaths{1,k};
            outfiles{end+1} = REMORA.hrp.ltsaNames(k, :);
            dfreqs = [dfreqs, REMORA.hrp.dfreq(k)];
            taves = [taves, REMORA.hrp.tave(k)];
        end
    end
    PARAMS.ltsa.rf_skip = [];
else
    % manual entry - pick a directory that contains the xwav dirs where
    % LTSA creation is desired
    dir_name = uigetdir('D:\');
    indirs = find_xwav_dirs(dir_name);
    outdirs = indirs;
    
    % LTSA parameters TODO fill these out!
%     PARAMS.ltsa.dfreq =  100; 
%     PARAMS.ltsa.tave = 5;
    taves = 5; 
    dfreqs = [100, 1, 10];
    PARAMS.ltsa.ch = 1; % which channel do you want to process?
    PARAMS.ltsa.ftype = 2; % 2 for xwavs, 1 for wavs
    PARAMS.ltsa.dtype =  1; % 1 for HRP data
%     ck_ltsaparams;

    % raw files to skip. leave this empty if no rfs wanted to skip
    PARAMS.ltsa.rf_skip = [];
end

% loop through each of the sets of directories
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
    PARAMS.ltsa.tave = tave;
    PARAMS.ltsa.dfreq = dfreq;
   
    % update indir/outdir we're using each iteration
%     if ~isfield(PARAMS.ltsa, 'indir')
        PARAMS.ltsa.indir = char(indirs{k});
%     end
    PARAMS.ltsa.outdir = char(outdirs{k});
    
    
    [~, dirname, ~] = fileparts(PARAMS.ltsa.indir);
    exp = '^[\w-_]+(?=_disk)';
    dataID = regexp(dirname, exp, 'match');
    
    % traditional xwav names either coming from procFun or a correctly
    % named directory
    if ~isempty(dataID)
        
        dataID = char(dataID(1, :));
        exp = 'disk(\d{2})[_df]*([0-9]*)';
        tokens = regexp(dirname, exp, 'tokens');
        tokens = tokens{1};
        disk = tokens{1};
        
        % if coming from procFun already have ltsa names generated - just need
        % to initialize outfile and determine disk # and df
        if isfield(REMORA, 'hrp')
            PARAMS.ltsa.outfile = char(outfiles{k});
            df = REMORA.hrp.dfs(k);
        % if coming from a correctly named directory
        else
            % df from directory name
            if ~isempty(tokens{2})
                df = str2num(tokens{2});
                PARAMS.ltsa.outfile = sprintf('%s_disk%s_%ds_%dHz_df%d.ltsa',dataID,disk,tave,dfreq,df);
           % if df not in the dir name, df = 1
            else
                df = 1;
                PARAMS.ltsa.outfile = sprintf('%s_disk%s_%ds_%dHz.ltsa',dataID,disk,tave,dfreq);
            end
        end
    % we need to generate a good name for this ltsa 
    else
        PARAMS.ltsa.outfile = strrep(PARAMS.ltsa.outdir, ' ', '_');
        exp = '[^A-z0-9_]+';
        PARAMS.ltsa.outfile = regexprep(PARAMS.ltsa.outdir, exp, '');
        PARAMS.ltsa.outfile = strrep(PARAMS.ltsa.outfile, '__', '_');
    end
    
% %     dataID = char(dataID(1, :));
% %     
% %     exp = 'disk(\d{2})[_df]*([0-9]*)';
% %     tokens = regexp(dirname, exp, 'tokens');
% %     tokens = tokens{1};
% 
%     disk = tokens{1};
%     if ~isempty(tokens{2})
%         df = str2num(tokens{2});
%         outfilestr = sprintf('%s_disk%s_%ds_%dHz_df%d.ltsa',dataID,disk,tave,dfreq,df);
% %         PARAMS.ltsa.outfile = sprintf('%s_disk%s_%ds_%dHz_df%d.ltsa',dataID,disk,tave,dfreq,df);
%     else
%         df = 1;
%         outfilestr = sprintf('%s_disk%s_%ds_%dHz.ltsa',dataID,disk,tave,dfreq);
% %         PARAMS.ltsa.outfile = sprintf('%s_disk%s_%ds_%dHz.ltsa',dataID,disk,tave,dfreq);
%     end
%  
%     if ~isfield(REMORA, 'hrp')
%         PARAMS.ltsa.outfile = outfilestr;
%     else 
%         
%     end
% %     if ~exist('outfiles')
% %         [~, dirname, ~] = fileparts(PARAMS.ltsa.indir);
% %         exp = '^[\w-_]+(?=_disk)';
% %         dataID = regexp(dirname, exp, 'match');
% % 
% %         % if we're using typical xwav naming conventions to create these LTSAs
% %         if ~isempty(dataID)
% %             dataID = char(dataID(1,:));
% % 
% %             exp = 'disk(\d{2})[_df]*([0-9]*)';
% %             tokens = regexp(dirname, exp, 'tokens');
% %             tokens = tokens{1};
% % 
% %             disk = tokens{1};
% %             if ~isempty(tokens{2})
% %                 df = str2num(tokens{2});
% %                 PARAMS.ltsa.outfile = sprintf('%s_disk%s_%ds_%dHz_df%d.ltsa',dataID,disk,tave,dfreq,df);
% %             else
% %                 df = 1;
% %                 PARAMS.ltsa.outfile = sprintf('%s_disk%s_%ds_%dHz.ltsa',dataID,disk,tave,dfreq);
% %             end
%         else
%             PARAMS.ltsa.outfile = strrep(PARAMS.ltsa.outdir, ' ', '_');
%             exp = '[^A-z0-9_]+';
%             PARAMS.ltsa.outfile = regexprep(PARAMS.ltsa.outdir, exp, '');
%             PARAMS.ltsa.outfile = strrep(PARAMS.ltsa.outfile, '__', '_');
%         end
%     else
%         PARAMS.ltsa.outfile = char(outfiles{k});
%     end
    
    % check to see if the ltsa file already exists
    PARAMS.ltsa.indir = char(indirs(k));
    if exist(fullfile(PARAMS.ltsa.indir, PARAMS.ltsa.outfile), 'file')
        ans = questdlg('LTSA file already found', 'LTSA creation', ...
            'Overwrite', 'Continue, don''t overwrite', 'Skip', 'Skip');
        if strcmp(ans, 'Continue, don''t overwrite')
            PARAMS.ltsa.outfile = sprintf('%s_copy.ltsa', PARAMS.ltsa.outfile(1:end-5));
        elseif strcmp(ans, 'Skip')
            continue
        end    
    end
%     PARAMS.ltsa.outfile = outfiles{k};
%     ck_ltsaparams;
%     info = audioinfo(fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(1,:)));
%     PARAMS.ltsa.fs = info.SampleRate;
    fprintf('\nMaking LTSA for disk %s, df %i\n', disk, df);
    mk_ltsa_dir;
end

end

function dirs = find_xwav_dirs(d)
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
        subdirs_xwav = find_xwav_dirs(subdirs{k});       
        dirs = cat_cell(dirs, subdirs_xwav);
    end
    cd(d);
    if ~isempty(dir('*.x.wav'))
        dirs{end+1} = d;
    end   
    
end

% concatenate two cell arrays cause APPARENTLY THIS ISN'T EASY IN MATLAB
function c1 = cat_cell(c1, c2)

for k = 1:size(c2, 2)
    c1{end+1} = c2{k};
end
end

