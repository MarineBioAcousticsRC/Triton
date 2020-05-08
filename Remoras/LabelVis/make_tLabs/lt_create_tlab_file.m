function lt_create_tlab_file

[file, path] = uigetfile({'*.txt';'*.s';'*.cTg'},'Select text file with detection times');

outDir = uigetdir([], 'Specify directory to save .tlab files');

% if canceled button pushed:
if strcmp(num2str(file),'0')
    return
end
    
fileFullPath = fullfile(path,file);

[~,filename,extFile] = fileparts(file);

if strcmp(extFile,'.s')
    % Text files with detection start and end times in secodns from the
    % start time of the audio file. Third column contains the labels.
    Starts = [];
    Stops = [];
    Labels = [];
    SearchFileMaskMat = {extFile};
    SearchPathMaskMat = {path};
    SearchRecursiv = 1;
    
    [PathFileListMat, FileListMat, ~] = ...
        utFindFiles(SearchFileMaskMat, SearchPathMaskMat, SearchRecursiv);

    for idx = 1:length(PathFileListMat)
    [StartsFile, StopsFile, LabelsFile] = lt_read_textFile(PathFileListMat{idx}, 'Binary', true);
    unscr = strsplit(FileListMat{idx},'.');
    filename = unscr{1,1};
    getdate = strsplit(filename,'_');
    d = [getdate{end-1},getdate{end}];
    rawStart = [str2num(['20',d(1:2)]), str2num(d(3:4)), str2num(d(5:6)), str2num(d(7:8)), str2num(d(9:10)), str2num(d(11:12))];
    Starts = [Starts; StartsFile/24/60/60 + datenum(rawStart(1,:))];
    Stops = [Stops; StopsFile/24/60/60 + datenum(rawStart(1,:))];
    Labels = [Labels;LabelsFile];
    end
    filename = fullfile([FileListMat{1}(1:10),'s']); % rename to get general name for hte folder
    
elseif strcmp(extFile,'.txt')
    % Text files with table format from Raven software. Table with multiple
    % columns, start and end times of detections are stored in BeginDate,
    % BegingClockTime and EndClockTime columns. Behavior column contains
    % the labels
    
    % chech how many columns it has
    table = readtable(fileFullPath);
    numCol = size(table,2);
    
%     if numCol > 3
%         data = lt_read_RavenTextFile(fileFullPath);
%         joinDateTime = @(date,time) datenum([date.Year  date.Month  date.Day  time.Hour  time.Minute time.Second]);
%         Starts = joinDateTime(data.BeginDate,data.BeginClockTime);
%         Stops = joinDateTime(data.BeginDate,data.EndClockTime);
%         Labels = data.Behavior;
%         disp('.txt file assumed to be Raven software output table format')
%     else
        % If does not follow Raven format, assume text file contains 3
        % columns, with start times, end times, and labels
        Starts = table{:,1};
        Stops = table{:,2};
        Labels = table{:,3};
        disp('.txt file assumed to have three columns: real start times (serial date number), real end times (serial date number), labels')
%     end
    
elseif strcmp(extFile,'.cTg')
    Starts = [];
    Stops = [];
    Labels = [];
    %get path to raw file 
    [rfFile,rfPath] = uigetfile({'*.wav','*.xwav'},'Select Corresponding Raw File');
    rfFull = fullfile(rfPath,rfFile);
    hdr = ioReadXWAVHeader(rfFull);
    rawStart = hdr.start.dnum; 
    cTgFile = fopen(fileFullPath);
    [table] = textscan(cTgFile,'%f %f %s');
    % assume cTg file contains 3
    % columns, with start times, end times, and labels
    Starts = ctg_to_datenum(table{1,1},rawStart)';
    Stops = ctg_to_datenum(table{1,2},rawStart)';
    Labels = table{:,3};
    disp('.cTg file assumed to have three columns: real start times (serial date number), real end times (serial date number), labels')
end

Times = [Starts, Stops];
Labels = Labels;

% Save detection times and labels to .tlab file
lt_write_labels(fullfile(outDir,[filename,'.tlab']), ...
    Times, Labels, 'Binary', true);

fprintf('Labels saved at: %s\n',fullfile(outDir,[filename,'.tlab']));

    function dnTimes = ctg_to_datenum(times,rawStart)
        for iT = 1:length(times)
            dnT = datenum([0 0 0 0 0 times(iT)]);
            dnTimes(iT) = rawStart + dnT;
        end
   