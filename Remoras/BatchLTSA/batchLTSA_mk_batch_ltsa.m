function batchLTSA_mk_batch_ltsa
% BATCHLTSA_MK_BATCH_LTSA   Create multiple LTSAs for many directories
%
%   Syntax:
%       BATCHLTSA_MK_BATCH_LTSA
%
%   Description:
%       Loop through multiple directories/subdirectories of audio files to
%       create LTSAs for each directory. This calls BATCHLTSA_MK_LTSA_DIR
%       which operates on each individual directory and provides messages
%       to track progress. 
%
%       This was modified from Ann Allen 1.93.20190212. There is some
%       lingering code/catches for trying to use the procFun/create LTSAs
%       directly from HRPs. This is not fleshed out/tested but could be
%       expanded on in the future. 
%
%   Inputs:
%       calls global PARAMS and REMORA
%
%	Outputs:
%       updates global PARAMS and REMORA
%
%   Examples:
%
%   See also BATCHLTSA_MK_LTSA_DIR
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   Updated:   04 May 2025
%
%   Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global PARAMS REMORA

if REMORA.batchLTSA.cancelled == 1; return; end

% load in data from REMORA (to simplify)
indirs =    REMORA.batchLTSA.ltsa.indirs;
outdirs =   REMORA.batchLTSA.ltsa.outdirs;
prefixes =  REMORA.batchLTSA.ltsa.prefixes;
outfiles =  REMORA.batchLTSA.ltsa.outfiles;
dirdata =   REMORA.batchLTSA.ltsa.dirdata;
taves =     REMORA.batchLTSA.ltsa.taves;
dfreqs =    REMORA.batchLTSA.ltsa.dfreqs;
chs =       REMORA.batchLTSA.ltsa.chs;

% loop through each of the sets of directories for actual ltsa creation
for k = 1:length(indirs)
    lIdx = k; % which LTSA (For progress bar)
    
    % set PARAMS for each LTSA to be created
    PARAMS.ltsa.indir = char(indirs{k});
    PARAMS.ltsa.outdir = char(outdirs{k});
    PARAMS.ltsa.outfile = char(outfiles{k});
    PARAMS.ltsa.tave = taves(k);
    PARAMS.ltsa.dfreq = dfreqs(k);
    PARAMS.ltsa.ch = chs(k);
    
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
        fprintf('\nMaking LTSA for %s disk %s df %i\n', REMORA.hrp.dataID, ...
            REMORA.hrp.disk, REMORA.hrp.dfs(k));
    end
    
    % make the ltsa!
    disp_msg(sprintf('Creating LTSA %i/%i: %s.', lIdx, ...
        length(REMORA.batchLTSA.ltsa.indirs),  PARAMS.ltsa.indir));
    batchLTSA_mk_ltsa_dir(lIdx);
    fprintf('Finished LTSA for directory %s\n', PARAMS.ltsa.indir)
    disp_msg(sprintf('Finished LTSA %i/%i.', lIdx, ...
        length(REMORA.batchLTSA.ltsa.indirs)));
    % fprintf('Press any key to continue...\n')
    %     pause
end % all directories

end





