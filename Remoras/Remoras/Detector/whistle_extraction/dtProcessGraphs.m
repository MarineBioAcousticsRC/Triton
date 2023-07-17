function [tonals, discardedN] = dtProcessGraphs(thr, WaitTimeRejection, toneset, resolutionHz, tonal_h, tonal_ret)
% [tonals, discardedN] = dtProcessGraphs(thr, WaitTimeRejection, toneset, 
%                           resolutionHz, tonal_h, tonal_ret)
%
% Process the hypothesis graphs in toneset.  
% Extracted whistles that meet the retention criteria (based on
% duration and possibly wait time) are:
% 1.  Returned in tonals if tonal_ret is true
% 2.  Written to media if tonal_h is an instance of a TonalOutputStream

import tonals.*;
tonals = java.util.LinkedList();

discardedN = 0;

% NOTE: Last 2 flag argument for disambiguate java
%       method can't both be true (Experimental stage)
% false, true - polynomial fit of first difference of
%               phase to frequency
% true, false - vector strength
% false, false - polynomial fit of frequency to time
g = toneset.disambiguate(thr.disambiguate_s, resolutionHz,...
    false, false);

edges = g.topological_sort();   % Obtain the edges

% Loop through each edge and process the tonal associated with it
segIt = edges.iterator();
while segIt.hasNext()
    edge = segIt.next();
    tone = edge.content;

    % Check tonal rejection criteria
    rejectP = dtRejectTonalP(tone, thr, WaitTimeRejection);
    if rejectP
        discardedN = discardedN + 1;
    else
        % it's a keeper
        if tonal_ret
            tonals.addLast(tone);   % User wants tonals returned
        end
        if ~ isempty(tonal_h)
            tonal_h.write(tone);    % save tonal to media
        end
    end
end


function rejectP = dtRejectTonalP(tone, thr, WaitTimeRejection)
% rejectP = dtRejectTonalP(tone, thr, WaitTimeRejection)
% Check rejection criteria
% Tonal is rejected if it is too short
% or possibly if the wait times between peaks are inappropriate.

% too short?
duration = tone.get_duration();
rejectP = duration <= thr.minlen_s;

% expected time between peaks too long?  Only check
% if the tonal was not too short and the user has
% enabled wait time rejection
if ~ rejectP && ~isempty(WaitTimeRejection)
    % empirical evidence indicates [5, .034, .4] is good
    % for a 40% FA with a 10% miss rate
    
    % Only bother checking for shorter tonals
    if  duration < WaitTimeRejection(3)
        t = tone.get_time();
        N = length(t);
        % set up indices to compute lagged diff
        Rng1 = 1:N-WaitTimeRejection(1);
        Rng2 = 1+WaitTimeRejection(1):N;
        
        reject_p = isempty(Rng1); % reject if too few points
        if ~ reject_p % enough points, check mean wait time
            waits = t(Rng2) - t(Rng1);
            reject_p = mean(waits) > WaitTimeRejection(2);
        end
    end
end
