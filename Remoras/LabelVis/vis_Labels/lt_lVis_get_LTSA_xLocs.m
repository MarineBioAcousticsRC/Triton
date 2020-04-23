function lt_lVis_get_LTSA_xLocs(inWindowDet,action)

     for iWin = 1:size(inWindowDet,1)
        winDetWavs(iWin) = find(PARAMS.ltsa.dnumStart<=inWindowDet(iWin,1)& inWindowDet(iWin,1)<=PARAMS.ltsa.dnumEnd);
    end
    detstartOff = (winDetWavs - ltsaS).*PARAMS.ltsa.dur; %find offset of raw file from start of LTSA
    detWavOff = winDets(:,1) - PARAMS.ltsa.dnumStart(winDetWavs);
    detTotOff = detstartOff+detWavOff;
    


