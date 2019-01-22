function loadTF(filename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% loadTF.m
% 
% function to load Transfer Function (tf) file into PARAMS structure
% the transfer function is applied/unapplied only to the Spectra plot 
% and when toggled TF ON/OFF via Control Window radio buttons
% 
% tf file is ascii text with *.tf extension
% tf file is arranged as colums of :
% freq [Hz] & 1/sensitivity [dB re uPa(rms)^2/counts^2]
% 1/sensitivity values are put in PARAMS.tf structure
%
% 1/sensitivity for tf file is calculated via the negative of the sum
% the following:
%
% 1) Sensor (Ceramic/PZT/hydrophone) 
%   [dB re Vrms^2/ uPa(rms)^2] Open Circuit Received Response

%   1042 ~ -200 dB flat 1 Hz to 100kHz
%   AQ-1 ~ -202 dB flat 1Hz to 10kHz, notch/peak ~ 25-30kHz
%   HS150 ?

% 2) Preamp + Filter Board Gain 
%   [dB]
%
%   Usually freqency dependent (hence, freq column in tf file)
%   
%   Various versions/series and frequency-dependent calibration plots/data
%
%   ARP round / RZ differential driven +/-5V
%   usually +40 dB & 3series+2parallel AQ-1s
%
%   HARP RZ = 100, 200 series differentially driven +/-5V
%   usually +40 dB below 10 kHz, peak +60-80dB ~ 70kHz?
%
%   HARP 300 series dual channel mixed in diffential receiver 0-5V
%   around +40 dB below 2 kHz, 10kHz < ~+80dB < 100 kHz
%   +15 dB added for 6-series AQ-1s low channel <2 kHz
%   ITC-1042 for high channel ~+80dB gain > 10 kHz
%
%   HARP 400 series mixing in preamp, better signal balance, single channel 0-5V
%   around +40 dB below 2 kHz, 10kHz < ~+80dB < 100 kHz
%   +15 dB added for 6-series AQ-1s low channel <2 kHz
%   ITC-1042 for high channel ~+80dB gain > 10 kHz
%
%   Towed Arrays use various verisons of 100,200,300,400 series boards 
%   and various sensors AQ-1, HS-150, ITC-1042
%
% 3) Analog to Digitial Converter A/D 
%   [dB re counts^2/Vp-p ^2]
%   
%   100/200 series preamps (A/D 16-bit/10.0 Vp-p):
%   76.3 dB re counts^2/Vp-p ^2 = 20*log10(2^16/10 = 6554)
%   should there be another 6 dB for differential rcvr ???
%
%   300 series preamps (A/D 16-bit/5.0 Vp-p):
%   82.3 dB re counts^2/Vp-p ^2 = 20*log10(2^16/5 = 13107)
%   kinda correct...mixing low+high stage in diff rcvr (effective signal for 
%   each stage/signal is only +/- 16384 (2^14) counts 
%
%   400 series preamps (A/D 16-bit/5.0 Vp-p):
%   82.3 dB re counts^2/Vp-p ^2 = 20*log10(2^16/5 = 13107)
%
% 4) Vp-p / Vrms:
%   9.0 [dB re Vp-p^2/Vrms^2] = 10*1og10((1.414 * 2)^2) 
%
% This is needed because the tf file sensitivity values are applied 
% (i.e., added in dB in plot_spectra.m) to the output of 
%   dtdata = detrend(DATA,'constant');
%   [Pxx,F] = pwelch(dtdata,window,noverlap,PARAMS.nfft,PARAMS.fs);
%   Pxx = 10*log10(Pxx);
%
% In other words, the DATA vector is in counts(p-p), but become
% counts(rms)^2 via the pwelch function, so the tf file needs to be
% in [dB re uPa(rms)^2/counts^2]
%
% or
%
% - [dB re uPa(rms)^2/counts^2] =
%
% + [dB re Vrms^2/uPa^2]                Sensor
% + [dB]                                Preamp+Filter Gain
% + [dB re counts^2/Vp-p ^2]            A/D converter
% + 9.0 [dB re Vp-p^2/Vrms^2]           Vp-p/Vrms
%
%
% Example:
%
% AQ-1 & 1042: ~ -200 dB re Vrms/uPa(rms)
% 400 series board: +40+15 dB low / +80 dB high
% A/D: +82 dB re counts^2/Vp-p^2
% p-p2rms: +9 dB re Vp-p^2/Vrms^2
%
% = -(-200 +55/+80 +82 +9) = +54/+29 dB re uPa(rms)/counts^2
%
% don't forget it's the negative of the sum to get the units correct
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS

fid = fopen(filename,'r');
PARAMS.tf.filename = filename;

[A,count] = fscanf(fid,'%f %f',[2,inf]);
PARAMS.tf.freq = A(1,:);
PARAMS.tf.uppc = A(2,:);    % [dB re uPa(rms)^2/counts^2]

% PARAMS.tf.uppc =  - PARAMS.tf.vpup - (82.35 + 9.0).*ones(size(PARAMS.tf.vpup));

fclose(fid);

