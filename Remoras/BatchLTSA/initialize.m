%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Initialize the BatchLTSA pulldown
%
% This remora can be used to generate LTSAs as a batch process operating on
% a directory of subdirectories containig sound files, for example multiple
% deployments or multiple decimation options. This was inspired by and
% adapted into a Remora from code written by Marie Roch and Ann Allen. 
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   Updated:   05 May 2025
%
%   Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global HANDLES REMORA


REMORA.batchLTSA.menu = uimenu(HANDLES.remmenu,'Label','&Batch LTSA',...
    'Enable','on','Visible','on');

% Batch create LTSAs over multiple directories
uimenu(REMORA.batchLTSA.menu, 'Label', 'Batch create LTSAs', ...
    'Callback', 'batchLTSA_pulldown(''batch_ltsas'')');
                   