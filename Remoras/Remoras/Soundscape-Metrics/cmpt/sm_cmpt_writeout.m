function sm_cmpt_writeout(tidx)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sm_cmpt_writeout.m
% 
% write to previously opened output files
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global REMORA 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%convert start time of current time average to ISO8601 date
thisstart = REMORA.sm.cmpt.pre.rembins(tidx) + datenum([2000 0 0 0 0 0]);
avg_date = dbSerialDateToISO8601(thisstart);

%% if 'mean' is selected
if REMORA.sm.cmpt.mean
    % if power spectral density selected
    if REMORA.sm.cmpt.psd
        % output in csv (later to be added ltsa);
        %write date
        fprintf(REMORA.sm.cmpt.fid.psd,'%s, ',avg_date);
        %write mean psd
        for a = 1:length(REMORA.sm.cmpt.pre.meanpsd)
            fprintf(REMORA.sm.cmpt.fid.psd,'%f',REMORA.sm.cmpt.pre.meanpsd(a));
            if a<length(REMORA.sm.cmpt.pre.meanpsd)
                fprintf(REMORA.sm.cmpt.fid.psd,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.psd,'\n');
    end
    
    % if broadband levels selected
    if REMORA.sm.cmpt.bb
        %write mean bb
        fprintf(REMORA.sm.cmpt.fid.bb,'%s, %f\n',avg_date,REMORA.sm.cmpt.pre.meanbb);
    end
    
    % if octave levels selected
    if REMORA.sm.cmpt.ol
        %write date
        fprintf(REMORA.sm.cmpt.fid.ol,'%s, ',avg_date);
        %write mean ol
        for a = 1:length(REMORA.sm.cmpt.pre.meanol)
            fprintf(REMORA.sm.cmpt.fid.ol,'%f',REMORA.sm.cmpt.pre.meanol(a));
            if a<length(REMORA.sm.cmpt.pre.meanol)
                fprintf(REMORA.sm.cmpt.fid.ol,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.ol,'\n');
    end
    
    % if third octave levels selected
    if REMORA.sm.cmpt.tol
       %write date
        fprintf(REMORA.sm.cmpt.fid.tol,'%s, ',avg_date);
        %write mean tol
        for a = 1:length(REMORA.sm.cmpt.pre.meantol)
            fprintf(REMORA.sm.cmpt.fid.tol,'%f',REMORA.sm.cmpt.pre.meantol(a));
            if a<length(REMORA.sm.cmpt.pre.meantol)
                fprintf(REMORA.sm.cmpt.fid.tol,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.tol,'\n');
    end
end

%% if 'median' is selected
if REMORA.sm.cmpt.median || REMORA.sm.cmpt.prctile
    % if power spectral density selected
    if REMORA.sm.cmpt.psd
        % output in csv (later to be added ltsa);
        %write date
        fprintf(REMORA.sm.cmpt.fid.psd_pct50,'%s, ',avg_date);
        %write median
        for a = 1:size(REMORA.sm.cmpt.pre.prcpsd,2)
            fprintf(REMORA.sm.cmpt.fid.psd_pct50,'%f',REMORA.sm.cmpt.pre.prcpsd(5,a));
            if a<size(REMORA.sm.cmpt.pre.prcpsd,2)
                fprintf(REMORA.sm.cmpt.fid.psd_pct50,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.psd_pct50,'\n');
    end
    
    % if broadband levels selected
    if REMORA.sm.cmpt.bb
        %write mean bb
        fprintf(REMORA.sm.cmpt.fid.bb_pct50,'%s, %f\n',avg_date,REMORA.sm.cmpt.pre.prcbb(5));
    end
    
    % if octave levels selected
    if REMORA.sm.cmpt.ol
        %write date
        fprintf(REMORA.sm.cmpt.fid.ol_pct50,'%s, ',avg_date);
        %write median
        for a = 1:size(REMORA.sm.cmpt.pre.prcol,2)
            fprintf(REMORA.sm.cmpt.fid.ol_pct50,'%f',REMORA.sm.cmpt.pre.prcol(5,a));
            if a<size(REMORA.sm.cmpt.pre.prcol,2)
                fprintf(REMORA.sm.cmpt.fid.ol_pct50,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.ol_pct50,'\n');
    end
    
    % if third octave levels selected
    if REMORA.sm.cmpt.tol
        %write date
        fprintf(REMORA.sm.cmpt.fid.tol_pct50,'%s, ',avg_date);
        %write median
        for a = 1:size(REMORA.sm.cmpt.pre.prctol,2)
            fprintf(REMORA.sm.cmpt.fid.tol_pct50,'%f',REMORA.sm.cmpt.pre.prctol(5,a));
            if a<size(REMORA.sm.cmpt.pre.prctol,2)
                fprintf(REMORA.sm.cmpt.fid.tol_pct50,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.tol_pct50,'\n');
    end
end

%% if 'percentile' is selected
if REMORA.sm.cmpt.prctile
    % if power spectral density selected
    if REMORA.sm.cmpt.psd
        %write 1%
        fprintf(REMORA.sm.cmpt.fid.psd_pct01,'%s, ',avg_date);
        for a = 1:size(REMORA.sm.cmpt.pre.prcpsd,2)
            fprintf(REMORA.sm.cmpt.fid.psd_pct01,'%f',REMORA.sm.cmpt.pre.prcpsd(1,a));
            if a<size(REMORA.sm.cmpt.pre.prcpsd,2)
                fprintf(REMORA.sm.cmpt.fid.psd_pct01,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.psd_pct01,'\n');
        
        %write 5%
        fprintf(REMORA.sm.cmpt.fid.psd_pct05,'%s, ',avg_date);
        for a = 1:size(REMORA.sm.cmpt.pre.prcpsd,2)
            fprintf(REMORA.sm.cmpt.fid.psd_pct05,'%f',REMORA.sm.cmpt.pre.prcpsd(2,a));
            if a<size(REMORA.sm.cmpt.pre.prcpsd,2)
                fprintf(REMORA.sm.cmpt.fid.psd_pct05,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.psd_pct05,'\n');
        
        %write 10%
        fprintf(REMORA.sm.cmpt.fid.psd_pct10,'%s, ',avg_date);
        for a = 1:size(REMORA.sm.cmpt.pre.prcpsd,2)
            fprintf(REMORA.sm.cmpt.fid.psd_pct10,'%f',REMORA.sm.cmpt.pre.prcpsd(3,a));
            if a<size(REMORA.sm.cmpt.pre.prcpsd,2)
                fprintf(REMORA.sm.cmpt.fid.psd_pct10,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.psd_pct10,'\n');
        
        %write 25%
        fprintf(REMORA.sm.cmpt.fid.psd_pct25,'%s, ',avg_date);
        for a = 1:size(REMORA.sm.cmpt.pre.prcpsd,2)
            fprintf(REMORA.sm.cmpt.fid.psd_pct25,'%f',REMORA.sm.cmpt.pre.prcpsd(4,a));
            if a<size(REMORA.sm.cmpt.pre.prcpsd,2)
                fprintf(REMORA.sm.cmpt.fid.psd_pct25,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.psd_pct25,'\n');
        
        %write 75%
        fprintf(REMORA.sm.cmpt.fid.psd_pct75,'%s, ',avg_date);
        for a = 1:size(REMORA.sm.cmpt.pre.prcpsd,2)
            fprintf(REMORA.sm.cmpt.fid.psd_pct75,'%f',REMORA.sm.cmpt.pre.prcpsd(6,a));
            if a<size(REMORA.sm.cmpt.pre.prcpsd,2)
                fprintf(REMORA.sm.cmpt.fid.psd_pct75,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.psd_pct75,'\n');
        
        %write 90%
        fprintf(REMORA.sm.cmpt.fid.psd_pct90,'%s, ',avg_date);
        for a = 1:size(REMORA.sm.cmpt.pre.prcpsd,2)
            fprintf(REMORA.sm.cmpt.fid.psd_pct90,'%f',REMORA.sm.cmpt.pre.prcpsd(7,a));
            if a<size(REMORA.sm.cmpt.pre.prcpsd,2)
                fprintf(REMORA.sm.cmpt.fid.psd_pct90,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.psd_pct90,'\n');
        
        %write 95%
        fprintf(REMORA.sm.cmpt.fid.psd_pct95,'%s, ',avg_date);
        for a = 1:size(REMORA.sm.cmpt.pre.prcpsd,2)
            fprintf(REMORA.sm.cmpt.fid.psd_pct95,'%f',REMORA.sm.cmpt.pre.prcpsd(8,a));
            if a<size(REMORA.sm.cmpt.pre.prcpsd,2)
                fprintf(REMORA.sm.cmpt.fid.psd_pct95,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.psd_pct95,'\n');
        
        %write 99%
        fprintf(REMORA.sm.cmpt.fid.psd_pct99,'%s, ',avg_date);
        for a = 1:size(REMORA.sm.cmpt.pre.prcpsd,2)
            fprintf(REMORA.sm.cmpt.fid.psd_pct99,'%f',REMORA.sm.cmpt.pre.prcpsd(9,a));
            if a<size(REMORA.sm.cmpt.pre.prcpsd,2)
                fprintf(REMORA.sm.cmpt.fid.psd_pct99,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.psd_pct99,'\n');
    end
    
    % if broadband levels selected
    if REMORA.sm.cmpt.bb
        fprintf(REMORA.sm.cmpt.fid.bb_pct01,'%s, %f\n',avg_date,REMORA.sm.cmpt.pre.prcbb(1));
        fprintf(REMORA.sm.cmpt.fid.bb_pct05,'%s, %f\n',avg_date,REMORA.sm.cmpt.pre.prcbb(2));
        fprintf(REMORA.sm.cmpt.fid.bb_pct10,'%s, %f\n',avg_date,REMORA.sm.cmpt.pre.prcbb(3));
        fprintf(REMORA.sm.cmpt.fid.bb_pct25,'%s, %f\n',avg_date,REMORA.sm.cmpt.pre.prcbb(4));
        fprintf(REMORA.sm.cmpt.fid.bb_pct75,'%s, %f\n',avg_date,REMORA.sm.cmpt.pre.prcbb(6));
        fprintf(REMORA.sm.cmpt.fid.bb_pct90,'%s, %f\n',avg_date,REMORA.sm.cmpt.pre.prcbb(7));
        fprintf(REMORA.sm.cmpt.fid.bb_pct95,'%s, %f\n',avg_date,REMORA.sm.cmpt.pre.prcbb(8));
        fprintf(REMORA.sm.cmpt.fid.bb_pct99,'%s, %f\n',avg_date,REMORA.sm.cmpt.pre.prcbb(9));
    end
    
    % if octave levels selected
    if REMORA.sm.cmpt.ol
        %write 1%
        fprintf(REMORA.sm.cmpt.fid.ol_pct01,'%s, ',avg_date);
        for a = 1:size(REMORA.sm.cmpt.pre.prcol,2)
            fprintf(REMORA.sm.cmpt.fid.ol_pct01,'%f',REMORA.sm.cmpt.pre.prcol(1,a));
            if a<size(REMORA.sm.cmpt.pre.prcol,2)
                fprintf(REMORA.sm.cmpt.fid.ol_pct01,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.ol_pct01,'\n');
        
        %write 5%
        fprintf(REMORA.sm.cmpt.fid.ol_pct05,'%s, ',avg_date);
        for a = 1:size(REMORA.sm.cmpt.pre.prcol,2)
            fprintf(REMORA.sm.cmpt.fid.ol_pct05,'%f',REMORA.sm.cmpt.pre.prcol(2,a));
            if a<size(REMORA.sm.cmpt.pre.prcol,2)
                fprintf(REMORA.sm.cmpt.fid.ol_pct05,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.ol_pct05,'\n');
        
        %write 10%
        fprintf(REMORA.sm.cmpt.fid.ol_pct10,'%s, ',avg_date);
        for a = 1:size(REMORA.sm.cmpt.pre.prcol,2)
            fprintf(REMORA.sm.cmpt.fid.ol_pct10,'%f',REMORA.sm.cmpt.pre.prcol(3,a));
            if a<size(REMORA.sm.cmpt.pre.prcol,2)
                fprintf(REMORA.sm.cmpt.fid.ol_pct10,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.ol_pct10,'\n');
        
        %write 25%
        fprintf(REMORA.sm.cmpt.fid.ol_pct25,'%s, ',avg_date);
        for a = 1:size(REMORA.sm.cmpt.pre.prcol,2)
            fprintf(REMORA.sm.cmpt.fid.ol_pct25,'%f',REMORA.sm.cmpt.pre.prcol(4,a));
            if a<size(REMORA.sm.cmpt.pre.prcol,2)
                fprintf(REMORA.sm.cmpt.fid.ol_pct25,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.ol_pct25,'\n');
        
        %write 75%
        fprintf(REMORA.sm.cmpt.fid.ol_pct75,'%s, ',avg_date);
        for a = 1:size(REMORA.sm.cmpt.pre.prcol,2)
            fprintf(REMORA.sm.cmpt.fid.ol_pct75,'%f',REMORA.sm.cmpt.pre.prcol(6,a));
            if a<size(REMORA.sm.cmpt.pre.prcol,2)
                fprintf(REMORA.sm.cmpt.fid.ol_pct75,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.ol_pct75,'\n');
        
        %write 90%
        fprintf(REMORA.sm.cmpt.fid.ol_pct90,'%s, ',avg_date);
        for a = 1:size(REMORA.sm.cmpt.pre.prcol,2)
            fprintf(REMORA.sm.cmpt.fid.ol_pct90,'%f',REMORA.sm.cmpt.pre.prcol(7,a));
            if a<size(REMORA.sm.cmpt.pre.prcol,2)
                fprintf(REMORA.sm.cmpt.fid.ol_pct90,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.ol_pct90,'\n');
        
        %write 95%
        fprintf(REMORA.sm.cmpt.fid.ol_pct95,'%s, ',avg_date);
        for a = 1:size(REMORA.sm.cmpt.pre.prcol,2)
            fprintf(REMORA.sm.cmpt.fid.ol_pct95,'%f',REMORA.sm.cmpt.pre.prcol(8,a));
            if a<size(REMORA.sm.cmpt.pre.prcol,2)
                fprintf(REMORA.sm.cmpt.fid.ol_pct95,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.ol_pct95,'\n');
        
        %write 99%
        fprintf(REMORA.sm.cmpt.fid.ol_pct99,'%s, ',avg_date);
        for a = 1:size(REMORA.sm.cmpt.pre.prcol,2)
            fprintf(REMORA.sm.cmpt.fid.ol_pct99,'%f',REMORA.sm.cmpt.pre.prcol(9,a));
            if a<size(REMORA.sm.cmpt.pre.prcol,2)
                fprintf(REMORA.sm.cmpt.fid.ol_pct99,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.ol_pct99,'\n');
    end
    
    % if third octave levels selected
    if REMORA.sm.cmpt.tol
        %write 1%
        fprintf(REMORA.sm.cmpt.fid.tol_pct01,'%s, ',avg_date);
        for a = 1:size(REMORA.sm.cmpt.pre.prctol,2)
            fprintf(REMORA.sm.cmpt.fid.tol_pct01,'%f',REMORA.sm.cmpt.pre.prctol(1,a));
            if a<size(REMORA.sm.cmpt.pre.prctol,2)
                fprintf(REMORA.sm.cmpt.fid.tol_pct01,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.tol_pct01,'\n');
        
        %write 5%
        fprintf(REMORA.sm.cmpt.fid.tol_pct05,'%s, ',avg_date);
        for a = 1:size(REMORA.sm.cmpt.pre.prctol,2)
            fprintf(REMORA.sm.cmpt.fid.tol_pct05,'%f',REMORA.sm.cmpt.pre.prctol(2,a));
            if a<size(REMORA.sm.cmpt.pre.prctol,2)
                fprintf(REMORA.sm.cmpt.fid.tol_pct05,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.tol_pct05,'\n');
        
        %write 10%
        fprintf(REMORA.sm.cmpt.fid.tol_pct10,'%s, ',avg_date);
        for a = 1:size(REMORA.sm.cmpt.pre.prctol,2)
            fprintf(REMORA.sm.cmpt.fid.tol_pct10,'%f',REMORA.sm.cmpt.pre.prctol(3,a));
            if a<size(REMORA.sm.cmpt.pre.prctol,2)
                fprintf(REMORA.sm.cmpt.fid.tol_pct10,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.tol_pct10,'\n');
        
        %write 25%
        fprintf(REMORA.sm.cmpt.fid.tol_pct25,'%s, ',avg_date);
        for a = 1:size(REMORA.sm.cmpt.pre.prctol,2)
            fprintf(REMORA.sm.cmpt.fid.tol_pct25,'%f',REMORA.sm.cmpt.pre.prctol(4,a));
            if a<size(REMORA.sm.cmpt.pre.prctol,2)
                fprintf(REMORA.sm.cmpt.fid.tol_pct25,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.tol_pct25,'\n');
        
        %write 75%
        fprintf(REMORA.sm.cmpt.fid.tol_pct75,'%s, ',avg_date);
        for a = 1:size(REMORA.sm.cmpt.pre.prctol,2)
            fprintf(REMORA.sm.cmpt.fid.tol_pct75,'%f',REMORA.sm.cmpt.pre.prctol(6,a));
            if a<size(REMORA.sm.cmpt.pre.prctol,2)
                fprintf(REMORA.sm.cmpt.fid.tol_pct75,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.tol_pct75,'\n');
        
        %write 90%
        fprintf(REMORA.sm.cmpt.fid.tol_pct90,'%s, ',avg_date);
        for a = 1:size(REMORA.sm.cmpt.pre.prctol,2)
            fprintf(REMORA.sm.cmpt.fid.tol_pct90,'%f',REMORA.sm.cmpt.pre.prctol(7,a));
            if a<size(REMORA.sm.cmpt.pre.prctol,2)
                fprintf(REMORA.sm.cmpt.fid.tol_pct90,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.tol_pct90,'\n');
        
        %write 95%
        fprintf(REMORA.sm.cmpt.fid.tol_pct95,'%s, ',avg_date);
        for a = 1:size(REMORA.sm.cmpt.pre.prctol,2)
            fprintf(REMORA.sm.cmpt.fid.tol_pct95,'%f',REMORA.sm.cmpt.pre.prctol(8,a));
            if a<size(REMORA.sm.cmpt.pre.prctol,2)
                fprintf(REMORA.sm.cmpt.fid.tol_pct95,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.tol_pct95,'\n');
        
        %write 99%
        fprintf(REMORA.sm.cmpt.fid.tol_pct99,'%s, ',avg_date);
        for a = 1:size(REMORA.sm.cmpt.pre.prctol,2)
            fprintf(REMORA.sm.cmpt.fid.tol_pct99,'%f',REMORA.sm.cmpt.pre.prctol(9,a));
            if a<size(REMORA.sm.cmpt.pre.prctol,2)
                fprintf(REMORA.sm.cmpt.fid.tol_pct99,', ');
            end
        end
        fprintf(REMORA.sm.cmpt.fid.tol_pct99,'\n');
    end
    
end