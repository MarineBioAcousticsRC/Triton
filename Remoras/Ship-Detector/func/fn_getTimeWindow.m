function dnumSnippet = fn_getTimeWindow(startIndex,startBin)

global REMORA

% number of time bins to step forward
tbin = REMORA.ship_dt.settings.durWind / REMORA.ship_dt.ltsa.tave;

% forward motion case (add backward option for interactive detector)
% difference in time bins between the current plotStartBin location and
% the end of the current plotStartRawIndex
d1_tbin = REMORA.ship_dt.ltsa.nave(startIndex)...
    - startBin;
% count the number of time bins by looping over the full raw files
% increment plotStartRawIndex & plotStartBin
if tbin > d1_tbin
    cbin = d1_tbin;
    % counter for RawIndex
    cindex = startIndex + 1;
    % sum bins over raw file indices
    while cbin + REMORA.ship_dt.ltsa.nave(cindex) < tbin - d1_tbin
        cbin = cbin + REMORA.ship_dt.ltsa.nave(cindex);
        cindex = cindex + 1;
    end
    % difference in time bins between new plotStartBin and the
    % new plotStartRawIndex
    d2_tbin = tbin - cbin;
else
    cindex = startIndex;
    d2_tbin = startBin + tbin;
end
% number of time bins until end of file
%
ebin = -d2_tbin;
% sum over the remaining rawfiles/Indices
for k = cindex:REMORA.ship_dt.ltsa.nrftot
    ebin = ebin + REMORA.ship_dt.ltsa.nave(k);
end
% plotStartBin too late to show whole plot
% recalculate
if ebin < tbin
    % difference in time bins between the number of tbins to plot and
    % the number from plotStartBin to the end of the file
    dbin = tbin-ebin;
    while dbin > d2_tbin
        dbin = dbin - REMORA.ship_dt.ltsa.nave(cindex);
        cindex = cindex - 1;
    end
    d2_tbin = d2_tbin - dbin;
end

startBin = d2_tbin;
startIndex = cindex;

dnumSnippet = REMORA.ship_dt.ltsa.dnumStart(startIndex)+ ...
    (startBin * REMORA.ship_dt.ltsa.tave) / (60 * 60 * 24);






