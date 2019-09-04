
function sh_subplot_data(nsub,reltim,fillavg_pwr,avg_pwr,stateLevs,...
    midRef,icr,s,e,sfar,efar,noise,sCloseShip,sFarShip,f,low,hi,...
    xpoints,passageColor)

marker = 6;
font = 8; % font titles
fontL = 8; % font legend
alpha = .4; % transparency

red = [.85 .325 .098];
gray = [0 0 0]+0.5;
black = [0 0 0];
blue = [0 .4470 .7410]; % ambient
green = [0.4660    0.6740    0.1880]; % ship

global REMORA

hold (REMORA.fig.sh.passageSubplot(nsub),'on')
plot(REMORA.fig.sh.passageSubplot(nsub),reltim,fillavg_pwr,'Color',gray,'DisplayName','Interpolated')
plot(REMORA.fig.sh.passageSubplot(nsub),reltim,avg_pwr,'Color',blue,'DisplayName','ASPD')
plot(REMORA.fig.sh.passageSubplot(nsub),reltim,linspace(stateLevs(1),stateLevs(1),...
    length(reltim)),'--','Color',red, 'LineWidth',.5,'DisplayName','Levels')
plot(REMORA.fig.sh.passageSubplot(nsub),reltim,linspace(stateLevs(2),stateLevs(2),...
    length(reltim)),'--','Color',red, 'LineWidth',.5,'DisplayName','Levels2')
plot(REMORA.fig.sh.passageSubplot(nsub),reltim,linspace(midRef,midRef,...
    length(reltim)),'Color',red, 'LineWidth',2,'DisplayName','Threshold')
plot(REMORA.fig.sh.passageSubplot(nsub),reltim(icr),linspace(midRef,midRef,...
    length(reltim(icr))),'.','Color',black,'MarkerSize',7,'DisplayName','Crossing')

if ~isempty(noise)
    if ~isempty(sCloseShip)
        plot(REMORA.fig.sh.passageSubplot(nsub),reltim(s),midRef,'o','Color',black,...
            'MarkerSize',marker,'DisplayName','Close detection');
        plot(REMORA.fig.sh.passageSubplot(nsub),reltim(e),midRef,'o','Color',black,...
            'MarkerSize',marker,'DisplayName','Close detection2');
    end
    if ~isempty(sFarShip) && nsub ~= 1
        plot(REMORA.fig.sh.passageSubplot(nsub),reltim(sfar),midRef,'x','Color',black,...
            'MarkerSize',marker,'DisplayName','Far detetection');
        plot(REMORA.fig.sh.passageSubplot(nsub),reltim(efar),midRef,'x','Color',black,...
            'MarkerSize',marker,'DisplayName','Far detetection2');
    end
    ypoints = [REMORA.fig.sh.passageSubplot(nsub).YLim(1),REMORA.fig.sh.passageSubplot(nsub).YLim(2),...
        REMORA.fig.sh.passageSubplot(nsub).YLim(2),REMORA.fig.sh.passageSubplot(nsub).YLim(1)];
    ypoints = repmat(ypoints,size(noise,1),1);
    for itr1 = 1: size(noise,1)
        patch(REMORA.fig.sh.passageSubplot(nsub),xpoints(itr1,:),ypoints(itr1,:),...
            passageColor(itr1,:),'FaceAlpha',alpha,'LineStyle','none','DisplayName','Passage')
    end
    ylim(REMORA.fig.sh.passageSubplot(nsub),[ypoints(1,1:2)])
    fPatches = findobj(REMORA.fig.sh.passageSubplot(nsub).Children, 'type', 'patch');
    fLines = findobj(REMORA.fig.sh.passageSubplot(nsub).Children, 'type', 'line');
    REMORA.fig.sh.passageSubplot(nsub).Children= [fLines;fPatches];
end

switch nsub
    case 1
        title(REMORA.fig.sh.passageSubplot(nsub),sprintf('High band (%d-%d Hz)',f(low),f(hi)),'FontSize',font)
    case 2
        title(REMORA.fig.sh.passageSubplot(nsub),sprintf('Medium band (%d-%d Hz)',f(low),f(hi)),'FontSize',font)
        ylabel(REMORA.fig.sh.passageSubplot(nsub),'Averaged PSD (dB re 1 \muPa^2/Hz)','FontSize',font)
    case 3
        title(REMORA.fig.sh.passageSubplot(nsub),sprintf('Low band (%d-%d Hz)',f(low),f(hi)),'FontSize',font)
        xlabel(REMORA.fig.sh.passageSubplot(nsub),'Time (Hours)','FontSize',font)
        
        % make some variables invisible in the legend
        childs = allchild(REMORA.fig.sh.passageSubplot(nsub));
        set(findobj(childs,'DisplayName','Interpolated'),'HandleVisibility','off')
        set(findobj(childs,'DisplayName','ASPD'),'HandleVisibility','off')
        set(findobj(childs,'DisplayName','Levels'),'HandleVisibility','off')
        set(findobj(childs,'DisplayName','Levels2'),'HandleVisibility','off')
        set(findobj(childs,'DisplayName','Threshold'),'HandleVisibility','off')
        set(findobj(childs,'DisplayName','Crossing'),'HandleVisibility','off')
        set(findobj(childs,'DisplayName','Close detection2'),'HandleVisibility','off')
        set(findobj(childs,'DisplayName','Far detetection2'),'HandleVisibility','off')
        
        if size(findobj(childs,'DisplayName','Close detection'),1) > 1
            multiObj = findobj(childs,'DisplayName','Close detection');
            set(multiObj(2:end),'HandleVisibility','off')
        end
        
        if size(findobj(childs,'DisplayName','Far detetection'),1) > 1
            multiObj = findobj(childs,'DisplayName','Far detetection');
            set(multiObj(2:end),'HandleVisibility','off')
        end
        
        if size(findobj(childs,'DisplayName','Passage','FaceColor',green),1) > 1
            multiObj = findobj(childs,'DisplayName','Passage','FaceColor',green);
            set(multiObj(2:end),'HandleVisibility','off')
        end
        
        if size(findobj(childs,'DisplayName','Passage','FaceColor',blue),1) > 1
            multiObj = findobj(childs,'DisplayName','Passage','FaceColor',blue);
            set(multiObj(2:end),'HandleVisibility','off')
        end
        
        set(findobj(childs,'DisplayName','Passage','FaceColor',blue),'DisplayName','Ambient');
        set(findobj(childs,'DisplayName','Passage','FaceColor',green),'DisplayName','Ship');
        
        if ~isempty(findobj(childs,'DisplayName','Close detection')) || ...
                ~isempty(findobj(childs,'DisplayName','Far detection')) || ...
                ~isempty(findobj(childs,'DisplayName','Ship')) || ...
                ~isempty(findobj(childs,'DisplayName','Ambient'))
%             legend(REMORA.fig.sh.passageSubplot(nsub),'show','FontSize', fontL,'Location','north','Orientation','horizontal')
            legend(REMORA.fig.sh.passageSubplot(nsub),'show','Location','north','Orientation','horizontal')
            REMORA.fig.sh.passageSubplot(3).Legend.Position = [0.1443 0.96 0.7613 0.0353];
            REMORA.fig.sh.passageSubplot(3).Legend.FontSize = fontL;
        end
        
end
REMORA.fig.sh.passageSubplot(nsub).FontSize = font;
hold (REMORA.fig.sh.passageSubplot(nsub),'off')