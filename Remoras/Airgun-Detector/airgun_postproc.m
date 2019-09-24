%1 - Load airgun detector output file
[FileName,PathName,~] = uigetfile('*.mat','Select .mat detection file');

load(fullfile(PathName,FileName));

%2 - Determine start and end time of file and divide into 1-hour bins
StartTime = datenum(rawStart(1,:));
sec2dnum = 60*60*24;
EndTime = datenum(rawStart(end,:))+ (rawDur(end)/sec2dnum);
HourDNum = 1/24;
HourVec = StartTime:HourDNum:EndTime;
if EndTime ~= HourVec(end)
    HourVec = [HourVec,EndTime];
end

%3 - For each bin, divide into 1s intervals
for ih = 1:length(HourVec)-1
    BinStart = HourVec(ih);
    BinEnd = HourVec(ih+1);
    SecVec = BinStart:(1/sec2dnum):BinEnd;

    %4 - Find intervals that contain detections and insert the quality value
    [bincounts,ind] = histc(bt(:,4),SecVec);
    DetSet = find(ind >0);

    if ~isempty(DetSet)
       bincounts(ind(DetSet))= allCorrVal(DetSet,1);
    end
    
    %5 - Look for autocorrelation peaks
    [c,lags] = xcorr(bincounts,200);
    
    %6 - Determine if peaks are within range
    
    
end
