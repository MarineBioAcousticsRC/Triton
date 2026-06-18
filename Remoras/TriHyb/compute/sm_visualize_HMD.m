function sm_visualize_HMD(ncPath, figPath, binMode)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sm_visualize_HMD.m
%
% Load HARP Hybrid Millidecade (.nc) products written by sm_calc_HMD.m and
% build a longterm spectrogram (with deployment boundaries), monthly average
% spectra, and seasonal average spectra. Called by mypsd_visualize_callback.
%
% binMode: 'hourly' | 'daily' | 'oneminute'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ncFiles = dir(fullfile(ncPath, '**', '*.nc'));
if isempty(ncFiles)
    disp(['No .nc files found in this directory: ', ncPath])
    return
end

nFiles = numel(ncFiles);
disp([num2str(nFiles), ' .nc files found, loading...'])

%% Load all files, checking frequency-bin consistency against the first file
freqRef = ncread(fullfile(ncFiles(1).folder, ncFiles(1).name), 'frequency');
nFreqRef = length(freqRef);

datnum_all = [];
SPL_all = [];
deploy_all = {};

for k = 1:nFiles
    thisFile = fullfile(ncFiles(k).folder, ncFiles(k).name);

    freq_k = ncread(thisFile, 'frequency');
    if length(freq_k) ~= nFreqRef
        error(['Frequency bin length mismatch: "', ncFiles(k).name, ...
            '" has ', num2str(length(freq_k)), ' frequency bins, expected ', ...
            num2str(nFreqRef), ' (from "', ncFiles(1).name, '"). ', ...
            'This indicates inconsistent processing parameters between files -- fix the source data, not this check.'])
    end

    psd_k = ncread(thisFile, 'psd');          % nFreq x nTime
    time_k = ncread(thisFile, 'time');        % seconds since 1970-01-01 UTC
    deployment_k = ncreadatt(thisFile, '/', 'deployment');

    datnum_k = datenum(1970,1,1) + double(time_k)/86400;

    datnum_all = [datnum_all; datnum_k(:)]; %#ok<AGROW>
    SPL_all = [SPL_all, psd_k]; %#ok<AGROW>
    deploy_all = [deploy_all; repmat({deployment_k}, length(time_k), 1)]; %#ok<AGROW>

    disp(['Loaded: ', ncFiles(k).name])
end

% Site/project/organization for titling and output filename, from the first file
siteAttr = ncreadatt(fullfile(ncFiles(1).folder, ncFiles(1).name), '/', 'site');
projectAttr = ncreadatt(fullfile(ncFiles(1).folder, ncFiles(1).name), '/', 'project');
orgAttr = ncreadatt(fullfile(ncFiles(1).folder, ncFiles(1).name), '/', 'organization');

%% Globally sort by time (handles files loaded out of chronological order)
[datnum_all, sortIdx] = sort(datnum_all);
SPL_all = SPL_all(:, sortIdx);
deploy_all = deploy_all(sortIdx);

%% Deployment boundaries (from the 'deployment' global attribute of each file)
changeIdx = [1; find(~strcmp(deploy_all(2:end), deploy_all(1:end-1))) + 1];
boundaryTimes = datnum_all(changeIdx);
boundaryNames = deploy_all(changeIdx);

%% Bin the longterm spectrogram per the selected resolution (mean in linear space -> dB)
switch binMode
    case 'oneminute'
        t_plot = datnum_all;
        SPL_plot_dB = SPL_all;
    case {'hourly', 'daily'}
        linPower = 10.^(SPL_all/10);   % nFreq x nTime
        TT = timetable(datetime(datnum_all, 'ConvertFrom', 'datenum'), linPower');
        TTbinned = retime(TT, binMode, 'mean');
        SPL_plot_dB = 10*log10(TTbinned.Var1');
        t_plot = datenum(TTbinned.Time);
    otherwise
        error(['Unknown bin mode: ', binMode])
end

%% Monthly average spectra (always from raw one-minute data)
[yrVec, moVec, ~] = datevec(datnum_all);
monthGroupKey = yrVec*100 + moVec;
uniqueMonthGroups = unique(monthGroupKey);
nMonthGroups = length(uniqueMonthGroups);
monthColors = turbo(nMonthGroups);

monthlySpectra = nan(nFreqRef, nMonthGroups);
monthlyLabels = cell(nMonthGroups, 1);
for g = 1:nMonthGroups
    idx = monthGroupKey == uniqueMonthGroups(g);
    linP = 10.^(SPL_all(:, idx)/10);
    monthlySpectra(:, g) = 10*log10(mean(linP, 2));
    yG = floor(uniqueMonthGroups(g)/100);
    mG = mod(uniqueMonthGroups(g), 100);
    monthlyLabels{g} = datestr(datenum(yG, mG, 1), 'mmm yyyy');
end

%% Seasonal average spectra (pooled across all years; always from raw one-minute data)
seasonNames = {'Summer', 'Spring', 'Fall', 'Winter'};
seasonMonths = {[6 7 8], [3 4 5], [9 10 11], [12 1 2]};
seasonAbbrev = {'J, J, A', 'M, A, M', 'S, O, N', 'D, J, F'};
seasonColors = [0.85 0.33 0.10;   % Summer - warm red/orange
                 0.30 0.70 0.30;   % Spring - green
                 0.80 0.50 0.10;   % Fall   - amber/brown
                 0.20 0.40 0.80];  % Winter - blue

seasonalSpectra = nan(nFreqRef, length(seasonNames));
seasonalLegend = cell(length(seasonNames), 1);
seasonalPresent = false(length(seasonNames), 1);
for s = 1:length(seasonNames)
    idx = ismember(moVec, seasonMonths{s});
    if any(idx)
        linP = 10.^(SPL_all(:, idx)/10);
        seasonalSpectra(:, s) = 10*log10(mean(linP, 2));
        seasonalLegend{s} = [seasonNames{s}, ': ', seasonAbbrev{s}];
        seasonalPresent(s) = true;
    end
end

%% Figure layout: top row = longterm spectrogram, bottom row = monthly | seasonal
fig = figure('Color', 'w', 'Units', 'pixels', 'Position', [50 50 1500 900]);

%% --- Top: longterm spectrogram with deployment boundaries ---
ax1 = subplot(2, 2, [1 2]);
pos1 = get(ax1, 'Position');
set(ax1, 'Position', [pos1(1), pos1(2) - 0.04, pos1(3), pos1(4)]);
surf(ax1, t_plot, freqRef, SPL_plot_dB, 'LineStyle', 'none');
view(ax1, [0 90]);
set(ax1, 'YScale', 'log', 'FontSize', 11);
climLo = min(SPL_plot_dB(:));
climHi = max(SPL_plot_dB(:)) + 3;
caxis(ax1, [climLo climHi]);
colormap(ax1, cmocean('thermal'));
cb = colorbar(ax1, 'eastoutside');
cb.Label.String = 'Spectrum Level (dB re 1\muPa^2/Hz)';
xlabel(ax1, 'Date');
ylabel(ax1, 'Frequency (Hz)');
xlim(ax1, [min(datnum_all) max(datnum_all)]);
ylim(ax1, [min(freqRef) max(freqRef)]);
datetick(ax1, 'x', 'mmm-yyyy', 'keeplimits');

yl = ylim(ax1);
zTop = max(SPL_plot_dB(:)) + 5;   % render above the surface so the line/label aren't occluded
hold(ax1, 'on');
for b = 1:length(boundaryTimes)
    plot3(ax1, [boundaryTimes(b) boundaryTimes(b)], [yl(1) yl(2)], [zTop zTop], 'k--', 'LineWidth', 2);
    text(ax1, boundaryTimes(b), yl(2), zTop, boundaryNames{b}, ...
        'Color', 'k', 'FontSize', 9, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'Clipping', 'off');
end
hold(ax1, 'off');
th1 = title(ax1, [orgAttr, ' ', projectAttr, ' ', siteAttr, ' - Longterm Spectral Average'], 'FontSize', 13);
th1.Units = 'normalized';
th1.Position(2) = th1.Position(2) + 0.03;

%% --- Bottom left: monthly average spectra ---
ax2 = subplot(2, 2, 3);
hold(ax2, 'on');
for g = 1:nMonthGroups
    semilogx(ax2, freqRef, monthlySpectra(:, g), 'Color', monthColors(g, :), 'LineWidth', 1.3);
end
hold(ax2, 'off');
set(ax2, 'XScale', 'log', 'FontSize', 10);
xlim(ax2, [min(freqRef) max(freqRef)]);
grid(ax2, 'on'); box(ax2, 'on');
xlabel(ax2, 'Frequency (Hz)');
ylabel(ax2, 'PSD (dB re 1\muPa^2/Hz)');
title(ax2, 'Monthly Average Spectra');
legend(ax2, monthlyLabels, 'Location', 'northeast', 'FontSize', 8, 'NumColumns', max(1, ceil(nMonthGroups/20)));

%% --- Bottom right: seasonal average spectra ---
ax3 = subplot(2, 2, 4);
hold(ax3, 'on');
for s = 1:length(seasonNames)
    if seasonalPresent(s)
        semilogx(ax3, freqRef, seasonalSpectra(:, s), 'Color', seasonColors(s, :), 'LineWidth', 2);
    end
end
hold(ax3, 'off');
set(ax3, 'XScale', 'log', 'FontSize', 10);
xlim(ax3, [min(freqRef) max(freqRef)]);
grid(ax3, 'on'); box(ax3, 'on');
xlabel(ax3, 'Frequency (Hz)');
ylabel(ax3, 'PSD (dB re 1\muPa^2/Hz)');
title(ax3, 'Seasonal Average Spectra');
legend(ax3, seasonalLegend(seasonalPresent), 'Location', 'best', 'FontSize', 9);

sgtitle(fig, [orgAttr, ' ', projectAttr, ' ', siteAttr, ' HMD'], 'FontSize', 15, 'FontWeight', 'bold');

%% Save
if ~exist(figPath, 'dir')
    mkdir(figPath);
end
outName = [orgAttr, '_', projectAttr, '_', siteAttr, '_HMD_Visualization.png'];
outFile = fullfile(figPath, outName);
saveas(fig, outFile);
disp(['Saved figure: ', outFile])

end
