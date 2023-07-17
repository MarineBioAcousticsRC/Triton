function sm_cmpt_writeout
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sm_cmpt_writeout.m
% 
% write to previously opened output files
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global REMORA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% find start and end time of deployment
if REMORA.sm.cmpt.mean  
    % if power spectral density selected
    if REMORA.sm.cmpt.psd
        if REMORA.sm.cmpt.csvout
            REMORA.sm.cmpt.pre.meanpsd = ones(REMORA.sm.cmpt.pre.thisltsa,...
                (REMORA.sm.cmpt.hfreq-REMORA.sm.cmpt.lfreq+1))*NaN;
            REMORA.sm.cmpt.pre.logmeanpsd = ones(REMORA.sm.cmpt.pre.thisltsa,...
                (REMORA.sm.cmpt.hfreq-REMORA.sm.cmpt.lfreq+1))*NaN;
        end
        if REMORA.sm.cmpt.ltsaout
            REMORA.sm.cmpt.pre.ltsapsd = ones(REMORA.sm.cmpt.pre.thisltsa,...
                REMORA.sm.cmpt.hfreq+1)*NaN;
        end
    end
    
    % if broadband levels selected
    if REMORA.sm.cmpt.bb
       REMORA.sm.cmpt.pre.meanbb = ones(REMORA.sm.cmpt.pre.thisltsa,1)*NaN;
    end
    
    % if octave levels selected
    if REMORA.sm.cmpt.ol
       REMORA.sm.cmpt.pre.meanol = ones(REMORA.sm.cmpt.pre.thisltsa,...
            length(REMORA.sm.cmpt.OLnfreq))*NaN;
    end
    
    % if third octave levels selected
    if REMORA.sm.cmpt.tol
        REMORA.sm.cmpt.pre.meantol = ones(REMORA.sm.cmpt.pre.thisltsa,...
            length(REMORA.sm.cmpt.TOLnfreq))*NaN;
    end
end

%% if 'median' is selected
if REMORA.sm.cmpt.median || REMORA.sm.cmpt.prctile
    % if power spectral density selected
    if REMORA.sm.cmpt.psd
        REMORA.sm.cmpt.pre.pct50psd = ones(REMORA.sm.cmpt.pre.thisltsa,...
            (REMORA.sm.cmpt.hfreq-REMORA.sm.cmpt.lfreq+1))*NaN;
    end
    
    % if broadband levels selected
    if REMORA.sm.cmpt.bb
        REMORA.sm.cmpt.pre.pct50bb = ones(REMORA.sm.cmpt.pre.thisltsa,1)*NaN;
    end
    
    % if octave levels selected
    if REMORA.sm.cmpt.ol
       REMORA.sm.cmpt.pre.pct50ol = ones(REMORA.sm.cmpt.pre.thisltsa,...
            length(REMORA.sm.cmpt.OLnfreq))*NaN;
    end
    
    % if third octave levels selected
    if REMORA.sm.cmpt.tol
        REMORA.sm.cmpt.pre.pct50tol = ones(REMORA.sm.cmpt.pre.thisltsa,...
            length(REMORA.sm.cmpt.TOLnfreq))*NaN;
    end
end

%% if 'percentile' is selected
if REMORA.sm.cmpt.prctile
    % if power spectral density selected
    if REMORA.sm.cmpt.psd
        REMORA.sm.cmpt.pre.pct01psd = ones(REMORA.sm.cmpt.pre.thisltsa,...
            (REMORA.sm.cmpt.hfreq-REMORA.sm.cmpt.lfreq+1))*NaN;
        REMORA.sm.cmpt.pre.pct05psd = ones(REMORA.sm.cmpt.pre.thisltsa,...
            (REMORA.sm.cmpt.hfreq-REMORA.sm.cmpt.lfreq+1))*NaN;
        REMORA.sm.cmpt.pre.pct10psd = ones(REMORA.sm.cmpt.pre.thisltsa,...
            (REMORA.sm.cmpt.hfreq-REMORA.sm.cmpt.lfreq+1))*NaN;
        REMORA.sm.cmpt.pre.pct25psd = ones(REMORA.sm.cmpt.pre.thisltsa,...
            (REMORA.sm.cmpt.hfreq-REMORA.sm.cmpt.lfreq+1))*NaN;
        REMORA.sm.cmpt.pre.pct75psd = ones(REMORA.sm.cmpt.pre.thisltsa,...
            (REMORA.sm.cmpt.hfreq-REMORA.sm.cmpt.lfreq+1))*NaN;
        REMORA.sm.cmpt.pre.pct90psd = ones(REMORA.sm.cmpt.pre.thisltsa,...
            (REMORA.sm.cmpt.hfreq-REMORA.sm.cmpt.lfreq+1))*NaN;
        REMORA.sm.cmpt.pre.pct95psd = ones(REMORA.sm.cmpt.pre.thisltsa,...
            (REMORA.sm.cmpt.hfreq-REMORA.sm.cmpt.lfreq+1))*NaN;
        REMORA.sm.cmpt.pre.pct99psd = ones(REMORA.sm.cmpt.pre.thisltsa,...
            (REMORA.sm.cmpt.hfreq-REMORA.sm.cmpt.lfreq+1))*NaN;
    end
    
    % if broadband levels selected
    if REMORA.sm.cmpt.bb
        REMORA.sm.cmpt.pre.pct01bb = ones(REMORA.sm.cmpt.pre.thisltsa,1)*NaN;
        REMORA.sm.cmpt.pre.pct05bb = ones(REMORA.sm.cmpt.pre.thisltsa,1)*NaN;
        REMORA.sm.cmpt.pre.pct10bb = ones(REMORA.sm.cmpt.pre.thisltsa,1)*NaN;
        REMORA.sm.cmpt.pre.pct25bb = ones(REMORA.sm.cmpt.pre.thisltsa,1)*NaN;
        REMORA.sm.cmpt.pre.pct75bb = ones(REMORA.sm.cmpt.pre.thisltsa,1)*NaN;
        REMORA.sm.cmpt.pre.pct90bb = ones(REMORA.sm.cmpt.pre.thisltsa,1)*NaN;
        REMORA.sm.cmpt.pre.pct95bb = ones(REMORA.sm.cmpt.pre.thisltsa,1)*NaN;
        REMORA.sm.cmpt.pre.pct99bb = ones(REMORA.sm.cmpt.pre.thisltsa,1)*NaN;
    end
    
    % if octave levels selected
    if REMORA.sm.cmpt.ol
        REMORA.sm.cmpt.pre.pct01ol = ones(REMORA.sm.cmpt.pre.thisltsa,...
            length(REMORA.sm.cmpt.OLnfreq))*NaN;
        REMORA.sm.cmpt.pre.pct05ol = ones(REMORA.sm.cmpt.pre.thisltsa,...
            length(REMORA.sm.cmpt.OLnfreq))*NaN;
        REMORA.sm.cmpt.pre.pct10ol = ones(REMORA.sm.cmpt.pre.thisltsa,...
            length(REMORA.sm.cmpt.OLnfreq))*NaN;
        REMORA.sm.cmpt.pre.pct25ol = ones(REMORA.sm.cmpt.pre.thisltsa,...
            length(REMORA.sm.cmpt.OLnfreq))*NaN;
        REMORA.sm.cmpt.pre.pct75ol = ones(REMORA.sm.cmpt.pre.thisltsa,...
            length(REMORA.sm.cmpt.OLnfreq))*NaN;
        REMORA.sm.cmpt.pre.pct90ol = ones(REMORA.sm.cmpt.pre.thisltsa,...
            length(REMORA.sm.cmpt.OLnfreq))*NaN;
        REMORA.sm.cmpt.pre.pct95ol = ones(REMORA.sm.cmpt.pre.thisltsa,...
            length(REMORA.sm.cmpt.OLnfreq))*NaN;
        REMORA.sm.cmpt.pre.pct99ol = ones(REMORA.sm.cmpt.pre.thisltsa,...
            length(REMORA.sm.cmpt.OLnfreq))*NaN;
    end
    
    % if third octave levels selected
    if REMORA.sm.cmpt.tol
        REMORA.sm.cmpt.pre.pct01tol = ones(REMORA.sm.cmpt.pre.thisltsa,...
            length(REMORA.sm.cmpt.TOLnfreq))*NaN;
        REMORA.sm.cmpt.pre.pct05tol = ones(REMORA.sm.cmpt.pre.thisltsa,...
            length(REMORA.sm.cmpt.TOLnfreq))*NaN;
        REMORA.sm.cmpt.pre.pct10tol = ones(REMORA.sm.cmpt.pre.thisltsa,...
            length(REMORA.sm.cmpt.TOLnfreq))*NaN;
        REMORA.sm.cmpt.pre.pct25tol = ones(REMORA.sm.cmpt.pre.thisltsa,...
            length(REMORA.sm.cmpt.TOLnfreq))*NaN;
        REMORA.sm.cmpt.pre.pct75tol = ones(REMORA.sm.cmpt.pre.thisltsa,...
            length(REMORA.sm.cmpt.TOLnfreq))*NaN;
        REMORA.sm.cmpt.pre.pct90tol = ones(REMORA.sm.cmpt.pre.thisltsa,...
            length(REMORA.sm.cmpt.TOLnfreq))*NaN;
        REMORA.sm.cmpt.pre.pct95tol = ones(REMORA.sm.cmpt.pre.thisltsa,...
            length(REMORA.sm.cmpt.TOLnfreq))*NaN;
        REMORA.sm.cmpt.pre.pct99tol = ones(REMORA.sm.cmpt.pre.thisltsa,...
            length(REMORA.sm.cmpt.TOLnfreq))*NaN;
    end
    
end