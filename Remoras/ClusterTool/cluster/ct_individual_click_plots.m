function ct_individual_click_plots(p,s,f,nodeSet,compositeData,Tfinal,labelStr,outDir)

siteNameNo_ = strrep(s.outputName,'_','\_');

for iF = 1:length(nodeSet)
    figure(400);clf
    
    subplot(1,3,1)
    errorbar(p.barInt(1:s.maxICIidx)+ s.barAdj,...
        compositeData(iF).iciMean,zeros(size(compositeData(iF).iciStd)),...
        compositeData(iF).iciStd,'.k')
    xlabel('ICI (sec)','FontSize',12)
    hold on
    hbI2 = bar(p.barInt(1:s.maxICIidx)+ s.barAdj,compositeData(iF).iciMean,1);
    xlim([0,p.barInt(s.maxICIidx)])
    ylim([0,1])
    ylabel('Relative Counts','FontSize',12)
%     annotation('textbox',[.02 .82 .1 .1],'units','normalized','String',...
%         siteNameNo_,'LineStyle','none','FontSize',14,'FontWeight','demi')
    set(gca,'box','on','fontsize',11)
    hold off
    ylim([0,1])
    
%     subplot(1,4,2)
%     annotation('textbox',[.22 .82 .1 .1],'units','normalized','String',...
%         ['n = ',num2str(size(nodeSet{iF},2))],'LineStyle','none','FontSize',11)
%     errorbar(p.barRate,compositeData(iF).cRateMean,...
%         zeros(size(compositeData(iF).cRateStd)),compositeData(iF).cRateStd,'.k')
%     hold on
%     hbR2 = bar(p.barRate,compositeData(iF).cRateMean,1);
%     xlabel('Click Rate (clicks/sec)','FontSize',12)
%     set(gca,'box','on','fontsize',11)
%     hold off
%     ylim([0,1])
%     xlim([min(p.barRate),max(p.barRate)])
    
    hs3 = subplot(1,3,2);
    hold on
    fPlot = f;
    if length(fPlot)~=length(compositeData(iF).spectraMeanSet) &&... 
        length(f(s.stIdx:s.edIdx))~=size(compositeData(iF).spectraMeanSet,2)
        %Catch for backward compatibility if orignial fill spectra were not stored
        fPlot = f(s.stIdx,s.edIdx);
    else
        warning('Frequency vector and spectra differ in length. Display errors possible in plots')
        fPlot = linspace(s.startFreq,s.endFreq,length(compositeData(iF).spectraMeanSet));
    end
    hp2 = plot(fPlot,compositeData(iF).spectraMeanSet,'-k','lineWidth',2);
    
    set(gca,'box','on','FontSize',11)
    ylim([0,1])
    xlim([min(f),max(f)])
    plot(fPlot,compositeData(iF).specPrctile,':k','lineWidth',2)
    ylabel('Relative Amplitude','FontSize',12)
    xlabel('Frequency (kHz)','FontSize',12)
    hold off
    grid on
    set(gca,'XMinorTick', 'on')
    hs3Pos = get(hs3,'Position');
    
    subplot(1,3,3)
    imagesc(1:length(nodeSet{iF}),f,Tfinal{iF,1}') ;
    h3im = gca;
    xlabel('Spectrum Number','FontSize',12)
    ylabel('Frequency (kHz)','FontSize',12)
    oldPos = get(h3im,'Position');
    set(h3im,'FontSize', 11)
    % ylim([f(stIdx),f(edIdx)])
    hc = colorbar;
    set(h3im,'Position',[oldPos(1),0.1404,hs3Pos(3),0.7846])
    caxis([0 1])
    
    set(hc,'Position',get(hc,'Position')-[0.01,0,.01,0],'Ylim',[0,1],...
        'FontSize',12)
    hcy = ylabel(hc,'Relative Amplitude','Rotation',-90);
    set(hcy,'Units','normalized')
    set(hcy,'Position',get(hcy,'Position')+[1,0,0],'Units','normalized')
    set(gca,'ydir','normal')
    set(gcf,'units','inches','PaperPositionMode','auto','OuterPosition',[0.25 0.25 11 4])
    colormap(jet)
    if s.saveOutput
        figName = fullfile(outDir,sprintf('%s_AutoType%d_longICI',s.outputName,iF));
        print(gcf,'-dtiff','-r600',[figName,'.tif'])
        saveas(gcf,[figName,'.fig'])
        fprintf('Done saving cluster %0.0f of %0.0f\n',iF,length(nodeSet))
    end

end

close(400)
fprintf('Individual cluster plots saved to %s\n',outDir)
