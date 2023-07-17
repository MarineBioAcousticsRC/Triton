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
        
        %check if date range should be modified- if first column of datevec
        %times is >2000, assume that should remove year to match triton
        %dates
        dvst = datevec(Starts);
        yearcol = dvst(:,1);
        if ~isempty(find(yearcol > 2000))
            Starts = Starts - datenum(2000,0,0,0,0,0);
            Stops = Stops - datenum(2000,0,0,0,0,0);
        end
        
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
    cTgFile = fopen(fileFullPath);
    [table] = textscan(cTgFile,'%f %f %s');
    % assume cTg file contains 3
    % columns, with start times, end times, and labels
    Starts = ctg_to_datenum(table{1,1},hdr)';
    Stops = ctg_to_datenum(table{1,2},hdr)';
    Labels = table{:,3};
    disp('.cTg file assumed to have three columns: real start times (serial date number), real end times (serial date number), labels')
end

Times = [Starts, Stops];
Labels = Labels;

% Save detection times and labels to .tlab file
lt_write_labels(fullfile(outDir,[filename,'.tlab']), ...
    Times, Labels, 'Binary', true);

fprintf('Labels saved at: %s\n',fullfile(outDir,[filename,'.tlab']));

    function dnTimes = ctg_to_datenum(times,hdr)
        dur = unique((hdr.raw.dnumEnd - hdr.raw.dnumStart).*60*60*24);
        if length(dur)>=2
            disp('WARNING! raw files not all of equal duration- may affect tlab creation')
        end
        
        rawFiles = hdr.raw.dnumStart;
        nRawFile = 1:length(rawFiles);
        secStart = [0,nRawFile.*dur(1)]; %convert rawfiles into time of start in seconds
        nextStart = [secStart(2:end),(nRawFile(end)*dur(1))];
        
        for iT = 1:length(times)
            rawFIdx = find(times(iT)>=secStart&times(iT)<=nextStart);
            dnDiff = times(iT) - secStart(rawFIdx); %find time within raw file of this detection 
            dnT = datenum([0 0 0 0 0 dnDiff]);%turn corrected offset time into a datenum 
            dnTimes(iT) = rawFiles(rawFIdx) + dnT; %add to start time of that raw file
        end
   