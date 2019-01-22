function dtPlotTonalSet(Filename, Tonalset, Color, Start_s, Stop_s, ...
    varargin)
% dtPlotTonalSet(Filename, tonalset, color, Start_s, Stop_s, OptionalArgs)
% Filename - Example - 'palmyra092007FS192-071011-230000.wav'
% Tonalset - Cell array of list of tonals
%            Example -  {tonalset1, tonalset2, ........}
% Color - Cell array of colors to plot different tonalsets.
%            Example -  {color1, color2, ........}
%            There is 1 to 1 mapping between tonalset and colors.
% Start_s - start time in s
% Stop_s - stop time in s
% Optional arguments in any order:
%   'ParameterSet', String or struct
%       Default set of parameters.  May either be a string
%       which is passed to dtThresh or a parameter structure
%       that has been loaded from dtThresh and possibly modified.
%       This argument is processed before any other argument, and other
%       arguments may override these values.
%   'Framing', [Advance_ms, Length_ms] - frame advance and length in ms
%       Defaults to 2 and 8 ms respectively
%   'Noise', method
%       Method for noise compensation in spectrogram plots.
%       It is recommended that the same noise compensation as
%       used for creating the tonal set and plotting them be used.  See
%       dtSpectrogramNoiseComp for valid methods. (default 'median')
%

import tonals.*;

% Defaults

% The threshold set is processed before any other argument as other
% arguments override the parameter set.
thr = dtParseParameterSet(varargin{:});  % retrieve parameters

NoiseMethod = {'median'};
scale = 1000; % kHz;

if length(Tonalset) ~= length(Color)
    error('Number of tonal sets and color must be equal');
end

k = 1;
while k <= length(varargin)
    switch varargin{k}
        case 'Framing'
            if length(varargin{k+1}) ~= 2
                error('%s must be [Advance_ms, Length_ms]', varargin{k});
            else
                thr.advance_ms = varargin{k+1}(1);
                thr.length_ms = varargin{k+1}(2);
            end
            k=k+2;
        case 'Noise'
            NoiseMethod = varargin{k+1}; k=k+2;
        case 'ParameterSet'
            k=k+2; % processed earlier
        otherwise
            try
                if isnumeric(varargin{k})
                    errstr = sprintf('Bad option %f', varargin{k});
                else
                    errstr = sprintf('Bad option %s', char(varargin{k}));
                end
            catch
                errstr = sprintf('Bad option in %d''optional argument', k);
            end
            error(sprintf('Plot:%s', errstr));
    end
end

% Plot Spectrogram
colormap(bone);
[notused ImageH] = dtPlotSpecgram(Filename, Start_s, Stop_s, ...
    'Framing', [thr.advance_ms, thr.length_ms], 'Noise', NoiseMethod);
% Load the icon stored in icon.mat
load icon;
% Add Brightness/Contrast icon to standard toolbar. When pushed
% brightness/contrast controls are displayed.
stdtoolH = findall(gcf, 'Type', 'uitoolbar');
uipushtool(stdtoolH, 'CData', cdata,...
    'Separator', 'on', 'HandleVisibility', 'off',...
    'TooltipString', 'Brightness/Contrast control',...
    'ClickedCallback', {@brightcontr_Callback, ImageH});
hold on;

% Plot detected tonals
%
% fileparts is Platform dependent.
[pathstr, fname, ext] = fileparts(Filename);
filenm = strcat(fname, ext);
title(filenm, 'fontname', 'helvetica', 'fontsize', 12,...
    'fontweight', 'b');

% Iterate over tonal sets
for tset = 1 : length(Tonalset)
    tonals = Tonalset{tset};
    % Iterate over tonals
    tonalN = tonals.size();
    for tidx = 1 : tonalN
        tonal = tonals.get(tidx-1);
        t = tonal.get_time();
        % Plot the tonal within the block limit.
        if ((t(1) <= Start_s) && (t(end) >= Start_s)) || ...
                (t(1) >= Start_s && t(1) <= Stop_s)
            
            f = tonal.get_freq() / scale;
            plot(t, f, Color{tset});
        end
    end
end

function brightcontr_Callback(hObject,eventdata, varargin)
% Brightness/Contrast controls
dtPlotBrightContrast(varargin{1});
