function cc_gmt_settings_init
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% cc_gmt_settings_init
%
% made by SGB 20240717
% Shelby G. Bloom (sbloom@ucsd.edu)
% modified/based on Soundscape-Metrics Remora settings folder code by Simone Baumann-Pickering
%
% initialize visEffort parameters
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global REMORA

REMORA.cc.gmt = [];

%% Input / Output Settings

REMORA.cc.gmt.GPSFilePath = '';
REMORA.cc.gmt.SightingDir = '';
REMORA.cc.gmt.OutputDir = '';
