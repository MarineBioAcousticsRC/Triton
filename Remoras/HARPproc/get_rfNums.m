function [ndir, numXWAVs, rawFileNums] = get_rfNums(infile, dfs, rf_end, rf_start, rf_skip)

global PARAMS REMORA

% calculate the number of raw files from dirlist 
% if the hrp file is truncated or otherwise missing data
% BJT: if hrp image is not the expected size there should be some attention
% grabbing user output
hrp_size = dir(infile);
hrp_size = hrp_size.bytes;

% some var initialization
% rf_skip = REMORA.hrp.rf_skip;
% ndir = 0; % number of rfs in this hrp

if hrp_size < 512 * PARAMS.head.dirlist(end, 1)
    fprintf('HRP file smaller than anticipated...\n');
    ndir = 0;
    for i = 1:length(PARAMS.head.dirlist) % Todo: replace with find?
        if 512*PARAMS.head.dirlist(i, 1) < hrp_size
            ndir = ndir + 1;
        else
            break
        end
    end
else
    ndir = PARAMS.head.nextFile;
end

% desired filesize for all generated files
filesize = 1.5*1024^3; 

% if boundaries don't make sense change them
if rf_end > ndir || rf_end == 0
    rf_end = ndir;
end

% number of rfs to be processed
nrf = rf_end-rf_start-length(find(rf_skip>=rf_start & rf_skip<=rf_end))+1; 

% loop through each decimation type and determine how many raw files can
% fit into each type of xwav
rawFileNums = zeros(1, length(dfs));
numXWAVs = zeros(1, length(dfs));

for i = 1:length(dfs)
    
    % if no decimation, just use 30 raw files/xwav
    if dfs(i) == 1
        if 30 > nrf
            rawFileNums(i) = nrf;
        else
            rawFileNums(i) = 30;
        end
        
    else
        % figure out how big each output file is going to be
        raw_rfNum = ceil((filesize * dfs(i)) ...
                       /(PARAMS.nsampPerSect * PARAMS.bitsPerSamp * ...
                       PARAMS.nsectPerRawFile));
                   
        % make each rf count divisible by 30 so xwav file endings
        % will sync up
%         rawFileNums(i) = raw_rfNum+(30-mod(raw_rfNum,30));
        rawFileNums(i) = raw_rfNum-mod(raw_rfNum,30);
                   
       % number of raw files for xwav exceeds the 
       % number of files on the disk
       if nrf < rawFileNums(i)
           rawFileNums(i) = nrf;
       end
    end
    
    % number of xwavs generated for each decimation factor
    numXWAVs(i) = nrf/rawFileNums(i);  
    numXWAVs(i) = ceil(numXWAVs(i));  % total number of XWAVs 
end
%ndir = ndir-1; % for files raw files that are segmented TODO 
end
                    
