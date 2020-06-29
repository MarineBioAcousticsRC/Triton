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

% ellipical filter
if PARAMS.filter
    [b,a] = ellip(4,0.1,40,[PARAMS.ff1 PARAMS.ff2]*2/PARAMS.fs);
    DATA(:,PARAMS.ch) = filter(b,a,DATA(:,PARAMS.ch));
end

len = length(DATA(:,PARAMS.ch));

% time series only
HANDLES.subplt.timeseries = subplot(HANDLES.plot.now);
HANDLES.plt.timeseries = plot((0:len-1)/PARAMS.fs,DATA(:,PARAMS.ch));

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
% & not a wav file
if PARAMS.ftype ~=1 && PARAMS.delimit.value && length(PARAMS.raw.delimit_time) ~= 1
  for r=1:length(PARAMS.raw.delimit_time)
    y = [v(3),v(4)];
    x = [PARAMS.raw.delimit_time(r), PARAMS.raw.delimit_time(r)];
    HANDLES.delimit.tsline(r) = line(x,y,'Color','r','LineWidth',4);
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
