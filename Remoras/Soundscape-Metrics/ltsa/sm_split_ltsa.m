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
nMinFiles = PARAMS.ltsahd.nsamp/PARAMS.ltsahd.sample_rate(1)/60;
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

PARAMS.ltsahd.ltsaIdx = ltsaIdx;