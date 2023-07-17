function sm_stepPlotTimeLTSA(direction)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sm_stepPlotTimeLTSA.m
%
% used to move the plot forward and backward by plot window size,
% not real-time.
%
% Parameter: 
%       direction - 'f' for forward, 'b' for backward
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS HANDLES
% disp_msg('Under Construction')

% number of time bins to step forward (same as was plotted previously)
tbin = floor((PARAMS.ltsa.tseg.hr * 60 *60 ) / PARAMS.ltsa.tave);

% forward motion case
if strcmp(direction,'f')
    % difference in time bins between the current plotStartBin location and
    % the end of the current plotStartRawIndex
    d1_tbin = PARAMS.ltsa.nave(PARAMS.ltsa.plotStartRawIndex) - PARAMS.ltsa.plotStartBin;
    % count the number of time bins by looping over the full raw files
    % increment plotStartRawIndex & plotStartBin
    if tbin > d1_tbin
        cbin = d1_tbin;
        % counter for RawIndex
        cindex = PARAMS.ltsa.plotStartRawIndex + 1;
        % sum bins over raw file indices
        while cbin + PARAMS.ltsa.nave(cindex) < tbin - d1_tbin
            cbin = cbin + PARAMS.ltsa.nave(cindex);
            cindex = cindex + 1;
        end
        % difference in time bins between new plotStartBin and the
        % new plotStartRawIndex
        d2_tbin = tbin - cbin;
    else
        cindex = PARAMS.ltsa.plotStartRawIndex;
        d2_tbin = PARAMS.ltsa.plotStartBin + tbin;
    end
    % number of time bins until end of file
    %
    ebin = -d2_tbin;
    % sum over the remaining rawfiles/Indices
    for k = cindex:PARAMS.ltsa.nrftot
        ebin = ebin + PARAMS.ltsa.nave(k);
    end
    % plotStartBin too late to show whole plot
    % recalculate
    if ebin < tbin
        % difference in time bins between the number of tbins to plot and
        % the number from plotStartBin to the end of the file
        dbin = tbin-ebin;
        while dbin > d2_tbin
            dbin = dbin - PARAMS.ltsa.nave(cindex);
            cindex = cindex - 1;
        end
        d2_tbin = d2_tbin - dbin;
    end
    % backward motion case
elseif strcmp(direction,'b')
    d1_tbin = PARAMS.ltsa.plotStartBin;
    if tbin > PARAMS.ltsa.plotStartBin & PARAMS.ltsa.plotStartRawIndex > 1
        cbin = d1_tbin;
        cindex = PARAMS.ltsa.plotStartRawIndex - 1;
        % sum bins over raw files / indices
        while cbin + PARAMS.ltsa.nave(cindex) < tbin - PARAMS.ltsa.plotStartBin
            cbin = cbin + PARAMS.ltsa.nave(cindex);
            cindex = cindex - 1;
            if cindex == 0
                cindex = 1;
                break
            end
        end
        d2_tbin = PARAMS.ltsa.nave(cindex) - (tbin - cbin);
    else
        cindex = PARAMS.ltsa.plotStartRawIndex;
        d2_tbin = PARAMS.ltsa.plotStartBin - tbin;
    end
else
    disp_msg('Wrong format for stepPlotTimeLTSA')
    disp_msg('Argument should be ''f'' or ''b''' )
    return
end

PARAMS.ltsa.plotStartBin = d2_tbin;
PARAMS.ltsa.plotStartRawIndex = cindex;

PARAMS.ltsa.plot.dnum = PARAMS.ltsa.dnumStart(PARAMS.ltsa.plotStartRawIndex)+ ...
    (PARAMS.ltsa.plotStartBin * PARAMS.ltsa.tave) / (60 * 60 * 24);

