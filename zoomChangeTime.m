function zoomChangeTime()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% zoomChangeTime.m
%
% after zooming in main figure plot window, change the time of the data
% to correspond to the zoomed values
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global HANDLES PARAMS
% only change time is zoom in on Time Series and Spectrogram
tsvalue = get(HANDLES.display.timeseries,'Value');
sgvalue = get(HANDLES.display.specgram,'Value');
savalue = get(HANDLES.display.ltsa,'Value');

if tsvalue  % timeseries
    if gco == HANDLES.subplt.timeseries | gco == HANDLES.plt.timeseries ...
            | gco == HANDLES.delimit.tsline

        v = axis;

        % set plot length
        PARAMS.tseg.sec = v(2) - v(1);

        % set the plot start time
        PARAMS.plot.dnum = PARAMS.plot.dnum + datenum([0 0 0 0 0 v(1)]);
        PARAMS.plot.dvec = datevec(PARAMS.plot.dnum);

        % read the data plot it
        readseg
        plot_triton
    end
end

if sgvalue % spectrogram
    if gco == HANDLES.subplt.specgram | gco == HANDLES.plt.specgram...
            | gco == HANDLES.delimit.sgline

        v = axis;

        % set plot length
        PARAMS.tseg.sec = v(2) - v(1);

        % set the plot start time
        PARAMS.plot.dnum = PARAMS.plot.dnum + datenum([0 0 0 0 0 v(1)]);
        PARAMS.plot.dvec = datevec(PARAMS.plot.dnum);

        % read the data plot it
        readseg
        plot_triton
    end
end

if savalue % long term spectral average
    if (ishandle(HANDLES.subplt.ltsa) & gco == HANDLES.subplt.ltsa) | ...
            (ishandle(HANDLES.plt.ltsa) & gco == HANDLES.plt.ltsa)

        v = axis;

        PARAMS.ltsa.tseg.hr = v(2) - v(1);
        PARAMS.ltsa.tseg.sec =  PARAMS.ltsa.tseg.hr * (60 * 60);  % convert from hours to second

        PARAMS.ltsa.plot.dnum = PARAMS.ltsa.plot.dnum + datenum([0 0 0 v(1) 0 0]);

        read_ltsadata
        plot_triton

    end

end
