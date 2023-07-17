function [result,f] = tonal1(gram, p, f)
%TONAL1		Detect tonal sounds in a signal.
%
% See C:/IshExtras/doc/TonalSoundDetection.txt for a longer description.
%
% result = tonal1(gram, params)
%    Given a [portion of a] spectrogram, detect any tonal sounds (whistles, 
%    moans, etc.) in it.  This is the algorithm used in Ishmael's Tonal1 
%    module.  gram is a spectrogram with each row a frequency bin and
%    each column a time slice, and params is a structure as explained below.
%
%    The return value 'result' is a cell vector of 4xN arrays.  Each array
%    corresponds to a whistle, though beware that the algorithm sometimes
%    'drops' whistles, only to start them up again a short time later -- thus
%    turning one whistle into two or three.  Each array in result has columns
%    of time steps -- i.e., one gram slice per column -- and rows of
%	 (1) slice numbers (i.e., the time index)
%        (2) bin numbers (i.e., the frequency index)
%        (3) a confidence number at each time/freq point (essentially, with
%            the value of the normalized gram cell)
%        (4) the slope of the contour at that point.  The slope is calculated
%            from the previous nfit (see below) points; its first element in
%            each array is 0, since at the start there aren't two points to 
%            fit a line to.
%
%    The algorithm works by keeping track of the frequency f of each tonal
%    sound in the signal, and adjusting f at each time step according to the 
%    gram and the recent slope of f.  
%
%    The following values must be provided as fields of the params structure.
%    The numbers here are values that have worked well on some dolphin sounds 
%    (using 48 kHz sRate, 512-point frame and FFT, 50% overlap, 0.5 s 
%    time-decay equalization).
%
%     peakPct 	 0.50  base percentile for calculating min peak height
%     peakHeight 0.85  min peak height above peakPct; in log-scaled gram units
%     nbd 	 8     param for dpeaks; in bins
%     mindiff 	 10    min dist from existing tonal to peak freq; in bins
%     nfit 	 10    usual number of most-recent points to fit; in slices
%     minlen 	 12    min length of valid tonal; in slices
%     minIndep 	 7     time tonal must be separate before joining; in slices
%
% [result,state] = tonal1(gram, params, previousState)
%    The previous state can be passed in to restart processing where it ended
%    on the last call to tonal1.  The algorithm does no backtracking, so
%    'gram' should begin at the slice after the gram in the previous call
%    to tonal1.  Note that the time index in 'result' starts over at 1 upon
%    each call to tonal1.  You'll have to keep track of the correct time
%    indices yourself.
%
%    If there is a 'state' output, then any continuing tonals are NOT closed
%    out upon return, as is usually done.  To close them out, do a call
%    with no 'state' output; it is okay to use an Nx0-sized gram for this.
%    Also, on the very first call at the start of a long multi-part gram,
%    it's okay to use an empty cell {} for previousState.
%
% See also tonal2, tonalTest, tonalFixParams.
%
% Dave Mellinger
% David.Mellinger@oregonstate.edu

% I think this, rather than tonal2, is what Ishmael uses.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% f is a vector of cells, with one cell for each tonal that is currently being
% tracked.  Each cell has 3 rows, each row with one value per step:
%    [freq bin number; confidence; slope]        (or NaN if missing)
if (nargin < 3), f = {}; end

binRange = 1 : nRows(gram);	% which frequency bins to use
result = {};		% 3xN arrays, each with rows of [slice;bin;confidence]

for sn = 1 : nCols(gram)		% slice number
  % Get indices of peaks as pIx, the bin index in gram().
  gramStrip = gram(binRange, sn);
  noiseLevel = percentile(gramStrip, p.peakPct);
  pIx = dpeaks(gramStrip, p.nbd, p.peakHeight + noiseLevel);	% peak indices
  vIx = gramStrip(pIx);				% values at pIx indices
  unused = true(1,length(pIx));		% which elements of pIx have been used?

  i = 1;
  while (i <= length(f))
    % Calculate t, the target frequency of each existing tonal.
    fi = f{i}(1,:);		% vector of bin numbers in this tonal so far
    if (length(fi) >= 2)
      % Calculate target freq by fitting line to last p.nfit points.
      nUse = min(length(fi), p.nfit);
      [m,dummy,t] = linefit(-nUse : -1, fi(end - nUse + 1 : end), 0);
    else
      % Not enough points to fit line yet; just use last frequency.
      t = fi(end);
      m = 0;
    end

    % Match existing tonals.  Each pIx peak is allowed to match > 1 tonal.
    % This code works even if pIx is empty.
    [dist,closest] = min(abs(t - pIx));
    if (dist < p.mindiff)
      f{i} = [f{i} [pIx(closest); vIx(closest)-noiseLevel; m]];
      unused(closest) = false;		% mark this member of pIx as used
      i = i + 1;
    else
      % No peak close enough.  Eliminate tonal i from f{}.
      result = tryadd(result, f{i}, sn-1, p.minlen);
      f(i) = [];
      % DON'T increment i
    end
  end		% while (i)
  
  % Eliminate tonals that aren't separate from a different, longer-lived one.
  i = 0;
  while (i < length(f))
    i = i + 1;
    if (length(f{i}) < p.minIndep)
      for j = 1 : i-1
	if (f{i}(1,end) == f{j}(1,end))		% on same peak?
	  % Remove f{i} or f{j}, whichever is shorter.  This shouldn't work --
	  % f{i} and f{j} may have different slopes -- but in practice it does.
	  ix = iff(nCols(f{i}) < nCols(f{j}), i, j);
	  %result = tryadd(result, f{ix}, sn, p.minlen);
	  f(ix) = [];
          i = i - 2;         % do same one over next time
	  break
	end
      end		% end of j loop
    end			% end of if (length...)
  end			% end of i loop

  % Add any unused tonals from pIx/vIx.
  f(nCols(f) + (1 : sum(unused))) = ...
      num2cell([pIx(unused) vIx(unused)-noiseLevel zeros(sum(unused),1)].',1);

end			% end of sn loop

% See if any existing tonals should be closed out.  This is done only
% when no future calls to this function are expected.
if (nargout < 2)
  for i = 1 : length(f)
    result = tryadd(result, f{i}, nCols(gram), p.minlen);
  end
  f = {};		% not strictly necessary, but cleaner
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = tryadd(result, fc, sn, minlen)
% See whether the sequence of frequencies and confidences fc should be
% added to the list of results.  result is a cell array with 2xN arrays, fi 
% is a two-row array with [fi;ci], sn is a scalar slice number.

% Find k = index of last non-NaN value = number of valid freqs in fi.
% First find nnan, the number of terminal NaNs in fi.
nnan = sub(find(~isnan(fliplr(fc(1,:)))), 1, 1) - 1;
k = nCols(fc) - nnan;				% index of last non-NaN value

if (k > minlen)
  % Append 3xN array with slice numbers, freq bin numbers, confidences,
  % and slopes to result.
  timeBins = sn-nnan - k + 1 : sn-nnan;
  freqConfBins = fc(:,1:k);
  result{end+1} = [timeBins; freqConfBins];
end


%%%%% added utility fns that must be part of Dave's environment
function r = nRows(x)
r = size(x, 1);

function c = nCols(x)
c = size(x, 2);

