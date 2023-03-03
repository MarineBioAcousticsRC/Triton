function Map = visLocalizations(positions, varargin)
% Map = visLocalizations(positions, timestamps, OptionalArguments)
% positions:  rows of [lat, long, depth]
% timestamps:
%
% OptionalArguments
% 'Map', map - Add to specified webmap that already exists
% 'Points', false (default) | true | cell array of names - 
%   false - connect positions with a line
%   true - display as discrete points
%   names - cell array of strings of length size(positions, 1)
%       Each string is associated with one the positions
% 'Icon', filename - When plotting points, will use the image contained
%       in the specified file instead of the standard balloon.  Color
%       has no use when Icon is specified.
% 'Attributes', attribute_vector - Values associated with an attribute
%       that should be displayed via color coding.  Currently, only 
%       numerical values are supported (not categorical).
%       Examples:  encoding depth or time
% 'AttributeRange' [low, high] - Specify low and high values for the 
%       attribute range rather than taking them from the data.
%       Useful when the function is called multiple times with different
%       data to ensure that attributes are plotted with the same color
%       scheme.
% 'AttributeFmtStr', str - Specify how attributes are to be formatted
%       using fprintf style formatting strings.
%       Defaults to '%f'.  
%       Example:  'Depth: %.1f m' --> "Depth: 32.5 m"
% 'Color' - Specify a line or marker color (e.g. 'k').  If Attributes
%       are specified, a colormap function can be specified (e.g. @hsv
%       or @bone) or a desired RGB colormap (e.g. the output of hsv(100))
% 'Basemap', name - base map for webmap if 'Map' is not specified

ColorRangeN = 500;

Basemap = 'Ocean Basemap';
Attributes = [];
AttributeRange = [];
Map = [];
Points = false;
Colormap = [];
AttributeFmtStr = '%f';
IconName = {};
IconScale = {};

% mapname 'Contours Hawaii 100 Meter Lines'
% currently unused

% layer = wmsfind(mapname);
% [RasterMap, RasterRef] = wmsread(layer);

idx = 1;
while idx < length(varargin)
    switch varargin{idx}
        case 'Map'
            Map = varargin{idx+1}; idx = idx+2;
        case 'Basemap'
            Basemap = varargin{idx+1}; idx = idx+2;
        case 'Points', 
            Points = varargin{idx+1}; idx = idx + 2;
        case 'Attributes'
            Attributes = varargin{idx+1}; idx = idx + 2;
        case 'AttributeRange'
            AttributeRange = varargin{idx+1}; idx = idx + 2;
        case 'AttributeFmtStr'
            AttributeFmtStr = varargin{idx+1}; idx = idx + 2;
        case 'Color'            
            Colormap = varargin{idx+1}; idx = idx + 2;
        case 'Icon'
            IconName = {'Icon', varargin{idx+1}}; idx = idx + 2;
        case 'IconScale'
            IconScale= {'IconScale', varargin{idx+1}}; idx = idx + 2;
        otherwise
            error('Bad argument at argument %d', idx + nargin);
    end
end

% Start webmap
if isempty(Map)
    Map = webmap(Basemap);
end

% Useful for starting a map then adding things later...
if isempty(positions)
    return
end


% Set map view padded by past the extrema
%viewbounds = visGetExtents([positions(:,1:2); references(:,1:2)], .1);

%wmlimits(map, viewbounds(1,:), viewbounds(2,:));

% Create array of geoshapes corresponding to line segments between
% positions
N = size(positions, 1) - 1;
% Build backwards so that we allocate all of the geovecs at once
for idx = N:-1:1
    shapes(idx) = geoshape(positions(idx + [0 1], 1), positions(idx + [0 1], 2));    
end
%geovec = geoshape(positions(:,1), positions(:,2));
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
       % colormap will span specified times
       AttributeRange = [min(Attributes), max(Attributes)];
    end
    
    % Determine colors
    delta_attribute = diff(AttributeRange);
    
    % Assign colors
    if Points
        values = Attributes;
    else
        % code attributes to line segments rather than points
        % using a moving average
        values = filter([.5 .5], 1, Attributes);
    end
    % Compute points along time line
    u = (values - AttributeRange(1)) / delta_attribute;
    uidx = round(u * (ColorRangeN-1))+1;
    
    Colors = Palette(uidx, :);            
end

if Points == false
    % Show points as track
    z = wmline(Map, shapes, 'Color', Colors);
else
    % show individual points
    % list of names not yet implemented...

    if ~isempty(Attributes)
        attr_strings = cellstr(num2str(Attributes, AttributeFmtStr));
        attrs = {'FeatureName', attr_strings};
    else
        attrs = {};
    end
    wmmarker(Map, positions(:, 1), positions(:, 2), ...
        'Color', Colors, IconName{:}, IconScale{:}, attrs{:});

end
1;




