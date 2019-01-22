function check_time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% check_time.m
%
% Check time of start of plot based on PARAMS.plot.dvec time
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global PARAMS HANDLES

%PARAMS.plot.dnum = datenum(PARAMS.plot.dvec); don't do this, it resets
%where it is set other places. Left in until next full release
PARAMS.start.dnum = datenum(PARAMS.start.dvec);
if ~isempty(PARAMS.xhd.byte_length)
    PARAMS.plot.bytelength = PARAMS.plot.initbytel;
end
%
% check if Display start time is before or after begin or end of data file, respectively
% datevec(PARAMS.plot.dnum)
dtime = PARAMS.plot.dnum - PARAMS.start.dnum;
dtime2 = PARAMS.end.dnum - (PARAMS.plot.dnum + datenum([0 0 0 0 0 PARAMS.tseg.sec]));
if dtime < 0
    disp_msg('Error: too early -> Plot start time is before the start of the data file')
    disp_msg('Error: Go back to previous time')
    %     disp(' ')
    %     PARAMS.plot.dnum = PARAMS.start.dnum;
    PARAMS.plot.dnum = PARAMS.save.dnum;
    dtime = 0;
    dtime2 = PARAMS.end.dnum - (PARAMS.plot.dnum + datenum([0 0 0 0 0 PARAMS.tseg.sec]));
    set([HANDLES.motion.seekbof HANDLES.motion.back HANDLES.motion.autoback HANDLES.motion.stop],'Enable','off');
    set([HANDLES.motion.seekeof HANDLES.motion.fwd HANDLES.motion.autofwd HANDLES.motion.nextfile HANDLES.motion.prevfile],'Enable','on');
    set(HANDLES.motion.stop,'Userdata',-1);
elseif dtime2 < 0
    disp_msg('Error: too late -> Plot start time is after the end of the data file')
    disp_msg('Error: Go back to previous time')
    %     PARAMS.plot.dnum = PARAMS.end.dnum - datenum([0 0 0 0 0 PARAMS.tseg.sec]);
    PARAMS.plot.dnum = PARAMS.save.dnum;
    if( PARAMS.plot.dnum < PARAMS.start.dnum )
        disp_msg('Error: Plot time segement too big');
        disp_msg('Error: Goto Beginning of File & Make time segment 1 second')
        %         disp(' ')
        PARAMS.plot.dnum = PARAMS.start.dnum;
        PARAMS.tseg.sec = 1;
    end
    dtime2 = 0;
    dtime = PARAMS.plot.dnum - PARAMS.start.dnum;
    set([HANDLES.motion.seekeof HANDLES.motion.fwd HANDLES.motion.autofwd HANDLES.motion.stop],'Enable','off');
    set([HANDLES.motion.seekbof HANDLES.motion.back HANDLES.motion.autoback HANDLES.motion.nextfile HANDLES.motion.prevfile],'Enable','on');
    set(HANDLES.motion.stop,'Userdata',-1);
end
%
% Check to see which RawFile the Plot Pointer (PARAMS.plot.dnum) is located
% Conditions:
% 1) Plot Pointer is between RawFile Start i and End i, and all is good
% 2) Plot Pointer is NOT between any RawFile Start/End pair:
% 2a) Plot Pointer is between RawEnd i and RawStart i+1.  Gap time between
% RawFile writes
% 2b) Plot Pointer is past last RawEnd time - wrong sample rate?
% 3) More than one Plot Pointer. This happens with RawEnd i is AFTER
% RawStart i+1. (Eg. the sample rate is less than actual and puts
% calculation of RawEnd after the next RawStart)
%
PARAMS.raw.currentIndex = [];
PARAMS.raw.currentIndex = find(PARAMS.plot.dnum - PARAMS.raw.dnumStart > ...
    - datenum([0 0 0 0 0 1/PARAMS.fs]) & PARAMS.plot.dnum < PARAMS.raw.dnumEnd);

% check if only one index, more than one or none:
% Condition 1) only one index, then all good
if ~isempty(PARAMS.raw.currentIndex) && length(PARAMS.raw.currentIndex) == 1
    %    disp(num2str(PARAMS.raw.currentIndex))
    % Condition 2)
elseif isempty(PARAMS.raw.currentIndex)
    %    disp('Plot pointer not between RawFile Start/End times')
    % shift values down to compare end of i and start i+1 ie gap between
    nextStart = PARAMS.raw.dnumStart(2:PARAMS.xhd.NumOfRawFiles);
    previousEnd = PARAMS.raw.dnumEnd(1:PARAMS.xhd.NumOfRawFiles-1);
    currentIndex = find(PARAMS.plot.dnum >= previousEnd ...
        & PARAMS.plot.dnum < nextStart);
    % Condition 2a)
    if ~isempty(currentIndex) && length(currentIndex) == 1
        %       disp(['I.e., gap after RawFile ',num2str(currentIndex),' and next'])
        if PARAMS.plot.dnum > PARAMS.save.dnum      % goto next RawFile
            PARAMS.raw.currentIndex = currentIndex + 1;
            PARAMS.plot.dnum = PARAMS.raw.dnumStart(PARAMS.raw.currentIndex);
            PARAMS.plot.dvec = PARAMS.raw.dvecStart(PARAMS.raw.currentIndex,:);
        else                                        % goto previous RawFile
            PARAMS.raw.currentIndex = currentIndex;
            PARAMS.plot.dnum = PARAMS.raw.dnumEnd(PARAMS.raw.currentIndex)...
                - datenum([0 0 0 0 0 (PARAMS.tseg.sec - 1/PARAMS.fs) ]);
            PARAMS.plot.dvec = PARAMS.raw.dvecEnd(PARAMS.raw.currentIndex,:)...
                - [0 0 0 0 0 (PARAMS.tseg.sec - 1/PARAMS.fs)];
        end
        %         disp(['Plot start time between RawFiles ',num2str(currentIndex),...
        %             ' and ',num2str(currentIndex + 1)])
    end
    %
    if PARAMS.plot.dnum > PARAMS.raw.dnumEnd(PARAMS.xhd.NumOfRawFiles)
        disp_msg('Plot Pointer past end of last RawFile time ')
        disp_msg(['Plot Pointer : ',num2str(datevec(PARAMS.plot.dnum))])
        disp_msg(['End of last RawFile : ',num2str(datevec(PARAMS.raw.dnumEnd(PARAMS.xhd.NumOfRawFiles)))])
        disp_msg(['Sample rate may be incorrect? ', num2str(PARAMS.fs)])
    end
    % Condition 3) if length(PARAMS.raw.currentIndex) == 2 then RawEnd i is
    % AFTER RawStart i+1 may be because sample rate is wrong or header times are off ...
elseif length(PARAMS.raw.currentIndex) > 1
    disp_msg(['Plot pointer is in more than one RawFile ',num2str(PARAMS.raw.currentIndex)])
    %disp_msg(['Sample rate may be incorrect? ', num2str(PARAMS.fs)])
    for k = 1: length(PARAMS.raw.currentIndex)
        disp_msg(['Header time ',num2str(k),' : ',timestr(PARAMS.raw.dnumStart(PARAMS.raw.currentIndex(k)),1)])
    end
end

%
% change dtime from days to seconds (get rid of rounding error)
%
dtime = (round ( 1e6 *( dtime * 24 * 60 * 60))) / 1e6;
dtime2 = (round ( 1e6 * (dtime2 * 24 * 60 * 60))) / 1e6;

%
% turn motion buttons on and off
%
if get(HANDLES.motion.stop,'Userdata') == -1
    if PARAMS.tseg.step == -1
        if dtime < PARAMS.tseg.sec
            set([HANDLES.motion.back HANDLES.motion.autoback],'Enable','off');
        elseif dtime >= PARAMS.tseg.sec
            set([HANDLES.motion.seekbof HANDLES.motion.back HANDLES.motion.autoback],'Enable','on');
        end
        if dtime2 < PARAMS.tseg.sec
            set([HANDLES.motion.fwd HANDLES.motion.autofwd],'Enable','off');
        elseif dtime2 >= PARAMS.tseg.sec
            set([HANDLES.motion.seekeof HANDLES.motion.fwd HANDLES.motion.autofwd],'Enable','on');
        end
    else
        if dtime < PARAMS.tseg.step
            set([HANDLES.motion.back HANDLES.motion.autoback],'Enable','off');
        elseif dtime >= PARAMS.tseg.step
            set([HANDLES.motion.seekbof HANDLES.motion.back HANDLES.motion.autoback],'Enable','on');
        end
        if dtime2 < PARAMS.tseg.step
            set([HANDLES.motion.fwd HANDLES.motion.autofwd],'Enable','off');
        elseif dtime2 >= PARAMS.tseg.step
            set([HANDLES.motion.seekeof HANDLES.motion.fwd HANDLES.motion.autofwd],'Enable','on');
        end
    end
    if dtime == 0
        set([HANDLES.motion.seekbof],'Enable','off');
    end
    if dtime2 == 0
        set([HANDLES.motion.seekeof],'Enable','off');
    end
end

