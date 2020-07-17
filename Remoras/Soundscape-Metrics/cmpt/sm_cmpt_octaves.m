function sm_cmpt_octaves

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sm_cmpt_octaves.m
% 
% initializes (third) octave boundaries and adjustments
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS REMORA 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load nominal frequencies from text file 
% (IEC/ANSI - https://law.resource.org/pub/us/cfr/ibr/002/ansi.s1.11.2004.pdf)
% definition of frequencies starts with band no. 11; nominal freq 13 Hz
thispath = fullfile(fileparts(mfilename('fullpath')));
fid = fopen(fullfile(thispath,'nominal_frequencies.txt'),'r');
txtfreq = textscan(fid,'%f');
fclose(fid);

nomTolFreq = txtfreq{1};

%% defines third octaves for band level calculations

% Center, lower and upper cut-off frequencies of the standard (IEC/ANSI) filters
fr = 1000; %reference frequency
G = 10^(3/10); %octave ration (base 10 system)
% [first last] IEC/ANSI band no.; #51 corresponds to band freq 112-141 kHz
iso_band = [11 52];  
for x = 1:iso_band(2) %x is IEC/ISO band number
    fmTolDec (x,1) = fr*G^((x-30)/3); %center frequency
    flowTolDec (x,1) = fmTolDec(x)*G^(-1/6); %lower cut-off frequency
    fhighTolDec (x,1) = fmTolDec(x)*G^(1/6); %upper cut-off frequency
end

%reduce to iso_band(1) limit
flowTolDec(1:iso_band(1)-1) = [];
fhighTolDec(1:iso_band(1)-1) = [];

%% extract octave levels from third octaves
% avoid band 51, not a full octave for any of the available data
nomOlFreq = nomTolFreq(2:3:end-3);
flowOlDec = flowTolDec(1:3:end-2);
fhighOlDec = fhighTolDec(3:3:end-1);

%% reduce to frequency range within band edges from user input
% TOL find lower and upper boundary
lidx = find(flowTolDec>=REMORA.sm.cmpt.lfreq,1,'first');
hidx = find(fhighTolDec<=REMORA.sm.cmpt.hfreq,1,'last');

flowTolDec = flowTolDec(lidx:hidx);
fhighTolDec = fhighTolDec(lidx:hidx);
nomTolFreq = nomTolFreq(lidx:hidx);

% OL find lower and upper boundary
lidx = find(flowOlDec>=REMORA.sm.cmpt.lfreq,1,'first');
hidx = find(fhighOlDec<=REMORA.sm.cmpt.hfreq,1,'last');

flowOlDec = flowOlDec(lidx:hidx);
fhighOlDec = fhighOlDec(lidx:hidx);
nomOlFreq = nomOlFreq(lidx:hidx);

%% reduce to full 1 Hz values of PSD and calculate correction for decimal Hz values
% TOL
flowTol = floor(flowTolDec);
fhighTol = floor(fhighTolDec);
REMORA.sm.cmpt.TOLbound = [flowTol fhighTol-1];
REMORA.sm.cmpt.TOLnfreq = nomTolFreq;

%correction factor to add to the sum across bins
REMORA.sm.cmpt.TOLcorr(:,1) = -10*log10((fhighTol - flowTol) ./ (fhighTolDec - flowTolDec)); 

% OL
flowOl = floor(flowOlDec);
fhighOl = floor(fhighOlDec);
REMORA.sm.cmpt.OLbound = [flowOl fhighOl-1];
REMORA.sm.cmpt.OLnfreq = nomOlFreq;

%correction factor to add to the sum across bins
REMORA.sm.cmpt.OLcorr(:,1) = -10*log10((fhighOl - flowOl) ./ (fhighOlDec - flowOlDec)); 

1;


