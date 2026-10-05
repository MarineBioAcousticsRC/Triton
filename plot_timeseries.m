function plot_timeseries
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% plot_timeseries.m
%
% plots the timeseries to the main window
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global DATA HANDLES PARAMS REMORA

% get which figures plotted
savalue = get(HANDLES.display.ltsa,'Value');
tsvalue = get(HANDLES.display.timeseries,'Value');
spvalue = get(HANDLES.display.spectra,'Value');
sgvalue = get(HANDLES.display.specgram,'Value');
MultiCh_On = get(HANDLES.mc.on, 'Value');

% total number of plots in window
m = savalue + tsvalue + spvalue + sgvalue;

% DATA length
if savalue && MultiCh_On
  PARAMS.ch = PARAMS.ch - 1;
end

% zero-phase FIR bandpass (see display_filter.m)
if PARAMS.filter
    DATA(:,PARAMS.ch) = display_filter(DATA(:,PARAMS.ch), ...
        PARAMS.fs, PARAMS.ff1, PARAMS.ff2);
end

% ---- display-only gap padding ----------------------------------------------
% See gap_pad_display: DATA comes back from readseg spliced across real
% recording gaps, so the plotted axis is short by the gap length after each one.
% Pad a LOCAL copy for the picture; the global DATA is left as readseg gave it.
tsDATA = DATA;
if PARAMS.ftype ~= 1 && isfield(PARAMS.raw,'gap_time') && ~isempty(PARAMS.raw.gap_time)
    tsDATA = gap_pad_display(DATA, PARAMS.raw.gap_time, PARAMS.fs, PARAMS.tseg.samp);
end

len = length(tsDATA(:,PARAMS.ch));

% time series only
HANDLES.subplt.timeseries = subplot(HANDLES.plot.now);
HANDLES.plt.timeseries = plot((0:len-1)/PARAMS.fs,tsDATA(:,PARAMS.ch));

% check to see if time series plot goes past end of data, if so,
% correct it
v = axis;
if PARAMS.auto.amp 
    if v(2) > (len-1)/PARAMS.fs
        v(2) = (len-1)/PARAMS.fs;
        axis(v)
    end
else
    axis([v(1) v(2) PARAMS.ts.min PARAMS.ts.max])
end

% plot red line if plot figure crosses RawFile boundary & delimit button on
% & this is an x.wav or x.flac. ftype == 2 rather than ~= 1: ftype 3 is a plain
% flac with no raw-file structure (sfregosi-noaa, PR #132).
if PARAMS.ftype == 2 && PARAMS.delimit.value && any(PARAMS.raw.delimit_time > 0)
  for r=1:length(PARAMS.raw.delimit_time)
    y = [v(3),v(4)];
    x = [PARAMS.raw.delimit_time(r), PARAMS.raw.delimit_time(r)];
    HANDLES.delimit.tsline(r) = line(x,y,'Color','r','LineWidth',4);
  end
end

% shade real recording gaps -- inserted silence, not quiet water
if PARAMS.ftype ~= 1 && PARAMS.delimit.value && ...
        isfield(PARAMS.raw,'gap_time') && ~isempty(PARAMS.raw.gap_time)
    y = [v(3), v(4)];
    for r = 1:size(PARAMS.raw.gap_time,1)
        x0 = PARAMS.raw.gap_time(r,1);
        x1 = x0 + PARAMS.raw.gap_time(r,2);
        HANDLES.delimit.tsgap(r) = patch('XData', [x0 x1 x1 x0], ...
            'YData', [y(1) y(1) y(2) y(2)], 'FaceColor', [1 0.55 0], ...
            'FaceAlpha', 0.25, 'EdgeColor', [1 0.55 0], 'LineStyle', ':', ...
            'LineWidth', 1.5);
    end
end

%labels
ylabel('Amplitude [counts]')
xlabel('Time [seconds]')

% text positions
tx = [0 0.70 0.85];                 % x
ty = [-0.05 -0.125 -0.175 -0.25];  % y upper left&right
ty2 = [-0.075 -0.175 -0.25 -0.35];  % y lower right

MultiCh_On = get(HANDLES.mc.on, 'Value');
if ~spvalue
    % put window start time on bottom plot only:
    if MultiCh_On
    else
    text('Position',[0 ty(m)],'Units','normalized',...
        'String',timestr(PARAMS.plot.dnum,1));
    end
end

% plot title on top plot
if ~sgvalue
  if MultiCh_On
  %left blank to not write in text under each individual graph, text
  %written in plot_triton.m under the last graph
  else
    if PARAMS.filter == 1
        title([PARAMS.inpath,PARAMS.infile,' CH=',num2str(PARAMS.ch),...
            '      Band Pass Filter ',num2str(PARAMS.ff1),' Hz to ',...
            num2str(PARAMS.ff2),' Hz'])
    else
        title([PARAMS.inpath,PARAMS.infile,' CH=',num2str(PARAMS.ch)])
    end
  end
end

if isfield(REMORA,'ltsa_plot_lVis_lab')
    if tsvalue
        REMORA.ltsa_plot_lVis_lab{3}();
    end
end
