function power_dB = powerlaw(spectra)
% Powerlaw spectrum normalization
% Helble et al., submitted

thr=dtThresh('mysticete');

% dB_cutoff=thr.dB_cutoff;
% area_cutoff=thr.area_cutoff;

whiteParam=thr.whitener;

spectra=10.^(spectra./20); %convert from dB 
spc= dtWhiten(spectra,whiteParam); %Run whitener on data
power_dB=20*log10(abs(spc));
return;
iexp1=thr.freqContrast; iexp2=thr.timeContrast; 
[spc]=NED_normalize(spc, iexp1, iexp2);

power_dB=20*log10(abs(spc));
%k1=max(max(power_dB))
%k1=-27; %subtracting out 
%power_dB=power_dB-k1; %normalizing


