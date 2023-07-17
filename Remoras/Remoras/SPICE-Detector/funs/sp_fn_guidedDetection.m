function [xwavNames,matlabDates] = sp_fn_guidedDetection(detFiles,p)
% Use to increase efficiency and accuracy by only running detector over 
% xwav files spanned by a previously defined "detection", requires .xls
% input file, with start/end times of encounters formatted as numbers.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read in .xls file containing 2 columns: interval start, interval times
% you must format your Excel dates/times as NUMBERS, not dates

% read the file into 3 matrices-- numeric, text, and raw cell array
sprintf('Loading guided detection file %s\n',p.gDxls)
[gDNum,gDTxt,~]  = xlsread(p.gDxls);

% figure out what kind of dates have been handed in
if size(gDNum,2)>= 2 
    %start and end dates are formatted as numbers
    disp('Assuming guided detection times are in excel datenum format')
    excelDates = gDNum(:,1:2);
    
    % convert excel datenums to matlab datenums (different pivot year)
    matlabDates = ones(size(excelDates)).*datenum('30-Dec-1899') ...
    + excelDates; % x2mdate does this, but requires financial toolbox

elseif size(gDTxt,2)>= 2
    %start and end dates are formatted as text
    disp('No number columns found')
    disp('Assuming guided detection times are in MM/DD/YYYY hh:mm:ss format')
    matlabDates = [datenum(gDTxt(2:end,1),'mm/dd/yyyy HH:MM:SS'),datenum(gDTxt(2:end,2),'mm/dd/yyyy HH:MM:SS')];
    
end  

% read xwav headers to determine start of each xwav file
startFile = ones(size(detFiles,1),1);
endFile = ones(size(detFiles,1),1);

fprintf('Reading audio file headers to identify files for guided detection. This may take awhile.\n')

% get file type list
fTypes = sp_io_getFileType(detFiles);

for m = 1:size(detFiles,1)
    thisXwav = detFiles{m};   
    fileHead = sp_io_readXWAVHeader(thisXwav,p,'fType',fTypes(m));
    startFile(m,1) = fileHead.start.dnum;
    endFile(m,1) = fileHead.end.dnum;
end
fprintf('Done reading audio file headers.\n')

detXwavIdxAll= zeros(size(startFile)); % holder for names of files to process

%take each detection, check which xwav files are associated with the detection
for iM = 1:size(matlabDates,1)   %%%%%%%% problems with this logic.
    % find which xwav file(s) correspond(s) with manual detection start 
    thisBoutStart = matlabDates(iM,1);
    thisBoutEnd = matlabDates(iM,2);

    % find files that have data in this bout:
    % case 1: file starts before bout start and ends after bout start
    case1 = find(startFile <= thisBoutStart & endFile >= thisBoutStart);
    
    % case 2: file starts before bout end and ends after bout end
    case2 = find(startFile <= thisBoutEnd & endFile >= thisBoutEnd);
    
    % case 3: file starts after bout start and ends before bout end
    case3 =  find(startFile >= thisBoutStart & endFile <= thisBoutEnd);
    
    % case 4: file starts before bout start and ends after bout end
    case4 =  find(startFile <= thisBoutStart & endFile >= thisBoutEnd);
    
    detXwavIdx = unique([case1;case2;case3;case4]);
    
    if isempty(detXwavIdx)
        fprintf('No Recordings during defined detection time period #%d \n', iM);
    else 
        fprintf('Found %0.0f files matching detection time period #%d \n',...
            size(detXwavIdx,1), iM);
        detXwavIdxAll(detXwavIdx) = 1;
    end
end

xwavNames = detFiles(detXwavIdxAll==1);