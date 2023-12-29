function Map = visTracks(tracks, varargin)
% Map = visLocalizations(tracks, OptionalArguments)
% tracks contains a structure array conforming to the WGS84 Tethys
% specification.  It must have:
%   Longitudes
%   Latitudes
%   Timestamps
% other fields are permissible but not used
%
% To obtain a set of tracks, use the dbGetLocalizations: e.g.
%  l = dbGetLocalization(q);  % where q is a database handle (see dbInit)
%  
% (e.g. part of what is returned by dbGetLocalizations)
% Each Track has the following fields that will be used:
% Extract the WGS84 component:
% wgs = arrayfun(@(x) x.Track.WGS84, l.Localization);
%
% OptionalArguments
% 'Map', map - Add to specified webmap that already exists
% 'Icon', filename - When plotting points, will use the image contained
%       in the specified file instead of the standard balloon.  Color
%       has no use when Icon is specified.
% 'Attribute', {Name, attribute_vector} - Values associated with a track
%       that will be displayed when the track is selected.
% 'ColorAttribute', Name - This attribute will be used to color track lines
% 'AttributeRange' [low, high] - Specify low and high values for the 
%       attribute range rather than taking them from the data.
%       Useful when the function is called multiple times with different
%       data to ensure that attributes are plotted with the same color
%       scheme.
% 'Color' - Specify a line or marker color (e.g. 'k').  If Attributes
%       are specified, a colormap function can be specified (e.g. @hsv
%       or @bone) or a desired RGB colormap (e.g. the output of hsv(100))
% 'Basemap', name - base map for webmap if 'Map' is not specified

ColorRangeN = 500;

Basemap = 'Ocean Basemap';
Attributes = containers.Map();
AttributeRange = [];
Map = [];
Colormap = [];
IconName = {};
IconScale = {};
ColorAttribute = 'Start';

% mapname 'Contours Hawaii 100 Meter Lines'
% currently unused

% layer = wmsfind(mapname);
% [RasterMap, RasterRef] = wmsread(layer);

tidx = 1;
while tidx < length(varargin)
    switch varargin{tidx}
        case 'Map'
            Map = varargin{tidx+1}; tidx = tidx+2;
        case 'Basemap'
            Basemap = varargin{tidx+1}; tidx = tidx+2;
        case 'Attribute'
            val = varargin{tidx+1};
            if ~iscell(val) | length(val) ~= 2
                error('Attribute value must be a cell array of name and values');
            end
            Attributes(val{1}) = val{2};
            tidx = tidx + 2;
        case 'AttributeRange'
            AttributeRange = varargin{tidx+1}; tidx = tidx + 2;;
        case 'ColorAttribute'            
            ColorAttribute = varargin{tidx+1}; tidx = tidx + 2;
        case 'Icon'
            IconName = {'Icon', varargin{tidx+1}}; tidx = tidx + 2;
        case 'IconScale'
            IconScale= {'IconScale', varargin{tidx+1}}; tidx = tidx + 2;
        otherwise
            error('Bad argument at argument %d', tidx + nargin);
    end
end

N = length(tracks);

% Get the start and end time of each track
Attributes('Start') = cell2mat(cellfun(@(x) x{1}(1), ...
        {tracks.Timestamps}, 'UniformOutput', false));
Attributes('End') = cell2mat(cellfun(@(x) x{1}(end), ...
        {tracks.Timestamps}, 'UniformOutput', false));

if isempty(Attributes)
    if isempty(Colormap)
        Colors = 'k';  % default when nothing supplied
    else
        Colors = Colormap;
    end
else
    if isempty(Colormap)
        Palette = hsv(ColorRangeN);  % default color map
    elseif isa(Colormap, 'function_handle')
        Palette = Colormap(ColorRangeN);
    elseif ischar(ColorMap)
        Palette = ColorMap;
    elseif isnumeric(ColorMap)
        assert(size(ColorMap, 2) == 3)
        Palette = ColorMap;
    end
    
    if isempty(AttributeRange)
       % Determine the min/max of the desired attribute
       AttributeRange = minmax(Attributes(ColorAttribute));
    end
    
    % Determine colors
    delta_attr = diff(AttributeRange);
    
    % Fn to assign colors to indices in size ColorRangeN color map
    attr2color = @(v) Palette(...
        round((v-AttributeRange(1))./delta_attr.*(ColorRangeN-1))+1, :);
end



% Construct a set of tracks
% We construct each line segment with a color based on the time between
% the start and end of the segment. This requires that each track be
% rendered as separate segments.

% Count number of segments
% sum number of points in each segment, subtracting one from each track
% as there are N-1 segments in a track defined by N points
trackpointsN = arrayfun(@(x) length(x.Longitudes{1}), tracks);  % points/track
segmentsN =  sum(trackpointsN - 1);
colors = zeros(N,3);
segidx = 1;

% Build up a cell array with 'AttrName', AttrVal, 'AttrName2', AttrVa2, ...
keys = Attributes.keys();
keyvals = cell(length(keys)*2, 1);
for kidx = 1:length(keys)
    keyvals{(kidx-1)*2+1} = keys{kidx};
    keyvals{(kidx-1)*2+2} = Attributes(keys{kidx});
end

colorval = Attributes(ColorAttribute);
for tidx = 1:N
    for kidx = 1:length(keys)
        vals = Attributes(keys{kidx});
        value = vals(tidx);
        if strcmp(keys{kidx}, 'Start') | strcmp(keys{kidx}, 'End')
            value = datestr(value, 0);
        end
        info.(keys{kidx}) = value;
    end
    if tidx == 1
        tidx
        % allocate entire array by copying first item to last, will
        % be overwritten
        shapes(tidx) = geoshape(...
            tracks(tidx).Latitudes{1}, tracks(tidx).Longitudes{1}, ...
            info);
        shapes(1) = shapes(tidx);
    else
        shapes(tidx) = geoshape(...
            tracks(tidx).Latitudes{1}, tracks(tidx).Longitudes{1}, ...
            info);
    end
    colors(tidx, :) = attr2color(colorval(tidx));
end


% Start webmap
if isempty(Map)
    Map = webmap(Basemap);
end

wmline(shapes, 'Color', colors);





