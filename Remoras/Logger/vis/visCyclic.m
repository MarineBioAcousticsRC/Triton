function visCyclic(PresenceI, Labels)
% Plot cyclic data in a polar plot with labels as specified

Period = size(PresenceI, 2);
if nargin < 2
    Labels = 0:Period-1;
end

if isnumeric(Labels)
    % Convert to strings
    LabelStr = cell(size(Labels));
    for k=1:length(Labels)
        LabelStr{k} = num2str(Labels(k));
    end
    Labels = LabelStr;
end

figure


Occupancies = sum(PresenceI);  % # in each bin

roseplot = false;
if roseplot
    % Convert counts to angles
    Angle_delta = 2*pi / Period;
    
    % Compute angle for each present entry
    Angles = zeros(sum(Occupancies), 1);
    n = 1;
    for idx = 1:Period;
        if Occupancies(idx)
            angle = (idx-1)*Angle_delta;
            Angles(n:n+Occupancies(idx)-1) = angle(ones(Occupancies(idx), 1));
            n = n+Occupancies(idx);
        end
    end
    rose(Angles,24);
    
    hHiddenText = findall(gca,'type','text', 'HorizontalAlignment', 'center');
    Angles = Angle_delta/2 : Angle_delta : 2*pi-Angle_delta/2;
    hObjToDelete = zeros( length(Angles)-4, 1 );
    k = 0;
    % Relabel axes
    for k=1:length(hHiddenText)
        %angle = sscanf('%f', get(hHiddenText(k), 'String'))
        idx = round(str2num(get(hHiddenText(k), 'String'))/360*Period);
        set(hHiddenText(k), 'String', Labels{idx+1});
    end
else
    N = size(PresenceI, 2);
    bar(0:N-1, Occupancies);
    set(gca, 'XLim', [-.5 N-.5])
    if N == 24
        set(gca, 'XTick', [6 12 18 24]-1);
    end
    
    xlim = get(gca, 'XLim');
    ylim = get(gca, 'YLim');
    patch([-.5 6 6 -.5]', [0 0 max(ylim) max(ylim)]', [-1 -1 -1 -1]', ...
        [0 0 0], 'LineStyle', 'none', 'FaceAlpha', .3)
    patch([18 24 24 18]', [0 0 max(ylim) max(ylim)]', [-1 -1 -1 -1]', ...
        [0 0 0], 'LineStyle', 'none', 'FaceAlpha', .3)
end
1;