function dnumSnippet = sh_read_time_window(startIndex,startBin)
% read start time of next window
global REMORA

% number of time bins to step forward
tbin = REMORA.sh.settings.slide / REMORA.sh.ltsa.tave;

% forward motion case (add backward option for interactive detector)
% difference in time bins between the current plotStartBin location and
% the end of the current plotStartRawIndex
d1_tbin = REMORA.sh.ltsa.nave(startIndex)- startBin;
% count the number of time bins by looping over the full raw files
% increment plotStartRawIndex & plotStartBin
if tbin > d1_tbin
    cbin = d1_tbin;
    % counter for RawIndex
    cindex = startIndex + 1;
    if cindex <= length(REMORA.sh.ltsa.nave)
        % sum bins over raw file indices
        while cbin + REMORA.sh.ltsa.nave(cindex) < tbin - d1_tbin
            cbin = cbin + REMORA.sh.ltsa.nave(cindex);
            cindex = cindex + 1;
        end
        % difference in time bins between new plotStartBin and the
        % new plotStartRawIndex
        d2_tbin = tbin - cbin;
    else
        cindex = startIndex;
        d2_tbin = startBin + tbin;
    end
else
    cindex = startIndex;
    d2_tbin = startBin + tbin;
end
% number of time bins until end of file
%
ebin = -d2_tbin;
% sum over the remaining rawfiles/Indices
for k = cindex:REMORA.sh.ltsa.nrftot
    ebin = ebin + REMORA.sh.ltsa.nave(k);
end
% plotStartBin too late to show whole plot
% recalculate
if ebin < tbin
    % difference in time bins between the number of tbins to plot and
    % the number from plotStartBin to the end of the file
    dbin = tbin-ebin;
    while dbin > d2_tbin
        dbin = dbin - REMORA.sh.ltsa.nave(cindex);
        cindex = cindex - 1;
    end
    d2_tbin = d2_tbin - dbin;
end

startBin = d2_tbin;
startIndex = cindex;

dnumSnippet = REMORA.sh.ltsa.dnumStart(startIndex)+ ...
    (startBin * REMORA.sh.ltsa.tave) / (60 * 60 * 24);






