function sm_cmpt_calib
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sm_cmpt_calib.m
% 
% add either transfer function or single value calibration to psd before
% averaging in time and frequency
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global REMORA PARAMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% single value calibration

if REMORA.sm.cmpt.sval
    % conversion of sensitivity to counts
    REMORA.sm.cmpt.counts= 2^15; %16 bit; +/- bit range
   % calibration value in dB re counts
    dbcounts= abs(20*log10(REMORA.sm.cmpt.counts)-REMORA.sm.cmpt.caldb);
    % adjust for single value
    REMORA.sm.cmpt.pre.psd = REMORA.sm.cmpt.pre.psd + dbcounts;
    
%% transfer function calibration
elseif REMORA.sm.cmpt.tfval
    files = dir(fullfile(REMORA.sm.cmpt.tpath, '*.tf'));
    if length(files) ~= 1
        error('Unable to find transfer fn or transfer fn ambiguous')
    end
    transferfnfile = fullfile(REMORA.sm.cmpt.tpath, REMORA.sm.cmpt.tfile);
    fileH = fopen(transferfnfile, 'r');
    if fileH == -1
        error('Unable to open transfer fn %s\n(corresponding to: %s)', ...
            transferfnfile, audiofile)
    end
    freqpower = textscan(fileH, '%f %f');  % freq <whitespace> dB format
    fclose(fileH);
    
    REMORA.sm.cmpt.pre.fvec = 0:1:REMORA.sm.cmpt.hfreq;

    % Resample to DFT resolution
    REMORA.sm.cmpt.pre.dB = interp1(freqpower{1}, freqpower{2}, REMORA.sm.cmpt.pre.fvec, 'linear', 'extrap');
    
    % adjust for single value
    REMORA.sm.cmpt.pre.psd = REMORA.sm.cmpt.pre.psd + REMORA.sm.cmpt.pre.dB;
end