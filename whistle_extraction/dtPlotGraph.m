function [handles, cidx]= dtPlotGraph(tonal_collection, varargin)
% [handles, cidx]= dtPlotGraph(a_graph, OptionalArgs)
% Display a collection of tonals or graph n the current figure.
% tonal_collection - graph structure or iterable tonals
%
% Outputs a list of handles in a cell array representing the graph and
% cidx, indicating the last color used.  cidx is only meaningful if the
% Colors argument is used.
%
% Optional Arguments:
%
% 'ColorMap', colorMap
%    colorMap is a list of RGB vectors that will be used in plotting
%    the graph.  When colorMap is not specified, the current color map
%    is used.
%
% 'ColorIdx', cidx (defuault 1)
%    cidx is the first index into the colormap to be used.
%    The value of cidx is incremented modulo size(colorMap, 1) each time
%    a color is used within this plot.  The final cidx is
%    returned so that subsequent plots can be in different colors.
%    When not specified, the current colormap is used.
%
% 'DistinguishEdges', b (default false)
%    b is a boolean that indicates whether all edges
%    should be plotted the same color (false), or differently (true).
%    By default this is false.
%
% 'Scale', scale
%    Plot in 'Hz' or 'kHz'
%
% 'LineStyle', style
% 'Marker', marker
%    Matlab line properties.  Default to '-' and 'none'
%
% 'Plot', what
%    What should be plotted:
%    'edge' - show edges, with colors changing between edges
%    'phase' - encode phase by color.  The ColorIdx, cidx,
%          and DistinguishEdges parameters are not valid
%          with this option.

    function PlotTonal(tonal)
        % Plot a single edge
        % Uses static scope rules to access details on how to plot
        % and has side effects.
        
        time = tonal.get_time();
        freq = tonal.get_freq() / scale;
        switch PlotType
            case 'edge'
                handles{hidx} = plot(time, freq, ...
                    'LineStyle', LineStyle, 'Marker', Marker, ...
                    'Color', ColorMap(cidx, :), ...
                    'LineWidth', LineWidth);
                if Distinct
                    % Change color for the next edge
                    cidx = mod(cidx, colorN) + 1;
                end
                if ~isempty(EdgeCallback)
                    set(handles{hidx}, 'UserData', tonal);
                    set(handles{hidx}, 'ButtonDownFcn', EdgeCallback);
                end
                
            case 'phase'
                % lots more work to be done here
                if length(time) > 1
                    phase = tonal.get_phase();
                    %dphase = mod(diff(phase), 2*pi);
                    dphase = tonal.get_dphase();
                    handles{hidx} = quiver(time, freq, ...
                        cos(dphase), sin(dphase)*Ydelta/Xdelta, .05, '.-');
                end
        end
        hidx = hidx + 1;
    end

% Defaults
ColorMap = get(gcf, 'ColorMap');
cidx = 1;
Distinct = false;
scale = 1000; % kHz
LineStyle = '-';
PlotType = 'edge';
EdgeCallback = [];
Marker = 'none';
LineWidth = 4;
if nargin < 1
    error('A graph to plot must be specified');
end

k = 1;
while k <= length(varargin)
    switch varargin{k}
        case 'EdgeCallback'
            EdgeCallback = varargin{k+1}; k=k+2;
        case 'ColorMap'
            ColorMap = varargin{k+1}; k=k+2;
        case 'ColorIdx'
            cidx = varargin{k+1}; k=k+2;
        case 'DistinguishEdges'
            Distinct = varargin{k+1}; k=k+2;
        case 'Scale'
            scale = varargin{k+1}; k=k+2;
        case 'LineStyle'
            LineStyle = varargin{k+1}; k=k+2;
        case 'LineWidth'
            LineWidth = varargin{k+1}; k=k+2;
        case 'Marker'
            Marker = varargin{k+1}; k=k+2;
        case 'Plot'
            PlotType = varargin{k+1}; k=k+2;
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
            error(sprintf('Detector:%s', errstr));
    end
end

colorN = size(ColorMap, 1);

% Obtain the tonals
if isa(tonal_collection, 'tonals.graph')
    import java.util.LinkedList
    
    edges = tonal_collection.topological_sort();
    % convert to edge list to tonal list
    tonal_collection = java.util.LinkedList();
    edgeit = edges.iterator();
    while edgeit.hasNext()
        edge = edgeit.next();
        tonal_collection.addLast(edge.content);
    end
end
    
    
% preallocate handles cell array
handles = cell(tonal_collection.size(), 1);

hidx = 1;
holdstate = ishold;
hold on

Xdelta = diff(get(gca, 'XLim'));
Ydelta = diff(get(gca, 'YLim'));

tonalIt = tonal_collection.iterator();

while tonalIt.hasNext()
    tonal = tonalIt.next();
    PlotTonal(tonal);
end

if ~ Distinct
    % Graph plotted in one color, increment to next one
    cidx = mod(cidx, colorN) + 1;
end

if ~ holdstate
    hold off
end

end  % end function
