function [Cep] = spCepstrum(FrameData, varargin)
% [Cepstrum] = spCepstrum(FrameData, ParameterList)
%	Generate the cepstrum for a given set of data frames.
%	Frames are assumed to be column vectors within the matrix
%	FrameData.  It is also assumed that any windowing functions
%	have already been applied.
%
%	Optional arguments:
%	'Spectrum', SpectrumVarArgList - cell array of optional arguments
%		'Method', SpectrumType
%			Indicates how spectrum should be computed.
%			Valid entries:  
%				'dft' - discrete Fourier transform.  Default.
%				'multitaper', N - Thomson multi-taper 
%					method.  The additional argument
%					N specifies the number of tapers.
%					Use [] for the default number of
%					tapers.
%		'Points', N - Size of FFT window.  Defaults to size
%			of frame.  If present and larger, zero pads
%			to provide interpolation for smaller frequency
%			intervals.
%
%	'Cepstrum', CepstrumVarArgList - cell array of optional arguments
%		'Method', 'linear'|'mel' - Linear- or Mel-spaced cepstrum
%		'Energy', 'retain'|'discard'
%			Retain or discard c0.  (default 'retain')
%			discard energy component.
%		'Coefficients', N - Number of cepstral coefficients to
%			retain not including energy.  N+1 must be <= the
%			number of points in the spectrum.  Default is 12.
%		'Filters', N
%			Number of filters for filter-bank methods (i.e. 'mel')
%			Defaults to 24 which is too large for some wideband
%			applications
%		'MelBand' [LowHz, HighHz] - Specify low and high cutoff
%			frequencies for the Mel filter banks.  This
%			parameter is a no-op when any method other than
%			mel has been selected.  Note that the pass band
%			is specified in Hz.
%
%	'SampleRate' - Data sample rate.  Default 8000.
%		Note that non-uniform filter banks (i.e. Mel scale)
%		will not function correctly if the SampleRate is not
%		specified and is not the default sampling rate.
%
%	Each row of the output CepData contains CepstrumPoints
%	of cepstral data.
%
% Examples:
%	Cep = spCepstrum(Frames);
%
%	Cep = spCepstrum(Frames, 'Spectrum', {'Method', 'dft', ...
%		'Points', 256}, 'Cepstrum', {'Method', 'mel', ...
%		'Filters', 24, 'Coefficients', 12}, 'SampleRate', 16000);
%
% This code is copyrighted 1997-2002 by Marie Roch.
% e-mail:  marie.roch@ieee.org
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 


% check arguments
error(nargchk(1, inf, nargin))

% Set up defaults 
SpectrumArgs = {};
CepstrumArgs = {};

[Components, Frames] = size(FrameData);
SampleRate = 8000;

n=1;
while n <= length(varargin)
  switch varargin{n}
   case 'Spectrum'
    if ~ iscell(varargin{n+1})
      error(sprintf('Argument to %s must be a cell array', varargin{n}))
    end
    SpectrumArgs = varargin{n+1}; n=n+2;

   case 'Cepstrum'
    if ~ iscell(varargin{n+1})
      error(sprintf('Argument to %s must be a cell array', varargin{n}))
    end
    CepstrumArgs = varargin{n+1}; n=n+2;

   case 'SampleRate'
    SampleRate = varargin{n+1}; n=n+2;

   otherwise
    error(sprintf('Bad optional argument: "%s"', varargin{n}));
  end
end



% Spectral analysis
SpectrumMethod = 'dft';		% default
SpectrumPoints = Components;
TaperCount = [];		% # tapers for pmtm()
n=1;
while n <= length(SpectrumArgs)
  switch SpectrumArgs{n}
   case 'Method'
    SpectrumMethod = SpectrumArgs{n+1}; n=n+2;
    if strcmp(SpectrumMethod, 'multitaper')
      TaperCount = SpectrumArgs{n}; n=n+1;
    end
    
   case 'Points',
    SpectrumPoints = SpectrumArgs{n+1}; n=n+2;
   otherwise
    error(sprintf('Bad value for keyword argument Spectrum: "%s"', ...
		  SpectrumArgs{n}));
  end
end

switch SpectrumMethod
 case 'dft'
  if SpectrumPoints < Components
    SpectrumPoints = Components;
    warning('Setting #DFT points to #Components (specified # smaller)');
  end
    
  Spectrum = fft(FrameData, SpectrumPoints);

  
  % Complex conjugate causes thrashing on very large
  % spectrae.  Break:
  %	Spectrum = Spectrum .* conj(Spectrum);	% Magnitude ^ 2
  % into blocks for faster computation
  Spectrae = size(Spectrum, 2);
  BlockSize = 1024;
  BlockCount = floor(Spectrae / BlockSize);
  BlockPartial = rem(Spectrae, BlockSize);
  for k=0:BlockCount-1
    Range = k*BlockSize+1:k+BlockSize;
    % Magnitude squared
    Spectrum(:, Range) = Spectrum(:, Range) .* conj(Spectrum(:, Range));
  end
  if BlockPartial
    Range = BlockCount*BlockSize+1:Spectrae;
    % Magnitude squared
    Spectrum(:, Range) = Spectrum(:, Range) .* conj(Spectrum(:, Range));
  end
    

 case 'multitaper'
  % Thomson mutli-tape spectrum estimation
  Spectrum = zeros(SpectrumPoints, Frames);
  for f=1:Frames
    Spectrum(:,f) = pmtm(FrameData(:,f), TaperCount, SpectrumPoints, ...
			 'twosided'); 
  end
    
 otherwise
  error(sprintf('Bad spectrum method "%s"', SpectrumMethod));
end
  
% cepstral defaults
CepstrumMethod = 'linear';	% type of cepstral analysis
Coefficients = 12;
RetainEnergy = 'retain';
% mfcc specific defaults
Filters = 24;
MFCCLowCutoffHz = 0;
MFCCHighCutoffHz = SampleRate / 2;

% process cepstral arguments
n=1;
while n <= length(CepstrumArgs)
  switch CepstrumArgs{n}
   case 'Method'
    CepstrumMethod = CepstrumArgs{n+1}; n=n+2;
   case 'Energy'
    RetainEnergy = CepstrumArgs{n+1}; n=n+2;
   case 'Filters'
    Filters = CepstrumArgs{n+1}; n=n+2;
   case 'Coefficients'
    Coefficients = CepstrumArgs{n+1}; n=n+2;
   case 'MelBand'
    if length(CepstrumArgs{n+1}) ~= 2
      error(sprintf('Bad keyword value for argument %s', CepstrumArgs{n}));
    else
      MFCCLowCutoffHz = CepstrumArgs{n+1}(1);
      MFCCHighCutoffHz = CepstrumArgs{n+1}(2);
    end
    n = n+2;
   otherwise
    error(sprintf('Bad value for keyword argument Cepstrum: "%s"', ...
		  CepstrumArgs{n}));
  end
end

if Coefficients + 1 > SpectrumPoints
  error(sprintf('Cepstrum Coefficients %d + 1 > Spectrum Points %d', ...
		Coefficients, SpectrumPoints));
end

switch CepstrumMethod
 case 'mel'
  % compute Mel-filtered cepstral coefficients
  Cep = spMFCC(Spectrum, SampleRate, Coefficients, Filters, ...
	       MFCCLowCutoffHz, MFCCHighCutoffHz);

 case 'linear'
  
  % The cepstrum is the inverse Fourier transform of the log
  % magnitude^2 of the spectrum.


  % Floor log filters at the ETSI ES 201 108 v1.1.2 2000-04
  % specification.  Note spec. for Mel filters and here we
  % are applying the threshold to DFT filter output.
  % log(1.9287e-22) = -50
  Floor = 1.9287e-22;
  Spectrum(find(Spectrum < Floor)) = Floor;
  LogCep = log(Spectrum);
  
  Cep = real(ifft(LogCep));	% real Cepstrum
  if Coefficients+2 < SpectrumPoints
    Cep(Coefficients+2:end,:) = [];	% Remove unwanted points
  end

  % Floor bins at -50 as suggested in ETSI ES 201 108 v1.1.2 2000-04 
  % standard.  (Note:  This is an abuse, ETSI was specified for Mel cep)
  Cep(find(Cep < -50)) = -50;
  
 otherwise
    error(sprintf('Bad CepstrumMethod:  "%s"', CepstrumMethod));
end

if strcmp(RetainEnergy, 'discard')
  Cep(1,:) = [];	% Caller does not want energy
end

