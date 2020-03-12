function sm_split_ltsa
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sm_split_ltsa.m
%
% divide files based on user input lenght of LTSA
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global PARAMS 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read file start times
dnumStart = PARAMS.ltsahd.dnumStart;
% convert number of samples per file to duration in minutes
if PARAMS.ltsa.ftype == 1       % do the following for wav files
    nMinFiles = PARAMS.ltsahd.nsamp/PARAMS.ltsahd.sample_rate(1)/60; 
else %and this for x.wav files
    % minutes per raw file over all x.wav files
    nMinRawFiles = PARAMS.ltsahd.byte_length/(PARAMS.ltsahd.sample_rate(1)/2)/4/60;
    % minutes per x.wav file
    nMinFiles = PARAMS.ltsahd.nsamp/PARAMS.ltsahd.sample_rate(1)/60;
end
% length of LTSA
nMinLTSAInc = PARAMS.ltsa.ndays*24*60;

%setup file idex based on sum of file durations equalling length of LTSA
% in days specified by user input
f = 1; %file number
ltsaIdx = [1 NaN]; %start and end file number for each to be calculated LTSA
while f < length(nMinFiles)
    %check if first LTSA index end entry exists; 
    %if so then start next LTSA start index
    if ~isnan(ltsaIdx(1,2))
        ltsaIdx(size(ltsaIdx,1)+1,1) = f;
    end
    
    %add up file durations until they reach max minutes per LTSA
    dur = 0;
    while dur <= nMinLTSAInc - nMinFiles(f) && f <length(nMinFiles)
        dur = dur + nMinFiles(f);
        f = f+1;
    end
    
    %note LTSA index end entry
    ltsaIdx(size(ltsaIdx,1),2) = f-1;
end

%modify last entry end to last file idx
ltsaIdx(size(ltsaIdx,1),2) = length(nMinFiles);
PARAMS.ltsa.ltsaIdx = ltsaIdx;

if PARAMS.ltsa.ftype ~= 1       % do the following for x.wav files only
    %setup file index based on sum of raw file durations equalling length of LTSA
    % in days specified by user input
    ltsaRawIdx = []; %start and end file number for each to be calculated LTSA
    
    for idx = 1:size(ltsaIdx,1)
        rawIdx = find(PARAMS.ltsahd.fnum>=ltsaIdx(idx,1) & ...
            PARAMS.ltsahd.fnum<=ltsaIdx(idx,2));
        ltsaRawIdx(idx,1) = rawIdx(1);
        ltsaRawIdx(idx,2) = rawIdx(end);
    end
    PARAMS.ltsahd.ltsaRawIdx = ltsaRawIdx;
end
1;