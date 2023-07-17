function [T] = sh_read_RavenTextFile(filename)
% [T] = sh_read_RavenTextFile(filename)

% Import data from text file - Raven Software Text files

delimiter = '\t';
startRow = 2;
formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]'; % read columns as text

% Open the text file.
fileID = fopen(filename,'r');

% Read columns of data according to the format.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,...
    'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');

% Close the text file.
fclose(fileID);

% Convert the contents of columns containing numeric text to numbers.
% Replace non-numeric text with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3,4,5,6,7,11]
    % Converts text in the input cell array to numbers. Replaced non-numeric
    % text with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1)
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',')
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'))
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric text to numbers.
            if ~invalidThousandsSeparator
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end

% Convert the contents of columns with dates to MATLAB datetimes using 
% the specified date format.
dateFormats = {'MM/dd/yyyy', 'HH:mm:ss.SSSS', 'HH:mm:ss.SSSS'};
dateFormatIndex = 1;
blankDates = cell(1,size(raw,2));
anyBlankDates = false(size(raw,1),1);
invalidDates = cell(1,size(raw,2));
anyInvalidDates = false(size(raw,1),1);
for col=[8,9,10]
    try
        dates{col} = datetime(dataArray{col}, 'Format', dateFormats{col==[8,9,10]}, 'InputFormat', dateFormats{col==[8,9,10]});
    catch
        try
            % Handle dates surrounded by quotes
            dataArray{col} = cellfun(@(x) x(2:end-1), dataArray{col}, 'UniformOutput', false);
            dates{col} = datetime(dataArray{col}, 'Format', dateFormats{col==[8,9,10]}, 'InputFormat', dateFormats{col==[8,9,10]}); %%#ok<SAGROW>
        catch
            dates{col} = repmat(datetime([NaN NaN NaN]), size(dataArray{col}));
        end
    end
    
    dateFormatIndex = dateFormatIndex + 1;
    blankDates{col} = cellfun(@isempty, dataArray{col});
    anyBlankDates = blankDates{col} | anyBlankDates;
    invalidDates{col} = isnan(dates{col}.Hour) - blankDates{col};
    anyInvalidDates = invalidDates{col} | anyInvalidDates;
end
dates = dates(:,[8,9,10]);
blankDates = blankDates(:,[8,9,10]);
invalidDates = invalidDates(:,[8,9,10]);

% Split data into numeric and cell columns.
rawNumericColumns = raw(:, [1,2,3,4,5,6,7,11]);
rawCellColumns = raw(:, [12,13]);

% Allocate imported array to column variable names
T = struct;
T.Selection = cell2mat(rawNumericColumns(:,1));
T.View = cell2mat(rawNumericColumns(:,2));
T.Channel = cell2mat(rawNumericColumns(:,3));
T.BeginTimes = cell2mat(rawNumericColumns(:,4));
T.EndTimes = cell2mat(rawNumericColumns(:,5));
T.LowFreqHz = cell2mat(rawNumericColumns(:,6));
T.HighFreqHz = cell2mat(rawNumericColumns(:,7));
T.BeginDate = dates{:, 1};
T.BeginClockTime = dates{:, 2};
T.EndClockTime = dates{:, 3};
T.DeltaTimes = cell2mat(rawNumericColumns(:,8));
T.Behavior = rawCellColumns(:,1);
T.Notes = rawCellColumns(:,2);