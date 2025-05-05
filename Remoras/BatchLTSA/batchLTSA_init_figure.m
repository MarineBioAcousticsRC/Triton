function batchLTSA_init_figure
% BATCHLTSA_INIT_FIGURE Sets up batchLTSA remora set up GUI figure
%
%   Syntax:
%       BATCHLTSA_INIT_FIGURE
%
%   Description:
%       Creates the initial figure for the set up GUI - defining its
%       appearance (location, size, and color).
%
%   Inputs:
%       none
%
%	Outputs:
%       updates global REMORA
%
%   Examples:
%
%   See also BATCHLTSA_INIT_GUI
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   Updated:   04 May 2025
%
%   Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global REMORA

defaultPos = [0.25,0.25,0.3,0.4];
REMORA.fig.batchLTSA = figure( ...
    'NumberTitle','off', ...
    'Name','Batch Create LTSAs',...
    'Units','normalized',...
    'MenuBar','none',...
    'Position',defaultPos, ...
    'Color', [1 1 1],...
    'Visible', 'on');

end

