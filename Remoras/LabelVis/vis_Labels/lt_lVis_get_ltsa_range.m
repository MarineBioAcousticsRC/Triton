function [starts,stops,dvStart,dvStop] = lt_lVis_get_ltsa_range

global PARAMS

ltsaBinWidth = PARAMS.ltsa.tave/(60*60*24); %get LTSA bin width in days
dnumId = 1;

for iInd = [1,size(PARAMS.ltsa.t,2)]
    [rawInd,rawT] = getIndexBin(PARAMS.ltsa.t(iInd));
    %removing a half in line below because bin time is calculated at center
    %of bin, and we want start of bin. Taken from ship detector
    dNums(dnumId) = PARAMS.ltsa.dnumStart(rawInd) + datenum([0 0 rawT*ltsaBinWidth - ltsaBinWidth/2]);
    dnumId = dnumId + 1;
end

starts = dNums(1);
stops = dNums(2) + ltsaBinWidth; %need to add a bin width to the last start value to get the actual stop value

dvStart = datevec(starts);
dvStop = datevec(stops);
