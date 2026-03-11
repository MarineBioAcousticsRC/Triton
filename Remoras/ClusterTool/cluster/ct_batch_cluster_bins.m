


load('E:\Code\triton1.93.20160524_remoras\Remoras\ClusterTool\settings\GOM_125dBpp.mat')

dirList = dir('I:\G*\**\*TPWS');
p.plotFlag = 0;
for iD = 1:length(dirList)
    p.inDir = fullfile(dirList(iD).folder,dirList(iD).name);
    p.outDir = fullfile(dirList(iD).folder,strrep(dirList(iD).name,'_TPWS','_ClusterBins_125_noNorm'));
    
    ct_cluster_bins(p)
    
end