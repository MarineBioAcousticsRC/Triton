function cc_conc_concatenate(indir, outdir)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% cc_conc_mconcatenate.m
%
% made by SGB 20240717
% Shelby G. Bloom (sbloom@ucsd.edu)
%
% in a directory, concatenate daily expanded files and save as .csv
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS REMORA

%REMORA.cc.conc.tic = tic;
%REMORA.cc.conc.indir = 'P:\CalCOFI\TestCases\fromBJT\expanded';
%REMORA.cc.conc.outdir = 'P:\CalCOFI\TestCases\fromBJT';

%get daily expanded files in directory
[REMORA.cc.conc.PathFileList, REMORA.cc.conc.FileList, REMORA.cc.conc.PathList] = ...
    utFindFiles('*.txt', REMORA.cc.conc.indir, 0);

%Create output file name - this is just the name of the first daily expanded file
% get name of first daily expanded file
REMORA.cc.conc.outputFileName = [REMORA.cc.conc.FileList{1}(1:end-6), '.txt'];
REMORA.cc.conc.outputFile = fullfile(REMORA.cc.conc.outdir, REMORA.cc.conc.outputFileName);

% Initialize a flag to indicate if this is the first file being processed
   isFirstFile = true;
    
% Display a message indicating that the concatenation process has began
    disp(['Files are being concatenated']);
  
% Loop through each text file and read its contents as a table
    for i = 1:length(REMORA.cc.conc.FileList)
        % Construct the full file name
        currentFile = fullfile(REMORA.cc.conc.PathList{i}, REMORA.cc.conc.FileList{i});
        
        % Read the contents of the file as a table
        currentTable = readtable(currentFile, 'Delimiter', ',');
        
        % Convert all variables in the current table to strings, preserving precision for doubles
        vars = currentTable.Properties.VariableNames;
        for j = 1:length(vars)
            varName = vars{j};
            if isnumeric(currentTable.(varName))
                % Convert numeric variables to strings with high precision
                currentTable.(varName) = arrayfun(@(x) sprintf('%.16g', x), currentTable.(varName), 'UniformOutput', false);
            else
                % Convert non-numeric variables to strings
                currentTable.(varName) = string(currentTable.(varName));
            end
        end

        % If this is the first file, initialize the combinedTable with its structure
        if isFirstFile
            combinedTable = currentTable;
            isFirstFile = false;
        else
            % Standardize variable names to match the combinedTable
            combinedVars = combinedTable.Properties.VariableNames;

            % Concatenate the current table with the combined table
            combinedTable = [combinedTable; currentTable];
        end
    end
    
    % Write the combined table to the output file
    writetable(combinedTable, REMORA.cc.conc.outputFile, 'FileType', 'text', 'Delimiter', ',');
    
    % Read the entire CSV file as lines
    fid = fopen(REMORA.cc.conc.outputFile, 'r');
    fileLines = textscan(fid, '%s', 'Delimiter', '\n');
    fclose(fid);
    fileLines = fileLines{1}; % Extract the cell array of lines

    % Modify the header line (assumed to be the first line)
    headerLine = fileLines{1}; % Get the first line (header line)
    headerCells = strsplit(headerLine, ','); % Split by commas (adjust delimiter if needed)

    % Define new variable names
    newVariableNames = {'EID','X','Y','ev','when','spd','hdg','cruise','vessel','eff','trn',...
        'port','star','qual','vis','precip','cloud','glareL','glareR','glareS','wind.dir',...
        'wind.spd','bft','swell','X1','X2','X3','X4','X5','X6','X7','X8','X9','X10','X11',...
        'X12','X13','X14','X15','X16','X17','X18','X19','X20','X21','X22','X23','X24',...
        'X25','X26','X27','X28','X29','X30','X31','X32','X33','X34','X35','X36'}; % Adjust as needed

    % Replace original headers with new headers
    headerCells = newVariableNames; % Replace headers with new names

    % Join the modified header cells back into a single line
    newHeaderLine = strjoin(headerCells, ',');

    % Replace the original header line in the fileLines cell array
    fileLines{1} = newHeaderLine;

    % Write modified lines back to the original CSV file
    fid = fopen(REMORA.cc.conc.outputFile, 'w');
    fprintf(fid, '%s\n', fileLines{:});
    fclose(fid);
    
    % Display a message indicating that the files have been concatenated
    disp(['Files have been concatenated and saved as ' REMORA.cc.conc.outputFileName]);
end