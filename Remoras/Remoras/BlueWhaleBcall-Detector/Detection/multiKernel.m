function [ker,voff,hoff] = multiKernel(f0, f1, t0, t1, BW, ...
    sRate, fRate, dataSize, zeroPad, nOverlap, nowarn)
% [ker,voff,hoff] = multiKernel(startF, endF, startT, endT, BW, ...
%                            sRate, fRate, dataSize, zeroPad, nOverlap, nowarn)
%
% Like kernel (q.v.), but allows multiple up- and down-sweeps.
% startF, endF, startT, and endT can be row- or column-vectors of 
% numbers, all the same length.  
% 
% Return value hoff is in seconds.  
% Return value voff is a bin number.  Yes, this is wrong.

showNsave = 0;		% 0=normal processing, 1=display & save nice pictures

if (size(BW) == [1 1]), BW = BW * ones(length(f0)); end
if (size(f0) ~= size(f1) | ...
    size(f0) ~= size(t0) | ...
    size(f0) ~= size(t1) | ...
    size(f0) ~= size(BW)     ),
   error('The start/end vectors for time, frequency, and bandwidth must be the same size.');
end

if (nRows(f0) ~= 1 & nCols(f0) ~= 1),
   error('Frequency and time values must be vectors or scalars.')
end

% Start-bins and widths must be computed because there may be roundoff
% in getSize; just using max(t1) for the width of result won't work.
% MATLAB's 1-based indexing is obnoxious.

widths  = round((t1-t0) * fRate) + 1;
starts  = round(t0*fRate) + 1;
w       = max(starts + widths - 1);
ker	= zeros(dataSize + zeroPad, 1);	% to get ker pieces placed correctly

nPieces = length(f0);
v0 = (dataSize + zeroPad) / 2;		% Nyquist bin; for min'ing
v1 = 0;					% for max'ing
hoffMin = Inf;
for i = 1:nPieces
  [kk,voff,hoff] = kernel(f0(i), f1(i), t1(i)-t0(i), BW(i), ...
				sRate, fRate, dataSize, zeroPad, nOverlap);
  hoffMin = min(hoffMin, hoff);
  hRange = starts(i) : (starts(i) + widths(i) - 1);
  vRange = voff : (voff+nRows(kk)-1);
  % Make sure ker is large enough.
  if (any(size(ker) < [max(vRange) max(hRange)]))
    ker(max(vRange), max(hRange)) = 0;
  end

  if (length(f0) > 1 & ~nowarn)
    disp('multiKernel: Using additive method; older kernels may be different')
  end
  ker(vRange, hRange) = ker(vRange, hRange) + kk;
  
  if (showNsave), saveker(ker(:,hRange), i, 244+i, 37); end
  v0 = min(v0,voff);  v1 = max(v1, voff+nRows(kk)-1);
end

if (showNsave), saveker(ker, 'All', 221, 100); error('All done!'); end

ker = ker(v0:v1,:);
voff = v0;				% bin number
hoff = hoffMin; if (hoff == Inf), hoff = 0; end

% Enable this code to plot the kernel.
if (0)
  figure(3)
  showKernel(ker, sRate, fRate, [v0 v1] / (dataSize+zeroPad) * sRate);
  % showKernel can be made to bomb deliberately
end
