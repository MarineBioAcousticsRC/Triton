function [tonals] = dtDiscardShortGround(ground_truth, grnd_thrLen_s)
% Discard short ground truth tonals. Returns the updated list of ground
% truth tonals after discarding the shorter ones.
%
% ground_truth - Ground truth tonals
% grnd_thrLen_s - Threshold length for ground truth tonals

groundIt = ground_truth.iterator();
tonals = java.util.LinkedList();
grndDiscarded_cnt = 0;
while groundIt.hasNext()
    ground_truth_tonal = groundIt.next();
    
    g_startTime = ground_truth_tonal.getFirst().time;
    g_endTime = ground_truth_tonal.getLast().time;
    if (g_endTime - g_startTime) > grnd_thrLen_s
        tonals.add(ground_truth_tonal);
    else
        grndDiscarded_cnt = grndDiscarded_cnt + 1;
        continue;
    end
end
fprintf('Number of shorter ground truth tonals = %d \n', grndDiscarded_cnt);
