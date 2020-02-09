function sm_cmpt_calib
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sm_cmpt_calib.m
% 
% add either transfer function or single value calibration to psd before
% averaging in time and frequency
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global REMORA 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% single value calibration

if REMORA.sm.cmpt.sval
    % conversion of sensitivity to counts
    REMORA.sm.cmpt.counts= 2^15; %16 bit; +/- bit range
    % counts/ dB rms - full system calibration value - 3 dB to account for
    % SPL in dB re counts
    dbcounts= abs(20*log10(REMORA.sm.cmpt.counts)-REMORA.sm.cmpt.caldb);
    % adjust for single value
    REMORA.sm.cmpt.pre.psd = REMORA.sm.cmpt.pre.psd + dbcounts;
    
%% transfer function calibration
elseif REMORA.sm.cmpt.tfval
    1;
end