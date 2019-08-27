function hSet = ct_intercluster_plots(p,s,f,nodeSet,compositeData,Tfinal,labelStr,figDir)

n1 = 3; % number of rows of subplots, one subplot per type
m1 = ceil(length(nodeSet)/n1); % number of columns of subplots
figure(41);clf(41);set(gcf,'Units','normalized','Position',[0.01,.05,.48,.4])
figure(42);clf(42);set(gcf,'Units','normalized','Position',[0.01,.52,.48,.4])
figure(43);clf(43);set(gcf,'Units','normalized','Position',[.5,.05,.48,.4])
figure(44);clf(44);set(gcf,'Units','normalized','Position',[.5,.52,.48,.4])

figName{1} = fullfile(figDir,sprintf('%s_autoTypes_allMeanSpec',s.outputName));
figName{2} = fullfile(figDir,sprintf('%s_autoTypes_allCatSpec',s.outputName));
figName{3} = fullfile(figDir,sprintf('%s_autoTypes_allICI',s.outputName));
figName{4} = fullfile(figDir,sprintf('%s_autoTypes_allcRate',s.outputName));

for iF = 1:length(nodeSet)
    hSet(1) = figure(41); % plot spectra means and percentiles
    subplot(n1,m1,iF)
    hold on
    plot(f,compositeData(iF).spectraMeanSet,'-k','lineWidth',2)
    %xlim([f(s.stIdx),f(s.edIdx)])
    legend(num2str(size(nodeSet{iF},2)),'location','Southeast')
    plot(f,compositeData(iF).specPrctile,'--k','lineWidth',2)
    grid on
    hold off
    ylim([0,1])
    
    hSet(2) = figure(42); % plot spectra as heatmap
    subplot(n1,m1,iF)
    imagesc(1:length(nodeSet{iF}),f(p.startFreqIdx:p.endFreqIdx),Tfinal{iF,1}')
    set(gca,'ydir','normal')
    title(labelStr{iF})
    % ylim([min(f(p.startFreqIdx)),max(f(p.endFreqIdx))])
    
    hSet(3) = figure(43); % plot ICI distributions
    subplot(n1,m1,iF)
    errorbar(p.barInt(1:s.maxICIidx) + s.barAdj,compositeData(iF).iciMean,...
        zeros(size(compositeData(iF).iciStd)),compositeData(iF).iciStd,'.k')
    hold on
    bar(p.barInt(1:s.maxICIidx) + s.barAdj,compositeData(iF).iciMean,1);
    xlim([0,p.barInt(s.maxICIidx)])
    ylim([0,1])
    hold off
    
    hSet(4) = figure(44); % plot click rate distributions
    subplot(n1,m1,iF)  
    imagesc(1:length(nodeSet{iF}),p.barInt(1:s.maxICIidx),[Tfinal{iF,2}./max(Tfinal{iF,2},[],2)]')
    set(gca,'ydir','normal')
end
figure(41)
mxlabel(41,'Frequency (kHz)','FontSize',16);
mylabel(41,'Normalized Amplitude','FontSize',16);
figure(42)
mxlabel(42,'Click Number','FontSize',16);
mylabel(42,'Frequency (kHz)','FontSize',16);
figure(43)
mxlabel(43,'ICI (sec)','FontSize',16);
mylabel(43,'Normalized Counts','FontSize',16);
figure(44)
mxlabel(44,'Click Number','FontSize',16);
mylabel(44,'ICI (sec)','FontSize',16);
mtit(41,strrep(s.outputName,'_',' ' ),'FontSize',12);
mtit(42,strrep(s.outputName,'_',' ' ),'FontSize',12);
mtit(43,strrep(s.outputName,'_',' ' ),'FontSize',12);
mtit(44,strrep(s.outputName,'_',' ' ),'FontSize',12);
colormap(jet)

if s.saveOutput
    disp('Saving figures...')
    for iFig = 1:length(figName)
        set(hSet(iFig),'units','inches','PaperPositionMode','auto')%,'OuterPosition',[0.25 0.25  10  7.5])
        print(hSet(iFig),'-dtiff','-r600',[figName{iFig},'.tiff'])
        saveas(hSet(iFig),[figName{iFig},'.fig'])
        fprintf('Done with figure %0.0f\n',iFig)
    end
end
