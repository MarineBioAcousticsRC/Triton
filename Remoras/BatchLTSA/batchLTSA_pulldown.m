function batchLTSA_pulldown(action)
% BATCHLTSA_PULLDOWN    Initializes pulldown menu for batchLTSA remora
%
%   Syntax:
%       BATCHLTSA_PULLDOWN(ACTION)
%
%   Description:
%       Defines the possible actions triggered by a selection of something
%       in the pulldown menu and then calls new functions for those
%       actions. For now this is just one action possible here: batch_ltsas
%       which triggers setting up the GUI figure (batchLTSA_init_figure),
%       defining some initial settings (batchLTSA_init_settings), and then
%       plots the actual set up GUI (batchLTSA_init_gui).
%
%   Inputs:
%       action   output of a uimenu call from initialize 
%
%	Outputs:
%       updates global HANDLES
%
%   Examples:
%
%   See also BATCHLTSA_INIT_FIGURE BATCHLTSA_INIT_SETTINGS
%   BATCHLTSA_INIT_GUI
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   Updated:   2025 May 04
%
%   Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% global PARAMS REMORA HANDLES

if strcmp(action, 'batch_ltsas')
    % dialog box - 
    batchLTSA_setpointers('watch');
    
    % set up to open gui window for batch ltsa creation
    batchLTSA_init_figure
    batchLTSA_init_settings
    
    % set up all default settings to motion gui
    batchLTSA_init_gui
    
    batchLTSA_setpointers('arrow');
    
end


function batchLTSA_setpointers(icon)
% local function to define the pointer as an arrow after modifying the gui
global HANDLES
set(HANDLES.fig.ctrl, 'Pointer', icon);
set(HANDLES.fig.main, 'Pointer', icon);
set(HANDLES.fig.msg, 'Pointer', icon);



