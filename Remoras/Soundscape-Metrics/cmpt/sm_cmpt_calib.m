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
    REMORA.sm.cmpt.counts= 23170; %current metric of number of counts/ dB rms
    dbcounts= abs(20*log10(REMORA.sm.cmpt.counts)-REMORA.sm.cmpt.caldb);
    % adjust for single value
    REMORA.sm.cmpt.pre.psd = REMORA.sm.cmpt.pre.psd + dbcounts;
    
%% transfer function calibration
elseif REMORA.sm.cmpt.tfval
    1;
end