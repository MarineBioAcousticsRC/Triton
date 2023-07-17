function plot_groups_AW(label, MeansN, indices, vq_feats, corpus_s, components_s, train_s, freq, groups)
% plot_groups(label, codebook, vq_feats, corpus_s, components_s, groups)
% Plot the components of the specified groups of data for a specific
% species by the codeword (mean) to which they have been clustered.
%
% label - string that appears in the figure title bar prior to the 
%   plot type.  Use '' if no additional title is desired.
% vq_feats - VQ codebook to which the features will be quantized.
% corpus_s and components_s - A specific instance of the corpus and
%   components arrays returned by prepare_corpus
% groups - Groups (sightings) to be plotted.

%%addition made for ART_warp data - all of these are passed to
%%plot_components_AW

% MeansN - the number of clusters 
% indices - the list of categories for each component/whistle
% train_s - the feature data used for creating the plots
% freq - the frequency data used for creating the plots

fprintf('Plotting components\n')
tstring = sprintf('%s %s', corpus_s.species, label);

if size(groups, 1) > 1
    groups = groups';  % ensure row vector
end

compH = figure('Name', sprintf('%s components', tstring));
colors = hsv(length(groups));
ax = [];  % array of axes for plots
counts = zeros(MeansN, 1);

if ~ isempty(train_s.features)

    figure(compH); % make active
    ax = plot_components_AW(indices, MeansN, ...
        train_s.map, ...
        freq, ...
        colors(length(groups),:), ax);
 
%     for g = groups
%         for file_idx = find(corpus_s.subgroup == g)'
%         % plot up to first three features
%             if ishandle(featH)
%                 if length(vq_feats) >= 3
%                     figure(featH); % make active
%                     plot3(components_s.component_feats{file_idx}(:, vq_feats(1)), ...
%                         components_s.component_feats{file_idx}(:, vq_feats(2)), ...
%                         components_s.component_feats{file_idx}(:, vq_feats(3)), ...
%                         '.', 'Color', colors(file_idx,:));
%                     xlabel(sprintf('f%d', vq_feats(1)));
%                     ylabel(sprintf('f%d', vq_feats(2)));
%                     zlabel(sprintf('f%d', vq_feats(3)));
%                     hold on
%                 elseif length(vq_feats) == 2
%                     figure(featH); % make active
%                     plot(components_s.component_feats{file_idx}(:, vq_feats(1)), ...
%                         components_s.component_feats{file_idx}(:, vq_feats(2)), ...
%                         '.', 'Color', colors(file_idx,:));
%                     xlabel(sprintf('f%d', vq_feats(1)));
%                     ylabel(sprintf('f%d', vq_feats(2)));
%                     hold on
%                 end
%             end
%         end
%     end
    newcounts = histc(indices, 1:MeansN);
    if size(newcounts, 2) > 1
        newcounts = newcounts'; 
    end
    counts = counts + newcounts;
end

% Show the number of components associated with each codeword
for k=1:length(counts)
    title(ax(k), sprintf('c%02d (N=%d)', k, counts(k)));
end
linkaxes(ax);
1;