function plot_models(Models)
% Generate plots of HMMs

for k=1:length(Models)
    figH = figure('Name', Models{k}.Name);
    dim = length(Models{k}.Mix.mu{1,1});
    subH = subplot(dim, 1, 1);
    
    for d=1:dim
        subplot(dim, 1, d);  % current dimension
        for s=1:Models{k}.NumberStates
            nmix = Models{k}.NumberMixtures;
            for m=1:nmix
                % plot mu +/- 1 std
                offset = (m - mean(nmix)) / (3*nmix);
                weight = Models{k}.Mix.c{s}(m);
                errorbar(s+offset, Models{k}.Mix.mu{s,m}(d), ...
                    sqrt(Models{k}.Mix.cov{s,m}(d)), ...
                    'LineWidth', max(1, round(weight * 10)));
                hold on;
                plot(s+offset, Models{k}.Mix.mu{s,m}(d), 'r*')
            end
        end
        if d == 1
            title(sprintf('%s state distributions \mu\pm\sigma', ...
                Models{k}.Name))
        end

    end
end