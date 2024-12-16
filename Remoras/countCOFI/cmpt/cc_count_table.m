function cc_count_table(indir, outdir, GMTdiff)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  cc_count_table.m
%
%  made by SGB 20240717
%  Shelby G. Bloom (sbloom@ucsd.edu)
%  based on code from BJT (bthayre@ucsd.edu) - cc-tableLoop_180430.R
%
%
%  in a directory of expanded files, open each expanded file, run some magic on it to make a
%  new table, and then append those tables for each expanded file into one bag table to make
%  the countCOFI table file and save as .csv
%
%
%  have to run this on expanded files instead of concatenated files because
%  in the section where we are identifying turns in order to add position
%  updates (lines 94-107) we are counting every 13th row in an expanded file
%  and using that as an index based on time, so if we were to use
%  concatenated files then we would not be correctly indexing every 13th row
%  based on time
%
%
%
% in the original code, the 'photos' column in the big mr table would pickup rows where the X24
% and X28 columns had spaces. I had to explicitly specify in this MATLAb code to preserve
% whitespaces in columns X24 and X28 so this is the same case in this code
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS REMORA

%REMORA.cc.conc.tic = tic;
%REMORA.cc.conc.indir = 'P:\CalCOFI\TestCases\fromBJT\expanded';
%REMORA.cc.conc.outdir = 'P:\CalCOFI\TestCases\fromBJT';

%get daily expanded files in directory
[REMORA.cc.count.PathFileList, REMORA.cc.count.FileList, REMORA.cc.count.PathList] = ...
    utFindFiles('*.txt', REMORA.cc.count.indir, 0);

%Create output file name - this is just the name of the first daily expanded file
% get name of first daily expanded file
REMORA.cc.count.outputFileName = [REMORA.cc.count.FileList{1}(4:7), '-', REMORA.cc.count.FileList{1}(8:9) '.csv'];
REMORA.cc.count.outputFile = fullfile(REMORA.cc.count.outdir, REMORA.cc.count.outputFileName);

% Initialize the master table outside the loop
REMORA.cc.count.masterTable = table();

% Display a message indicating that the files have been concatenated
disp(['Table is being generated']);

% Loop through each text file and read its contents as a table
for i = 1:length(REMORA.cc.count.FileList)
    % Construct the full file name
    REMORA.cc.count.currentFile = fullfile(REMORA.cc.count.PathList{i}, REMORA.cc.count.FileList{i});
    
    %we need to specify the variables class types so that for every
    %expanded file we read in it is the same
    % Specify the variable names and their corresponding types
    varNames = {'EID', 'X', 'Y', 'ev', 'when', 'spd', 'hdg', 'cruise', 'vessel', 'eff', 'trn', 'port', 'star', 'qual', 'vis', 'precip',...
        'cloud', 'glareL', 'glareR', 'glareS', 'wind_dir', 'wind_spd', 'bft', 'swell', 'X1', 'X2', 'X3', 'X4', 'X5', 'X6', 'X7', 'X8',...
        'X9', 'X10', 'X11', 'X12', 'X13', 'X14', 'X15', 'X16', 'X17', 'X18', 'X19', 'X20', 'X21', 'X22', 'X23', 'X24', 'X25', 'X26',...
        'X27', 'X28', 'X29', 'X30', 'X31', 'X32', 'X33', 'X34', 'X35', 'X36'};
    varTypes = {'double', 'double', 'double', 'char', 'datetime', 'double', 'double', 'char', 'char', 'char', 'double', 'char', 'char',...
        'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char',...
        'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char',...
        'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char', 'char',};
    % Detect import options
    opts = detectImportOptions(REMORA.cc.count.currentFile);
    % Set the variable types
    opts = setvartype(opts, varNames, varTypes);
    % Ensure spaces are not treated as missing values for specific character columns
    columnsToPreserveSpaces = {'X24', 'X28'}; % Specify the column names where you want to preserve spaces
    opts = setvaropts(opts, columnsToPreserveSpaces, 'WhitespaceRule', 'preserve');
    
    
    
    
    % Read the contents of the file as a table
    ccm = readtable(REMORA.cc.count.currentFile, opts);
    % ccmclassTypes = varfun(@class, ccm, 'OutputFormat', 'cell');
    %ccm2 = readtable(REMORA.cc.count.currentFile);
    %ccm2.trn = str2double(ccm2.trn);
    %ccm2classTypes = varfun(@class, ccm, 'OutputFormat', 'cell');
    
    
    
    
    ccData = ccm(~ismissing(ccm.trn) & ~ismissing(ccm.eff), :); % remove rows where there is an NA in either trn or eff columns
    % ccDataclassTypes = varfun(@class, ccData, 'OutputFormat', 'cell');
    
    % Assign codes to data output
    %Code = strings(height(ccData), 1);
    Code = cell(height(ccData), 1);
    Code(strcmp(ccData.ev, 'SEA')) = {'W'}; % Weather update
    Code(strcmp(ccData.ev, 'COM')) = {'C'}; % Comment
    Code(strcmp(ccData.ev, 'SIT') & strcmp(ccData.X1, 'PINN')) = {'PINN'}; % Pinniped sighting
    Code(strcmp(ccData.ev, 'SIT') & strcmp(ccData.X1, 'TURT')) = {'TURT'}; % Turtle sighting
    Code(strcmp(ccData.ev, 'SIT') & strcmp(ccData.X1, 'SHIP')) = {'SH'}; % Ship sighting
    
    
    % Identifying turns, in order to add position updates
    pos = ccData(strcmp(ccData.ev, 'POS') & ~ismissing(ccData.hdg), :); % subset to position updates
    pos = pos(~isnan(pos.hdg), :); % NA strings made it into 1/10/17
    hdg = pos(1:13:end, :); len = length(hdg.hdg); hdg_column = hdg.hdg; % subset to headings
    turns = false(height(hdg) - 1, 1);
    
    for j = 1:(height(hdg) - 1)
        if abs(hdg.hdg(j + 1) - hdg.hdg(j)) >= 12
            turns(j) = true;
        end
    end
    turns = [turns; false];
    turns = hdg(~strcmp(hdg.eff, '0') & turns, :); % subset to turns that occur only during observation effort
    Code(ismember(ccData.EID, turns.EID)) = {'P'};
    
    % Observation effort
    eff = ccData(strcmp(ccData.ev, 'EFF'), :);
    CodeEff = repmat(string(NaN), height(eff), 1);
    
    if eff.eff{1} == '0'
        CodeEff{1} = 'B'; % Figure out starting effort
    end
    
    %     for k = 2:height(eff)
    %         effnow = eff.eff{k};
    %         effnow = string(effnow(1));
    %         effpre = eff.eff{k-1};
    %         effpre = string(effpre(1));
    %
    %         if effnow == '0' && effpre ~= '0'
    %             CodeEff(k) = 'B'; % If effort WAS off but is NOW on...
    %         elseif effnow ~= '0' && effpre == '0'
    %             CodeEff(k) = 'E'; % If effort WAS on but is NOW off...
    %         elseif effnow == '6' && effpre ~= '6'
    %             CodeEff(k) = 'OO'; % If both observers were one but now only one is on...
    %         elseif effnow ~= '6' && effpre == '6'
    %             CodeEff(k) = 'OB'; % If one observer was on but now both are back on...
    %         end
    %     end
    
    
    for i = 2:length(eff.eff)
        % Store status at this index and immediately before
        effnow = eff.eff{i}(1); % Current effort (first character)
        effpre = eff.eff{i-1}(1); % Previous effort (first character)
        
        % Apply code
        if strcmp(effnow, '6') && ~strcmp(effpre, '6')
            CodeEff{i} = 'OO'; % If both observers were on but now only one is on...
        elseif ~strcmp(effnow, '6') && strcmp(effpre, '6')
            CodeEff{i} = 'OB'; % If one observer was on but now both are back on...
        elseif strcmp(effnow, '0') && ~strcmp(effpre, '0')
            CodeEff{i} = 'B'; % If effort WAS off but is NOW on...
        elseif ~strcmp(effnow, '0') && strcmp(effpre, '0')
            CodeEff{i} = 'E'; % If effort WAS on but is NOW off...
        end
    end
    
    CodeEff = table(eff.EID, CodeEff, 'VariableNames', {'EID', 'Code'});
    CodeEff = CodeEff(~ismissing(CodeEff.Code), :);
    
    % Transect effort
    trn = ccData(strcmp(ccData.ev, 'EFF'), :);
    CodeTrn = repmat(string(NaN), height(trn), 1);
    
    if trn.trn(1) == 0
        CodeTrn(1) = 'RT'; % Figure out starting transect effort
    end
    
    for m = 2:height(trn)
        trnnow = trn.trn(m);
        trnpre = trn.trn(m-1);
        
        if trnnow == 0 && trnpre ~= 0
            CodeTrn{m} = 'RT'; % If transect WAS off but is NOW on...
        elseif trnnow ~= 0 && trnpre == 0
            CodeTrn{m} = 'XT'; % If transect WAS on but is now off...
        end
    end
    
    CodeTrn = table(trn.EID, CodeTrn, 'VariableNames', {'EID', 'Code'});
    CodeTrn = CodeTrn(~ismissing(CodeTrn.Code), :);
    
    % Refine transect codes with Begin/End transect
    rt = find(CodeTrn.Code == 'RT', 1, 'first');
    CodeTrn.Code(rt) = 'ST';
    
    xt = find(CodeTrn.Code == 'XT', 1, 'last');
    CodeTrn.Code(xt) = 'ET';
    
    % Observer changes
    obs = ccData(strcmp(ccData.ev, 'EFF'), :);
    CodeObs = repmat(string(NaN), height(obs), 1);
    
    for n = 2:height(obs)
        portnow = obs.port{n};
        portpre = obs.port{n-1};
        starnow = obs.star{n};
        starpre = obs.star{n-1};
        
        if ~strcmp(portnow, portpre) || ~strcmp(starnow, starpre)
            CodeObs(n) = 'OC'; % If observers have changed...
        end
    end
    
    CodeObs = table(obs.EID, CodeObs, 'VariableNames', {'EID', 'Code'});
    CodeObs = CodeObs(~ismissing(CodeObs.Code), :);
    
    % Whale Sightings
    sits = ccData(ismember(ccData.ev, {'SIT', 'UPD'}) & strcmp(ccData.X1, 'CETA'), :);
    %sitsclassTypes = varfun(@class, ccm, 'OutputFormat', 'cell');
    sits = sits(~strcmp(sits.X17, ''), :); % finding empty species ids starting 2017-08
    %sitsX17firstElementType = class(sits.X17{1});
    sits.CodeSit = repmat({'NA'}, height(sits), 1);
    usits = unique(sits.X2);
    
    newsits = [];
    for o = 1:length(usits)
        sit = sits(strcmp(sits.X2, usits{o}), :);
        %sitsX2firstElementType = class(sits.X2{1});
        %usitsfirstElementType = class(usits{1});
        if height(sit) == 1
            sit.CodeSit{1} = 'SB/SE'; % If there is only one entry for this sighting
        else
            sit.CodeSit{1} = 'SB';
            sit.CodeSit{end} = 'SE';
            
            if height(sit) > 2
                sit.CodeSit(2:end-1) = repmat({'SP'}, 1, height(sit)-2);
            end
        end
        newsits = [newsits; sit];
    end
    
    % CodeSit = table(newsits.EID, newsits.CodeSit, 'VariableNames', {'EID', 'Code'});
    
    % Check if newsits is empty
    if isempty(newsits)
        % Create an empty table
        CodeSit = table([], {}, 'VariableNames', {'EID', 'Code'});
    else
        % Create table from newsits
        CodeSit = table(newsits.EID, newsits.CodeSit, 'VariableNames', {'EID', 'Code'});
    end
    
    
    %     if ~isempty(newsits)
    %         CodeSit = table(newsits.EID, newsits.CodeSit', 'VariableNames', {'EID', 'Code'});
    %     else
    %         %Handle case where newsits is empty
    %         CodeSit = table([], {}, 'VariableNames', {'EID', 'Code'}); %empty table
    %     end
    
    
    
    
    
    
    % Combine code banks and subset ccData output to those with event codes
    ccData.Code = Code;
    %ccDataCodefirstElementType = class(ccData.Code{1});
    %CodeCC = ccData(~ismissing(ccData.Code) & strlength(ccData.Code) > 0, {'EID', 'Code'});
    %CodeCC = ccData(~isspace(ccData.Code) & ~isempty(ccData.Code), {'EID', 'Code'});
    CodeCC = ccData(~cellfun(@isempty, ccData.Code), :);
    CodeCC = table(CodeCC.EID, CodeCC.Code, 'VariableNames', {'EID', 'Code'});
    % streamlined version: CodeCC = table(ccData.EID(~cellfun(@isempty, ccData.Code)), ccData.Code(~cellfun(@isempty, ccData.Code)), 'VariableNames', {'EID', 'Code'});
    
    % Combine our 5 dataframes of event codes
    Codes = [CodeCC; CodeEff; CodeTrn; CodeObs; CodeSit];
    Codes = sortrows(Codes, 'EID');
    
    % Expand Codes dataframe to include all original data for corresponding EID
    newcode = table();
    for p = 1:height(Codes)
        cci = ccData(ccData.EID == Codes.EID(p), :);
        cci.Code = [];
        newcodei = [table(repmat(Codes.Code(p), height(cci), 1), 'VariableNames', {'Code'}), cci];
        newcode = [newcode; newcodei];
    end
    Codes = newcode;
    Codes.comment = repmat(string(''), height(Codes), 1);
    Codes.comment(Codes.Code == 'C') = Codes.X1(Codes.Code == 'C');
    
    % Clear out event data that does not pertain to sightings
    Codes{~ismember(Codes.X1, {'PINN', 'CETA', 'SHIP', 'TURT'}), 26:50} = {''};
    
    % Convert ccData output to table columns
    currentmr = cell(height(Codes), 62);
    colnames = {'Event_Code', 'Cruise', 'Date_DST', 'Time_DST', 'Date_Time_DST', 'GMT_Diff', 'Date_Time_GMT', 'Lat', 'Lon', ...
        'DecLat', 'DecLong', 'PortObs', 'StbdObs', 'Quality', 'Visibility', 'Precipitation', 'Cloud', ...
        'Glare_L', 'Glare_R', 'Glare_Quality', 'Wind_dir_T', 'Wind_spd_T', 'Bft', 'Swell_ft', ...
        'Sighting_No', 'Init_Observer', 'Cue', 'Ship_Heading_Tru', 'Sighting_Bearing_Tru', ...
        'Bino_Reticle', 'Distance_m', 'Sight_Meth', 'Envelope_Depth', 'Envelope_Depth2', ...
        'Envelope_Width', 'Envelope_Width2', 'Best', 'Min', 'Max', 'Calf', 'Species1', 'Species2', 'sp1_percent', 'sp2_percent', ...
        'Effort', 'Off_Effort_Code', 'Transect', 'Off_Transect_Code', ...
        'Primary_Behaviour', 'Other_Behaviour1', 'Other_Behaviour2', ...
        'Photos', 'Photographer_Cam1', 'Camera_1', 'FirstFrame_1', 'LastFrame_1', ...
        'Photographer_Cam2', 'Camera_2', 'FirstFrame_2', 'LastFrame_2', 'Comments', 'SOG_knots'};
    currentmr = cell2table(currentmr, 'VariableNames', colnames);
    
    % Populate master dataframe by drawing upon Codes dataframe
    Codes = Codes(~ismissing(Codes.eff) & ~isnan(Codes.trn), :);
    %CodesefffirstElementType = class(Codes.eff{1});
    %CodestrnfirstElementType = class(Codes.trn{1});
    %CodesclassTypes = varfun(@class, Codes, 'OutputFormat', 'cell');
    
    
    currentmr.Event_Code = Codes.Code;
    currentmr.Cruise = Codes.cruise;
    currentmr.Date_DST = datestr(Codes.when, 'yyyy-mm-dd');
    currentmr.Time_DST = timeofday(Codes.when);
    currentmr.Date_Time_DST = datestr(Codes.when, 'yyyy-mm-dd HH:MM:SS');
    currentmr.GMT_Diff = repmat(REMORA.cc.count.GMTdiff, height(currentmr), 1);
    currentmr.Date_Time_GMT = datetime(Codes.when, 'TimeZone', 'America/Los_Angeles', 'Format', 'yyyy-MM-dd HH:mm:ss');
    currentmr.Date_Time_GMT.TimeZone = 'GMT';
    currentmr.DecLat = Codes.Y;
    currentmr.DecLong = Codes.X;
    currentmr.PortObs = Codes.port;
    currentmr.StbdObs = Codes.star;
    currentmr.Quality = strrep(Codes.qual, ' ', '');
    currentmr.Visibility = strrep(Codes.vis, ' ', '');
    currentmr.Precipitation = strrep(Codes.precip, ' ', '');
    currentmr.Cloud = strrep(Codes.cloud, ' ', '');
    currentmr.Glare_L = strrep(Codes.glareL, ' ', '');
    currentmr.Glare_R = strrep(Codes.glareR, ' ', '');
    currentmr.Glare_Quality = strrep(Codes.glareS, ' ', '');
    currentmr.Wind_dir_T = strrep(Codes.wind_dir, ' ', '');
    currentmr.Wind_spd_T = strrep(Codes.wind_spd, ' ', '');
    currentmr.Bft = Codes.bft;
    currentmr.Swell_ft = strrep(Codes.swell, ' ', '');
    
    % Non sighting II
    currentmr.Effort = repmat({'OFF'}, height(currentmr), 1);
    currentmr.Effort(strcmp(Codes.eff, '0')) = {'ON'};
    
    currentmr.Off_Effort_Code = repmat({''}, height(currentmr), 1);
    currentmr.Off_Effort_Code(~strcmp(Codes.eff, '0')) = Codes.eff(~strcmp(Codes.eff, '0'));
    
    currentmr.Transect = repmat({'OFF'}, height(currentmr), 1);
    currentmr.Transect(Codes.trn == 0) = {'ON'};
    
    currentmr.Off_Transect_Code = repmat({''}, height(currentmr), 1);
    currentmr.Off_Transect_Code(~strcmp(cellstr(num2str(Codes.trn)), '0')) = cellstr(num2str(Codes.trn(~strcmp(cellstr(num2str(Codes.trn)), '0'))));
    
    % Sighting
    sitcode = strrep(string(strcat(Codes.X1, Codes.X2)), 'CETA', '');
    sitcode = strrep(sitcode, '0', '');
    currentmr.Sighting_No = sitcode;
    currentmr.Init_Observer = Codes.X3;
    currentmr.Cue = Codes.X4;
    currentmr.Ship_Heading_Tru = Codes.hdg;
    currentmr.Sighting_Bearing_Tru = Codes.X6;
    currentmr.Bino_Reticle = Codes.X7;
    currentmr.Distance_m = Codes.X8;
    meth = repmat({''}, height(currentmr), 1);
    meth(~ismissing(Codes.X7)) = {'Bino'};
    meth(~ismissing(Codes.X8)) = {'Eyes'};
    currentmr.Sight_Meth = meth;
    currentmr.Envelope_Depth = Codes.X9;
    currentmr.Envelope_Depth2 = Codes.X10;
    currentmr.Envelope_Width = Codes.X11;
    currentmr.Envelope_Width2 = Codes.X12;
    currentmr.Best = Codes.X13;
    currentmr.Min = Codes.X14;
    currentmr.Max = Codes.X15;
    currentmr.Calf = Codes.X16;
    currentmr.Species1 = Codes.X17;
    currentmr.Species2 = Codes.X19;
    currentmr.sp1_percent = Codes.X18;
    currentmr.sp2_percent = Codes.X20;
    currentmr.Primary_Behaviour = Codes.X21;
    currentmr.Other_Behaviour1 = Codes.X22;
    currentmr.Other_Behaviour2 = Codes.X23;
    
    photos = repmat({''}, height(currentmr), 1);
    photos((~cellfun('isempty', Codes.X24) & ~strcmp(Codes.X24, 'NA')) | (~cellfun('isempty', Codes.X28) & ~strcmp(Codes.X28, 'NA'))) = {'YES'};
    %photos((~cellfun('isempty', Codes.X26) & ~strcmp(Codes.X26, 'NA')) | (~cellfun('isempty', Codes.X27) & ~strcmp(Codes.X27, 'NA')) |...
    %    (~cellfun('isempty', Codes.X30) & ~strcmp(Codes.X30, 'NA')) | (~cellfun('isempty', Codes.X31) & ~strcmp(Codes.X31, 'NA'))   ) = {'YES'};
    currentmr.Photos = photos;
    currentmr.Photographer_Cam1 = Codes.X24;
    currentmr.Camera_1 = Codes.X25;
    currentmr.FirstFrame_1 = Codes.X26;
    currentmr.LastFrame_1 = Codes.X27;
    currentmr.Photographer_Cam2 = Codes.X28;
    currentmr.Camera_2 = Codes.X29;
    currentmr.FirstFrame_2 = Codes.X30;
    currentmr.LastFrame_2 = Codes.X31;
    currentmr.Comments = Codes.comment;
    currentmr.SOG_knots = Codes.spd;
    
    % Append to the master table, only keep variable names from the first input file
    if i == 1
        REMORA.cc.count.masterTable = currentmr;
    else
        % Append only the relevant columns
        REMORA.cc.count.masterTable = vertcat(REMORA.cc.count.masterTable, currentmr);
    end
end


% Write the combined table to the output file
writetable(REMORA.cc.count.masterTable, REMORA.cc.count.outputFile);

% Read the entire CSV file as lines
fid = fopen(REMORA.cc.count.outputFile, 'r');
fileLines = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);
fileLines = fileLines{1}; % Extract the cell array of lines

% Modify the header line (assumed to be the first line)
headerLine = fileLines{1}; % Get the first line (header line)
headerCells = strsplit(headerLine, ','); % Split by commas (adjust delimiter if needed)

% Define new variable names
newVariableNames = {'Event.Code','Cruise','Date.DST','Time.DST','Date.Time.DST','GMT.Diff','Date.Time.GMT','Lat','Lon',...
    'DecLat','DecLong','PortObs','StbdObs','Qualilty','Visibility','Precipitation','Cloud',...
    'Glare.L','Glare.R','Glare.Quality','Wind.dir.T','Wind.spd.T','Bft','Swell.ft',...
    'Sighting.No','Init.Observer','Cue','Ship.Heading.Tru','Sighting.Bearing.Tru',...
    'Bino.Reticle','Distance.m','Sight.Meth','Envelope.Depth','Envelope.Depth2',...
    'Envelope.Width','Envelope.Width2','Best','Min','Max','Calf','Species1','Species2','sp1.percent','sp2.percent',...
    'Effort','Off.Effort.Code','Transect','Off.Transect.Code',...
    'Primary.Behaviour','Other.Behaviour1','Other.Behaviour2',...
    'Photos','Photographer.Cam1','Camera.1','FirstFrame.1','LastFrame.1',...
    'Photographer.Cam2','Camera.2','FirstFrame.2','LastFrame.2','Comments','SOG [knots]'}; % Adjust as needed

% Replace original headers with new headers
headerCells = newVariableNames; % Replace headers with new names

% Join the modified header cells back into a single line
newHeaderLine = strjoin(headerCells, ',');

% Replace the original header line in the fileLines cell array
fileLines{1} = newHeaderLine;

% Write modified lines back to the original CSV file
fid = fopen(REMORA.cc.count.outputFile, 'w');
fprintf(fid, '%s\n', fileLines{:});
fclose(fid);

% Display a message indicating that the files have been concatenated
disp(['Table creation complete! '  REMORA.cc.count.outputFileName  ' has been written to '  REMORA.cc.count.outdir ' !!!']);
end