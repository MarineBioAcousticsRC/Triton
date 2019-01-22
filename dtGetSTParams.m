function STParams = dtGetSTParams(handles, STParams)
% STParams = dtGetSTParams(handles, STParams)
%
% Read the short time detection parameters from a set of handles and
% populate an existing structure (STParams) when specified, or
% create a new one.
error(nargchk(1,2,nargin));

STParams.Ranges = zeros(0,2);  % start empty
STParams.Thresholds = zeros(1,0);

% We should think about how to restructure this such that it can
% be data driven... project for later (MAR)

Values = {'off', 'on'};

STParams.MeanAve_s = str2double(get(handles.MeanSubDurEdtxt, 'string'));

% check tonal detector
enabled = get(handles.tonals, 'Value');
set(handles.TonalControls, 'Enable', Values{enabled+1});
STParams.WhistleMinLength_s = str2double(get(handles.MinDurEdtxt, 'string'));
STParams.WhistleMinSep_s = str2double(get(handles.MinSepEdtxt, 'string'));
if enabled
    range = [str2double(get(handles.MinTonalFreqEdtxt, 'string')), ...
        str2double(get(handles.MaxTonalFreqEdtxt, 'string'))];
    STParams.Ranges(end+1,:) = range;
    STParams.Thresholds(end+1) = str2double(...
        get(handles.TonalThresholdEdtxt, 'string'));
    STParams.WhistlePos = size(STParams.Ranges, 1);
else
    STParams.WhistlePos = 0;
end

% check click detector
enabled = get(handles.broadbands, 'Value');

set(handles.BBControls, 'Enable', Values{enabled+1});
STParams.MinClickSaturation = ...
    str2double(get(handles.MinBBSatEdtxt, 'string'));
STParams.MaxClickSaturation = ...
    str2double(get(handles.MaxBBSatEdtxt, 'string'));
if enabled
    range = [str2double(get(handles.MinBBFreqEdtxt, 'string')) ...
        str2double(get(handles.MaxBBFreqEdtxt, 'string'))];
    STParams.Ranges(end+1,:) = range;
    STParams.Thresholds(end+1) = str2double(...
        get(handles.BBThresholdEdtxt, 'string'));
    STParams.ClickPos = size(STParams.Ranges, 1);
else
    STParams.ClickPos = 0;
end
