function ct_cc_save_plots(hObject,eventdata)

global REMORA

close(REMORA.fig.ct.cc_saveFigs)

if ~isfield(REMORA.ct.CC,'output')
    warning('No composite clusters loaded')
    ct_load_composite_clusters
end

if ~isdir(REMORA.ct.CC.output.figDir)
    mkdir(REMORA.ct.CC.output.figDir)
end
REMORA.ct.CC.output.s.saveOutput = 1;
if REMORA.ct.CC.output.saveCombinedPlotsTF 
    disp('Saving combined plots...')
    if ~REMORA.ct.CC.output.remakePlots &&(ishandle(41)&&ishandle(42)&&ishandle(43)&&ishandle(44))
        % if all figs exist, just save them
        disp('Warning: Saving currently-displayed plots.')
        s = REMORA.ct.CC.output.s;
        hSet(1) = figure(41);hSet(2) = figure(42);hSet(3) = figure(43);hSet(4) = figure(44);
        figName{1} = fullfile(REMORA.ct.CC.output.figDir,sprintf('%s_autoTypes_allMeanSpec',s.outputName));
        figName{2} = fullfile(REMORA.ct.CC.output.figDir,sprintf('%s_auHtoTypes_allCatSpec',s.outputName));
        figName{3} = fullfile(REMORA.ct.CC.output.figDir,sprintf('%s_autoTypes_allICI',s.outputName));
        figName{4} = fullfile(REMORA.ct.CC.output.figDir,sprintf('%s_autoTypes_allICIgram',s.outputName));
        for iFig = 1:length(figName)
            set(hSet(iFig),'units','inches','PaperPositionMode','auto')%,'OuterPosition',[0.25 0.25  10  7.5])
            print(hSet(iFig),'-dtiff','-r600',[figName{iFig},'.tiff'])
            saveas(hSet(iFig),[figName{iFig},'.fig'])
            fprintf('Done with figure %0.0f\n',iFig)
        end
    else
        % otherwise make them again and save
        ct_intercluster_plots(REMORA.ct.CC.output.p,REMORA.ct.CC.output.s,...
            REMORA.ct.CC.output.f,REMORA.ct.CC.output.nodeSet,...
            REMORA.ct.CC.output.compositeData,REMORA.ct.CC.output.Tfinal,...
            REMORA.ct.CC.output.labelStr,REMORA.ct.CC.output.figDir)
    end
    disp('Done saving combined plots...')

end

if REMORA.ct.CC.output.saveIndivPlotsTF
    disp('Saving individual plots...')

    ct_individual_click_plots(REMORA.ct.CC.output.p,REMORA.ct.CC.output.s,...
        REMORA.ct.CC.output.f,REMORA.ct.CC.output.nodeSet,...
        REMORA.ct.CC.output.compositeData,REMORA.ct.CC.output.Tfinal,...
        REMORA.ct.CC.output.labelStr,REMORA.ct.CC.output.figDir)
    disp('Saving individual plots...')

end
figure(REMORA.fig.ct.cc_postcluster)
