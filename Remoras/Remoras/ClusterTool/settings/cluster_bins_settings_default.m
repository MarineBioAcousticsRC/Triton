% cluster_bins_settings_default

%%% Set inputs and setting values for cluster_bins %%%

% Deployment info
p.siteName = ''; % First few letters of TPWS file names
p.TPWSitr = 1;

% Folder info:
p.inDir = 'E:\Code\Kait-Matlab-Code\tritons\triton1.93.20160524\triton1.93.20160524\Remoras\ClusterTool\test_data\dolphin'; % where the TPWS files live, 
p.outDir = 'E:\ClusterTool\test_data\dolphin'; % where to save outputs
p.recursSearch = 1; % search subfolders if true.

%%% Clustering parameter choices %%%
p.minClust = 50;% minimum number of clicks required for a cluster to be retained.
% Think about how fast your species click, group sizes, and how many clicks they make
% per N minutes...
p.pruneThr = 90; % Percentage of edges between nodes that you want to prune.
% Pruning speeds up clustering, but can result in isolation (therefore
% loss) of rare click types.
p.variableThreshold = 1; % if 0, all edges weaker than p.pruneThr are removed from graph.
% if 1, p.pruneThr percent of edges are removed from graph. 
p.maxCWiterations = 15;% maximum number of clustering iterations allowed per bin.

p.sampleRate = 200; % Sample rate in kHz, only used if frequency vector f 
% is not provided in TPWS files. MUCH BETTER TO PROVIDE f than rely on this!!!

p.pgThresh = 0; % Percentile of nodes to remove from network using PageRank weights.
% e.g. If you use 25, nodes with PR in the lowest 25th percentile will be
% pruned out.
p.modular = 0; % if you use a number other than 0, modularity algorithm will be used
% instead of chinese whispers for community detection. Not recommended.
% In the modularity algorithm, this parameter influences the number of
% communities detected. 1 = no bias, >1 bias toward fewer communities, <1,
% bias toward more communities.
p.useSpectra = 1;
p.useEnvelope = 0;

p.mergeTF = 0; % If 1, when a graph is large, we will attempt to reduce computation time
% by merging extremely similar nodes before clustering. 
p.linearTF = 1;% compare spectra in linear space
p.plotFlag = 1; % Want plots? Turn this off for large jobs, but useful for
% seeing how your clusters are coming out when choosing parameters above.
p.falseRM = 0; % Want to remove false positives? Working on removing the 
% need for manual false positive ID step.
p.pauseAfterPlotting = 0; % if you want it to pause post plotting so you can look
% at the clustering results between bins, make this 1. Turn off for fast
% processing.

%%% Frequencies you want to compare clicks across:
% comparing across the full bandwidth tends to reduce differences between click
% types. Results are typically better if you focus on comparing the region
% where frequencies differ most.
p.startFreq = 5; % index of start freq in vector "f" from TPWS
p.endFreq = 98; % index of end freq

%%% Vectors to use for binning ICI and click rate
p.barIntMax = 0.6; % ICI bins in seconds (minICI:resolution:maxICI)
%p.barRate = 1:1:30; % click rate in clicks per second (minRate:resolution:maxRate)

p.diff = 0;% compare first derivative of spectra if 1. If 0 spectra will be compared normally.

% Option to enforce a minimum recieved level (dB peak to peak), and only
% cluster high-amplitude clicks, which tend to have cleaner spectra.
p.ppThresh = 120;

%%% Time bins: clicks are clustered by time bin. How long of a bin do you
% want to consider?
% Larger bins -> more clicks, better representation for slow clicking species.
% But large time bins mean more click counts -> longer computation times,
% or subsampling
p.timeStep = 5; % bin duration in mins
p.maxNetworkSz = 10000; % maximum # of clicks allowed in a network.
% If there are more clicks in a time bin than this number, a random subset
% will be selected for clustering. Your computer will need to handle
% maxNetworkSz^2 edges, so more RAM -> larger networks.
p.minCueGap = 0; % minimum gap between clicks in seconds. Helps exclude buzzes.

p.diary = 0; % If 1, turn on diary logging of console output. Warning: Files can get large.

p.parpoolSize = 1; % How many parallel workers to use?