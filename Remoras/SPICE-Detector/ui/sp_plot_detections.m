function sp_plot_detections

global PARAMS REMORA HANDLES DATA


if get(HANDLES.display.specgram, 'Value') == 1
    specH = HANDLES.subplt.specgram;
    
    hold(specH,'on')
    plot(specH,REMORA.spice_dt.guiDets.clickTimes',...
        [REMORA.spice_dt.guiDets.peakFrVec,REMORA.spice_dt.guiDets.peakFrVec]'*1000,'-*r')
    hold(specH,'off')

end

if get(HANDLES.display.timeseries, 'Value') == 1
    specTS = HANDLES.subplt.timeseries;
    
    hold(specTS,'on')
    plot(specTS,REMORA.spice_dt.guiDets.clickTimes',...
        repmat(0, size(REMORA.spice_dt.guiDets.clickTimes,1),...
            size(REMORA.spice_dt.guiDets.clickTimes,2))','-*r')
    hold(specTS,'off')

end