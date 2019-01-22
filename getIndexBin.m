function [rawIndex,tBin] = getIndexBin(cx)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% getIndexBin.m
%
% Gets the index and time of the raw file
% 
% Parameters:
%       cx - time in user units (time [hr])
% Return:
%       rawIndex - the index of the raw file
%       tBin - the time the raw file starts
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global PARAMS 
% size of time bins in [hr]
tbinsz = PARAMS.ltsa.tave / (60*60);
% time vector time bin of cursor pick
% need to move time vector over 1/2 bin because of 'image plot'
tvector = PARAMS.ltsa.t +  0.5* tbinsz;
% find which time bin the cursor(cx) is in
cursorBin = [];
cursorBin = find( (tvector - cx) <= tbinsz & ...
    (tvector - cx) >= 0);
% take only one, just in case more than one were found...
if ~isempty(cursorBin)
    cursorBin = cursorBin(1);
else
    cursorBin = 1;
end

% index of raw file that starts plot
rawIndex = PARAMS.ltsa.plotStartRawIndex;

% number of bins before next raw file
deltaBin = PARAMS.ltsa.nave(rawIndex) - PARAMS.ltsa.plotStartBin + 1;
% find time bin and raw file of cursor
if deltaBin >= cursorBin
    % First set of bins.  Special case as we may have not plotted 
    % the initial bins of this group.
    tBin = PARAMS.ltsa.plotStartBin + cursorBin  - 1;
else
    tBin = cursorBin - deltaBin;  % Remove bins we're moving past
    rawIndex = rawIndex + 1;
    % find which raw file cursorBin is in
    while tBin > PARAMS.ltsa.nave(rawIndex)
        tBin = tBin - PARAMS.ltsa.nave(rawIndex);
        rawIndex = rawIndex + 1;
        if rawIndex > PARAMS.ltsa.nrftot
            rawIndex = PARAMS.ltsa.nrftot;
            tBin = PARAMS.ltsa.nave(rawIndex);
            break
        end
    end
end