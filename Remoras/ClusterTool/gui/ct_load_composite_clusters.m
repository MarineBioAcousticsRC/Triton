function ct_load_composite_clusters(hObject,eventdata)

global REMORA
[FileName,PathName,~] = uigetfile('*all.mat','Select composite clusters output file to load');
disp('loading...')
ccData = load(fullfile(PathName,FileName));
% TODO: need some kind of check here to see if it's the right thing.
REMORA.ct.CC.output = ccData;
REMORA.ct.CC_params = ccData.p;
REMORA.ct.CC_params.outputName = FileName;
REMORA.ct.CC.output.remakePlots = 1;
disp('load complete.')
