function sp_dt_motion(action)

global REMORA HANDLES

% back button
if strcmp(action, 'back')
    motion('back');
    sp_dt_gui
% forward button
elseif strcmp(action, 'forward')
    motion('forward');
    sp_dt_gui
elseif strcmp(action, 'refresh')
    % check if xwav has been loaded and enable editing if so
    % set back/fwd buttons to corresponding handles on control panel
%     if isfield(PARAMS, 'xhd')
%         set(REMORA.spice_dt.MinBBFreqEdtxt, 'Enable', 'on');
%         set(REMORA.spice_dt.MaxBBFreqEdtxt, 'Enable', 'on');
%     end
    sp_dt_gui
end

% update enabling of fwd/back buttons
set(REMORA.spice_dt.fwd, 'Enable', ...
    get(HANDLES.motion.fwd, 'Enable'));
set(REMORA.spice_dt.back, 'Enable', ...
    get(HANDLES.motion.back, 'Enable'));

% next part runs for everything, which is why refresh will work
% Run detection on current spectrogram plot (if spectrogram open)
%if ~isempty(REMORA.spice_dt.guiDets)
sp_plot_detections;
%         dtST_signal(PARAMS.pwr, PARAMS.fs, PARAMS.nfft, PARAMS.overlap, ...
%             PARAMS.f, true, 'Ranges', REMORA.dt.params.Ranges , ...
%             'MinClickSaturation', REMORA.dt.params.MinClickSaturation, ...
%             'MaxClickSaturation', REMORA.dt.params.MaxClickSaturation, ...
%             'WhistleMinLength_s', REMORA.dt.params.WhistleMinLength_s ,...
%             'WhistleMinSep_s', REMORA.dt.params.WhistleMinSep_s, ...
%             'Thresholds', REMORA.dt.params.Thresholds, ...
%             'MeanAve_s', REMORA.dt.params.MeanAve_s, ...
%             'WhistlePos', REMORA.dt.params.WhistlePos, ...
%             'ClickPos', REMORA.dt.params.ClickPos);
%    end
end

% check for classification labels
% if REMORA.dt.class.PlotLabels
%   dtPlotLabels('spectra', ...
%     .9* PARAMS.f(PARAMS.fimax)-PARAMS.f(PARAMS.fimin));
% end