function ct_load_composite_clusters(hObject,eventdata)

global REMORA
[FileName,PathName,~] = uigetfile('*all.mat','Select composite clusters output file to load');
if FileName == 0
    warning('No composite clusters file selected, some tools may not work.')
else
    disp('loading...')
    ccData = load(fullfile(PathName,FileName));
    % TODO: need some kind of check here to see if it's the right thing.
    REMORA.ct.CC.output = ccData;
    REMORA.ct.CC_params = ccData.s;
    REMORA.ct.CC_params.outputName = ccData.s.outputName;
    REMORA.ct.CC.output.remakePlots = 1;
    REMORA.ct.CC.output.s.saveOutput = 0;
    ct_intercluster_plots(REMORA.ct.CC.output.p,REMORA.ct.CC.output.s,...
        REMORA.ct.CC.output.f,REMORA.ct.CC.output.nodeSet,...
        REMORA.ct.CC.output.compositeData,REMORA.ct.CC.output.Tfinal,...
        REMORA.ct.CC.output.labelStr,[]);
    ct_init_compClust_window
    disp('load complete.')
end