function Cepstrum = spPcmToCep(Pcm, varargin)
% Cesptrum = spPcmToCep(PCM, ParameterList)
%
% Convert PCM to cepstrum
%
% The following optional parameters are recognized:
%	'CepstrumPoints', BandSpecN
%		Specifies the number of cepstral parameters + energy
%		which will be stored for each filter bank.  (default 12)
%		i.e. 10 stores c0 (energy) + c1-c10
%	'Endpoint', N - if non zero, runs endpointer on audio (default 0)
%	'FFTPoints', BandSpecN - Create with an N point FFT (default 256)
%	'FFTScale', Scale - Use 'linear' or critical band
%		'mel' / 'critical band' frequency scale.  Default
%		is linear.
%	'FilterBank', Name - String specifying the name of a .mat
%		file containing a filter bank realization named
%		FilterBank.  See spBandPass() for details on the 
%		filter bank structure.
%	'MaxTime', N - Maximum time in seconds of speech data to process
%		from each file.  (default 30)
%	'NoEnergy' - Do not return c0, the energy term
%	'Preemphasis', Alpha - Apply a first order preemphasis network
%		(low pass filter)  before computing the cepstrum.  Alpha
%		indicates the value of y[n] = x[n] - Alpha*x[n-1].
%	'SampleRate', N - Sample rate (default 8000)
%	'WindowSpacingMS', N - Distance between succesive window frames
%		(default 16)	
%	'WindowLengthMS', N - Length of window (default 32)
%	'Verbosity', N - Verbosity control 0=quiet (default), >0=noisier
%
% BandSpecN - indicates a parameter that can be applied for all sub-bands
% or a vector of parameters to be applied to each sub-band.
% Examples:
%	10		- All bands have parameter 10
%	[10, 5, 3]	- For a 3 band filter, band1 10, band2 5, band3 3
%
% Caveats:  
% 1.  Window sizes are adjusted to the nearest power of 2 frames based
% upon the sample rate for more efficient computation.  Window size and
% spacing are reported.
%
% 2.  Frames with zero energy are dropped to prevent errors in computing
% the cepstrum.  When sub-band cepstrums are being computed, this can
% result in frame drop out of one band without affecting the other.
% This will affect efforts to time synchronize the sub-bands.
%
% This code is copyrighted 1997-2000 by Marie Roch.
% e-mail:  marie-roch@uiowa.edu
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

error(nargchk(1, inf, nargin));

			% set defaults
MaxTimeSec = 30;	% Maximum amount of time to process
CepstrumPoints = 12;
SampleRate = 8000;
WindowSpacingMS = 16;
WindowLengthMS = 32;
Alpha = 0;
Endpoint = 0;
FFTPoints = 256;
FFTScale = 'linear';
FilenameFormat = '%s';
FilterBank = [];
FilterBankFile = [];
NoEnergy = 0;
Verbosity = 0;


n=1;
while n <= length(varargin)
  switch varargin{n}
   case 'CepstrumPoints'
    CepstrumPoints = varargin{n+1}; n=n+2;
   case  'FFTPoints'
    FFTPoints = varargin{n+1}; n=n+2;
   case 'FFTScale'
    FFTScale = varargin{n+1}; n=n+2;
   case 'FilterBank'
    FilterBankFile = varargin{n+1}; n=n+2;
   case 'MaxTime'
    MaxTimeSec = varargin{n+1}; n=n+2;
   case 'SampleRate'
    SampleRate = varargin{n+1}; n=n+2;
   case 'WindowLengthMS'
    WindowLengthMS = varargin{n+1}; n=n+2;
   case 'WindowSpacingMS'
    WindowSpacingMS = varargin{n+1}; n=n+2;
   case 'NoEnergy'
    NoEnergy = 1; n=n+1;
   case 'Preemphasis'
    Alpha = varargin{n+1}; n=n+2;
   case 'Verbose'
    Verbosity = varargin{n+1}; n=n+2;
   otherwise
    error(sprintf('Bad optional argument: "%s"', varargin{n}));
  end
end


MaxTimeSamples = MaxTimeSec * SampleRate;

WindowSpacingSec = WindowSpacingMS / 1000;
WindowLengthSec = WindowLengthMS / 1000;

if ~isempty(FilterBankFile)
  load(FilterBankFile);	% loads FilterBank structure
  FilterN = size(FilterBank.PassBands, 1);
else
  FilterN = 1;
end

CepstrumPoints = spiSubBandValues(CepstrumPoints, FilterN);
FFTPoints = spiSubBandValues(FFTPoints, FilterN);

% Determine how we will be filtering the signal
if isempty(FilterBank)
  Method = 'filterbank'; 
else
  if ~ isfield(FilterBank, 'Method')
    Method = 'filterbank';
  else
    Method = FilterBank.Method;
  end
end

% Preemphasize if requested
if Alpha
  Pcm = spPreemphasis(Pcm, Alpha);
end

switch Method
 case 'filterbank'
  % Band pass filter 
  % If no filter was specified (FilterBank == []), simply places 
  % unfiltered data in the same format as band pass filtered signals
  % for uniformity.
  BandPass = spBandPass(Pcm, SampleRate, FilterBank);
  BandPass.FilterFile = FilterBankFile;
      
  % compute window spacing & length
  if Verbosity
    fprintf('\nFilter Bank window information:\n')
    fprintf('Scale: %s\n', FFTScale);
    fprintf('\t\t\t    Spacing\t    Length\n');
    fprintf(['Bank\tLow\tHigh\tFrames\tSec\tFrames\tSec' ... 
	     '\tFrame/Sec\tFFT PTS\n']);
  end
  WindowSpacingTime = WindowSpacingSec(ones(FilterN,1));
  WindowLengthTime = WindowLengthSec(ones(FilterN,1));
  WindowSpacing  = ...
      ceil(WindowSpacingSec .* BandPass.SampleRate);
  WindowLength = ...
      ceil(WindowLengthSec .* BandPass.SampleRate);
  if Verbosity
    for k=1:FilterN
      fprintf('%d\t%d\t%d\t%d\t%.4f\t%d\t%.4f\t%.4f\t\t%d\n', ...
	      k, BandPass.PassBands(k,:), ...
	      WindowSpacing(k), WindowSpacingTime(k), ...
	      WindowLength(k), WindowLengthTime(k), ...
	      1/WindowSpacingTime(k), FFTPoints(k));
      if WindowLength(k) > FFTPoints(k)
	fprintf('TRUNCATED\n');
      else
	fprintf('\n');
      end
    end
  end
  
  for k=1:FilterN
    % Frame, subject to window, & compute real cepstrum
    [FramedPcm, IndexPcm] = spFrame(BandPass.Signal{k}, ...
				    WindowSpacing(k), WindowLength(k));
    
    FramedPcm = spWindow(FramedPcm);
    FramedPcm = spDropLowEnergy(FramedPcm);	% Remove zero energy frames
    
    % WARNING:  We will be saving this as a matrix and the read
    % routine will count on having the variable be named Cepstrum.
    Cepstrum.Data{k} = spCepstrum(FramedPcm, ...
				  'CepstrumPoints', CepstrumPoints(k), ...
				  'FFTPoints', FFTPoints(k), ...
				  'FFTScale', FFTScale, ...
				  'SampleRate', BandPass.SampleRate(k), ...
				  'DiscardEnergy', NoEnergy);
  end
 case 'fft'
  % Implement filterbank via FFT
  if idx == 1
    % First pass, compute window spacing & length
    [WindowSpacing(1:FilterN), WindowSpacingTime(1:FilterN)] = ...
	nearestpower2(WindowSpacingSec, SampleRate);
    [WindowLength(1:FilterN), WindowLengthTime(1:FilterN)] = ...
	nearestpower2(WindowLengthSec, SampleRate);
    fprintf('Filter Bank window information:\n')
	fprintf('\t\t\t\tSpacing\t\tLength\n');
	fprintf('Bank\tLow\tHigh\tFrames\tSec\tFrames\tSec\tFrame/Sec\n');
	for k=1:FilterN
	  fprintf('%d\t%d\t%d\t%d\t%.4f\t%d\t%.4f\t%.4f\n', ...
	      k, FilterBank.PassBands(k,:), ...
		  WindowSpacing(k), WindowSpacingTime(k), ...
		  WindowLength(k), WindowLengthTime(k), ...
		  1/WindowSpacingTime(k));
	end
  end
  
  [FramedPcm, IndexPcm] = spFrame(Pcm, WindowSpacing(1), WindowLength(1));
  
  FramedPcm = spWindow(FramedPcm);
  FramedPcm = spDropLowEnergy(FramedPcm);	% Remove zero energy frames
  BandPass = spFFTBandPass(FramedPcm, SampleRate, FilterBank);
  BandPass.SampleRate = SampleRate ./ WindowSpacing;
  
  for k=1:FilterN
    % Compute cepstrum based on Fourier transform and 
    % retain energy + requested number of cepstral coeffs.
    Cep = real(ifft(log((BandPass.Signal{k} .* conj(BandPass.Signal{k})))));
    if NoEnergy
      Cepstrum.Data{k} = Cep(2:(CepstrumPoints(k)+1),:)';
    else
      Cepstrum.Data{k} = Cep(1:(CepstrumPoints(k)+1),:)';
    end
  end
  
 otherwise
  error('Bad filter method in FilterBank.Method');
end

Cepstrum.Attribute.SourceDataSampleRate = BandPass.SampleRate;
Cepstrum.Attribute.PassBands = BandPass.PassBands;
Cepstrum.Attribute.CepstralSpacingMS = WindowSpacingTime * 1000;
Cepstrum.Attribute.CepstralLengthMS = WindowLengthTime * 1000;
Cepstrum.Attribute.SampleRate = 1 ./ WindowSpacingTime;


function Vector = spiSubBandValues(Values, SubBands)
% spiSubBandValues(Values, SubBands)
% Verifies the a vector of Values matches the number of specified
% SubBands.  In the special case where Values is a scalar, converts
% to a vector of length SubBands containing the scalar value for each
% item.
switch length(Values)
  case 1	% scalar
    Vector = Values(ones(SubBands, 1));
  case SubBands
    Vector = Values;
  otherwise
    error('Parameters do not match number of sub-bands')
end
