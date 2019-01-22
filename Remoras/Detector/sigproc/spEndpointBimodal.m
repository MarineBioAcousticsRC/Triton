function [SpeechFrames Threshold] = spEndpointBimodal(Energy, varargin)
% [SpeechFrames Threshold] = spEndpointBimodal(Energy, OptionalArguments)
% 
% Implements a silence/speech detector based upon a bimodal energy
% distribution assumption.  Returns indices of frames retained and
% the silence/speech activity threshold.
%
% Optional arguments:
%
%       'Verbosity', N - if N > 0, print messages
%                0 - silent operation
%                1 - print summary indicating thresholds and frame
%                   retention. (default)
%                2 - Show EM algorithm output
%       'Display, N - Plot distributions if N ~= 0
%       'Normalize', String
%               'none' - default
%               'max' - Subtract maximum value
%               'median' - Subtract median value (energy values of 0
%                       are ignored in computing the median) 
%       'Threshold', T
%               Don't estimate the threshold, use T instead.
%               Useful if a global threshold has been estimated earlier.
%
% This code is copyrighted 2005 by Marie Roch.
% e-mail:  marie.roch@ieee.org
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

Verbosity = 0;  % defaults
Display = 0;
Normalize = 'none';
Threshold = [];

k=1;
while k<length(varargin)
  switch varargin{k}
   case 'Verbosity'
    Verbosity = varargin{k+1}; k=k+2;
   case 'Display'
    Display = varargin{k+1}; k=k+2;
   case 'Normalize'
    Normalize = varargin{k+1}; k=k+2;
   case 'Threshold'
    Threshold = varargin{k+1}; k=k+2;
   otherwise
    error('Bad optional argument "%s"', varargin{k})
  end
end

if utIsVector(Energy, 'Type', 'row')
  Energy = Energy';     % make column vector
end

Frames = length(Energy);

switch Normalize
   case 'none'
   case 'max'
    Energy = Energy / max(abs(Energy));
   case 'median'
    % take median throwing out zero energy frames first
    Energy = Energy - median(Energy(find(Energy > 0)));
   otherwise
    error('bad statistic %s', Normalize);
end

ConstructModels = isempty(Threshold);

if ConstructModels
  % Remove uppper % to solve for problem when 2nd distribution found above speech
  Samples = sort(Energy);
  Samples(round(.95*length(Samples)):end) = [];

  % Remove zero energy frames
  ZeroEnergyFrames = find(Samples == 0);
  Samples(ZeroEnergyFrames) = [];
  
  % Set variance floors for Gaussians
  MinVariance = .01 * var(Samples);
  
  Info.MaximumIterations = 3;
  if Verbosity > 1
    HmmVerbosity = 2;
  else
    HmmVerbosity = 0;
  end
  gmm = hmmCreateModel(1, 2, Samples, Info, 'Verbosity', HmmVerbosity);
  
  % Solve for cross over point.   Set weighted pdfs at x
  % equal to one another and solve.
  %
  % For example, see eqns (16, 17):
  %  @Article{raj2003:endpointer,
  %    status =	 {ec},
  %    author = 	 {Raj, Bhiksha and Singh, Rita},
  %    title = 	 {Classifier-based non-linear projection for adaptive
  %                    endpointing of continuous speech},
  %    journal = 	 {Computer Speech and Language},
  %    year = 	 2003,
  %    volume =	 {17},
  %    number =	 {1},
  %    pages =	 {5-26},
  %    month =	 {January}
  %  }
  
  % waste of time, but makes things more readable
  
  c_min = .01;
  [dontcare index] = find(gmm.Mix.c < c_min);
  if isempty(index)
    c = gmm.Mix.c;
  else
    c(index) = c_min;
    c(mod(index+1, 2)) = 1 - c_min;
  end
  
  Range = 1:2;
  for k = Range
    u(k) = gmm.Mix.mu(k);                 % mean
    S(k) = max(gmm.Mix.cov.Sigma{k}, MinVariance); % variance
    K(k) = log(c(k)) - .5*log(S(k));      % constant scaled by prior
    P2(k) = .5/S(k);                      % half precision
  end
  
  % Set up polynomial coefficients AX^2 + BX + C = 0
  A = P2(2) - P2(1);
  B = u(1)/S(1) - u(2)/S(2);
  C = K(1) - K(2) - u(1)^2*P2(1) + u(2)^2*P2(2);
  

  if C
    % Solve quadratic
    % solve quadratic AX^2 + BX + C = 0
    Discriminant = B^2 - 4*A*C;
    if Discriminant > 0 
      Discriminant = sqrt(Discriminant);
    else
      Discriminant = 0;
    end
    Roots = (-B + [-Discriminant Discriminant])/(2*A);
  else
    Roots = -C/B; % same variance - degenerated to AX+B = 0
  end
  
  CorrectRoot = find(Roots > min(u) & Roots < max(u));
  if isempty(CorrectRoot)
    % means on same side of crossing point, probably not speech/silence
    % ad hoc, use the separation between the means to pick a hopefully
    % appropriate spot
    Threshold = min(u) - (max(u) - min(u));
  else
    Threshold = Roots(CorrectRoot);
  end
end

% Find speech frames
SpeechFrames = find(Energy > Threshold);

if Display
  figure('Name', 'spEndpointBimodal')
  subplot(2,1,1)
  hist(Energy, 50)
  xlabel('Energy')
  ylabel('Frequency')
  hold on
  plot([Threshold Threshold], get(gca, 'YLim'), 'r-');  % decision boundary
  if ConstructModels
    % plot pdfs on 2nd axis
    ax{1} = gca;  % save old axis
    % Create new axis which si physically on top of the old one.
    ax{2} = axes('Position', get(ax{1}, 'Position'), ...
                 'YAxisLocation', 'right', ...
                 'Color', 'none', ...
                 'YColor', 'b');
    hold on
    x = linspace(min(Energy), max(Energy));
    % plot each Gaussian
    for k=1:length(gmm.Mix.mu)
      plot(x, ...
           gmm.Mix.c(k)* 1./sqrt(2*pi*gmm.Mix.cov.Sigma{k}) * ...
           exp(-.5 .* (x-gmm.Mix.mu(k)).^2.*gmm.Mix.cov.SigmaInv{k}), 'g-');
    end
    ylabel('Pr(X|M_k)')
    set(ax{2}, 'XLim', get(ax{1}, 'XLim'));      % Make x axes coincident
    set(ax{2}, 'XTick', []);    % Remove tick marks on 2nd axis to avoid
                                %  occasional double display which should
                                %  not be an issue but is...
    hold off
  end
  
  % plot energy showing noise/speech decisions
  subplot(2,1,2)
  Speech = NaN * ones(size(Energy));
  Noise = Speech;
  
  Speech(SpeechFrames) = Energy(SpeechFrames);
  NoiseFrames = setdiff(1:length(Energy), SpeechFrames);
  Noise(NoiseFrames) = Energy(NoiseFrames);
  
  plot(1:length(Energy), Noise, 'r', 1:length(Energy), Speech, 'g');
  xlabel('frame index');
  ylabel('energy');
end
  

if Verbosity
  if ConstructModels
    fprintf('Thresholding speech [%f, %f, %f]:  ', min(u), Threshold, ...
            max(u));
  else
    fprintf('Thresholding speech [%f]:  ', Threshold);
    ZeroEnergyFrames = find(Energy == 0);
  end
  fprintf('Before: %d, After %d (# zero energy %d)\n', Frames, ...
          length(SpeechFrames), length(ZeroEnergyFrames))
end

