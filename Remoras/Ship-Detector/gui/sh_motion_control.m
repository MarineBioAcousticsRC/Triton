function sh_motion_control(action)

global REMORA HANDLES

% back button
if strcmp(action, 'Back')
    motion_ltsa('back');
    sh_detector_motion
% forward button
elseif strcmp(action, 'Forward')
    motion_ltsa('forward');
    sh_detector_motion
% refresh button    
elseif strcmp(action, 'Refresh')
    sh_detector_motion
end

% update enabling of fwd/back buttons
set(REMORA.sh_verify.fwd, 'Enable', ...
    get(HANDLES.ltsa.motion.fwd, 'Enable'));
set(REMORA.sh_verify.back, 'Enable', ...
    get(HANDLES.ltsa.motion.back, 'Enable'));

% next part runs for everything, which is why refresh will work
% sh_plot_detections;

end
