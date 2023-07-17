function x = sh_date_to_xaxis(datenums) 
% x = fn_date_to_xaxis(datenums)
% For the specified plot type ('ltsa' only for now), convert each of the
% serial dates (datenums) to an x axis offset.  x is a matrix of the 
% same shape as datenums.  If a date lies outside the current plot, its
% offset is set to NaN.

global PARAMS

% initialize x to same shape as datenums with NaN
x = NaN;
x = x(ones(size(datenums)));

[start, stop] = sh_get_ltsa_range;
valid = find(start <= datenums & stop >= datenums);
if size(valid, 1) > 1
    valid = valid';
end

[startFile, startIdx] = timeIndexBin(start);
[stopFile, ~] = timeIndexBin(stop);
% Indicate how many averages there in the preceding files for each file
% in range.
CumAvg = cumsum([0 PARAMS.ltsa.nave(startFile:max(startFile, stopFile-1))]);

% Compute bin width in hours
BinWidth_u = PARAMS.ltsa.tave/(60*60);

for idx = valid
    % find the file and ltsa bin idx for the idx'th date
    [fileIdx, binIdx,~] = timeIndexBin(datenums(idx));
    % Take into account the number of bins in other files covered in
    % the plot.
    cumAvgIdx = fileIdx - startFile + 1;
    offsetFromStart = CumAvg(cumAvgIdx) + binIdx - startIdx;
    % Convert to x-axis units and store.
    x(idx) = offsetFromStart * BinWidth_u;
end

function [rawIndex, tBin, present] = timeIndexBin(time)
% Given a Matlab serial date (dnum), find the raw index file and LTSA bin
% that contains it.  The variable present is true when a long term spectral
% average was calculated for the requested time, and false when it is
% between valid times, such as when the data has been scheduled (duty
% cycled) and the requested time is when the sensor is inactive.

global PARAMS

rawIndex = find(time >= PARAMS.ltsa.dnumStart & ...
                time <= PARAMS.ltsa.dnumEnd);

if isempty(rawIndex)
  % first one past requested time
  rawIndex = min(find(time < PARAMS.ltsa.dnumStart));
  present = false;
else
  present = true;
  if ~ isscalar(rawIndex)
    % Under most circumstances, any given instant in time should  
    % occur only in one file.
    multtimewarn = true;        % if too annoying set to false
    if multtimewarn 
      files = sprintf('%s ', PARAMS.ltsahd.fname{rawIndex});
      warning('Requested time %s occurs in multiple files %s.', ...
              files, datestr(time));
    end
    rawIndex = rawIndex(1);  
  end
end

% Find ltsa bin number in current rawIndex
if present
  delta = time - PARAMS.ltsa.dnumStart(rawIndex);
  % Compute bin width 
  tBinWidth = datenum([0 0 PARAMS.ltsa.tave/(60*60*24)]);
  tBin = 1 + round(delta / tBinWidth);
else
  tBin = 1;
end