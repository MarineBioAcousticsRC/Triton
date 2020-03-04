function showKernel(ker, sRate, fRate, freqBounds, cLims)
% showKernel(ker, sRate, fRate [,freqBounds [,cLims]])
% Display a kernel as an image.  sRate and fRate are for scaling the axes.
% The display parameters are set here in the code.
%
% If freqBounds are specified, they are the bottom and top frequencies
% of the kernel.
%
% If the 2-vector cLims is specified, it gives the values that are mapped
% to [white black] in the display.  If not specified, fixed values are used;
% see the code.

if (nargin < 4), freqBounds = [sRate/2 0]; end

% Choose what values of ker to scale to black and white on the display.  Use
% cLims if it is specified; otherwise you should enable one of the "elseif"
% caluses below.
if (nargin >= 5)
  black = cLims(2);		% this ker value displays as black
  white = cLims(1);		% ...and this as white
elseif (0)
  % blue kernel
  black = 0.99;			% this ker value displays as black
  white = -0.3;			% ...and this as white
elseif (0)
  % fin vertical kernel
  black = 1.1;			% this ker value displays as black
  white = -0.4;			% ...and this as white
elseif (0)
  % right whale kernel
  black = 7;			% this ker value displays as black
  white = 4;			% ...and this as white
else
  % another right whale kernel
  black = 0.99;			% this ker value displays as black
  white = -0.45;		% ...and this as white
end

hadd   = 0;

vstrip = 0;			% this many rows are removed from top & bottom
ker = ker(1+vstrip:nRows(ker)-vstrip, :);
ker = [zeros(nRows(ker),hadd)  ker  zeros(nRows(ker),hadd)];
					%%%ker = flipud(ker) / max(max(ker));
%ker = ker / max(max(ker));

ncolor = 32;

ker1 = min(ncolor, max(1, (ker - white) * (ncolor / (black - white)) + 1));
image([0 nCols(ker)/fRate], freqBounds, ker1);
colormap(flipud(gray(ncolor)));
set(gca, 'YDir', 'norm', 'TickDir', 'out')
%set(gca, 'XTick', [], 'YTick', []);
%wysiwyg

%error('Deliberate bomb to stop further processing.');
