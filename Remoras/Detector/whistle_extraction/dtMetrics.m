function dtMetrics(detected_tonals)
% Generates presence metric for both detected tonals and ground truth
% tonals. Performance measures Recall and Precision are also calculated.
% Ground truth tonals are loaded from saved file ground_truth.mat.
%
% detected_tonals - list of tonals detected.
%
% Example call:
% tonals = dtTonalsTracking(File, t0, t1, 'Framing', [2, 8]);
% detected_tonals = dtTonalsPlot(File, tonals, t0, t1,'Framing', [2, 8],...
% 'Plot', {'tonal'});
% dtPlotUIGroundtruth(File, detected_tonals, t0, t1, 'Framing', [2, 8]);
% dtMetrics(detected_tonals);


import tonals.*

% load ground_truth tonals
load ground_truth;

tonal_obj = tonal();

% detected_tonals presence metric
presence_mtr_detected = tonal_obj.presence(detected_tonals);
fprintf('\nPresence metric for detected tonals\n');
fprintf('Start time\t');
fprintf('End time\n');
for idx = 0 : presence_mtr_detected.get(0).size() - 1
    fprintf('%.3f\t\t',presence_mtr_detected.get(0).get(idx));
    fprintf('%.3f\n',presence_mtr_detected.get(1).get(idx));
end

% ground_truth_tonals presence metric
presence_mtr_ground = tonal_obj.presence(ground_truth_tonals);
fprintf('\nPresence metric for ground truth tonals\n');
fprintf('Start time\t');
fprintf('End time\n');
for idx = 0 : presence_mtr_ground.get(0).size() - 1
    fprintf('%.3f\t\t',presence_mtr_ground.get(0).get(idx));
    fprintf('%.3f\n',presence_mtr_ground.get(1).get(idx));
end


% Detected tonals time metric
time_mtr_detected = tonal_obj.get_time_startEnd(detected_tonals);
% Ground truth tonals time metric
time_mtr_ground = tonal_obj.get_time_startEnd(ground_truth_tonals);

% Start and end time Java array for detected tonals and ground truth tonals
s_time_detected = time_mtr_detected.get(0);
e_time_detected = time_mtr_detected.get(1);
s_time_ground = time_mtr_ground.get(0);
e_time_ground = time_mtr_ground.get(1);

% Check if there are any extra tonal added to ground truth tonal.
% If there are, we make size of detected tonal list equal to size of ground
% truth tonal list by adding 0.0 to start and end time of detected tonal
% for each extra ground truth tonal.
if (s_time_detected.size() ~= s_time_ground.size())
    size_diff = s_time_ground.size() - s_time_detected.size();
    for diff_idx = 1 : size_diff
        s_time_detected.add(0.0);
        e_time_detected.add(0.0);
    end
end

% Recall - Percent of whistles detected.
%          Of the N ground turth tonals points where tonal existed,
%          what percent did we detect.
detected_pts = 0.0;
ground_pts = 0.0;
for idx = 0 : s_time_ground.size() - 1
    
    % empty ground truth tonal
    if (s_time_ground.get(idx) == 0.0 && e_time_ground.get(idx) == 0.0)
        continue;
    end
    % empty detected tonal
    if (s_time_detected.get(idx) == 0.0 && e_time_detected.get(idx) == 0.0)
        ground_pts = ground_pts + (e_time_ground.get(idx) - ...
            s_time_ground.get(idx));
        continue;
    end
    
    ground_pts = ground_pts + e_time_ground.get(idx) ...
        - s_time_ground.get(idx);
    
    if (e_time_detected.get(idx) < e_time_ground.get(idx))
        if (s_time_detected.get(idx) < s_time_ground.get(idx))
            detected_pts = detected_pts + (e_time_detected.get(idx) - ...
                s_time_ground.get(idx));
        else
            detected_pts = detected_pts + (e_time_detected.get(idx) - ...
                s_time_detected.get(idx));
        end
    else
        if (s_time_detected.get(idx) < s_time_ground.get(idx))
            detected_pts = detected_pts + (e_time_ground.get(idx) - ...
                s_time_ground.get(idx));
        else
            detected_pts = detected_pts + (e_time_ground.get(idx) - ...
                s_time_detected.get(idx));
        end
    end
end
R = (detected_pts / ground_pts) * 100;
fprintf('\n\nRecall = %.2f%% \n', R);

% Precision - Percent of correct detection of whistle.
%             Of the N detected tonals points where there were detection,
%             what percent were correct.
correct_detected_pts = 0.0;
detected_pts = 0.0;
for idx = 0 : s_time_ground.size() - 1
    
    % empty ground truth tonal
    if (s_time_ground.get(idx) == 0.0 && e_time_ground.get(idx) == 0.0)
        detected_pts = detected_pts + (e_time_detected.get(idx) - ...
            s_time_detected.get(idx));
        continue;
    end
    % empty detected tonal
    if (s_time_detected.get(idx) == 0.0 && e_time_detected.get(idx) == 0.0)
        continue;
    end
    
    detected_pts = detected_pts + (e_time_detected.get(idx) - ...
        s_time_detected.get(idx));
    
    if (e_time_detected.get(idx) < e_time_ground.get(idx))
        if (s_time_detected.get(idx) < s_time_ground.get(idx))
            correct_detected_pts = correct_detected_pts + ...
                e_time_detected.get(idx) - s_time_ground.get(idx);
        else
            correct_detected_pts = correct_detected_pts + ...
                e_time_detected.get(idx) - s_time_detected.get(idx);
        end
    else
        if (s_time_detected.get(idx) < s_time_ground.get(idx))
            correct_detected_pts = correct_detected_pts + ...
                e_time_ground.get(idx) - s_time_ground.get(idx);
        else
            correct_detected_pts = correct_detected_pts + ...
                e_time_ground.get(idx) - s_time_detected.get(idx);
        end
    end
end
P = (correct_detected_pts / detected_pts) * 100;
fprintf('Precision = %.2f%% \n\n', P);




