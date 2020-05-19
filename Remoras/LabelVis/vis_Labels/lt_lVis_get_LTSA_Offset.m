function detXpos = lt_lVis_get_LTSA_Offset(inWindowDet,action)

global PARAMS
plotStart = PARAMS.ltsa.plotStartRawIndex;
rfDur = PARAMS.ltsa.dur(1); %assumes same duration of all rfs in LTSA

if strcmp(action,'starts')
    for iWin = 1:size(inWindowDet,1)
        winDetWavIdx{iWin} = find(PARAMS.ltsa.dnumStart<=inWindowDet(iWin,1)& inWindowDet(iWin,1)<=PARAMS.ltsa.dnumEnd);
        if size(winDetWavIdx{iWin},2)>1
            winDetWavIdx{iWin} = winDetWavIdx{iWin}(1);
            disp('WARNING! Detection start time found in two raw files')
        end
    end
    
    wDWIdx = [winDetWavIdx{:}];
    winDetWavs = PARAMS.ltsa.dnumStart(wDWIdx)';
    detstartOff = (wDWIdx - plotStart).*rfDur; %find offset of raw file from start of LTSA
    detWavOff = inWindowDet(:,1) - winDetWavs;
    detWavOffSec = lt_convertDatenum(detWavOff,'seconds');
    detXpos = (detstartOff' + detWavOffSec)./3600; %convert seconds back to hours
    
    
    
elseif strcmp(action,'stops')
    
    for iWin = 1:size(inWindowDet,1)
        winDetWavIdx{iWin} = find(PARAMS.ltsa.dnumStart<=inWindowDet(iWin,2)& inWindowDet(iWin,2)<=PARAMS.ltsa.dnumEnd);
       if size(winDetWavIdx{iWin},2)>1
            winDetWavIdx{iWin} = winDetWavIdx{iWin}(1);
            disp('WARNING! Detection end time found in two raw files!')
        end
    end
    
    wDWIdx = [winDetWavIdx{:}];
    winDetWavs = PARAMS.ltsa.dnumStart(wDWIdx)';
    detstartOff = (wDWIdx - plotStart).*rfDur; %find offset of raw file from start of LTSA
    detWavOff = inWindowDet(:,2) - winDetWavs;
    detWavOffSec = lt_convertDatenum(detWavOff,'seconds');
    detXpos = (detstartOff' + detWavOffSec)./3600; %convert seconds back to hours
    
else
    disp('WARNING! Action not registered. Available options are starts or stops')
end


