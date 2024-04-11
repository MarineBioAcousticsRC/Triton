function plot_ltsa
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% plot_ltsa.m
%
% Plots ltsa on main window
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS HANDLES REMORA

% get which figures plotted
savalue = get(HANDLES.display.ltsa,'Value');
tsvalue = get(HANDLES.display.timeseries,'Value');
spvalue = get(HANDLES.display.spectra,'Value');
sgvalue = get(HANDLES.display.specgram,'Value');


% if isfield(REMORA,'ltsa_plot_lVis_lab')
%     if savalue
%         REMORA.ltsa_plot_lVis_lab{1}();
%     end
%     if sgvalue
%         REMORA.ltsa_plot_lVis_lab{2}();
%     end
%     if tsvalue
%         REMORA.ltsa_plot_lVis_lab{3}();
%     end
% end

% total number of plots in window
m = savalue + tsvalue + spvalue + sgvalue;

% check and apply/remove ltsa equalization:
state1 = get(HANDLES.ltsa.eq.tog,'Value');
state2 = get(HANDLES.ltsa.eq.tog2,'Value');
eflag = 0;
if state1 == get(HANDLES.ltsa.eq.tog,'Max') && ...
        state2 == get(HANDLES.ltsa.eq.tog2,'Min')
    pwr = PARAMS.ltsa.pwr - mean(PARAMS.ltsa.pwr,2) * ones(1,length(PARAMS.ltsa.t));
    eflag = 1;
elseif state1 == get(HANDLES.ltsa.eq.tog,'Max') && ...
        state2 == get(HANDLES.ltsa.eq.tog2,'Max')
    pwr = PARAMS.ltsa.pwr - PARAMS.ltsa.mean.save* ones(1,length(PARAMS.ltsa.t));
    eflag = 2;
elseif state1 == get(HANDLES.ltsa.eq.tog,'Min') %CMS-used by BS disk 06 but also for disk 03 that works! 
    pwr = PARAMS.ltsa.pwr;
    eflag = 0;
end

% change plot freq axis
pwr = pwr(PARAMS.ltsa.fimin:PARAMS.ltsa.fimax,:);

c = (PARAMS.ltsa.contrast/100) .* pwr + PARAMS.ltsa.bright; % CMS-pwr has infinity (+/-) in here

% plot specgram
HANDLES.subplt.ltsa = subplot(HANDLES.plot.now);

if PARAMS.ltsa.fax == 0
    HANDLES.plt.ltsa = image(PARAMS.ltsa.t,PARAMS.ltsa.f,c);
elseif PARAMS.ltsa.fax == 1
    flen = length(PARAMS.ltsa.f);
    [M,N] = logfmap(flen,4,flen);
    c = M*c;
    f = M*PARAMS.ltsa.f;
    HANDLES.ltsa.plt = image(PARAMS.ltsa.t,f,c);
    set(get(HANDLES.plt.ltsa,'Parent'),'YScale','log');
    set(gca,'TickDir','out')
elseif PARAMS.ltsa.fax == 2
    HANDLES.plt.ltsa = image(PARAMS.ltsa.t,PARAMS.ltsa.f/1000,c);
end

% Make sure color range is fixed.
set(HANDLES.plt.ltsa,'CDataMapping','scaled');
caxis([1,65]);

% shift and shrink plot by dv
dv = 0.075;
v = get(get(HANDLES.plt.ltsa,'Parent'),'Position');

axis xy

Pos = get(HANDLES.fig.main,'Position');

% colorbar
PARAMS.ltsa.cb = colorbar('vert');

v2 = get(PARAMS.ltsa.cb,'Position');
set(PARAMS.ltsa.cb,'Position',[0.925 v2(2) 0.01 v2(4)])
yl=get(PARAMS.ltsa.cb,'YLabel');
set(yl,'String','Spectrum Level [dB re counts^2/Hz]')

% set color bar xlimit
minp = min(min(PARAMS.ltsa.pwr));
maxp = max(max(PARAMS.ltsa.pwr));
%set(PARAMS.ltsa.cb,'YLim',[minp maxp]) %Commented out because it changes
%colorbar to show only part of the range.

% One of the child objects of the colorbar is an image, find it so we can
% set an appropriate scale.
PARAMS.ltsa.cbb = findobj(get(PARAMS.ltsa.cb, 'Children'), 'Type', 'image');
minc = min(min(c));
maxc = max(max(c));
difc = 2;
set(PARAMS.ltsa.cbb,'CData',[minc:difc:maxc]')
set(PARAMS.ltsa.cbb,'YData',[minp maxp]) %CMS - breaking here for BS_disk04, because minc and minp are neg. infinity
%sets the tick mode for color bar to manual to fix printing error
set(PARAMS.ltsa.cb,'YTickMode','manual')

% define colormapping
if strcmp(PARAMS.ltsa.cmap,'gray') % make negative colormap ie dark is big amp
    g = gray;
    szg = size(g);
    cmap = g(szg:-1:1,:);
    colormap(cmap)
else
    colormap(PARAMS.ltsa.cmap)
end

% labels
xlabel('Time [hours]')

% get freq axis label
ylim = get(get(HANDLES.plt.ltsa,'Parent'),'YLim');
ytick = get(get(HANDLES.plt.ltsa,'Parent'),'YTick');
if  ylim(2) < 10000
    set(get(HANDLES.plt.ltsa,'Parent'),'YtickLabel',num2str(ytick'))
    ylabel('Frequency [Hz]')
else
    set(get(HANDLES.plt.ltsa,'Parent'),'YtickLabel',num2str((ytick')./1000))
    ylabel('Frequency [kHz]')
end
set(get(HANDLES.plt.ltsa,'Parent'),'YtickMode','manual')

% title - always displayed
sa_title = sprintf(' CH=%d', PARAMS.ltsa.ch);
title([PARAMS.ltsa.inpath,PARAMS.ltsa.infile, sa_title])

% text positions
tx = [0 0.70 0.85];                 % x
ty = [-0.05 -0.125 -0.175 -0.25];  % y upper left&right
ty2 = [-0.075 -0.175 -0.25 -0.35];  % y lower right

text('Position',[tx(1) ty(m)],'Units','normalized',...
    'String',timestr(PARAMS.ltsa.plot.dnum,6));
%     'String',[num2str(PARAMS.ltsa.start.yr),':',PARAMS.ltsa.start.str]);
text('Position',[tx(2) ty(m)],'Units','normalized',...
    'String',['Fs = ',num2str(PARAMS.ltsa.fs),', Tave = ',...
    num2str(PARAMS.ltsa.tave),'s, NFFT = ',num2str(PARAMS.ltsa.nfft)]);
HANDLES.ltsa.BC = text('Position',[tx(3) ty2(m)],'Units','normalized',...
    'String',['B = ',num2str(PARAMS.ltsa.bright),', C = ',num2str(PARAMS.ltsa.contrast)]);

% Spectrogram Equalization:
if eflag == 1 || eflag == 2
   text('Position',[tx(2) ty2(m)],'Units','normalized',...
    'String',['SG Equal On'])
end

if PARAMS.ltsa.delimit.value
    ltsa_delimiter
end


if isfield(REMORA,'ltsa_plot_lVis_lab')
    if savalue
        REMORA.ltsa_plot_lVis_lab{1}();
    end
end

% change time in control window to data time in plot window
set(HANDLES.ltsa.time.edtxt1,'String',timestr(PARAMS.ltsa.plot.dnum,6));
% set(HANDLES.ltsa.time.edtxt3,'String',PARAMS.ltsa.tseg.hr);


