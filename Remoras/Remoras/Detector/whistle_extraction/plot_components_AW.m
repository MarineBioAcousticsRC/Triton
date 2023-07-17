function ax = plot_components(comp_category, N, comp2whistle, whistles, color, ax)
% ax = plot_components(comp_category, N, comp2whistle, whistles, ax, color)
% Given a vector of categories to which components have been assigned,
% plot each component according to the category.  The matrix
% comp2whistle maps components to portions of the given whistle filenames.
%
% Components are plotted using the specified RGB triple specified by color
% on the axis handle vector ax.  If ax is empty, one axis for each category
% is created.


cols = ceil(N/4);
rows = ceil(N/cols);
if isempty(ax)
    for k=1:N
        ax(k) = subplot(rows, cols, k);
        hold on;
    end
end

w_idx = 1;  % whistle index
c_start = 3;  % start and end of component relative to whistle
c_end = 4;

advance_s = .01;  % hardcoded from feature extraction

previous_w = NaN;  % no previous whistle
for k=1:length(comp_category)
    if comp_category(k) == 0 || isnan(comp_category(k)) == 1
        continue
    else
        
        fv = whistles{k}';   % the frequency vector of each component    
        t = (0:length(fv)-1)*advance_s; % interpolated time vector

    % indices covering this component
        range = comp2whistle(k,c_start):comp2whistle(k,c_end);

        plot(ax(comp_category(k)), t(range)-t(range(1)), fv(range), ...
                'Color', color);
    end
end

% Make all plots same scale
xrng = zeros(N, 2);
yrng = zeros(N, 2);
for k=1:N
    xrng(k, :) = get(ax(k), 'XLim');
    yrng(k, :) = get(ax(k), 'YLim');
end
set(ax, 'XLim', [min(xrng(:,1)), max(xrng(:,2))]);
set(ax, 'YLim', [min(yrng(:,1)), max(yrng(:,2))]);
1;