% composite_clusters_settings_default

% Settings for running composite_clusters.m
% Consider making separate versions to keep track of settings used on
% different projects

% File locations and names
s.outputName = 'GOM'; % used to name output files
s.inDir = 'E:\ClusterTool\test_data\dolphin'; 
s.inFileString = 'GofMX*.mat'; 
s.outDir = 'E:\ClusterTool\test_data\dolphin\cc';

% Saving?
s.saveOutput = 1; %set to 1 to save output file and figs, else 0

%%%% Similarity %%%%
s.useSpectraTF = 1; % compare on spectra?
s.useTimesTF = 1;
% choose if you want to include ICI **OR** click rate in similarity calculation
s.iciModeTF = 1; % 1 if you want to use modal ICI (time between clicks)
%OR
s.iciDistTF = 0;% 1 if you want to compare ici distributions
%OR
s.cRateTF = 0; % 1 if you want to use click rate (# of clicks per second)

%%%
s.correctForSaturation = 1; % 1 if you want to look for minor ICI peaks in 
% cases where clicking is so dense that individual ICIs are obscured. This
% helps with dolphins, but may hurt if you are trying to pull out ships and
% rain too. Only for modal ICI
s.specDiffTF = 0; % set to 1 to use spectral 1st derivatives for correlation
s.linearTF = 0; % Compare spectra in linear space = 1, compare spectra in dB space = 0;
s.singleClusterOnly = 0; % Only use single cluster bins to train
%%%% Distribution Pruning %%%%
s.startFreq = 5;
s.endFreq = 80;
s.maxICI = .5;
s.minICI = 0;

%%%% Clustering %%%%
s.minClust = 25; % minimum number of bins required for a cluster to be retained.
s.pruneThr = 90; % Percentage of edges between nodes that you want to prune.
s.pgThresh = 0; % Percentile of nodes to remove from network using PageRank weights.
% e.g. If you use 25, nodes with PR in the lowest 25th percentile will be
% pruned out.
s.modular = 0; % If you use a number other than 0, modularity algorithm will
% be used instead of chinese whispers. Not recommended.
s.maxClust = 20000;% maximum number of bins to cluster. If you have more than
% this, a random subset of this size will be selected.
s.subSampOnlyOnce = 1; % if your input contains more than maxClust clicks, they 
% will be subsampled. If subSampOnlyOnce = 1, then a subsample will
% be selected, and it will be reclustered N times. This ends up looking at
% fewer clicks, but avoids the risk that the best set of final clusters could
% be chosen based on the simplest subset. It's also faster.
% If subSampOnlyOnce = 0, then a new subsample will be selected on each of
% N iterations. This looks at more signals, but risks that the final
% clusters will be chosen from the subset that happened to have the least
% variability.
s.minClicks = 50; % minimum number of clicks per bin that you want to consider
% higher number makes cleaner clusters, but may miss things that click
% slowly.
s.clusterPrune = 0;
s.maxCWIterations = 30; % Maximum number of CW iterations
% Number of clusterings to use for evidence accumulation
s.N = 5; % bigger is theoretically more robust, but takes longer
s.mergeTF = 0 ;
%%%% Plotting %%%%
s.subPlotSet = 1; % Set to 1 if you want plots with each click type as a subplot
s.indivPlots = 0; % Set to 1 if you want separate plots for each click type

s.SBdiff = 0.1; %default difference for comparing spectra of undesirable clusters to those of bins in binDataPruned
s.SBperc = 0.9; %default percentage similarity between a bad cluster and a given bin for bin to be removed


s.diary = 0;