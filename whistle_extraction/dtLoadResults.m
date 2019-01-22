function tonals = dtLoadResults(result, type, roots)
% tonals = dtLoadResults(result, type, roots)
%
% This function permits loading tonals associated with correct detections,
% false positives, and misses associated with a specific file.
% These tonals can either be analyzed manually or inspected with
% a tool such as dtTonalAnnotation()
% 
% result - An element of results as returned by scoreall, e.g. results(3)
% type - 'all' | 'snr' - Based on all ground truth tonals or only those
%       that meet selection criteria (more than just SNR)
% roots - {'oldbasedir', 'newbasedir'} - The detection files may be in a
%       different location than the one used when running the initial
%       detections.  The old base directory is stripped off and replaced
%       with the new one.  If omitted, not translation is done.
%
% Returns tonals structure:
%       tonals.falsePos - false positives
%       tonals.detections - the good, the bad, and the ugly (all)
%       tonals.gt_match - Detections that match ground truth 
%       tonals.gt_miss - Ground truth tonals that were not detected

if nargin < 3
    roots = [];
else
    if ~iscell(roots) || length(roots) ~= 2
        error('Roots must be {''Oldroot'', ''Newroot''');
    end
end


% False positives
fname = maproot(result.falsePos, roots);
tonals.falsePos = dtTonalsLoad(fname, 'Binary');
% Other fields
names = {'detections', 'gt_match', 'gt_miss'};
for idx=1:length(names)
    fname = maproot(result.(type).(names{idx}), roots);
    tonals.(names{idx}) = dtTonalsLoad(fname, 'Binary');
end

tonals.file = maproot(result.file, roots);

function newname = maproot(oldname, roots)
% newname = maproot(oldname, roots)
% Strip prefix roots{1} from oldname and replace with roots{2}
% Returns oldname if roots is empty

if isempty(roots)
    newname = oldname;
else
    newname = strrep(oldname, roots{1}, roots{2});
end

