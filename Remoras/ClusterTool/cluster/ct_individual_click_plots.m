function ct_individual_click_plots(p,s,f,nodeSet,compositeData,Tfinal,labelStr,outDir)

siteNameNo_ = strrep(s.outputName,'_','\_');

for iF = 1:length(nodeSet)
%%
    figure(400);clf
    set(gcf,'PaperPositionMode','auto','units','inches','OuterPosition',[0.25 0.25 11 4])

    hs2 = subplot(1,3,2);
    imagesc(1:length(nodeSet{iF}),p.barInt(1:s.maxICIidx),...
        [Tfinal{iF,2}./max(Tfinal{iF,2},[],2)]')
    set(gca,'ydir','normal')
    
    xlabel('Bin Number','FontSize',12)
%     hold on
%     hbI2 = bar(p.barInt(1:s.maxICIidx)+ s.barAdj,compositeData(iF).iciMean,1);
%     xlim([0,p.barInt(s.maxICIidx)])
%     ylim([0,1])
    ylabel('ICI (sec)','FontSize',12)
%     annotation('textbox',[.02 .82 .1 .1],'units','normalized','String',...
%         siteNameNo_,'LineStyle','none','FontSize',14,'FontWeight','demi')
    set(gca,'box','on','fontsize',11)
    hold off
    %ylim([0,1])
    
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
    
    hs3 = subplot(1,3,3);
    hs2Pos = get(hs2,'Position');
    hs3Pos = get(hs3,'Position');
    imagesc(1:length(nodeSet{iF}),1:p.maxDur,[Tfinal{iF,10}./max(Tfinal{iF,10},[],2)]')
    set(gca,'ydir','normal')
    xlabel('Bin Number','FontSize',12)
    ylabel('Samples','FontSize',12)
    set(gca,'box','on','fontsize',11)
    hold off
    h3im = gca;

    oldPos = get(h3im,'Position');
    % ylim([f(stIdx),f(edIdx)])

    
    subplot(1,3,1)

    fPlot = f;
    if length(fPlot)~= size(Tfinal{iF,1},2) &&... 
        length(f(s.stIdx:s.edIdx))~=size(Tfinal{iF,1},2)
        %Catch for backward compatibility if orignial fill spectra were not stored
        fPlot = f(s.stIdx:s.edIdx);
    end
    % if it STILL doesn't match, interpolate and warn the user.
    if length(fPlot)~=size(Tfinal{iF,1},2) &&... 
        length(f(s.stIdx:s.edIdx))~=size(Tfinal{iF,1},2)
        warning('Frequency vector and spectra differ in length. Display errors possible in plots')
        fPlot = linspace(s.startFreq,s.endFreq,length(compositeData(iF).spectraMeanSet));
    end
    
    imagesc(1:length(nodeSet{iF}),fPlot,Tfinal{iF,1}') ;
    xlabel('Spectrum Number','FontSize',12)
    ylabel('Frequency (kHz)','FontSize',12)
    set(gca,'ydir','normal')

        
    hc = colorbar(hs3);
    %set(h3im,'Position',[hs3Pos(1),hs2Pos(2)+.05,hs2Pos(3)-.01,hs2Pos(4)-.05])
    caxis([0 1])
    hcp = get(hc,'Position');
    set(hc,'Position',[hs3Pos(1)+hs3Pos(3)+.02,hs2Pos(2),hcp(3),hs2Pos(4)],'Ylim',[0,1],...
        'FontSize',12)
    
    hcy = ylabel(hc,'Relative Amplitude','Rotation',-90);
    set(hcy,'Units','normalized','Position',get(hcy,'Position')+[1,0,0],'Units','normalized')
    colormap(jet)
    drawnow
   mtit(400,[siteNameNo_,': Cluster ',num2str(iF)],'FontSize',12);
   
%     % sorry but things are moving around.
%     hs3Pos = get(hs3,'Position');    

%     set(h2im,'Position',[hs3Pos(1),hs2Pos(2),hs2Pos(3)-.01,hs2Pos(4)])
%%
    if s.saveOutput
        figName = fullfile(outDir,sprintf('%s_type%d',s.outputName,iF));
        print(gcf,'-dtiff','-r600',[figName,'.tif'])
        saveas(gcf,[figName,'.fig'])
        fprintf('Done saving cluster %0.0f of %0.0f\n',iF,length(nodeSet))
    end

end

close(400)
fprintf('Individual cluster plots saved to %s\n',outDir)
