function plot_spectra
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% plot_spectra.m
%
% Plots the spectra to the main window
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global DATA HANDLES PARAMS

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

% remove dc offset (mean)
dtdata = detrend(DATA(:,PARAMS.ch),'constant');
%window = triton_hanning_v140(PARAMS.nfft);
window = hanning(PARAMS.nfft);
noverlap = round((PARAMS.overlap/100)*PARAMS.nfft);
% calc power spectral density (need signal toolbox)
if PARAMS.nfft <= length(dtdata)
    [Pxx,F] = pwelch(dtdata,window,noverlap,PARAMS.nfft,PARAMS.fs);
else
    disp_msg('DATA Length less than FFT Length')
    disp_msg('Spectra Plot Not Updated')
    % time should be replotted
    text('Position',[0 -0.25],'Units','normalized',...
    'String',timestr(PARAMS.plot.dnum,1));
    return
end

% calc RMS (ie average power)
% n = length(dtdata);
% rmsdB = 20*log10( sqrt(sum(dtdata .* dtdata)/n));

Pxx = 10*log10(Pxx);

% apply transfer function
if PARAMS.tf.flag == 1 
    [C,ia,ic] = unique(PARAMS.tf.freq);
    if length(ia) == length(ic)
        freq = PARAMS.tf.freq;
        uppc = PARAMS.tf.uppc;
    else
        freq = PARAMS.tf.freq(ia);
        uppc = PARAMS.tf.uppc(ia);
    end
    Ptf = interp1(freq,uppc,F,'linear','extrap');
    Pxx = Ptf + Pxx;
end

% Pmax = max(Pxx);

HANDLES.subplt.spectra = subplot(HANDLES.plot.now);

% linear or log axis
if PARAMS.fax == 0
    HANDLES.plt.spectra = plot(F,Pxx);
elseif PARAMS.fax == 1
    HANDLES.plt.spectra = semilogx(F,Pxx);
end
grid on

% % xlabel
xlabel('Frequency [Hz]')

% ylabel
if PARAMS.tf.flag == 0
    ylabel('Spectrum Level [dB re counts^2/Hz]')
%     if PARAMS.nfft == PARAMS.fs
%         ylabel('Pressure Level [dB re counts]')
%     end
elseif PARAMS.tf.flag == 1
%     ylabel('Spectrum Level [dB re uPa^2/Hz]')
    ylabel('Spectrum Level [dB re \muPa^2/Hz]')
%     if PARAMS.nfft == PARAMS.fs
%         ylabel('Pressure Level [dB re uPa]')
%     end
end

% get axis limits and change
v=axis;
if PARAMS.auto.spl
    axis([PARAMS.freq0 PARAMS.freq1 v(3) v(4) ]);
else
    axis([PARAMS.freq0 PARAMS.freq1 PARAMS.sp.min PARAMS.sp.max ]);
end

% time info
len = length(DATA(:,PARAMS.ch));
dT1 = len/PARAMS.fs;

% text positions
tx = [0 0.70 0.85];                 % x
ty = [-0.05 -0.125 -0.175 -0.25];  % y upper left&right
ty2 = [-0.075 -0.175 -0.25 -0.35];  % y lower right

MultiCh_On = get(HANDLES.mc.on, 'Value');

if MultiCh_On
  %left blank to not write in text under each individual graph, text
  %written in plot_triton.m under the last graph
else
% time - always on spectra plot
  text('Position',[tx(1) ty(m)],'Units','normalized',...
    'String',timestr(PARAMS.plot.dnum,1));
  % spectral parameters - always plotted
  text('Position',[tx(2) ty(m)],'Units','normalized',...
    'String',['Fs = ',num2str(PARAMS.fs),', NFFT = ',num2str(PARAMS.nfft),...
    ', %OL = ',num2str(PARAMS.overlap)]);
text('Position',[tx(3) ty2(m)],'Units','normalized',...
    'String',['Time Window = ',num2str(dT1),' secs']);
end

if PARAMS.tf.flag == 1
    if ~isempty(PARAMS.tf.filename)
        text('Position',[tx(1) ty2(m)],'Units','normalized',...
            'String',['TF File: ',PARAMS.tf.filename]);
    else
        text('Position',[tx(1) ty2(m)],'Units','normalized',...
            'String','TF File: Not Loaded');
%             'String',['TF File: Not Loaded']);
    end
end

% title if only spectra plot
% if ~tsvalue & ~sgvalue
if ~tsvalue && ~sgvalue
  if MultiCh_On
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