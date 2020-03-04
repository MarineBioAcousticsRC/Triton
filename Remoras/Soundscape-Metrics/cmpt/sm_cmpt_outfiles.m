function sm_cmpt_outfiles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sm_cmpt_outfiles.m
% 
% initialize output files dependent on user choices
% bb, ol, tol, psd (mean, median, prctile)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global REMORA 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% define file name components

% project, site, deployment ID based on LTSA file name
fileid = REMORA.sm.cmpt.FileList{1}(1:end-8);

% time stamp & band edges to create header info
timestamp = 'yyyy-mm-ddTHH:MM:SSZ';
psdHeaderInc = REMORA.sm.cmpt.lfreq:REMORA.sm.cmpt.avgf:REMORA.sm.cmpt.hfreq;

% time average suffix for file name - either s, min or h
if REMORA.sm.cmpt.avgt>59 && REMORA.sm.cmpt.avgt < 3600
    % convert to minutes
    avgt = REMORA.sm.cmpt.avgt/60;
    suffix = [num2str(avgt),'min'];
    
elseif REMORA.sm.cmpt.avgt>3599
    %convert to hours
    avgt = REMORA.sm.cmpt.avgt/3600;
    suffix = [num2str(avgt),'h'];
    
else
    %leave as seconds
    avgt = REMORA.sm.cmpt.avgt;
    suffix = [num2str(avgt),'s'];
end


%% if 'mean' is selected
if REMORA.sm.cmpt.mean
    % if power spectral density selected
    if REMORA.sm.cmpt.psd
        % output in csv (later to be added ltsa format)
        REMORA.sm.cmpt.out.meanpsd = [fileid,'_PSD_mean_',suffix,'.csv'];
        REMORA.sm.cmpt.out.meanltsa = [fileid,'_PSD_mean_',suffix,'.ltsa'];
        
        % header
        n = 1; % increments +1 per loops
        header = [timestamp,', '];
        for f = 1:length(psdHeaderInc)     
            header = [header 'PSD_',num2str(psdHeaderInc(f)),', '];
            n = n + 1;
        end
        % remove last ', ' in header
        header = header(1:end-2);
        
        %open file and write header
        REMORA.sm.cmpt.fid.psd = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.meanpsd),'w');
        fprintf(REMORA.sm.cmpt.fid.psd,'%s \n',header);
    end
    
    % if broadband levels selected
    if REMORA.sm.cmpt.bb
        % output in csv
        REMORA.sm.cmpt.out.meanbb = [fileid,'_BB_mean_',suffix,'.csv'];
        
        % header
        header = [timestamp,', ',['BB_',num2str(REMORA.sm.cmpt.lfreq),'-',num2str(REMORA.sm.cmpt.hfreq)]];
       
        %open file and write header
        REMORA.sm.cmpt.fid.bb = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.meanbb),'w');
        fprintf(REMORA.sm.cmpt.fid.bb,'%s \n',header);
    end
    
    % if octave levels selected
    if REMORA.sm.cmpt.ol
        % output in csv
        REMORA.sm.cmpt.out.meanol = [fileid,'_OL_mean_',suffix,'.csv'];
        
        % header
        n = 1; % increments +1 per loops
        header = [timestamp,', '];
        for f = 1 : length(REMORA.sm.cmpt.OLnfreq)    
            header = [header 'OL_',num2str(REMORA.sm.cmpt.OLnfreq(f)),', '];
            n = n + 1;
        end
        % remove last ', ' in header
        header = header(1:end-2);
        
        %open file and write header
        REMORA.sm.cmpt.fid.ol = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.meanol),'w');
        fprintf(REMORA.sm.cmpt.fid.ol,'%s \n',header);
    end
    
    % if third octave levels selected
    if REMORA.sm.cmpt.tol
        % output in csv
        REMORA.sm.cmpt.out.meantol = [fileid,'_TOL_mean_',suffix,'.csv'];
        
        % header
        n = 1; % increments +1 per loops
        header = [timestamp,', '];
        for f = 1 : length(REMORA.sm.cmpt.TOLnfreq)    
            header = [header 'TOL_',num2str(REMORA.sm.cmpt.TOLnfreq(f)),', '];
            n = n + 1;
        end
        % remove last ', ' in header
        header = header(1:end-2);
        
        %open file and write header
        REMORA.sm.cmpt.fid.tol = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.meantol),'w');
        fprintf(REMORA.sm.cmpt.fid.tol,'%s \n',header);
    end
end

%% if 'median' is selected
if REMORA.sm.cmpt.median || REMORA.sm.cmpt.prctile
    % if power spectral density selected
    if REMORA.sm.cmpt.psd
        % output in csv (later to be added ltsa format)
        REMORA.sm.cmpt.out.psd_pct50 = [fileid,'_PSD_',suffix,'.csv'];
        
        % header
        n = 1; % increments +1 per loops
        header = [timestamp,', '];
         for f = 1:length(psdHeaderInc)     
            header = [header 'PSD_',num2str(psdHeaderInc(f)),', '];
            n = n + 1;
        end
        % remove last ', ' in header
        header = header(1:end-2);
        
        %open file and write header
        REMORA.sm.cmpt.fid.psd_pct50 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.psd_pct50),'w');
        fprintf(REMORA.sm.cmpt.fid.psd_pct50,'%s \n',header);
    end
    
    % if broadband levels selected
    if REMORA.sm.cmpt.bb
        % output in csv
        REMORA.sm.cmpt.out.bb_pct50 = [fileid,'_BB_',suffix,'.csv'];
        
        % header
        header = [timestamp,', ',['BB_',num2str(REMORA.sm.cmpt.lfreq),'-',num2str(REMORA.sm.cmpt.hfreq)]];
       
        %open file and write header
        REMORA.sm.cmpt.fid.bb_pct50 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.bb_pct50),'w');
        fprintf(REMORA.sm.cmpt.fid.bb_pct50,'%s \n',header);
    end
    
    % if octave levels selected
    if REMORA.sm.cmpt.ol
        % output in csv
        REMORA.sm.cmpt.out.ol_pct50 = [fileid,'_OL_',suffix,'.csv'];
        
        % header
        n = 1; % increments +1 per loops
        header = [timestamp,', '];
        for f = 1 : length(REMORA.sm.cmpt.OLnfreq)    
            header = [header 'OL_',num2str(REMORA.sm.cmpt.OLnfreq(f)),', '];
            n = n + 1;
        end
        % remove last ', ' in header
        header = header(1:end-2);
        
        %open file and write header
        REMORA.sm.cmpt.fid.ol_pct50 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.ol_pct50),'w');
        fprintf(REMORA.sm.cmpt.fid.ol_pct50,'%s \n',header);
    end
    
    % if third octave levels selected
    if REMORA.sm.cmpt.tol
        % output in csv
        REMORA.sm.cmpt.out.tol_pct50 = [fileid,'_TOL_',suffix,'.csv'];
        
        % header
        n = 1; % increments +1 per loops
        header = [timestamp,', '];
        for f = 1 : length(REMORA.sm.cmpt.TOLnfreq)    
            header = [header 'TOL_',num2str(REMORA.sm.cmpt.TOLnfreq(f)),', '];
            n = n + 1;
        end
        % remove last ', ' in header
        header = header(1:end-2);
        
        %open file and write header
        REMORA.sm.cmpt.fid.tol_pct50 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.tol_pct50),'w');
        fprintf(REMORA.sm.cmpt.fid.tol_pct50,'%s \n',header);
    end
end

%% if 'percentile' is selected
if REMORA.sm.cmpt.prctile
    % if power spectral density selected
    if REMORA.sm.cmpt.psd
        % output in csv
        REMORA.sm.cmpt.out.psd_pct01 = [fileid,'_PSD_pct01_',suffix,'.csv'];
        REMORA.sm.cmpt.out.psd_pct05 = [fileid,'_PSD_pct05_',suffix,'.csv'];
        REMORA.sm.cmpt.out.psd_pct10 = [fileid,'_PSD_pct10_',suffix,'.csv'];
        REMORA.sm.cmpt.out.psd_pct25 = [fileid,'_PSD_pct25_',suffix,'.csv'];
        REMORA.sm.cmpt.out.psd_pct75 = [fileid,'_PSD_pct75_',suffix,'.csv'];
        REMORA.sm.cmpt.out.psd_pct90 = [fileid,'_PSD_pct90_',suffix,'.csv'];
        REMORA.sm.cmpt.out.psd_pct95 = [fileid,'_PSD_pct95_',suffix,'.csv'];
        REMORA.sm.cmpt.out.psd_pct99 = [fileid,'_PSD_pct99_',suffix,'.csv'];
        
        % header
        n = 1; % increments +1 per loops
        header = [timestamp,', '];
        for f = 1:length(psdHeaderInc)     
            header = [header 'PSD_',num2str(psdHeaderInc(f)),', '];
            n = n + 1;
        end
        % remove last ', ' in header
        header = header(1:end-2);
        
        %open file and write header
        REMORA.sm.cmpt.fid.psd_pct01 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.psd_pct01),'w');
        fprintf(REMORA.sm.cmpt.fid.psd_pct01,'%s \n',header);
        
        REMORA.sm.cmpt.fid.psd_pct05 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.psd_pct05),'w');
        fprintf(REMORA.sm.cmpt.fid.psd_pct05,'%s \n',header);
        
        REMORA.sm.cmpt.fid.psd_pct10 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.psd_pct10),'w');
        fprintf(REMORA.sm.cmpt.fid.psd_pct10,'%s \n',header);
        
        REMORA.sm.cmpt.fid.psd_pct25 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.psd_pct25),'w');
        fprintf(REMORA.sm.cmpt.fid.psd_pct25,'%s \n',header);
        
        REMORA.sm.cmpt.fid.psd_pct75 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.psd_pct75),'w');
        fprintf(REMORA.sm.cmpt.fid.psd_pct75,'%s \n',header);
        
        REMORA.sm.cmpt.fid.psd_pct90 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.psd_pct90),'w');
        fprintf(REMORA.sm.cmpt.fid.psd_pct90,'%s \n',header);
        
        REMORA.sm.cmpt.fid.psd_pct95 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.psd_pct95),'w');
        fprintf(REMORA.sm.cmpt.fid.psd_pct95,'%s \n',header);
        
        REMORA.sm.cmpt.fid.psd_pct99 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.psd_pct99),'w');
        fprintf(REMORA.sm.cmpt.fid.psd_pct99,'%s \n',header);
    end
    
    % if broadband levels selected
    if REMORA.sm.cmpt.bb
        % output in csv
        REMORA.sm.cmpt.out.bb_pct01 = [fileid,'_BB_pct01_',suffix,'.csv'];
        REMORA.sm.cmpt.out.bb_pct05 = [fileid,'_BB_pct05_',suffix,'.csv'];
        REMORA.sm.cmpt.out.bb_pct10 = [fileid,'_BB_pct10_',suffix,'.csv'];
        REMORA.sm.cmpt.out.bb_pct25 = [fileid,'_BB_pct25_',suffix,'.csv'];
        REMORA.sm.cmpt.out.bb_pct75 = [fileid,'_BB_pct75_',suffix,'.csv'];
        REMORA.sm.cmpt.out.bb_pct90 = [fileid,'_BB_pct90_',suffix,'.csv'];
        REMORA.sm.cmpt.out.bb_pct95 = [fileid,'_BB_pct95_',suffix,'.csv'];
        REMORA.sm.cmpt.out.bb_pct99 = [fileid,'_BB_pct99_',suffix,'.csv'];
        
        % header
        header = [timestamp,', ',['BB_',num2str(REMORA.sm.cmpt.lfreq),'-',num2str(REMORA.sm.cmpt.hfreq)]];
       
        %open file and write header
        REMORA.sm.cmpt.fid.bb_pct01 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.bb_pct01),'w');
        fprintf(REMORA.sm.cmpt.fid.bb_pct01,'%s \n',header);
        
        REMORA.sm.cmpt.fid.bb_pct05 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.bb_pct05),'w');
        fprintf(REMORA.sm.cmpt.fid.bb_pct05,'%s \n',header);
        
        REMORA.sm.cmpt.fid.bb_pct10 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.bb_pct10),'w');
        fprintf(REMORA.sm.cmpt.fid.bb_pct10,'%s \n',header);
        
        REMORA.sm.cmpt.fid.bb_pct25 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.bb_pct25),'w');
        fprintf(REMORA.sm.cmpt.fid.bb_pct25,'%s \n',header);
        
        REMORA.sm.cmpt.fid.bb_pct75 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.bb_pct75),'w');
        fprintf(REMORA.sm.cmpt.fid.bb_pct75,'%s \n',header);
        
        REMORA.sm.cmpt.fid.bb_pct90 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.bb_pct90),'w');
        fprintf(REMORA.sm.cmpt.fid.bb_pct90,'%s \n',header);
        
        REMORA.sm.cmpt.fid.bb_pct95 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.bb_pct95),'w');
        fprintf(REMORA.sm.cmpt.fid.bb_pct95,'%s \n',header);
        
        REMORA.sm.cmpt.fid.bb_pct99 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.bb_pct99),'w');
        fprintf(REMORA.sm.cmpt.fid.bb_pct99,'%s \n',header);
    end
    
    % if octave levels selected
    if REMORA.sm.cmpt.ol
        % output in csv
        REMORA.sm.cmpt.out.ol_pct01 = [fileid,'_OL_pct01_',suffix,'.csv'];
        REMORA.sm.cmpt.out.ol_pct05 = [fileid,'_OL_pct05_',suffix,'.csv'];
        REMORA.sm.cmpt.out.ol_pct10 = [fileid,'_OL_pct10_',suffix,'.csv'];
        REMORA.sm.cmpt.out.ol_pct25 = [fileid,'_OL_pct25_',suffix,'.csv'];
        REMORA.sm.cmpt.out.ol_pct75 = [fileid,'_OL_pct75_',suffix,'.csv'];
        REMORA.sm.cmpt.out.ol_pct90 = [fileid,'_OL_pct90_',suffix,'.csv'];
        REMORA.sm.cmpt.out.ol_pct95 = [fileid,'_OL_pct95_',suffix,'.csv'];
        REMORA.sm.cmpt.out.ol_pct99 = [fileid,'_OL_pct99_',suffix,'.csv'];
        
        % header
        n = 1; % increments +1 per loops
        header = [timestamp,', '];
        for f = 1 : length(REMORA.sm.cmpt.OLnfreq)    
            header = [header 'OL_',num2str(REMORA.sm.cmpt.OLnfreq(f)),', '];
            n = n + 1;
        end
        % remove last ', ' in header
        header = header(1:end-2);
        
        %open file and write header
        REMORA.sm.cmpt.fid.ol_pct01 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.ol_pct01),'w');
        fprintf(REMORA.sm.cmpt.fid.ol_pct01,'%s \n',header);
        
        REMORA.sm.cmpt.fid.ol_pct05 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.ol_pct05),'w');
        fprintf(REMORA.sm.cmpt.fid.ol_pct05,'%s \n',header);
        
        REMORA.sm.cmpt.fid.ol_pct10 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.ol_pct10),'w');
        fprintf(REMORA.sm.cmpt.fid.ol_pct10,'%s \n',header);
        
        REMORA.sm.cmpt.fid.ol_pct25 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.ol_pct25),'w');
        fprintf(REMORA.sm.cmpt.fid.ol_pct25,'%s \n',header);
        
        REMORA.sm.cmpt.fid.ol_pct75 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.ol_pct75),'w');
        fprintf(REMORA.sm.cmpt.fid.ol_pct75,'%s \n',header);
        
        REMORA.sm.cmpt.fid.ol_pct90 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.ol_pct90),'w');
        fprintf(REMORA.sm.cmpt.fid.ol_pct90,'%s \n',header);
        
        REMORA.sm.cmpt.fid.ol_pct95 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.ol_pct95),'w');
        fprintf(REMORA.sm.cmpt.fid.ol_pct95,'%s \n',header);
        
        REMORA.sm.cmpt.fid.ol_pct99 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.ol_pct99),'w');
        fprintf(REMORA.sm.cmpt.fid.ol_pct99,'%s \n',header);
    end
    
    % if third octave levels selected
    if REMORA.sm.cmpt.tol
        % output in csv
        REMORA.sm.cmpt.out.tol_pct01 = [fileid,'_TOL_pct01_',suffix,'.csv'];
        REMORA.sm.cmpt.out.tol_pct05 = [fileid,'_TOL_pct05_',suffix,'.csv'];
        REMORA.sm.cmpt.out.tol_pct10 = [fileid,'_TOL_pct10_',suffix,'.csv'];
        REMORA.sm.cmpt.out.tol_pct25 = [fileid,'_TOL_pct25_',suffix,'.csv'];
        REMORA.sm.cmpt.out.tol_pct75 = [fileid,'_TOL_pct75_',suffix,'.csv'];
        REMORA.sm.cmpt.out.tol_pct90 = [fileid,'_TOL_pct90_',suffix,'.csv'];
        REMORA.sm.cmpt.out.tol_pct95 = [fileid,'_TOL_pct95_',suffix,'.csv'];
        REMORA.sm.cmpt.out.tol_pct99 = [fileid,'_TOL_pct99_',suffix,'.csv'];
        
        % header
        n = 1; % increments +1 per loops
        header = [timestamp,', '];
        for f = 1 : length(REMORA.sm.cmpt.TOLnfreq)    
            header = [header 'TOL_',num2str(REMORA.sm.cmpt.TOLnfreq(f)),', '];
            n = n + 1;
        end
        % remove last ', ' in header
        header = header(1:end-2);
        
        %open file and write header
       REMORA.sm.cmpt.fid.tol_pct01 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.tol_pct01),'w');
        fprintf(REMORA.sm.cmpt.fid.tol_pct01,'%s \n',header);
        
        REMORA.sm.cmpt.fid.tol_pct05 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.tol_pct05),'w');
        fprintf(REMORA.sm.cmpt.fid.tol_pct05,'%s \n',header);
        
        REMORA.sm.cmpt.fid.tol_pct10 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.tol_pct10),'w');
        fprintf(REMORA.sm.cmpt.fid.tol_pct10,'%s \n',header);
        
        REMORA.sm.cmpt.fid.tol_pct25 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.tol_pct25),'w');
        fprintf(REMORA.sm.cmpt.fid.tol_pct25,'%s \n',header);
        
        REMORA.sm.cmpt.fid.tol_pct75 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.tol_pct75),'w');
        fprintf(REMORA.sm.cmpt.fid.tol_pct75,'%s \n',header);
        
        REMORA.sm.cmpt.fid.tol_pct90 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.tol_pct90),'w');
        fprintf(REMORA.sm.cmpt.fid.tol_pct90,'%s \n',header);
        
        REMORA.sm.cmpt.fid.tol_pct95 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.tol_pct95),'w');
        fprintf(REMORA.sm.cmpt.fid.tol_pct95,'%s \n',header);
        
        REMORA.sm.cmpt.fid.tol_pct99 = ...
            fopen(fullfile(REMORA.sm.cmpt.outdir,REMORA.sm.cmpt.out.tol_pct99),'w');
        fprintf(REMORA.sm.cmpt.fid.tol_pct99,'%s \n',header);
    end
    
end
