function cc_count_settings_init
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% cc_count_settings_init
%
% made by SGB 20240717
% Shelby G. Bloom (sbloom@ucsd.edu)
% modified/based on Soundscape-Metrics Remora settings folder code by Simone Baumann-Pickering
%
% initialize concatenate parameters
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global REMORA

REMORA.cc.count = [];

%% Input / Output Settings

REMORA.cc.count.indir = '';
REMORA.cc.count.outdir = '';
REMORA.cc.count.GMTdiff = 7; % GMT Time Difference
