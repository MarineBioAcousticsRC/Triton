function dtcontrol(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% dtcontrol.m
%
% toggle on/off detection control window buttons
% set spectrogram detection parameters
%
% ripped off control.m Triton v 1.61
%
% Do not modify the following line, maintained by CVS
% $Id: dtcontrol.m,v 1.9 2008/02/27 01:11:41 mroch Exp $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES PARAMS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if strcmp(action, 'detection_noise')
    %
    % Noise selection for mean subtraction
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if get(HANDLES.dt.NoiseEst, 'Value')
        % User wants to pick means
        set(HANDLES.dt.MeanNoiseControls, 'Enable', 'off')
        PARAMS.dt.mean_selection = 2;
        set(HANDLES.fig.main,'pointer','fullcrosshair');
        disp_msg('Select start of noise')
    else
        % User cancels selection of means
        PARAMS.dt.mean_selection = 0;
        set(HANDLES.fig.main,'pointer','arrow');
        disp_msg('Noise selection cancelled, reverting to running mean');
        PARAMS.dt.mean_enabled = 0;
        set(HANDLES.dt.NoiseEst, 'Value', 0)
        set(HANDLES.dt.MeanNoiseControls, 'Enable', 'on')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action, 'MeanSubtractionDuration')
    %
    % Set running mean duration for spectral subtraction
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PARAMS.dt.MeanAve_s = str2double(get(HANDLES.dt.MeanSubDurEdtxt, 'string'));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action, 'dt_tonals')
    %
    % Set tonal detector state and allow parameter setting
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % set common detector parameters
    PARAMS.dt = dtGetSTParams(HANDLES.dt, PARAMS.dt);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action, 'dt_broadbands')
    %
    % Set broadband detector run/state and allow parameter setting
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % set common detector parameters
    PARAMS.dt = dtGetSTParams(HANDLES.dt, PARAMS.dt);
    
elseif strcmp(action,'MinTonalFreq')
    %
    % Set minimum frequency for Tonal detector
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ValueHz = str2double(get(HANDLES.dt.MinTonalFreqEdtxt,'String'));
    PARAMS.dt.Ranges(PARAMS.dt.WhistlePos,1) = ...
        dtVerifyRange('Min Tonal Freq', 0, PARAMS.fmax, ValueHz, 0, ...
                      HANDLES.dt.MinTonalFreqEdtxt);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'MaxTonalFreq')
    %
    % Set maximum frequency for Tonal detector
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ValueHz = str2double(get(HANDLES.dt.MaxTonalFreqEdtxt,'String'));
    PARAMS.dt.Ranges(PARAMS.dt.WhistlePos,2) = ...
        dtVerifyRange('Max Tonal Freq', 0, PARAMS.fmax, ...
                      ValueHz, PARAMS.fmax, ...
                      HANDLES.dt.MaxTonalFreqEdtxt);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'MinBroadbandFreq')
    %
    % Set minimum frequency for Broadband detector
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ValueHz = str2double(get(HANDLES.dt.MinBBFreqEdtxt,'String'));
    PARAMS.dt.Ranges(PARAMS.dt.ClickPos,1) = ...
        dtVerifyRange('Min Broadband freq', 0, PARAMS.fmax, ValueHz, 0, ...
                      HANDLES.dt.MinBBFreqEdtxt);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'MaxBroadbandFreq')
    %
    % Set maximum frequency for Broadband detector
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ValueHz = str2double(get(HANDLES.dt.MaxBBFreqEdtxt,'String'));
    PARAMS.dt.Ranges(PARAMS.dt.ClickPos,2) = ...
        dtVerifyRange('Max Broadband freq', 0, PARAMS.fmax, ...
                      ValueHz, PARAMS.fmax, HANDLES.dt.MaxBBFreqEdtxt);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'MinTonalDuration')
    %
    % Set minimum duration for tonal calls
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TonalDur_s = str2double(get(HANDLES.dt.MinDurEdtxt, 'string'));
    PARAMS.dt.WhistleMinLength_s = ...
        dtVerifyRange('Tonal duration s', 0, Inf, TonalDur_s, .25, ...
                      HANDLES.dt.MinDurEdtxt);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'MinTonalSeparation')
    %
    % Set minimum separation between tonal calls, merge if less
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TonalSep_s = str2double(get(HANDLES.dt.MinSepEdtxt, 'string'));
    PARAMS.dt.WhistleMinSep_s = ...
        dtVerifyRange('Tonal separation s', 0, Inf, TonalSep_s, .0256, ...
                      HANDLES.dt.MinSepEdtxt);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'MinBBSaturation')
    %
    % Set minimum saturation of broadband calls
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    minSaturationHz = str2double(get(HANDLES.dt.MinBBSatEdtxt, 'string'));
    PARAMS.dt.MinClickSaturation = ...
        dtVerifyRange('Broadband min. saturation Hz', 0, diff(PARAMS.dt.Ranges(PARAMS.dt.ClickPos,:)), ...
                      minSaturationHz, diff(PARAMS.dt.Ranges(PARAMS.dt.ClickPos,:))*.8, ...
                      HANDLES.dt.MinBBSatEdtxt);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'MaxBBSaturation')
    %
    %  Set maximum saturation of broadband calls
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    maxSaturationHz = str2double(get(HANDLES.dt.MaxBBSatEdtxt, 'string'));
    PARAMS.dt.MaxClickSaturation = ...
        dtVerifyRange('Broadband max. saturation Hz', PARAMS.dt.MinClickSaturation*1.05, Inf, ...
                      maxSaturationHz, diff(PARAMS.dt.Ranges(PARAMS.dt.ClickPos,:)), ...
                      HANDLES.dt.MaxBBSatEdtxt);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'TonalThreshold')
    %
    % Set detection threshold above noise for tonal calls
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PARAMS.dt.Thresholds(PARAMS.dt.WhistlePos) = str2double(get(HANDLES.dt.TonalThresholdEdtxt, 'string'));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'BBThreshold')
    %
    % Set detection threshold above noise for broadband calls
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PARAMS.dt.Thresholds(PARAMS.dt.ClickPos) = str2double(get(HANDLES.dt.BBThresholdEdtxt, 'string'));
end
