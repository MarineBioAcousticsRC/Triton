function cc_vis_settings_init
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% cc_vis_settings_init
%
% made by SGB 20240717
% Shelby G. Bloom (sbloom@ucsd.edu)
% modified/based on Soundscape-Metrics Remora settings folder code by Simone Baumann-Pickering
%
% initialize visEffort parameters
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global REMORA

REMORA.cc.vis = [];

%% Input / Output Settings

REMORA.cc.vis.GPSFilePath = '';
REMORA.cc.vis.effFilePath = '';
REMORA.cc.vis.oDir = '';
