function [boutStarts,boutStops] = lt_lVis_defineBouts(starts,stops,boutGap)
%function for creating bout-level times from click detections 

%if starts and stops are not chronological, reorder
% We should do this when tlabs are loaded as opposed to each time
%starts = sort(starts);
%stops = sort(stops);

nextDet = [starts(2:end);stops(end)];
detDiff = nextDet - stops;

boutStops = [stops(detDiff >= boutGap);stops(end)];
nextBout = nextDet(detDiff >=boutGap);
%next bout needs to be adjusted to correspond with the correct ends
boutStarts = [starts(1); nextBout(1:end)];