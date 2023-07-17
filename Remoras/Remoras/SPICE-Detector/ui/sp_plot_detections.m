function sp_plot_detections

global REMORA HANDLES 


if get(HANDLES.display.specgram, 'Value') == 1
    specH = HANDLES.subplt.specgram;
    if isfield(REMORA.spice_dt,'specMarkerHandle')
        delete(REMORA.spice_dt.specMarkerHandle);
        REMORA.spice_dt.specMarkerHandle = [];
    end
    if ~isempty(REMORA.spice_dt.guiDets)
        hold(specH,'on')
        REMORA.spice_dt.specMarkerHandle = plot(specH,...
            REMORA.spice_dt.guiDets.clickTimes',...
            [REMORA.spice_dt.guiDets.peakFrVec,...
            REMORA.spice_dt.guiDets.peakFrVec]'*1000,'-ow');
        hold(specH,'off')
    end
end

if get(HANDLES.display.timeseries, 'Value') == 1
    specTS = HANDLES.subplt.timeseries;
    if isfield(REMORA.spice_dt,'timeMarkerHandle')
        delete(REMORA.spice_dt.timeMarkerHandle);
        REMORA.spice_dt.timeMarkerHandle = [];
    end
    if ~isempty(REMORA.spice_dt.guiDets)
        hold(specTS,'on')
        REMORA.spice_dt.timeMarkerHandle = plot(specTS,...
            REMORA.spice_dt.guiDets.clickTimes',...
            REMORA.spice_dt.detParams.countThresh.*...
            ones(size(REMORA.spice_dt.guiDets.clickTimes,1),...
            size(REMORA.spice_dt.guiDets.clickTimes,2))','-*k');
        hold(specTS,'off')
    end
end