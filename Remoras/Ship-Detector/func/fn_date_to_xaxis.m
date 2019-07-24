function x = fn_date_to_xaxis(datenums) 
% x = fn_date_to_xaxis(datenums)
% For the specified plot type ('ltsa' only for now), convert each of the
% serial dates (datenums) to an x axis offset.  x is a matrix of the 
% same shape as datenums.  If a date lies outside the current plot, its
% offset is set to NaN.

global PARAMS

% initialize x to same shape as datenums with NaN
x = NaN;
x = x(ones(size(datenums)));

[start, stop] = fn_get_ltsa_range;
valid = find(start <= datenums & stop >= datenums);
if size(valid, 1) > 1
    valid = valid';
end

[startFile, startIdx] = fn_ltsa_TimeIndexBin(start);
[stopFile, ~] = fn_ltsa_TimeIndexBin(stop);
% Indicate how many averages there in the preceding files for each file
% in range.
CumAvg = cumsum([0 PARAMS.ltsa.nave(startFile:max(startFile, stopFile-1))]);

% Compute bin width in hours
BinWidth_u = PARAMS.ltsa.tave/(60*60);

for idx = valid
    % find the file and ltsa bin idx for the idx'th date
    [fileIdx, binIdx,~] = fn_ltsa_TimeIndexBin(datenums(idx));
    % Take into account the number of bins in other files covered in
    % the plot.
    cumAvgIdx = fileIdx - startFile + 1;
    offsetFromStart = CumAvg(cumAvgIdx) + binIdx - startIdx;
    % Convert to x-axis units and store.
    x(idx) = offsetFromStart * BinWidth_u;
end