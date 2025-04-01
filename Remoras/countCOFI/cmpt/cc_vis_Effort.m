function cc_vis_Effort(GPSFilePath, effFilePath, oDir)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  cc_vis_Effort.m
%
%  made by SGB 20240724
%  Shelby G. Bloom (sbloom@ucsd.edu)
%  modified/based on code from BJT (bthayre@ucsd.edu) - visEffort_2019_12.m
%
%  using underway GPS track data and a concatenated file of daily expanded
%  files for a single cruise, generate visEffort outputs (visual effort,
%  detection summary, species sighting text files)
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS REMORA

    cnum1 = regexp(REMORA.cc.vis.effFilePath, '\d{6}', 'match');
    % should always have a match
    cnum1 = cnum1{1};
    
    mystSp = {'BA', 'BM', 'BP', 'ER', 'MN', 'ULW'};
    odontSp = {'DC', 'DD', 'DSP', 'GG', 'GM', 'LB', 'LO', 'OO', 'PD', 'PM', 'SC', 'TT', 'UD', 'ZICA'};
    
    % Display a message indicating that visEffort outputs are being made
    disp(['All visEfffort outputs are being generated']);

    % measure/plot visual effort
    [gpsTrack] = plotCountCofiTrackWithEffort_200121(REMORA.cc.vis.GPSFilePath, 1, REMORA.cc.vis.effFilePath, REMORA.cc.vis.oDir);

    % count sightings 
    [spStr, spCounts, sightInfo] = countCofiSightingSummary_200121(REMORA.cc.vis.effFilePath);

    uMyst = 0;
    % write out mysticete detectionInfo csv
    offn1 = fullfile(REMORA.cc.vis.oDir, sprintf('%s-%s_mystInfo.csv', cnum1(1:4), cnum1(5:6)));
    fod1 = fopen(offn1, 'w');
    fprintf(fod1, 'species,groups,individuals\n');
    for s = 1:length(mystSp)
        si = find(strcmpi(mystSp{s}, spStr));
        g = spCounts(si, 1);
        iv = spCounts(si, 2);
        fprintf(fod1, '%s,%d,%d\n', mystSp{s}, g, iv);
        if g > 0
            uMyst = uMyst + 1;
        end
    end
    fclose(fod1);

    uOdont = 0;
    % write out odontocete detectionInfo csv
    offn2 = fullfile(REMORA.cc.vis.oDir, sprintf('%s-%s_odontInfo.csv', cnum1(1:4), cnum1(5:6)));
    fod2 = fopen(offn2, 'w');
    fprintf(fod2, 'species,groups,individuals\n');
    for s = 1:length(odontSp)
        si = find(strcmpi(odontSp{s}, spStr));
        g = spCounts(si, 1);
        iv = spCounts(si, 2);
        fprintf(fod2, '%s,%d,%d\n', odontSp{s}, g, iv);
        if g > 0 
            uOdont = uOdont + 1;
        end
    end
    fclose(fod2);

    % make file for histograms...number unique myst/odont/oneffort time
    offn = fullfile(REMORA.cc.vis.oDir, sprintf('%s-%s_visEffortSummary.csv', cnum1(1:4), cnum1(5:6)));
    fod = fopen(offn, 'w');
    fprintf(fod, 'mystSpecies, odontSpecies, effortHours, effortDistanceKm\n');
    fprintf(fod, '%d, %d, %.3f, %.3f\n', uMyst, uOdont, gpsTrack.onEffortTime * 24, gpsTrack.totD);
    fclose(fod);
    
    % make species sighting text files
    countcofi2GMTSpeciesFiles(REMORA.cc.vis.effFilePath, REMORA.cc.vis.oDir);
    
    
    % Display a message indicating that all the visEffort outputs have been
    % made
    disp(['All visEfffort outputs have been generated and saved to '  REMORA.cc.vis.oDir ' !!!']);
end