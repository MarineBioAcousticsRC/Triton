function [Stat, RMS] = spRMSstat(Signal)
% Compute statistics related to the RMS.
% Signal is assumed to be a matrix where each column is a signal 
% whose RMS is to be computed.  The following statistics will
% be gathered on the RMS and returned as a row vector in Stat:
%
%	min RMS
%	max RMS
%	RMS10 - Ten percent of the RMS values fall beneath this RMS.
%	RMS90 - Ninety percent ...
%	Median RMS
%	Mean RMS
%	Noise floor 20*log10(max RMS - min RMS)
%	Robust noise floor 20*log10(90% RMS - 10% RMS)
% 
% The RMS values are returned in RMS

RMS = spRMS(Signal);
SortedRMS = sort(RMS);
Length = length(RMS);

RMS = zeros(1,8);
Stat(1) = SortedRMS(1);			% min
Stat(2) = SortedRMS(Length);		% max
Stat(3) = SortedRMS(ceil(Length*.1));	% 10th percentile
Stat(4) = SortedRMS(ceil(Length*.9));	% 90th percentile
Stat(5) = median(SortedRMS);		% median
Stat(6) = mean(SortedRMS);		% mean

WarnState = warning;			% Note whether warnings enabled & suppress
warning off;				% to handle infinite noise floor.
Stat(7) = 20*log10(Stat(2) - Stat(1));	% noise floor
Stat(8) = 20*log10(Stat(4) - Stat(3));	% robust noise floor
warning WarnState;			% restore

