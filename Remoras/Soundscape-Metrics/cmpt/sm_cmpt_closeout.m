function sm_cmpt_closeout
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sm_cmpt_closeout.m
% 
% closes output files dependent on user choices
% bb, ol, tol, psd (mean, median, prctile)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global REMORA 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% close open file names after computation is finished

% if 'mean' is selected
if REMORA.sm.cmpt.mean  
    % if power spectral density selected
    if REMORA.sm.cmpt.psd
        fclose(REMORA.sm.cmpt.fid.psd);
    end
    
    % if broadband levels selected
    if REMORA.sm.cmpt.bb
        fclose(REMORA.sm.cmpt.fid.bb);
    end
    
    % if octave levels selected
    if REMORA.sm.cmpt.ol
        fclose(REMORA.sm.cmpt.fid.ol);
    end
    
    % if third octave levels selected
    if REMORA.sm.cmpt.tol
        fclose(REMORA.sm.cmpt.fid.tol);
    end
end

%% if 'median' is selected
if REMORA.sm.cmpt.median || REMORA.sm.cmpt.prctile
    % if power spectral density selected
    if REMORA.sm.cmpt.psd
        fclose(REMORA.sm.cmpt.fid.psd_pct50);
    end
    
    % if broadband levels selected
    if REMORA.sm.cmpt.bb
        fclose(REMORA.sm.cmpt.fid.bb_pct50);
    end
    
    % if octave levels selected
    if REMORA.sm.cmpt.ol
        fclose(REMORA.sm.cmpt.fid.ol_pct50);
    end
    
    % if third octave levels selected
    if REMORA.sm.cmpt.tol
       fclose(REMORA.sm.cmpt.fid.tol_pct50);
    end
end

%% if 'percentile' is selected
if REMORA.sm.cmpt.prctile
    % if power spectral density selected
    if REMORA.sm.cmpt.psd
        fclose(REMORA.sm.cmpt.fid.psd_pct01);
        fclose(REMORA.sm.cmpt.fid.psd_pct05);
        fclose(REMORA.sm.cmpt.fid.psd_pct10);
        fclose(REMORA.sm.cmpt.fid.psd_pct25);
        fclose(REMORA.sm.cmpt.fid.psd_pct75);
        fclose(REMORA.sm.cmpt.fid.psd_pct90);
        fclose(REMORA.sm.cmpt.fid.psd_pct95);
        fclose(REMORA.sm.cmpt.fid.psd_pct99);
    end
    
    % if broadband levels selected
    if REMORA.sm.cmpt.bb
        fclose(REMORA.sm.cmpt.fid.bb_pct01);
        fclose(REMORA.sm.cmpt.fid.bb_pct05);
        fclose(REMORA.sm.cmpt.fid.bb_pct10);
        fclose(REMORA.sm.cmpt.fid.bb_pct25);
        fclose(REMORA.sm.cmpt.fid.bb_pct75);
        fclose(REMORA.sm.cmpt.fid.bb_pct90);
        fclose(REMORA.sm.cmpt.fid.bb_pct95);
        fclose(REMORA.sm.cmpt.fid.bb_pct99);
    end
    
    % if octave levels selected
    if REMORA.sm.cmpt.ol
        fclose(REMORA.sm.cmpt.fid.ol_pct01);
        fclose(REMORA.sm.cmpt.fid.ol_pct05);
        fclose(REMORA.sm.cmpt.fid.ol_pct10);
        fclose(REMORA.sm.cmpt.fid.ol_pct25);
        fclose(REMORA.sm.cmpt.fid.ol_pct75);
        fclose(REMORA.sm.cmpt.fid.ol_pct90);
        fclose(REMORA.sm.cmpt.fid.ol_pct95);
        fclose(REMORA.sm.cmpt.fid.ol_pct99);
    end
    
    % if third octave levels selected
    if REMORA.sm.cmpt.tol
        fclose(REMORA.sm.cmpt.fid.tol_pct01);
        fclose(REMORA.sm.cmpt.fid.tol_pct05);
        fclose(REMORA.sm.cmpt.fid.tol_pct10);
        fclose(REMORA.sm.cmpt.fid.tol_pct25);
        fclose(REMORA.sm.cmpt.fid.tol_pct75);
        fclose(REMORA.sm.cmpt.fid.tol_pct90);
        fclose(REMORA.sm.cmpt.fid.tol_pct95);
        fclose(REMORA.sm.cmpt.fid.tol_pct99);
    end
    
end
