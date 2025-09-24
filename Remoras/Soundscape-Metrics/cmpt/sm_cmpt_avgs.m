function sm_cmpt_avgs(fidx,n)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sm_cmpt_avgs.m
%
% compute averages based on time average bins generated in sm_cmpt_timeinc.m
% and input header matrix generated in sm_cmpt_setup.m
% fidx - File number relative to all LTSA files in folder
% n - File number relative to start number within files (different to 
%     fidx if start ~1)
%
% 1) check whether LTSA spectral average should be kept 
%   (REMORA.sm.cmpt.header col 3)
% 2) pull out idx of averages to be computed from time stamp 
%   (REMORA.sm.cmpt.header col 1) based on time bin of new average
%   (REMORA.sm.cmpt.avgbins)
% 3) check if number of averages are acceptable based on user input
%    (REMORA.sm.cmpt.perc)
% 4) compute metrics based on user input - bb, ol, tol, psd (mean, median, 
%    prctile); check for band edges (lfreq, hfreq) and frequency binning
%    (avgf)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS REMORA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% handle sepctral averages remaining from previous LTSA file
if n == 1
    % set up variables for computation if this is the first LTSA to be run
    REMORA.sm.cmpt.pre.rembins = []; % time bins from previous LTSA to be computed
    REMORA.sm.cmpt.pre.ltsaavgs = []; % spectral averages from previous LTSA
    REMORA.sm.cmpt.pre.timeavgs = []; % start time of spectral averages from previous LTSA
end

%% find which time bins to be computed fall within this LTSA
starttime = REMORA.sm.cmpt.header(1,1);
endtime = REMORA.sm.cmpt.header(end,1) + datenum([0 0 0 0 0 PARAMS.ltsa.tave]);

%-----------------------------------------------------------------------------
% CMS testing if code breaks:
my_time = REMORA.sm.cmpt.avgbins;
actual_dates = datetime(my_time,'ConvertFrom','datenum');
actual_start = datetime(starttime,'ConvertFrom','datenum');
actual_end = datetime(endtime,'ConvertFrom','datenum');

% if header has end times at 0:
if endtime == datenum([0 0 0 0 0 PARAMS.ltsa.tave]); % meaning the endtime was 0
disp('End time needed adjustments, going to the last nonzero end time.')
new_endtime_idx = find(REMORA.sm.cmpt.header(:,1)>0,1,'last'); % get the index of the last nonzero time
endtime = REMORA.sm.cmpt.header(new_endtime_idx,1) + datenum([0 0 0 0 0 PARAMS.ltsa.tave]); % make this the new endtime with the added buffer
end

% if our ltsa time is less than our time bin:
actual_end = datetime(endtime,'ConvertFrom','datenum'); % to override an end time of zero 
time_dur = actual_end-actual_start;
time_dur_sec = seconds(time_dur);
avgt = REMORA.sm.cmpt.avgt;
if time_dur_sec < avgt
    actual_start % displays the start and end times
    actual_end
    disp('LTSA time less than average bin.')
end
% %-----------------------------------------------------------------------------

thisavgbins = find(my_time>=starttime & ...
    my_time<=endtime);
%%%%%%% check next line logic!!!!!
if thisavgbins(1) ~= 1
    thisavgbins = [thisavgbins(1)-1; thisavgbins]; % move to one index prior to include starttime
end
REMORA.sm.cmpt.pre.thisltsa = length(thisavgbins);

% pull together bins for this ltsa and those remaining from last ltsa
REMORA.sm.cmpt.pre.rembins = [REMORA.sm.cmpt.avgbins(thisavgbins,:); ...
    REMORA.sm.cmpt.pre.rembins];

% preallocate toc
timebintoc = zeros(REMORA.sm.cmpt.pre.thisltsa,1);

% start counter for display
count = 0;
seg = 0;
seg0 = 0;
pnum = 0;
%% cycle through time bins
for tidx = 1:REMORA.sm.cmpt.pre.thisltsa
    timebintic = tic;
    %define start and end of current time bin to be averaged
    thisstart = REMORA.sm.cmpt.pre.rembins(tidx);
    thisend = thisstart + datenum([0 0 0 0 0 REMORA.sm.cmpt.avgt]);
    
    % find which header start times fall within this new average time
    hidx = find(REMORA.sm.cmpt.header(:,1)>=thisstart & ...
        REMORA.sm.cmpt.header(:,1)<thisend);

    % find if some of those may need to be removed 
    remidx = find(REMORA.sm.cmpt.header(hidx,3)==0);
    hidx(remidx) = [];

    % check if NOT last LTSA && at the end of an LTSA && contains averages;
    % if the full time bin (thisend) is not available then mark to store
    if fidx ~= length(REMORA.sm.cmpt.FileList) && ...
            tidx == REMORA.sm.cmpt.pre.thisltsa && ~isempty(hidx) && thisend > endtime
        last_avg = 1;
    else
        last_avg = 0;
    end

    % identify if coverage over time period is sufficient for average to be
    % computed || or last_avg is marked
    if (length(hidx) + length(REMORA.sm.cmpt.pre.timeavgs))...
            >= REMORA.sm.cmpt.avgt*REMORA.sm.cmpt.perc || last_avg == 1

        % pre-allocate for this average
        ltsaavgs = ones(length(hidx),PARAMS.ltsa.nf)*NaN;
        % pull out times
        timeavgs = REMORA.sm.cmpt.header(hidx,1);

        % read in LTSA time averages
        fid = fopen(fullfile(PARAMS.ltsa.inpath,PARAMS.ltsa.infile),'r');
        for h = 1:length(hidx)
            skip = REMORA.sm.cmpt.header(hidx(h),2);
            fseek(fid,skip,'bof');

            % CMS debugging: 2/26/24 UPDATE - error doesn't happen when all
            % of this code I used to check it is commented out...but may be skipping the last time average session of all ltsas?
%             check_ltsaavg = fread(fid,[PARAMS.ltsa.nf,1],'single');
%             check_size=length(check_ltsaavg);
% %             dbstop in sm_cmpt_avgs.m at 131 if check_size~=1001
% 
%             % read data into File power
% 
%             % CMS edits, trying to debug breaking at the last time session
%             if h==length(hidx)
%                 ltsaavgs(h,:) = fread(fid,[PARAMS.ltsa.nf,1],'single')';
%             elseif h==1:length(hidx)-1
            ltsaavgs(h,:) = fread(fid,[PARAMS.ltsa.nf,1],'single');
%             end

        end
        fclose (fid);
        
        if tidx == 1
            % add to potential averages from previous LTSA if this is first
            % average of this LTSA
            ltsaavgs = [REMORA.sm.cmpt.pre.ltsaavgs;ltsaavgs]; 
            % add to potential time stamps from previous LTSA
            timeavgs = [REMORA.sm.cmpt.pre.timeavgs;timeavgs];
            
            REMORA.sm.cmpt.pre.ltsaavgs = [];
            REMORA.sm.cmpt.pre.timeavgs = [];
        end
        
        if last_avg == 1
            % remove time bins computed within this LTSA; retain last time
            % bin for next LTSA together with original averages and times
            REMORA.sm.cmpt.pre.rembins(1:REMORA.sm.cmpt.pre.thisltsa-1) = []; % all time bins remaining to be computed
            REMORA.sm.cmpt.pre.ltsaavgs = ltsaavgs; % spectral averages from LTSA
            REMORA.sm.cmpt.pre.timeavgs = timeavgs; % start times from  LTSA
        else
            
            % crop at upper band edge
            [~,poslow] = min(abs(PARAMS.ltsa.freq-REMORA.sm.cmpt.lfreq));
            [~,poshigh] = min(abs(PARAMS.ltsa.freq-REMORA.sm.cmpt.hfreq));
            REMORA.sm.cmpt.pre.psd = ltsaavgs(:,1:poshigh);

            %% adjust psd for transfer function or single value calibration here
            if REMORA.sm.cmpt.cal
                sm_cmpt_calib
            end

            %% prepare matrices for calculations
            % convert to power for band level summation and averaging
            REMORA.sm.cmpt.pre.pwr = 10.^(REMORA.sm.cmpt.pre.psd/10);

            % if bb, sum up band power
            if REMORA.sm.cmpt.bb
                bb=[];
                % lower frequency edge
                bb = sum(REMORA.sm.cmpt.pre.pwr(:,poslow:end),2);
            end

            % if tol, sum up tol band power
            if REMORA.sm.cmpt.tol
                tol = [];
                for a = 1:size(REMORA.sm.cmpt.TOLbound,1)
                    tol(:,a) = sum(REMORA.sm.cmpt.pre.pwr(:,...
                        (REMORA.sm.cmpt.TOLbound(a,1):REMORA.sm.cmpt.TOLbound(a,2))),2);
                end
            end

            % if ol, sum up ol band power
            if REMORA.sm.cmpt.ol
                ol=[];
                for a = 1:size(REMORA.sm.cmpt.OLbound,1)
                    ol(:,a) = sum(REMORA.sm.cmpt.pre.pwr(:,...
                        (REMORA.sm.cmpt.OLbound(a,1):REMORA.sm.cmpt.OLbound(a,2))),2);
                end
            end
    %!!!!!!!!!!!!!!!!!!!!!!!!!!! TO TEST FOR LTSA        
            % if frequency average for psd is not 1 Hz bin, change freq binning
            if REMORA.sm.cmpt.avgf ~= 1
                vec = 0:REMORA.sm.cmpt.avgf:size(REMORA.sm.cmpt.pre.pwr,2);
                pwr = ones(size(REMORA.sm.cmpt.pre.pwr,1),length(vec)-1)*NaN;
                for a = 1:length(vec)-1
                    pwr(:,a) = mean(REMORA.sm.cmpt.pre.pwr(:,...
                        (vec(a)+1:vec(a+1))),2);
                end
                % replace 1 Hz power with reduced frequency bin width power
                REMORA.sm.cmpt.pre.pwr = pwr;
                % replace psd
                REMORA.sm.cmpt.pre.psd = 10*log10(REMORA.sm.cmpt.pre.pwr);
                % adjust for bin width
                %!!!!!!!!!!!!!!!!!! TO DO
            end
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!



            %% if 'mean' is selected
            if REMORA.sm.cmpt.mean

                % if power spectral density selected
                if REMORA.sm.cmpt.psd
                    % arithmetic mean
                    REMORA.sm.cmpt.pre.meanpsd = 10*log10(nanmean(REMORA.sm.cmpt.pre.pwr));
                    REMORA.sm.cmpt.pre.logmeanpsd = nanmean(REMORA.sm.cmpt.pre.psd);

                    if REMORA.sm.cmpt.avgf == 1
                        % if a csv output is to be written; crop at lower frequency edge
                        if REMORA.sm.cmpt.csvout
                            % arithmetic mean
                            REMORA.sm.cmpt.pre.meanpsd_csv = ...
                                REMORA.sm.cmpt.pre.meanpsd(poslow:end);
                            %logarithmic mean
                            REMORA.sm.cmpt.pre.logmeanpsd_csv = ...
                                REMORA.sm.cmpt.pre.logmeanpsd(poslow:end);
                        end
                    end
                end

                % if broadband levels selected
                if REMORA.sm.cmpt.bb
                   REMORA.sm.cmpt.pre.meanbb = 10*log10(nanmean(bb));               
                end

                % if octave levels selected
                if REMORA.sm.cmpt.ol
                   REMORA.sm.cmpt.pre.meanol = 10*log10(nanmean(ol));
                   % adjust for octave level rounding based on 1 Hz increments
                   REMORA.sm.cmpt.pre.meanol = REMORA.sm.cmpt.pre.meanol + ...
                       REMORA.sm.cmpt.OLcorr.';
                end

                % if 1/3 octave levels selected
                if REMORA.sm.cmpt.tol
                   REMORA.sm.cmpt.pre.meantol = 10*log10(nanmean(tol));
                   % adjust for octave level rounding based on 1 Hz increments
                   REMORA.sm.cmpt.pre.meantol = REMORA.sm.cmpt.pre.meantol + ...
                       REMORA.sm.cmpt.TOLcorr.';
                end
            end

            %% if 'median' or 'percentile' is selected
            if REMORA.sm.cmpt.median || REMORA.sm.cmpt.prctile
                p = [1, 5, 10, 25, 50, 75, 90, 95, 99];

                % if power spectral density selected
                if REMORA.sm.cmpt.psd
                    % compute percentiles
                    if REMORA.sm.cmpt.avgt>1
                        REMORA.sm.cmpt.pre.prcpsd = 10*log10(prctile(REMORA.sm.cmpt.pre.pwr,p));
                        if REMORA.sm.cmpt.avgf == 1
                            % crop to lower band edge
                            REMORA.sm.cmpt.pre.prcpsd = REMORA.sm.cmpt.pre.prcpsd(:,poslow:end);
                        end
                    else
                        REMORA.sm.cmpt.pre.prcpsd = ones(length(p),size(REMORA.sm.cmpt.pre.pwr,2))*NaN;
                        REMORA.sm.cmpt.pre.prcpsd(5,:) = 10*log10(REMORA.sm.cmpt.pre.pwr);
                        if REMORA.sm.cmpt.avgf == 1
                            % crop to lower band edge
                            REMORA.sm.cmpt.pre.prcpsd = REMORA.sm.cmpt.pre.prcpsd(:,poslow:end);
                        end
                    end
                end

                % if broadband levels selected
                if REMORA.sm.cmpt.bb
                    % compute percentiles
                    REMORA.sm.cmpt.pre.prcbb = 10*log10(prctile(bb,p));
                end

                % if octave levels selected
                if REMORA.sm.cmpt.ol
                   % compute percentiles
                    REMORA.sm.cmpt.pre.prcol = 10*log10(prctile(ol,p));
                end

                % if third octave levels selected
                if REMORA.sm.cmpt.tol
                    % compute percentiles
                    REMORA.sm.cmpt.pre.prctol = 10*log10(prctile(tol,p));
                end
            end
            % write to output files
            sm_cmpt_writeout(tidx)
            
            timebintoc(tidx) = toc(timebintic);
            
            % display progress
            if REMORA.sm.cmpt.avgt>=3600 %display every hour, otherwise reduce output
                disp(['Time average ',num2str(tidx),'/',num2str(REMORA.sm.cmpt.pre.thisltsa),...
                     ' computed; ',datestr(thisstart),' - ',datestr(thisend+dateoffset),'; duration ',num2str(timebintoc(tidx)),' s'])
            else %display progress every hour
                count = count+REMORA.sm.cmpt.avgt;
                seg = seg + 1;
                
                if count >=3600
                    pnum = pnum + 1;
                    timehtoc(pnum) = toc(timebintic);
                    disp(['Time average ',num2str(tidx),'/',num2str(REMORA.sm.cmpt.pre.thisltsa),...
                        ' computed; ',datestr(thisend+dateoffset),'; duration ',...
                        num2str(timehtoc(pnum)),' s; ', num2str(seg),' segments'])
                    count = 0;
                    seg = 0;
                end
            end
        end
    else
        if REMORA.sm.cmpt.avgt>=3600 %display every hour, otherwise reduce output
            perc = (length(hidx) + length(REMORA.sm.cmpt.pre.timeavgs))/...
                REMORA.sm.cmpt.avgt;
            % display progress

            disp(['Time average ',num2str(tidx),'/',num2str(REMORA.sm.cmpt.pre.thisltsa),...
                    ' NOT computed; ',datestr(thisstart),' - ',datestr(thisend),'; duration ',num2str(timebintoc(tidx)),' s'])
            disp(['Not enough coverage: ',num2str(perc*100),'%; '])
        else %display progress every hour
            count = count+REMORA.sm.cmpt.avgt;
            seg0 = seg0 + 1;
            if count >=3600
                pnum = pnum + 1;
                disp(['Time averages NOT computed since last print: ',num2str(seg),' segments; ',...
                    datestr(thisend+dateoffset),'; ',num2str(tidx),'/',num2str(REMORA.sm.cmpt.pre.thisltsa)])
                count = 0;
            end
        end
    end
    
    % if the last time average was calculated and no remaining data
    if tidx == REMORA.sm.cmpt.pre.thisltsa && last_avg == 0
        % set up variables for computation
        REMORA.sm.cmpt.pre.rembins = []; % all time bins remaining to be computed
        REMORA.sm.cmpt.pre.ltsaavgs = []; % spectral averages from previous LTSA
        REMORA.sm.cmpt.pre.timeavgs = []; % start time of spectral averages from previous LTSA
    end
    
end
1;

