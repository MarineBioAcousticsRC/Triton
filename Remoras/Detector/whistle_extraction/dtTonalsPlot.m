function dtTonalsPlot(Filenames, tonals, graphs, Start_s, Stop_s, varargin)
% dtTonalsPlot(Filename(s), tonals, graphs, Start_s, Stop_s, OptionalArgs)
% Filenames - Cell array of filenames that are assumed to be consecutive
%            Example -  {'palmyra092007FS192-071011-230000.wav',
%                        'palmyra092007FS192-071011-231000.wav'}
% graphs - Set of detected graphs from which tonals were extracted
% tonals - whistle like tonals
% Start_s - start time in s relative to the start of the first recording
% Stop_s - stop time in s relative to the start of the first recording
%
% Optional arguments in any order:
%   'Framing', [Advance_ms, Length_ms] - frame advance and length in ms
%       Defaults to 2 and 8 ms respectively
%   'Plot', str or cell array of strings - 
%       Indicates what to plot.  When more than one plot type is specified,
%       the figure is broken into subplots and each type is plotted on
%       a separate axis.  The axes are linked.
%       'graph' - Plots tonal graphs
%       'edge' - Plot edges of tonal graphs
%       'tonal' (default) - Plot extracted tonals
%       'spectrogram' - spectrogram only
%   'OverSpectrogram', [] or {} or cell array of strings -
%       Controls if and how a spectrogram is created before plotting tonals
%       [] - no spectrogram
%       {} - default spectrogram (gray scale, fast noise subtraction)
%       cell array - spectrogram with optional arguments from
%            dtPlotSpecgram.  
%       Example:  
%         'OverSpectrogram', {'Render', 'floor', 'Noise', 'median'}
%         Plots whatever was specified by 'Plot' on top of a spectrogram
%         that has been smoothed by a median smoother.  All time X freq
%         nodes beneath the default threshold have been set to black.
%       Note that the specified parameters override what would have been
%       plotted by default.  Thus, the range is still appropriate and
%       the default noise subtraction are used.
%   'ParameterSet', String or struct
%       Default set of parameters.  May either be a string
%       which is passed to dtThresh or a parameter structure
%       that has been loaded from dtThresh and possibly modified.
%       This argument is processed before any other argument, and other
%       arguments may override these values.
%   'NewFigure', boolean
%       Create new figure (default) or plot on existing one.
%       When plotting on an existing figure, plotting multiple
%       things is likely to cause problems due to the call to subplot.
%    'AxisColor', Color
%       Plot labels and axis in specified color, e.g. 'w' - white
%    'ReverseColor', true|false (default false)
%       Colormap is flipped such that high energy plots are displayed
%       as darker colors
%
% Example call:
% [tonals graphs]= dtTonalsTracking(File, t0, t1, 'Framing', [2, 8]);
% dtTonalsPlot(File, tonals, graphs, t0, t1,'Framing', [2, 8], 'Plot', ...
% {'spectrogram', 'graph'});

import tonals.*;

% defaults -----------------------------------------------
PathType = {'tonal'};   % plot whistles
AxisColor = {};
NewFigure = true;
BlackWhite = true;
ReverseColor = false;
HzPerkHz = 1000;
% The threshold set is processed before any other argument as other
% arguments override the parameter set.
thr = dtParseParameterSet(varargin{:});

SpecArgs = {};   % plot tonals over default spectrogram

% The hue, saturation, value color map is a nice one to use as it
% produces colors across the visible spectrum.  Unfortunately, they
% sequentially close to one another, so we randomize them.
colorsN = 7;
colors = hsv(colorsN); 
colors = colors(randperm(colorsN), :);
coloridx = 1;

% processs arguments -------------------------------------
k = 1;

if ischar(Filenames)
    Filenames = {Filenames};
end

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
        case 'AxisColor'
            AxisColor = varargin(k+1); k=k+2;
        case 'ParameterSet'
            k=k+2; % already processed
        case 'Plot'
            PathType = varargin{k+1}; k=k+2;
            if ischar(PathType)
                PathType = {PathType};
            elseif ~ iscell(PathType)
                error('Plot argument must be a string or cell');
            else
                % verify the plot types here as plotting is expensive
                % and it's better to find an error now than on the Nth
                % plot
                for m=1:length(PathType)
                    switch PathType{m}
                        case {'graph', 'edge', 'tonal', ...
                                'spectrogram', 'phase'}
                        otherwise
                            error('Bad Plot type')
                    end
                end
            end
            
        case 'OverSpectrogram'
            SpecArgs = varargin{k+1}; k=k+2;
            
        case 'NewFigure'
            NewFigure = varargin{k+1}; k=k+2;
            
        case 'ReverseColor'
            ReverseColor = varargin{k+1}; k=k+2;
            if ~ isscalar(ReverseColor)
              error('%s must be true or false', varargin{k});
            end
            
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
            error(errstr);
    end
end

% do the work ----------------------------------------------

file_idx = 1;


if NewFigure
    figH = figure('Name', 'Tonal plot');
else
    figH = gcf;  % use current figure
end

PathTypeN = length(PathType);
holdstate = ishold;

 if iscell(SpecArgs)
     if ~ isempty(SpecArgs)
         if iscell(SpecArgs{1})
             % each item is a spectrogram argument list
             SpecArgList = SpecArgs;
         else
             % charcteristics for all spectrograms
             SpecArgList = {SpecArgs};
         end
     else
         SpecArgList = {{SpecArgs}};
     end
 else
     SpecArgList = {SpecArgs};
 end
 
ImageH = []; % Image handle (Spectrogram)
ax = zeros(PathTypeN, 1);
for s=1:PathTypeN
    set(0, 'CurrentFigure', figH);  % make figure current
    SpecArgs = spectrogram_params(...
        SpecArgList{min(s, length(SpecArgList))}, ...
        thr.advance_ms, thr.length_ms, thr.high_cutoff_Hz, AxisColor);
    if BlackWhite
        map = bone;
    else
        map = jet;
    end
    if ReverseColor
        map = flipud(map);
    end
    % Set appropriate subplot if needed
    if PathTypeN > 1
        ax(s) = subplot(PathTypeN, 1, s);
    else
        ax(s) = gca;
    end
    colormap(map);
    hold on
    
    if ~ isempty(SpecArgs)
        % might be nice to plot once and duplicate image, worry about
        % that later
        [notused ImH] = dtPlotSpecgram(Filenames{file_idx}, ...
            Start_s, Stop_s, 'ParameterSet', thr, SpecArgs{:});
        ImageH = [ImageH ImH];
        hold on
    end
    start_t = tic;
    switch PathType{s} 
        case 'spectrogram'
            % do nothing
        case 'tonal'
            [newh, coloridx] = dtPlotGraph(tonals, 'ColorMap', colors, ...
                'ColorIdx', coloridx, 'DistinguishEdges', true, ...
                'LineWidth', 2, 'EdgeCallback', @dtEdgePhaseCB);
        otherwise
            % iterator over graphs and plot approrpriately
            it = graphs.iterator();

         while it.hasNext()
            toneset = it.next();
            switch PathType{s}
                case 'graph'
                    [newh, coloridx] = dtPlotGraph(toneset, 'ColorMap',colors, ...
                        'ColorIdx', coloridx, 'DistinguishEdges', false, ...
                        'LineWidth', 2, ...
                        'EdgeCallback', @dagcb); %@dtEdgePhaseCB);
                    
                case 'phase'
                    [newh, coloridx] = dtPlotGraph(toneset, ...
                        'ColorIdx', coloridx, 'DistinguishEdges', false, ...
                        'Plot', 'phase');

                case 'edge'
                    % When the edge call back is set, Java objects
                    % are associated with the figure.  I'm not sure yet,
                    % but it seems like clear java doesn't seem to work,
                    % even if we close the figure.  We don't seem to be
                    % seeing the changes which makes me think that the Java
                    % objects are not being released...
                    EdgeCallback = {'EdgeCallback', @dtEdgeCallback};
                    %EdgeCallback = {};
                    [newh, coloridx] = dtPlotGraph(toneset, ...
                        'ColorMap', colors, 'ColorIdx', coloridx, ...
                        'DistinguishEdges', true, EdgeCallback{:});
                    
                otherwise
                    error('Bad argument to Show:  %s', PathType{s});
            end
            coloridx = mod(coloridx, colorsN) + 1;
         end
    end
    fprintf('Compute & render %s: ', PathType{s});
    fprintf('\nElapsed time since start:  %s\n', ...
        datestr(datenum(0, 0, 0, 0, 0, toc(start_t)), 13));
    title(PathType{s});
    xlabel('time (s)')
    ylabel('freq (kHz)')
    if ~ isempty(AxisColor)
        AxisH = gca;
        set(get(AxisH, 'Title'), 'Color', AxisColor{:});
    end
end

% Load the icon stored in icon.mat
load icon;
% Add Brightness/Contrast icon to standard toolbar. When pushed
% brightness/contrast controls are displayed.
stdtoolH = findall(figH, 'Type', 'uitoolbar');
uipushtool(stdtoolH, 'CData', cdata,...
    'Separator', 'on', 'HandleVisibility', 'off',...
    'TooltipString', 'Brightness/Contrast control',...
    'ClickedCallback', {@brightcontr_Callback, ImageH});

if length(ax) > 1
    linkaxes(ax);
end

if ~ holdstate
    hold off
end

function Args = spectrogram_params(ArgList, Advance_ms, Length_ms, Cutoff_Hz, AxisColor)
% set spectrogram parameters
if iscell(ArgList)
    % spectrogram desired, set parameters
    Defaults = {'Framing', [Advance_ms, Length_ms], ...
        'Click_dB', 10,  ...
        'Noise', {'median'}, 'AxisColor', AxisColor};
    if ~ isempty(ArgList)
        if isempty(ArgList{1})
            if iscell(ArgList{1})
                Args = {Defaults{:}};
            else
                Args = {};
            end
        else
            % Defaults overridden by user settings
            Args = {Defaults{:}, ArgList{:}};
        end
    end
else
    if ~ isempty(ArgList)
        error('OverSpectrogram must be a cell array or []');
    end
end

function brightcontr_Callback(hObject,eventdata, varargin)
% Brightness/Contrast controls
dtPlotBrightContrast(varargin{1});
