function dtcontrol_ltsa(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% dtcontrol_ltsa.m
%
% toggle on/off detection control window buttons
% set LTSA detection parameters
%
% ripped off control.m Triton v 1.61
%%
% Do not modify the following line, maintained by CVS
% $Id: dtcontrol_ltsa.m,v 1.3 2007/02/12 18:17:28 mroch Exp $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES PARAMS
%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
if strcmp(action, 'IgnorePeriodic_toggle')
    % 
    % Toggle Ignore Periodic on/off with radio button
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if get(HANDLES.ltsa.dt.IgnPeriodic, 'Value')
        PARAMS.ltsa.dt.ignore_periodic=1;
        set(HANDLES.ltsa.dt.PeriodicEdit, 'Enable', 'On')
    else
        PARAMS.ltsa.dt.ignore_periodic=0;
        set(HANDLES.ltsa.dt.PeriodicEdit, 'Enable', 'Off')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'LowPeriod')
    %
    % Set new Low value for periodic signals
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    LowPeriod_s = str2num(get(HANDLES.ltsa.dt.LPeriodEdtxt,'String'));
    PARAMS.ltsa.dt.LowPeriod_s = ...
        dtVerifyRange('LTSA Low Ignore Periodic s', 0, Inf, ...
                      LowPeriod_s, 0, HANDLES.ltsa.dt.LPeriodEdtxt);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'HighPeriod')
    %
    %   Set new High value for periodic signals
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    HighPeriod_s = str2num(get(HANDLES.ltsa.dt.HPeriodEdtxt,'String'));
    PARAMS.ltsa.dt.HighPeriod_s = ...
        dtVerifyRange('LTSA High Ignore Periodic s', 0, Inf, ...
                      HighPeriod_s, 500, HANDLES.ltsa.dt.HPeriodEdtxt);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'MinFreq')
    %
    % Set minimum frequency for detection
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ValueHz = str2num(get(HANDLES.ltsa.dt.MinFreqEdtxt,'String'));
    PARAMS.ltsa.dt.HzRange(1) = ...
        dtVerifyRange('Min LTSA Detector Hz', 0, PARAMS.ltsa.fmax, ...
                      ValueHz, 0, HANDLES.ltsa.dt.MinFreqEdtxt);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'MaxFreq')
    %
    % Set maximum frequency for detection
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ValueHz = str2num(get(HANDLES.ltsa.dt.MaxFreqEdtxt,'String'));
    PARAMS.ltsa.dt.HzRange(2) = ...
        dtVerifyRange('Max LTSA Detector Hz', 0, PARAMS.ltsa.fmax, ...
                      ValueHz, PARAMS.ltsa.fmax, HANDLES.ltsa.dt.MaxFreqEdtxt);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    
elseif strcmp(action,'MinDuration')
    %
    % Set minimum duration between detections
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Value_s = str2num(get(HANDLES.ltsa.dt.MinDurEdtxt,'String'));
    PARAMS.ltsa.dt.MinDuration = ...
        dtVerifyRange('LTSA Min Duration s', 0, Inf, ...
                      Value_s, 1, HANDLES.ltsa.dt.MinDurEdtxt);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'Threshold')
    %
    % set threshold above noise
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Value_dB = str2num(get(HANDLES.ltsa.dt.ThresholdEdtxt,'String'));
    PARAMS.ltsa.dt.Threshold_dB = ...
        dtVerifyRange('LTSA Threshold dB', 0, Inf, ...
                      Value_dB, 2, HANDLES.ltsa.dt.ThresholdEdtxt);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action, 'detection_noise')
    %
    % Noise selection for mean subtraction
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if get(HANDLES.ltsa.dt.NoiseEst, 'Value')
        % User wants to pick means
        set(HANDLES.ltsa.dt.MeanNoiseControls, 'Enable', 'off')
        PARAMS.ltsa.dt.mean_selection = 2;
        set(HANDLES.fig.main,'pointer','fullcrosshair');
        disp_msg('Select start of noise')
    else
        % User cancels selection of means
        PARAMS.ltsa.dt.mean_selection = 0;
        set(HANDLES.fig.main,'pointer','arrow');
        disp_msg('Noise selection cancelled, reverting to running mean');
        PARAMS.ltsa.dt.mean_enabled = 0;
        set(HANDLES.ltsa.dt.NoiseEst, 'Value', 0)
        set(HANDLES.ltsa.dt.MeanNoiseControls, 'Enable', 'on')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'MeanSubtractionDuration')
    %
    % set duration for rolling mean subtraction
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Value_h = str2num(get(HANDLES.ltsa.dt.MeanSubDurEdTxt,'String'));
    PARAMS.ltsa.dt.Threshold_h = ...
        dtVerifyRange('LTSA Means subtraction h', 0, Inf, ...
                      Value_h, Inf, HANDLES.ltsa.dt.MeanSubDurEdTxt);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'plot_toggle')
    %
    % Toggle for plotting detections
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if get(HANDLES.ltsa.dt.plot, 'Value')
        PARAMS.ltsa.dt.ifPlot = 1;
    else
        PARAMS.ltsa.dt.ifPlot = 0;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'PlotClass_toggle')
    %
    % Toggle for plotting classifications
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     if get(HANDLES.ltsa.dt.plotClass, 'Value')
%         PARAMS.ltsa.dt.ifPlotClass = 1;
%     else
%         PARAMS.ltsa.dt.ifPlotClass = 0;
%     end
end;
