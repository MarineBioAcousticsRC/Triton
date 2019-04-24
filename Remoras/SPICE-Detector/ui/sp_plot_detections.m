function sp_plot_detections

global PARAMS REMORA HANDLES DATA

specH = HANDLES.subplt.specgram;

hold(specH,'on')
plot(REMORA.spice_dt.guiDets.clickTimes',...
    repmat([REMORA.spice_dt.guiDets.peakFrVec,REMORA.spice_dt.guiDets.peakFrVec]'*1000,'-*r')