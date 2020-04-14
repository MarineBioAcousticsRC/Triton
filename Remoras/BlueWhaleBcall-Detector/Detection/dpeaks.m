function peakIx = dpeaks(x, nbd, thresh)
%DPEAKS		Return the peak values in a sequence
%
% peakIx = dpeaks(seq, nbd)
%    Finds all the peaks in vector seq that are local maxima and at least
%    as high as any other point within nbd elements.  So if nbd is 0,
%    returns the maxima in seq.  Returns a column vector of indices into seq.
%    If a peak is broad (i.e., several successive values in seq are the same), 
%    uses the lowest index of the several possible.  As a special case, 
%    if nbd < 0, just returns the whole array.
%
% peakIx = dpeaks(seq, nbd, thresh)
%    As above, but a peak must additionally be at least as big as thresh.
%
% See also fitpeaks.
%
% Dave Mellinger

x = x(:);
n = length(x);
if (nbd < 0 | n < 2)
  peakIx = 1:length(x);
else
  % endpoints can be peaks too
  if (all(x(1) >= x)), p0 = x(1) > x(n);	% all are equal
  else                 p0 = x(1) > x(2);
  end
  p1 = (x(n-1) < x(n));
  
  % p is the initial guess at the peak locations
  p = find([p0; (x(1:n-2) < x(2:n-1)) & (x(2:n-1) >= x(3:n)); p1]);
  if (nargin > 2), p = p(find(x(p) >= thresh)); end	% detect.m also uses >=
  
  % Now test points in p for being greater than neighbors.
  v = x(p);
  peakIx = zeros(length(p), 1);
  k = 0;
  for i = 1:length(p)
    if (v(i) >= x(max(1,p(i)-nbd) : min(n,p(i)+nbd))),
      k = k + 1;
      peakIx(k) = p(i);
    end
  end
  peakIx = peakIx(1:k);
end

if (nargout > 1),
   train = zeros(n, 1);
   train(peakIx) = x(peakIx);
end
