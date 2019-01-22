function plot_results(Plot_type)
% Plot the performance of he system using Graph/Bar chart.
% Plot_type - Type of a plot
%   'bar'- Bar charts
%   'graph' - Graphs

snr_dB = 10;
if snr_dB == 8
    R_species_8dB = [69.82 61.69 50.09 72.75 68.82];    % Recall
    P_species_8dB = [60.80 52.28 43.08 53.75 41.89];    % Precision
    C_species_8dB = [82 83.27 75 79 81];    % Coverage
    species_8dB = [R_species_8dB' P_species_8dB' C_species_8dB'];
else if snr_dB == 10
        R_species_10dB = [47.43 63.08 31.24 57.89 39.16];
        P_species_10dB = [72.62 70.68 60.22 63.38 61.15];
        C_species_10dB = [79 97 82 86 87];
        species_10dB = [R_species_10dB' P_species_10dB' C_species_10dB'];
    end
end

Species = [1 2 3 4 5]; % x - axis
Species_name = {'' 'bottlenose' 'short beaked' 'long beaked' 'spinner' 'melon headed' ''};

figure;
if isequal(Plot_type, 'graph')
    if snr_dB == 8
        plot(Species, R_species_8dB, '-.r*', Species, P_species_8dB, '--bd', ...
            Species, C_species_8dB, '-gs', 'LineWidth', 2);
    else if snr_dB == 10
            plot(Species, R_species_10dB, '-.r*', Species, P_species_10dB,...
                '--bd', Species, C_species_10dB, '-gs', 'LineWidth', 2);
        end
    end
else if isequal(Plot_type, 'bar')
        if snr_dB == 8
            bar(Species, species_8dB);
        else if snr_dB == 10
                bar(Species, species_10dB);
            end
        end
    end
end

% legend
legend('Recall', 'Precision', 'Coverage', 3);

% Axis updates
%title('Performance for SNR of 8 decibels', 'fontsize', 12, 'fontweight', 'b');
AxisH = gca;
set(AxisH, 'XLim', [0, 6]);
set(AxisH, 'YLim', [0, 100]);
set(AxisH, 'XTick', 0:7, 'XTickLabel', Species_name);
set(AxisH, 'fontsize', 12, 'fontweight', 'b');
xlabel('Species', 'fontsize', 12, 'fontweight', 'b');
ylabel('Performance (in %)', 'fontsize', 12, 'fontweight', 'b');
