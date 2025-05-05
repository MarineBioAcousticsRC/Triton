function batchLTSA_init_batch_ltsa
% BATCHLTSA_INIT_BATCH_LTSA     Runs precheck and mk_ltsa functions
%
%   Syntax:
%       BATCHLTSA_INIT_BATCH_LTSA
%
%   Description:
%       Initializes the actual steps to batch-generate LTSAs. This is
%       triggered by the 'Batch Create LTSAs' button on the set up GUI
%       control window. 
% 
%       This will display a message in the Triton Message Window, run a
%       series of prechecks using BATCHLTSA_MK_BATCH_LTSA_PRECHECK, and 
%       then run the actual LTSA creation process BATCHLTSA_MK_BATCH_LTSA
%
%   Inputs:
%       none
%
%	Outputs:
%       none
%
%   Examples:
%
%   See also BATCHLTSA_MK_BATCH_LTSA_PRECHECK BATCHLTSA_MK_BATCH_LTSA
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   Updated:   04 May 2025
%
%   Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% global REMORA PARAMS

%% Actually run the mk_ltsa code! 
    disp_msg('Creating LTSAs...');
    batchLTSA_mk_batch_ltsa_precheck;
    batchLTSA_mk_batch_ltsa;
    
end