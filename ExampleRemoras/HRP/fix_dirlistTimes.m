function fix_dirlistTimes(dflag)
%
% fix_dirlistTimes.m
%
% useage: >>fix_dirlistTimes(dflag)
%   dflag = display flag, on = 1
%
% based on mod_xwavhdrTime.m 091125 smw
%
%
% 100528 smw
global PARAMS

% check to see if PARAMS.xhd and PARAMS.head exist
if ~isfield(PARAMS,'head')
    disp('Error : PARAMS.head undefined')
    return
end

% expected time difference
if PARAMS.head.samplerate == 200000
    dt = 75;  % single channel 200 kHz
elseif PARAMS.head.samplerate == 100000 && PARAMS.nch == 4
    dt = 35.960;   % 4 channel @ 100 kHz/chan 
elseif PARAMS.head.samplerate == 2000
    dt = 7500;
else
    disp_msg('Not yet supported')
    return
end

% loop while current raw file time is later than next
% loop takes care of two or more sequential bad (buffer wrap around) raw file times
% algorithm works from the the last bad raw file time forward in a group of
% bad raw file dirlist times.
I = 1;  % intit loop
c = 0;
while ~isempty(I)
    % raw file start times in days
    y = datenum([PARAMS.head.dirlist(:,2) PARAMS.head.dirlist(:,3)...
        PARAMS.head.dirlist(:,4) PARAMS.head.dirlist(:,5) PARAMS.head.dirlist(:,6) ...
        PARAMS.head.dirlist(:,7)+(PARAMS.head.dirlist(:,8)/1000)]);
    % differenced time in seconds
    dy = 24*60*60*diff(y);
    %  find current raw files times later than next raw file and modify to
    %  correct times
    I = [];
    I = find( dy < 0);
    Ilen = length(I);
    if ~isempty(I)
        if dflag
            disp(' ')
            disp([num2str(Ilen),' Raw File Times Later than Next'])
            disp(' ')
            dm = [I,datevec(y(I)),dy(I)];  
            disp(num2str(dm))
        end
        
        % calculat modified times
        % only good if one bad time, doesn't work for two or more sequential
        % bad times...
        y(I) = y(I+1) - datenum([0 0 0 0 0 dt]);
        % put in date vector
        ydv = datevec(y);
        % get mseconds from decimal seconds
        ydv(:,7) = floor(1000*(ydv(:,6) - floor(ydv(:,6))));
        ydv(:,6) = floor(ydv(:,6));
        % could fix ticks if greater than 999, but ripple effect to sec,
        % min,hr....
        
        % modify dirlist times
        PARAMS.head.dirlist(I,2:8) = ydv(I,1:7);
        
    else
        if dflag
            disp('No Current Raw File Times Later than Next')
        end
    end
    c = c + 1;
end
if dflag
    disp(['Greatest number of sequential bad raw file dirlist times: ',num2str(c-2)])
end

