function difftime_dirlist(filename,dflag)
%3/11/2011
% useage >> difftime_dirlist(filename,d)
%       if dflag == 1, then display header values in command window
%       if dflag == 2, then also display all timing errors
%
% this function reads raw HARP file disk directory and compares times
% between directory entries...used for data quality checking.
%
% smw 061030 stolen from cktime_dirlist

global PARAMS

PARAMS.head.baddirlist = []; % empty it incase it has something left over

% cell array to hold each of the output messages
msgs = {};

% check to see if file exists - return if not
if ~exist(filename)
    disp_msg(sprintf('Error - no file %s', filename));
    return
end

% display flag: display values = 1
eflag = 0;
% if dflag == 1 || dflag == 2
%     read_rawHARPhead(filename,0)
%     disp_msg(' ');
%     disp_msg(sprintf('Disk # %d', PARAMS.head.disknumberSector2));
if dflag == 2
    eflag = 1; % eflag == 1 to show all timing errors
end
% end


% read HARP head
read_rawHARPhead(filename, dflag);

% read raw HARP dirlist
read_rawHARPdir(filename,0);

disp_msg(' ');
disp_msg(sprintf('Disk # %d', PARAMS.head.disknumberSector2));

%
if PARAMS.head.nextFile == 0
    if dflag
        disp_msg(sprintf('Empty Disk %d', PARAMS.head.disknumberSector2));
    end
    PARAMS.head.numTimingError = -9;
    return
elseif PARAMS.head.firstDirSector ~= 8
    if dflag
        disp_msg('Disk Header Corrupted');
        disp_msg(filename);
        disp_msg('Exit Evaluation');
    end
    PARAMS.head.numTimingError = -8;
    return
else
    % convert date time into datenumber (days since Jan 01, 0000) Note: year is
    % two digits.... ie 2005 is 05
    if ~strcmp(deblank(PARAMS.head.firmwareVersion),'1.14c')
        dnum_dirlist = datenum([PARAMS.head.dirlist(:,2:6) PARAMS.head.dirlist(:,7) + PARAMS.head.dirlist(:,8)/1000]);
    else    % don't use milliseconds with old data
        dnum_dirlist = datenum([PARAMS.head.dirlist(:,2:6) PARAMS.head.dirlist(:,7)]);
        L = [];
        L = find(PARAMS.head.dirlist(:,8) ~= 0);
        if ~isempty(L) && dflag
            disp_msg(sprintf('Number of files with non-zero millisecond values : %d', length(L)));
        end
    end
    
    % difference sequential directory listings
    ddnum = diff(dnum_dirlist);
    
    % convert to seconds and remove round off error
    difftime = round(ddnum*60*60*24*1000)./1000;
    
    % check for bad number of sectors recorded
    K = [];
    K = find(PARAMS.head.dirlist(:,10) > 60000);
    
    
    % remaining # bytes in file = # bytes in file -  # sectors / bytes/sector
    % should be zero if each file is an integer number of sectors
    if isempty(K)
        dbytes = PARAMS.head.dirlist(:,11) - PARAMS.head.dirlist(:,10) .* 512 ;
    else
        dbytes = PARAMS.head.dirlist(:,11) - 60000 * 512;
        if dflag
            disp_msg(sprintf('Number of files with bad number of sectors recorded : %d', length(K)));
        end
    end
    
    J = find(dbytes);
    if ~isempty(J) && dflag
        disp_msg('raw HARP files is not integer number of sectors');
        % disp_msg([PARAMS.head.dirlist(J,1)])
    end
    
    % DT[seconds/dirlist] = # sectors * # samples/sector / # samples/ second
    % 250 samples / sector (12 bytes (of the 512bytes/sector) are for timing
    % header
    if isempty(K)
        DT = (PARAMS.head.dirlist(:,10) .* 250 + dbytes) ./ PARAMS.head.dirlist(:,9);
    else
        DT = (60000 .* ones(length(PARAMS.head.dirlist(:,10)),1) .* 250 + dbytes) ./ PARAMS.head.dirlist(:,9);
        
    end
    
    
    % find times when the
    % difference between directory listing is not what it should be
    I = [];
    
    dtime1 = 0;
    dtime2 = 0;
    
    staus = ckFirmware;
    % sample rate check
    if PARAMS.rec.sr*1000 ~= PARAMS.head.samplerate
        disp(' ')
        disp('Warning !!! : hrp file sample rate is not the same as user input')
        disp(['hrpfile: PARAMS.head.samplerate = ',num2str(PARAMS.head.samplerate)])
        disp(['user input: PARAMS.rec.sr = ',num2str(PARAMS.rec.sr), (kHz)'])
        disp(' ')
    else
        %         disp('hrp file sample rate is the same as user input')
    end
    
    % dtime1 should be the duration in seconds of each raw file
    dtime1 = PARAMS.nsampPerRawFile / (PARAMS.nch * PARAMS.rec.sr * 1000);
    % dtime2 = dtime1 for continuous recordings

    dtime2 = dtime1;
    
    if PARAMS.rec.int == 0 && PARAMS.rec.dur == 0
        % continuous recording
    elseif PARAMS.rec.int ~= 0 && PARAMS.rec.dur ~= 0
        % duty cycle
        % dtime 2 = time between end of one and start of next duty-cycle section + 1 rf 
        dtime2 = 60 * (PARAMS.rec.int - PARAMS.rec.dur) + dtime1;
    else
        disp('Error: not continuous and not duty cycle??')
    end
    
%     disp(['rawfile duration = ', num2str(dtime1),' (s)'])
%     disp(['rawfile duty-cycle gap duration = ', num2str(dtime2),' (s)'])

    PARAMS.rec.dtime1 = dtime1;
    PARAMS.rec.dtime2 = dtime2;
    
    %% old way
    if 0
        % Old firmware: 1.14c - only integer seconds with times....
        if strcmp(deblank(PARAMS.head.firmwareVersion),'1.14c') & ...
                PARAMS.head.dirlist(1,9) == 80000
            dtime1 = 187;
            dtime2 = 188;
        else
            if PARAMS.rec.sr == 20
                dtime1 = 750;
                dtime2 = 750;
            elseif PARAMS.rec.sr == 32
                dtime1 = 468.75;
                dtime2 = 468.75;
            elseif PARAMS.rec.sr == 40
                dtime1 = 375;
                dtime2 = 375;
            elseif PARAMS.rec.sr == 50
                dtime1 = 300;
                dtime2 = 300;
            elseif PARAMS.rec.sr == 80      % 80,000 sample/sec
                dtime1 = 187.5;
                if PARAMS.rec.int == 0  % continuous
                    dtime2 = 187.5;
                elseif PARAMS.rec.int == 12 & PARAMS.rec.dur == 6   %
                    dtime2 = 532.5; % 60*(12-6) + 172.5
                elseif PARAMS.rec.int == 18 & PARAMS.rec.dur == 6  % OCNMS3&4
                    dtime2 = 892.5; % 60*(18-6) + 172.5
                elseif PARAMS.rec.int == 20 & PARAMS.rec.dur == 10 % GofCA2
                    dtime2 = 637.5; % 60*(20-10) + 37.5
                elseif PARAMS.rec.int == 30 & PARAMS.rec.dur == 10 % OCNMS2?
                    dtime2 = 1237.5; % 60*(30-10) + 37.5
                end
            elseif PARAMS.rec.sr == 100 && PARAMS.rec.nch == 4
                dtime1 = 35.960;        % 4 channel HARP
                dtime2 = dtime1;
            elseif PARAMS.rec.sr == 200
                dtime1 = 75;
                if PARAMS.rec.int == 0  % continuous
                    % use the following for continuous data:
                    %I = find(difftime ~= DT(2:length(DT)));
                    dtime2 = 75;
                elseif PARAMS.rec.int == 10 && PARAMS.rec.dur == 5 % SOCAL04A
                    dtime2 = 375; % 60*(10-5) + 75
                elseif PARAMS.rec.int == 15 & PARAMS.rec.dur == 5 % SOCAL02
                    dtime2 = 675; % 60*(15-5) + 75
                elseif PARAMS.rec.int == 20 & PARAMS.rec.dur == 5 % Palmyra1
                    dtime2 = 975; % 60*(20-5) + 75
                elseif PARAMS.rec.int == 20 & PARAMS.rec.dur == 10 % Cross1
                    dtime2 = 675; % 60*(20-10) + 75
                elseif PARAMS.rec.int == 25 & PARAMS.rec.dur == 5 % Cross2,GC3,GC5
                    dtime2 = 1275; % 60*(25-5) + 75
                elseif PARAMS.rec.int == 30 & PARAMS.rec.dur == 5 % GC4site7
                    dtime2 = 1575; % 60*(30-5) + 75
                elseif PARAMS.rec.int == 40 & PARAMS.rec.dur == 5 % GofCA1
                    dtime2 = 2175; % 60*(40-5) + 75
                end
            end
        end
    end
    
    
    %%
    if dtime1 == 0 || dtime2 == 0  % won't happen
        disp_msg(' ');
        disp_msg('SampleRate/Interval/Duration/NumChannels not yet supported');
        disp_msg(sprintf('SR = %d kHz', PARAMS.rec.sr));
        disp_msg(sprintf('Int = %0.2g min', PARAMS.rec.int));
        disp_msg(sprintf('Dur = %0.2g min', PARAMS.rec.dur));
        disp_msg(sprintf('NCH = %d channels', PARAMS.rec.nch));
        disp_msg('Enter new values or change code check_dirlist_times.m');
        toolpd('ck_dirlist_times')
    else
        I = find(difftime ~= dtime2 & difftime ~= dtime1);
    end
    
    
    % goal is to not tag sequential difftime for time that is ok
    % in otherwords, a bad difftime happens for a good time happens from
    % previous, sequential bad time.
    
    icount = 0;
    len = length(I);
    Ix=[];
    if len == 1 && I(1) == 1    % if the first time is bad
        Ix = 0;
    elseif len == 1 && I(1) == length(difftime) % if last one is bad
        Ix = I(1);
    elseif len == 2 && I(1) == I(2) - 1
        Ix = I(1);   % only first one is bad
    elseif len > 2
        Ix(1) = I(1);
        for k = 2: len-1
            if I(k) == I(k-1) + 1 && I(k+1) ~= I(k) + 1
                % don't use this I(k), it's ok...
            else
                icount = icount+1;
                Ix(icount) = I(k);
            end
        end
        if I(len) == I(len-1) + 1
            % don't use last one
        else
            icount = icount+1;
            Ix(icount) = I(len);
        end
    end
    % increase indices by 1
    Ix = Ix'+1;
    
    % more work is need on following:
    if Ix > 1
        PARAMS.head.baddirlist = [Ix difftime(Ix-1) PARAMS.head.dirlist(Ix,:)];
    elseif Ix == 1
        PARAMS.head.baddirlist = [Ix difftime(Ix) PARAMS.head.dirlist(Ix,:)];
    end
    
    PARAMS.head.numTimingError = length(Ix);
    
    if dflag
        disp_msg(sprintf('Number of directory list timing errors : %d', length(Ix)));
        disp_msg(sprintf('Number of raw files tested : %d', length(dnum_dirlist)));
        
        if eflag && ~isempty(Ix)
            % comment the next line if want summary without timing errors displayed
            if strcmp(PARAMS.head.firmwareVersion(1),'V')
                disp_msg(sprintf('%5d %12.3f %10d %2d %3d %3d %3d %3d %3d %7d %7d %12d %12d\n',PARAMS.head.baddirlist(:,1:13)'));
            elseif strcmp(PARAMS.head.firmwareVersion(1),'3') || ...
                   strcmp(PARAMS.head.firmwareVersion(1),'4') || ...
                   strcmp(PARAMS.head.firmwareVersion(1),'6')
                disp_msg(sprintf('%5d %12.3f %10d %2d %3d %3d %3d %3d %3d %7d %7d %12d %12d %7d\n',PARAMS.head.baddirlist(:,1:14)'));
            else
                disp(['Unknown firmware version : ', PARAMS.head.firmwareVersion])
            end
            % need to ck_firmware and use SATA.bool = 2 for SD and 14 column
            % dirlist  220916 smw
        end
        disp_msg(' ')
    end
end

end
