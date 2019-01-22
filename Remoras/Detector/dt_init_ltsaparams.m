function ltsainfo = init_ltsaparams(currentoptions)
%
% Return ltsainfo containing ltsainfo.ltsa and ltasinfo.ltsahd
% which describe a default LTSA.  The optional currentoptions
% allows a user to pass in a structure containing an ltsa
% substructure.  Any user settable options from currentoptions.ltsa
% will be copied into the returned ltsainfo structure, permitting
% user's to retain options between one LTSA and another.
%
% 060508 smw
% 060914 smw modified for wav files
%
% Do not modify the following line, maintained by CVS
% $Id: init_ltsaparams.m,v 1.7 2007/10/16 21:09:12 msoldevilla Exp $

% Make sure that if ltsainfo is provided, it has ltsainfo.ltsa
if nargin < 1 
  currentoptions = [];
elseif ~isempty(currentoptions) && (~ isstruct(currentoptions) || ~ isfield(currentoptions, 'ltsa'))
    error('ltsainfo must be empty or a structure')
end

ltsainfo.ltsahd = [];   % dummy for now

ltsainfo.ltsa.start.dnum = datenum([0 1 1 0 0 0]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initial parameters for LTSA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the defaults first
if ispc % works for all machines
  ltsainfo.ltsa.inpath='C:'; 			
else
  ltsainfo.ltsa.inpath = '/';
end

ltsainfo.ltsa.infile='';           % no default

% User settable parameters
if isempty(currentoptions)
  % Use defaults
  ltsainfo.ltsa.tseg.hr = 2;        % display N h of data
  ltsainfo.ltsa.tseg.step = -1;     % Step size (== segment dur by default)
  ltsainfo.ltsa.freq0 = 0;				% frequency lower limit
  ltsainfo.ltsa.freq1 = -1;         % frequency upper limit
  ltsainfo.ltsa.bright = 70;			% shift in dB
  ltsainfo.ltsa.contrast = 180;		% amplify in % dB
  ltsainfo.ltsa.fax = 0;            % linear or log freq axis
  ltsainfo.ltsa.cmap = 'jet';			% color map for spectrogram
else
  % Caller passed in values - use them instead of defaults
  ltsainfo.ltsa.tseg.hr = currentoptions.ltsa.tseg.hr;  % display N h of data
  ltsainfo.ltsa.tseg.step = currentoptions.ltsa.tseg.step;      % step size
  ltsainfo.ltsa.freq0 = currentoptions.ltsa.freq0;				% frequency lower limit
  ltsainfo.ltsa.freq1 = currentoptions.ltsa.freq1;         % frequency upper limit
  ltsainfo.ltsa.bright = currentoptions.ltsa.bright;				% shift in dB
  ltsainfo.ltsa.contrast = currentoptions.ltsa.contrast;			% amplify in % dB
  ltsainfo.ltsa.fax = currentoptions.ltsa.fax;                 % linear or log freq axis
  ltsainfo.ltsa.cmap = currentoptions.ltsa.cmap;			% color map for spectrogram
end

ltsainfo.ltsa.tseg.sec = ltsainfo.ltsa.tseg.hr * 60 * 60;         % initial window time segment duration

ltsainfo.ltsa.ftype = 1;
ltsainfo.ltsa.start.yr = 0;
ltsainfo.ltsa.start.str = '0000';
ltsainfo.ltsa.aptime = 0;			%  pause time (typically CPU speed dependent?
ltsainfo.ltsa.cancel = 0;




% user defined:
ltsainfo.ltsa.tave = 5;       % averaging time [seconds]
ltsainfo.ltsa.dfreq = 100;    % frequency bin size [Hz]

% experiment defined (in XWAV file):
ltsainfo.ltsa.fs = 200000;    % sample rate [Hz]

% calculated based on user defined:
% number of samples for fft (nfft = 1000 for dfreq=200Hz & fs=200000Hz)
ltsainfo.ltsa.nfft = ltsainfo.ltsa.fs / ltsainfo.ltsa.dfreq;    
% compression factor (cfact = 1000 for tave=5sec,fs=200000Hz,dfreq=200)
ltsainfo.ltsa.cfact = ltsainfo.ltsa.tave * ltsainfo.ltsa.fs / ltsainfo.ltsa.nfft;   

% other
if ispc
  rootdir = 'c:\';
else
  rootdir = '/';
end
ltsainfo.ltsa.indir = rootdir;   % starting data directory
ltsainfo.ltsa.ftype = 2; % 1= WAVE, 2=XWAV
ltsainfo.ltsa.dtype = 1; % 1 = HARP, 2 = ARP, 3 = OBS, 4 = towed array or sonobuoy
ltsainfo.ltsa.ch = 1;    % channel to do ltsa on for multichannel wav files

if ~isfield(ltsainfo.ltsa, 'dt')
  ltsainfo.ltsa.dt = dt_initLTSA(ltsainfo.ltsa);  % init LTSA detection parameters
  ltsainfo.ltsa.dt.ifPlot = 0;
end
