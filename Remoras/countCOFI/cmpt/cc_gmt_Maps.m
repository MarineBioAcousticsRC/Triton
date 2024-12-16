function cc_gmt_Maps(SightingDir, GPSFilePath, OutputDir)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  cc_GMT_Maps.m
%
%  made by SGB 20240807
%  Shelby G. Bloom (sbloom@ucsd.edu)
%
%  having the person specify the
%  using underway GPS track data (can use concatenated daily expanded file data if
%  needed but 1) you will need to modify code in Myst_map and Odont_Map and 2) the 
%  plot will not include the full track of the cruise) and species sighting text files
%  for a single cruise, generate GMT maps for odontocetes and mysticetes
%  sighted
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS REMORA

    % Get the list of files in the directory
    fileList = dir(fullfile(REMORA.cc.gmt.SightingDir, '*.*')); % Modify the pattern if needed

    % Check if there are any files
    if ~isempty(fileList)
        % Get the name of the first file (excluding directories)
        for k = 1:length(fileList)
            if ~fileList(k).isdir
                firstFileName = fileList(k).name;
                break;
            end
        end

        % Extract the first 7 characters from the file name
        if length(firstFileName) >= 7
            CruiseID = firstFileName(1:7);
        else
            error('The first file name is too short to extract 7 characters.');
        end
    else
        error('No files found in the specified directory.');
    end

    % Set global variables (adjust if needed)
    REMORA.cc.gmt.CruiseID = CruiseID;

    %make odontocete map
    % Display a message indicating that odontcete plot is being generated
    disp(['Making Odontocete GMT map...']);
    
    Odont_Map(REMORA.cc.gmt.CruiseID, REMORA.cc.gmt.SightingDir, REMORA.cc.gmt.GPSFilePath, REMORA.cc.gmt.OutputDir);
    
    % Display a message indicating that odontcete plot has been generated and saved 
    disp(['Odontocete GMT map has been generated and saved to ' REMORA.cc.gmt.OutputDir ' !!!']);
    
    
    %make mystictet map
    % Display a message indicating that odontcete plot is being generated
    disp(['Making Mysticete GMT map...']);
    
    Myst_Map(REMORA.cc.gmt.CruiseID, REMORA.cc.gmt.SightingDir, REMORA.cc.gmt.GPSFilePath, REMORA.cc.gmt.OutputDir);
    
     % Display a message indicating that odontcete plot has been generated and saved 
    disp(['Mysticete GMT map has been generated and saved to ' REMORA.cc.gmt.OutputDir ' !!!']);
    
    % Display a message indicating that all done
    disp(['DONE']);
end