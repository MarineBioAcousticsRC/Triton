function batchLTSA_mk_batch_ltsa

global PARAMS REMORA

% load in data from PARAMS
indirs =    PARAMS.ltsa.indirs;
outdirs =   PARAMS.ltsa.outdirs;
prefixes =  PARAMS.ltsa.prefixes;
outfiles =  PARAMS.ltsa.outfiles;
dirdata =   PARAMS.ltsa.dirdata;
taves =     PARAMS.ltsa.taves;
dfreqs =    PARAMS.ltsa.dfreqs;

% loop through each of the sets of directories for actual ltsa creation
for k = 1:length(indirs)
    lIdx = k; % which LTSA (For progress bar)
    
    PARAMS.ltsa.indir = char(indirs{k});
    PARAMS.ltsa.outdir = char(outdirs{k});
    PARAMS.ltsa.outfile = char(outfiles{k});
    PARAMS.ltsa.tave = taves(k);
    PARAMS.ltsa.dfreq = dfreqs(k);
    
    % run from matlab command line
    if ~isfield(REMORA, 'hrp') % the *else* below isn't tested...carry over from Ann Allen*
        d = dirdata{k};
        if ~isfield(d, 'dataID') % non xwav/typical dir
            fprintf('\nMaking LTSA for directory %s\n', PARAMS.ltsa.indir)
        else
            fprintf('\nMaking LTSA for %s disk %s df %i\n', d.dataID, d.disk, d.df);
        end
        % run from procFun
    else
        % untested...
        fprintf('\nMaking LTSA for %s disk %s df %i\n', REMORA.hrp.dataID, REMORA.hrp.disk, REMORA.hrp.dfs(k));
    end
    
    % make the ltsa!
    disp_msg(sprintf('Creating LTSA %i/%i: %s.', lIdx, length(PARAMS.ltsa.indirs), ...
        PARAMS.ltsa.indir));
    batchLTSA_mk_ltsa_dir(lIdx);
    fprintf('Finished LTSA for directory %s\n', PARAMS.ltsa.indir)
    disp_msg(sprintf('Finished LTSA %i/%i.', lIdx, length(PARAMS.ltsa.indirs)));
    % fprintf('Press any key to continue...\n')
    %     pause
end % all directories

end





