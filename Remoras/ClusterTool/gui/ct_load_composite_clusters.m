function ct_load_composite_clusters

global REMORA
[FileName,PathName,~] = uigetfile('*.mat','Select composite clusters output file to load');
ccData = load(fullfile(PathName,FileName));
% TODO: need some kind of check here to see if it's the right thing.
REMORA.ct.CC.output = ccData;

