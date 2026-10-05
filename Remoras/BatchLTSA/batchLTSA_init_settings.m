function batchLTSA_init_settings
% BATCHLTSA_INIT_SETTINGS   Define initial/default settings
%
%   Syntax:
%       BATCHLTSA_INIT_SETTINGS
%
%   Description:
%       Define the initial/default settings to pupulate BATCHLTSA_INIT_GUI
%
%   Inputs:
%       none
%
%	Outputs:
%       updates global REMORA
%
%   Examples:
%
%   See also
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   Updated:   04 May 2025
%
%   Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global REMORA

settings.inDir = '';
settings.outDir  = '';
settings.tave = '5';
settings.dfreq = '100';
settings.dataType = 'XWAV'; % default is XWAV
settings.numCh = 'single';
settings.whCh = 1;

REMORA.batchLTSA.settings = settings;

end