function dtcontrol(action)
global REMORA PARAMS HANDLES

if strcmp(action, '')

% Set minimum frequency for Broadband detector
elseif strcmp(action,'MinBroadbandFreq')
    ValueHz = str2double(get(REMORA.dt.MinBBFreqEdtxt,'String'));
    REMORA.dt.params.Ranges(REMORA.dt.params.ClickPos,1) = ...
        dtVerifyRange('Min Broadband freq', 0, PARAMS.fmax, ValueHz, 0, ...
        REMORA.dt.MinBBFreqEdtxt);
              
% Set maximum frequency for Broadband detector  
elseif strcmp(action,'MaxBroadbandFreq')
    ValueHz = str2double(get(REMORA.dt.MaxBBFreqEdtxt,'String'));
    REMORA.dt.params.Ranges(REMORA.dt.params.ClickPos,2) = ...
        dtVerifyRange('Max Broadband freq', 0, PARAMS.fmax, ...
        ValueHz, PARAMS.fmax, REMORA.dt.MaxBBFreqEdtxt);
    
% Set minimum saturation of broadband calls
elseif strcmp(action,'MinBBSaturation')
    minSaturationHz = str2double(get(REMORA.dt.MinBBSatEdtxt, 'string'));
    REMORA.dt.params.MinClickSaturation = ...
        dtVerifyRange('Broadband min. saturation Hz', 0, diff(REMORA.dt.params.Ranges(REMORA.dt.params.ClickPos,:)), ...
        minSaturationHz, diff(REMORA.dt.params.Ranges(REMORA.dt.params.ClickPos,:))*.8, ...
        REMORA.dt.MinBBSatEdtxt);  

% Set maximum saturation of broadband calls
elseif strcmp(action,'MaxBBSaturation')
    maxSaturationHz = str2double(get(REMORA.dt.MaxBBSatEdtxt, 'string'));
    REMORA.dt.params.MaxClickSaturation = ...
        dtVerifyRange('Broadband max. saturation Hz', REMORA.dt.params.MinClickSaturation*1.05, Inf, ...
        maxSaturationHz, diff(REMORA.dt.params.Ranges(REMORA.dt.params.ClickPos,:)), ...
        REMORA.dt.MaxBBSatEdtxt);
                  
% Set detection threshold above noise for broadband calls
elseif strcmp(action,'BBThreshold')
    REMORA.dt.params.Thresholds(REMORA.dt.params.ClickPos) = str2double(get(REMORA.dt.BBThresholdEdtxt, 'string')); 
end
end

