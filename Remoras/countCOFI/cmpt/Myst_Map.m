function Myst_Map(CruiseID, SightingDir, GPSFilePath, OutputDir)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Myst_Map.m
%
%  made by SGB 20240807
%  Shelby G. Bloom (sbloom@ucsd.edu)
%  modified/based on code from BJT (bthayre@ucsd.edu) -
%  CalCofi_Myst_Template.bat
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Get the directory of the current script
    scriptDir = fileparts(mfilename('fullpath'));

    % Define variables
    DepDir = scriptDir; % Set to the directory of the current script

    minLon = -126.75;
    maxLon = -116.25;
    minLat = 29.5;
    maxLat = 38.5;

    % Read in gridded data
    cd(DepDir)
    G = gmt('read', '-Tg GRIDONE_1D_140-110W_20-50N.nc'); % file needs to be in current directory
    % Read in color palette
    C = gmt('read', '-Tc CalCOFI_by.cpt');

    % Create label file
    D = struct;
    D.data = [-118, 38];
    D.text = {CruiseID};

    % Run GMT commands
    map = gmt('psbasemap', '-B2/2 -R-126.75/-116.25/29.5/38.5 -Jm.5i -K');
    map = gmt('grdimage', '-R -Jm -C -V -O -K -n+c', G, C);
    map = gmt('pscoast', '-R -Ggray -Jm -Df -B -K -O');
    map = gmt('grdcontour', '-R -C10000 -L-10000/0 -Q10 -Jm -V -K -O -W0.75p', G);
    map = gmt('pstext', '-Jm -R -F+f16p,Helvetica-Bold,0/102/204 -V -K -O', D);

    % Plot data if file exists
    cd(SightingDir);
    categories = {'ULW', 'Mn', 'Bp', 'Er', 'Bm', 'Ba'};
    colors = {'yellow', 'purple', 'green', 'orange', 'blue', 'red'};
    shapes = {'Sc10p', 'St10p', 'Sh10p', 'Ss10p', 'Sd10p', 'Sa10p'};

    for i = 1:length(categories)
        filename = fullfile(SightingDir, [CruiseID, '_', categories{i}, '.txt']);
        if exist(filename, 'file') == 2
            data = gmt('read', ['-Tt ', filename]);
            map = gmt('psxy', ['-R -Jm -N -A -O -K -L -W.5p -', shapes{i}, ' -G', colors{i}], data);
        end
    end

    % Read in trackline data - right now only usable for underway data, but
    % line 139 can be modified to use concatenated data
    % Read the CSV file and extract specified columns
    data = readtable(GPSFilePath, 'ReadVariableNames', false);
    data = [data.Var3, data.Var2]; %if use concatenated data, use ---> data = [str2double(data.Var2(2:end)), str2double(data.Var3(2:end))];
    %data = [str2double(data.Var2(2:end)), str2double(data.Var3(2:end))];
    % Create trackline data file
    T = struct('data', data);
    % Plot track line
    map = gmt('psxy', '-A -W.75p -Jm -R -O -V -K', T);

    % Read in CalCofiStations data
    cd(DepDir)
    S = gmt('read', '-Tt CalCofiStations_N113.txt'); % file needs to be in current directory
    % Plot additional stations
    map = gmt('psxy', '-R -Jm -N -Sc4.25p -O -L -G0/0/0 -A', S);

    % Convert plot to a PNG and display in MATLAB as Figure
    I = gmt('psconvert -TG -P -E300 -A', map); % transparent PNG
    figure()
    h = imshow(I.image);
    OutputFile = [CruiseID, '_Mysticete.png'];
    OutputFullName = fullfile(OutputDir, OutputFile);
    saveas(h, OutputFullName, 'png');
end