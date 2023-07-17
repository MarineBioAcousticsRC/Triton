function ct_plot_bin_clusters(p,f,spectraMean,envMean,inputFileName,dtt,specHolder,...
    envSetHolder,sizeCA,binNum,totalBins,figCounter)

% plot mean spectra

if ~isgraphics(99)
    h99 = figure(99);clf
    set(h99,...
        'Name','ClusterBins Active Plotting',...
        'NumberTitle','off',...
        'Units','normalized',...
        'Position',[.2,.45,.65,.35])
else
    figure(99);clf
end
nSubplots = 4;


subplot(1,nSubplots,1)
hold on
% hR = rectangle('Position',[f(p.stIdx),0,f(p.edIdx)-f(p.stIdx),...
%     1],'FaceColor',[.99,.92,.8],'EdgeColor',[.99,.92,.8]);
plot(f,spectraMean,'linewidth',2)
ylim([min(min(spectraMean)),...
    max(max(spectraMean))])
hold off
box on
xlim([min(f),max(f)])
%ylim([0,1])
ylabel('Normalized Amplitude','Fontsize',12)
xlabel('Frequency (kHz)','Fontsize',12)
title('Mean Spectra' )
set(gca,'OuterPosition',get(gca,'OuterPosition')+[0,0.1,0,-.2])

% Plot envelope shape
subplot(1,nSubplots,4)
allEnv = cell2mat(envSetHolder');
if p.normalizeTF
    imagesc((allEnv./max(allEnv,[],2))')
else
    imagesc(allEnv')
end
%set(gca,'ydir','normal')
ylabel('Samples','Fontsize',12)
xlabel('ClickNumber','Fontsize',12)
delimLocs = cumsum(sizeCA);
% draw delimiters btwn click spectra if there are
% multiple types
if size(delimLocs,2)>1
    hold on
    for iDlim = 1:size(delimLocs,2)-1
        
        plot([delimLocs(iDlim),delimLocs(iDlim)],...
            [0,size(allEnv,2)],'k','LineWidth',3)
    end
    hold off
end
title('Waveform Envelope' )
set(gca,'OuterPosition',get(gca,'OuterPosition')+[0,0.1,0,-.2])

% Plot ICI distribution
h1 = subplot(1,nSubplots,3);
plot(p.barInt,dtt./repmat(max(dtt,[],2),1,size(dtt,2)),'linewidth',2)
xlim([min(p.barInt),max(p.barInt)])
ylabel('Normalized Counts','Fontsize',12)
xlabel('ICI (sec)','Fontsize',12)
title('ICI Distribution' )
set(gca,'OuterPosition',get(gca,'OuterPosition')+[0,0.1,0,-.2])

% % Plot click rate distribution
% subplot(2,2,4)
% plot(p.barRate,cRate)
% xlim([min(p.barRate),max(p.barRate)])
% ylabel('Counts','Fontsize',12)
% xlabel('Click Rate (clicks/sec)','Fontsize',12)

% plot concatenated spectra. Need to handle case where
% multiple click types are present.
h2 = subplot(1,nSubplots,2);
colormap(jet)
allSpectra = cell2mat(specHolder');
% if ~p.normalizeTF
%     imagesc(1:size(allSpectra,1),f,min(max(allSpectra,0),1)')
% else
imagesc(1:size(allSpectra,1),f,allSpectra')
%end
% draw delimiters btwn click spectra if there are
% multiple types
if size(delimLocs,2)>1
    hold on
    for iDlim = 1:size(delimLocs,2)-1
        
        plot([delimLocs(iDlim),delimLocs(iDlim)],...
            [min(f),max(f)],'k','LineWidth',3)
    end
    hold off
end
set(gca,'ydir','normal','Fontsize',10)
ylabel('Frequency (kHz)','Fontsize',12)
xlabel('Click Number','Fontsize',12)
set(gca,'OuterPosition',get(gca,'OuterPosition')+[0,0.1,0,-.2])

set(gcf,'PaperPosition', [-2.4,3.6,13.3,3.6])
% pause
title('Concatenated Spectra' )

[~, fileName, fileExt] = fileparts(inputFileName);
fileName = strrep(fileName,'_','\_'); % escape underscores so they don't become subscripts
hMainTitle = annotation('textbox',[.1,.91,.8,.09],'Units','normalized',...
    'HorizontalAlignment','center','EdgeColor','none','string',...
    sprintf('%s: Bin %0.0f of %0.0f',[fileName,fileExt],binNum,totalBins));

drawnow
if isfield(p,'pauseAfterPlotting') && p.pauseAfterPlotting
    % alert the user in both matlab console and triton messages that code
    % is paused.
    if p.tritonMsg 
        disp_msg('Paused. Press any key to continue.')
    end
    disp('Paused. Press any key to continue.')
    pause
end
 %saveas(gcf,sprintf('E:\\Data\\plot_cluster_bins\\saveFig_%0.0f.jpg',figCounter))