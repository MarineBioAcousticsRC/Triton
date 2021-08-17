function sm_cmpt_setup

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sm_cmpt_setup.m
% 
% initializes matrices and time vectors for averaging
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS REMORA 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% find number of raw files that went into the LTSA calculation and set up header matrix


fprintf('%s \n\t\t %s - %s\n', ...
    PARAMS.ltsa.infile, ...
    datestr(PARAMS.ltsa.dnumStart(1),'mm/dd/yy HH:MM'),...
    datestr(PARAMS.ltsa.dnumEnd(end),'mm/dd/yy HH:MM'));

% removal of disk write data in seconds
REMORA.sm.cmpt.remove = 15;

%% re-compute decimal date, some error due to rounding
PARAMS.ltsa.dnumStart = datenum(PARAMS.ltsa.dvecStart);
PARAMS.ltsa.dnumEnd = datenum(PARAMS.ltsa.dvecEnd);

%% compute header matrix based on time bins in LTSA from start to end of LTSA

% time of first average in LTSA
start_time = PARAMS.ltsa.dnumStart(1);
% duration of last file
timeLF = datenum([0 0 0 0 0 PARAMS.ltsa.nave(end)*PARAMS.ltsa.tave]);
% time of last average in LTSA
end_time = PARAMS.ltsa.dnumStart(end) + timeLF;
%continuous vector of timestamps in increments of LTSA averaging time
tvec = start_time:datenum([0 0 0 0 0 PARAMS.ltsa.tave]):end_time;

% col 1: start time of each average time bin
% col 2: byteloc in LTSA
% col 3: keep or discard time bin (e.g. missing value, disk write, strumming)     
REMORA.sm.cmpt.header = zeros(length(tvec),3)*NaN;
REMORA.sm.cmpt.header(:,1) = tvec;
REMORA.sm.cmpt.header(:,3) = 0;

%fill in byte location within LTSA for each raw file
for ridx = 1:PARAMS.ltsa.nrftot
    % find index in header matrix based on time stamp of raw file
    % look for closest value - cannot do == due to rounding errors in datenum
    [~, minPos] = min(abs(REMORA.sm.cmpt.header(:,1)-PARAMS.ltsa.dnumStart(ridx)));
    % compute vector of byte locations for each average * 4 bytes for
    % 'single' precision
    if PARAMS.ltsa.nave(ridx)>0
        bytevec = PARAMS.ltsa.byteloc(ridx):PARAMS.ltsa.nf*4:...
            (PARAMS.ltsa.byteloc(ridx)+PARAMS.ltsa.nf*(PARAMS.ltsa.nave(ridx)-1)*4);
        bytevec = bytevec.'; %transpose
        % keep or discard average; currently keep all, need to add logic for
        % erroneous data
        if REMORA.sm.cmpt.dw == 1 %do this for xwav files
            keep = ones(length(bytevec),1);
            % define how many time bins for disk write
            tbin = REMORA.sm.cmpt.remove/PARAMS.ltsa.dfreq;
            if tbin<length(keep)
                keep(1:tbin) = 0;
            else
                keep = zeros(length(bytevec),1);
            end
        else %do this for wav files
            keep = ones(length(bytevec),1);
        end
        % fill into position of header matrices
        REMORA.sm.cmpt.header(minPos:(minPos+length(bytevec)-1),2) = bytevec;
        REMORA.sm.cmpt.header(minPos:(minPos+length(bytevec)-1),3) = keep;
    end
end

%check for NaN in last row; would occur if partial second and hence not computed
if isnan(REMORA.sm.cmpt.header(end,2))
    REMORA.sm.cmpt.header(end,:) = [];
end





