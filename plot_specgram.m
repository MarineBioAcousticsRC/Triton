function plot_specgram
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% plot_specgram.m
%
% Plots the spectogram to the main window
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

if savalue && MultiCh_On
  PARAMS.ch = PARAMS.ch -1 ;
end

% ellipical filter
if PARAMS.filter
    [b,a] = ellip(4,0.1,40,[PARAMS.ff1 PARAMS.ff2]*2/PARAMS.fs);
    DATA(:,PARAMS.ch) = filter(b,a,DATA(:,PARAMS.ch));
end

if PARAMS.nfft <= length(DATA)
  % make spectrogram
  mkspecgram
elseif ~isempty(DATA(:,PARAMS.ch))
    disp_msg('DATA Length less than FFT Length')
    disp_msg('Setting plot to DATA Length')
    PARAMS.nfft = length(DATA(:,PARAMS.ch));
    set(HANDLES.specnfft.edtxt,'String', num2str(PARAMS.nfft))
    plot_triton
else
    disp_msg('DATA Length less than FFT Length')
    disp_msg('Spectrogram Plot Not Updated')
    return
end

% check and apply/remove spectrogram equalization:
state1 = get(HANDLES.sgeq.tog,'Value');
state2 = get(HANDLES.sgeq.tog2,'Value');
eflag = 0;
if state1 == get(HANDLES.sgeq.tog,'Max') & ...
        state2 == get(HANDLES.sgeq.tog2,'Min')
    sg = PARAMS.pwr - mean(PARAMS.pwr,2) * ones(1,length(PARAMS.t));
    eflag = 1;
elseif state1 == get(HANDLES.sgeq.tog,'Max') & ...
        state2 == get(HANDLES.sgeq.tog2,'Max')
    sg = PARAMS.pwr - PARAMS.mean.save* ones(1,length(PARAMS.t));
    eflag = 2;
elseif state1 == get(HANDLES.sgeq.tog,'Min')
    sg = PARAMS.pwr;
    eflag = 0;
end

% apply transfer function
if PARAMS.tf.flag == 1
    [C,ia,ic] = unique(PARAMS.tf.freq); % check for repeated values and discard
    if length(ia) == length(ic)
        freq = PARAMS.tf.freq;
        uppc = PARAMS.tf.uppc;
    else
        freq = PARAMS.tf.freq(ia);
        uppc = PARAMS.tf.uppc(ia);
    end
    Ptf = interp1(freq,uppc,PARAMS.f,'linear','extrap');
%     Ptf = interp1(PARAMS.tf.freq,PARAMS.tf.uppc,PARAMS.f,'linear','extrap');
    sz = size(sg);
    bwdb = 10*log10(PARAMS.nfft/PARAMS.fs);
    sg = Ptf*ones(1,sz(2)) + sg + bwdb*ones(sz(1),sz(2));
elseif PARAMS.tf.flag == 0  % do not apply transfer function
    sg = sg;
end
% apply brightness & contrast
c = (PARAMS.contrast/100) .* sg + PARAMS.bright;

HANDLES.subplt.specgram = subplot(HANDLES.plot.now);

if PARAMS.sgfax == 0
    HANDLES.plt.specgram = image(PARAMS.t,PARAMS.f,c);
% commented this part out because spectrogram doesn't need log axis
elseif PARAMS.sgfax == 1
    flen = length(PARAMS.f);
    if flen > 1000
        disp_msg('FFT Length too Long for Logarithmic Spectrogram Plot')
        disp_msg('Spectrogram Plot Not Updated')
        return
    end
    [M,N] = logfmap(flen,4,flen);
    c = M*c;
    f = M*PARAMS.f;
    HANDLES.plt.specgram = image(PARAMS.t,f,c);
    set(get(HANDLES.plt.specgram,'Parent'),'YScale','log');
    set(gca,'TickDir','out')

% there is a problem with this surf implementation - different sample rates
% and time windows seem to be missing data ( try df100 with 7 seconds, df20
% with 10 seconds )
%     HANDLES.plt.specgram = surf(PARAMS.t,PARAMS.f,c,'Linestyle','none','CDataMapping','direct');
%     sgAx = get(HANDLES.plt.specgram,'Parent');
%     view(sgAx,0,90)
%     set(sgAx,'yscale','log')
%     set(sgAx,'TickDir','out')
%     set(sgAx,'Ylim',[ PARAMS.freq0 PARAMS.freq1 ]);
end

% draw delimiter line if active and not wav file
% draw delimiter line does NOT work for new log specgram/surf
if PARAMS.ftype ~=1 && PARAMS.delimit.value && length(PARAMS.raw.delimit_time) ~= 1
    for r=1:length(PARAMS.raw.delimit_time)
        y = [min(PARAMS.f),max(PARAMS.f)];
        x = [PARAMS.raw.delimit_time(r), PARAMS.raw.delimit_time(r)];
        HANDLES.delimit.sgline(r) = line(x,y,'Color','r','LineStyle','--','LineWidth',4);
    end
end

% Make sure color range is fixed.
set(HANDLES.plt.specgram,'CDataMapping','scaled');
caxis([1,65]);

axis xy

% colorbar
PARAMS.cb = colorbar('vert');
v2 = get(PARAMS.cb,'Position');
set(PARAMS.cb,'Position',[0.925 v2(2) 0.01 v2(4)])
yl=get(PARAMS.cb,'YLabel');
if PARAMS.tf.flag == 1
    set(yl,'String','Spectrum Level [dB re 1\muPa^2/Hz]')
else
    set(yl,'String','Spectrum Level [dB re counts^2/Hz]')
end

% get freq axis label
ylim = get(get(HANDLES.plt.specgram,'Parent'),'YLim');
ytick = get(get(HANDLES.plt.specgram,'Parent'),'YTick');
if  ylim(2) < 10000
    set(get(HANDLES.plt.specgram,'Parent'),'YtickLabel',num2str(ytick'))
    ylabel('Frequency [Hz]')
else
    set(get(HANDLES.plt.specgram,'Parent'),'YtickLabel',num2str((ytick')./1000))
    ylabel('Frequency [kHz]')
end
set(get(HANDLES.plt.specgram,'Parent'),'YtickMode','manual')
set(get(HANDLES.plt.specgram, 'Parent'), 'TickDir', 'out')

% set color bar limit
% minp = min(min(PARAMS.pwr)); 
minp = min(min(sg));
% maxp = max(max(PARAMS.pwr)); 
maxp = max(max(sg));
%set(PARAMS.cb,'YLim',[minp maxp]) %Commented out because it changes
%colorbar to show only part of the range.

% image (child of colorbar)
PARAMS.cbb = findobj(get(PARAMS.cb, 'Children'), 'Type', 'image');
minc = min(min(c));
maxc = max(max(c));
if isinf(minc)
    minc = -100;
end
if isinf(maxc)
    maxc = 100;
end
difc = 2;
set(PARAMS.cbb,'CData',[minc:difc:maxc]')
set(PARAMS.cbb,'YData',[minp maxp])
%sets the tick mode for color bar to manual to fix printing error
set(PARAMS.cb,'YTickMode','manual')

% define colormapping
if strcmp(PARAMS.cmap,'gray') % make negative colormap ie dark is big amp
    g = gray;
    szg = size(g);
    cmap = g(szg:-1:1,:);
    colormap(cmap)
else
    colormap(PARAMS.cmap)
end

if ~tsvalue
    % label
    xlabel('Time [seconds]')
end

% text positions
tx = [0 0.70 0.85];
ty = [-0.05 -0.125 -0.175 -0.25];
ty2 = [-0.075 -0.175 -0.25 -0.35];
MultiCh_On = get(HANDLES.mc.on, 'Value');

if MultiCh_On
  %left blank to not write in text under each individual graph, text
  %written in plot_triton.m under the last graph
else
% put window start time on bottom plot only:
if ~tsvalue & ~spvalue
    % put window start time on all plots:
    text('Position',[tx(1) ty(m)],'Units','normalized',...
        'String',timestr(PARAMS.plot.dnum,1));
end
% spectral parameters
text('Position',[tx(2) ty(m)],'Units','normalized',...
  'String',['Fs = ',num2str(PARAMS.fs),', NFFT = ',num2str(PARAMS.nfft),...
  ', %OL = ',num2str(PARAMS.overlap)]);
HANDLES.BC = text('Position',[tx(3) ty2(m)],'Units','normalized',...
  'String',['B = ',num2str(PARAMS.bright),', C = ',num2str(PARAMS.contrast)]);
end

% Spectrogram Equalization:
if eflag == 1 | eflag == 2
   text('Position',[tx(2) ty2(m)],'Units','normalized',...
    'String',['SG Equal On'])
end

% always plot title - specgram always on top
if PARAMS.filter == 1 && PARAMS.ch == 1
    title([PARAMS.inpath,PARAMS.infile,' CH=',num2str(PARAMS.ch),...
        '      Band Pass Filter ',num2str(PARAMS.ff1),' Hz to ',...
        num2str(PARAMS.ff2),' Hz'])
elseif ~PARAMS.filter == 1 && PARAMS.ch == 1
    title([PARAMS.inpath,PARAMS.infile,' CH=',num2str(PARAMS.ch)])
end

if isfield(REMORA,'ltsa_plot_lVis_lab')
    if sgvalue
        REMORA.ltsa_plot_lVis_lab{2}();
    end
end
