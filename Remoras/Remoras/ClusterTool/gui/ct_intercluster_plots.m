function hSet = ct_intercluster_plots(p,s,f,nodeSet,compositeData,Tfinal,labelStr,figDir)

n1 = min([3,round(length(nodeSet)/2)]); % number of rows of subplots, one subplot per type
m1 = ceil(length(nodeSet)/n1); % number of columns of subplots
figure(41);clf(41);set(gcf,'Units','normalized','Position',[0.01,.05,.48,.4])
figure(42);clf(42);set(gcf,'Units','normalized','Position',[0.01,.52,.48,.4])
figure(43);clf(43);set(gcf,'Units','normalized','Position',[.5,.05,.48,.4])
figure(44);clf(44);set(gcf,'Units','normalized','Position',[.5,.52,.48,.4])
figure(45);clf(45);set(gcf,'Units','normalized','Position',[.5,.52,.48,.4])

figName{1} = fullfile(figDir,sprintf('%s_allMeanSpec',s.outputName));
figName{2} = fullfile(figDir,sprintf('%s_allCatSpec',s.outputName));
figName{3} = fullfile(figDir,sprintf('%ss_allICI',s.outputName));
figName{4} = fullfile(figDir,sprintf('%s_allICIimage',s.outputName));
figName{5} = fullfile(figDir,sprintf('%s_allWaveEnv',s.outputName));
if isfield(s,'normalizeSpectra') && s.normalizeSpectra
    normTF = 1;
else
    normTF = 0;
end
for iF = 1:length(nodeSet)
    hSet(1) = figure(41); % plot spectra means and percentiles
    subplot(n1,m1,iF)
    hold on

    fPlot = f;
    if length(fPlot)~=size(compositeData(iF).spectraMeanSet,2) &&... 
        length(f(s.stIdx:s.edIdx))==size(compositeData(iF).spectraMeanSet,2)
        %Catch for backward compatibility if orignial fill spectra were not stored
        fPlot = f(s.stIdx,s.edIdx);
    elseif length(fPlot)~=size(compositeData(iF).spectraMeanSet,2) 
        warning('Frequency vector and spectra differ in length. Display errors possible in plots')
        fPlot = linspace(s.startFreq,s.endFreq,length(compositeData(iF).spectraMeanSet));
    end
    plot(fPlot,compositeData(iF).spectraMeanSet,'-k','lineWidth',2)
    xlim([fPlot(1),fPlot(end)])

    text(.5,.1,sprintf('N = %0.0f',size(nodeSet{iF},2)),'Units','normalized',...
        'BackgroundColor','w','Margin',1)
    plot(fPlot,compositeData(iF).specPrctile,'--k','lineWidth',2)
    grid on
    hold off
    if normTF
        ylim([0,1])
    end
    hSet(2) = figure(42); % plot spectra as heatmap
    subplot(n1,m1,iF)

    if s.normalizeSpectra
        imagesc(1:length(nodeSet{iF}),f,min(max(Tfinal{iF,1},0),1)')
    else
       imagesc(1:length(nodeSet{iF}),f,Tfinal{iF,1}')
    end
    set(gca,'ydir','normal')
    title(labelStr{iF})
    % ylim([min(f(p.startFreqIdx)),max(f(p.endFreqIdx))])
    
    hSet(3) = figure(43); % plot ICI distributions
    subplot(n1,m1,iF)
    plot(p.barInt(1:s.maxICIidx) + s.barAdj,...
        compositeData(iF).iciMean+compositeData(iF).iciStd,':k')     
%     errorbar(p.barInt(1:s.maxICIidx) + s.barAdj,compositeData(iF).iciMean,...
%         zeros(size(compositeData(iF).iciStd)),compositeData(iF).iciStd,'.k')
    hold on
    bar(p.barInt(1:s.maxICIidx) + s.barAdj,compositeData(iF).iciMean,1);
    xlim([0,p.barInt(s.maxICIidx)])
    if normTF
        ylim([0,1])
    end
    hold off
    
    hSet(4) = figure(44); % plot click rate distributions
    subplot(n1,m1,iF)
    imagesc(1:length(nodeSet{iF}),p.barInt(1:s.maxICIidx),[Tfinal{iF,2}./max(Tfinal{iF,2},[],2)]')
    set(gca,'ydir','normal')
        
    hSet(5) = figure(45); % plot click rate distributions
    if size(Tfinal,2)>=10
        subplot(n1,m1,iF)
        imagesc(1:length(nodeSet{iF}),1:p.maxDur,[Tfinal{iF,10}./max(Tfinal{iF,10},[],2)]')
        set(gca,'ydir','normal')
    end
end
figure(41)
mxlabel(41,'Frequency (kHz)','FontSize',16);
if normTF
    mylabel(41,'Normalized Amplitude','FontSize',16);
else
    mylabel(41,'Amplitude','FontSize',16);
end
figure(42)
mxlabel(42,'Click Number','FontSize',16);
mylabel(42,'Frequency (kHz)','FontSize',16);
colormap(jet)
figure(43)
mxlabel(43,'ICI (sec)','FontSize',16);
if normTF
    mylabel(43,'Normalized Counts','FontSize',16);
else
    mylabel(43,'Counts','FontSize',16);
end
figure(44)
mxlabel(44,'Bin Number','FontSize',16);
mylabel(44,'ICI (sec)','FontSize',16);
colormap(jet)
mxlabel(45,'Bin Number','FontSize',16);
mylabel(45,'Samples','FontSize',16);
colormap(jet)
mtit(41,strrep(s.outputName,'_',' ' ),'FontSize',12);
mtit(42,strrep(s.outputName,'_',' ' ),'FontSize',12);
mtit(43,strrep(s.outputName,'_',' ' ),'FontSize',12);
mtit(44,strrep(s.outputName,'_',' ' ),'FontSize',12);
mtit(45,strrep(s.outputName,'_',' ' ),'FontSize',12);

if s.saveOutput
    disp('Saving figures...')
    for iFig = 1:length(figName)
        set(hSet(iFig),'units','inches','PaperPositionMode','auto');%,'OuterPosition',[0.25 0.25  10  7.5])
        print(hSet(iFig),'-dtiff','-r600',[figName{iFig},'.tiff'])
        saveas(hSet(iFig),[figName{iFig},'.fig'])
        fprintf('Done with figure %0.0f\n',iFig)
    end
end


