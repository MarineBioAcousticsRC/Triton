function ct_plot_bin_clusters(p,f,spectraMean,envMean,cRate,dtt,specHolder,...
    sizeCA,binNum,totalBins)

% plot mean spectra
h99 = figure(99);clf
set(h99,'MenuBar','none',...
    'Name','ClusterBins Active Plotting',...
    'NumberTitle','off',...
    'Position',[.2,.45,.65,.35],...
    'Units','normalized')


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
ylabel('Normalized Amplitude','Fontsize',12)
xlabel('Frequency (kHz)','Fontsize',12)

% Plot envelope shape
subplot(1,nSubplots,4)
plot(envMean','linewidth',2)
ylabel('Counts','Fontsize',12)
xlabel('Duration (samples)','Fontsize',12)


% Plot ICI distribution
h1 = subplot(1,nSubplots,3);
plot(p.barInt,dtt./repmat(max(dtt,[],2),1,size(dtt,2)),'linewidth',2)
xlim([min(p.barInt),max(p.barInt)])
ylabel('Normalized Counts','Fontsize',12)
xlabel('ICI (sec)','Fontsize',12)

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
imagesc(1:size(allSpectra,1),f,min(max(allSpectra,0),1)')
delimLocs = cumsum(sizeCA);
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
set(gcf,'PaperPosition', [-2.4,3.6,13.3,3.6])
% pause

hMainTitle = mtit(sprintf('Bin %0.0f of %0.0f',binNum,totalBins));

drawnow
% saveas(gcf,sprintf('saveFig_%0.0f.jpg',itrCounter))