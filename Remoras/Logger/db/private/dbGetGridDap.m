function results = dbGetGridDap(dom, squeezeP)

domdims = dbXPathDomQuery(dom, 'Grid/Dims');
dims = char(dbDomGetValue(domdims.item(0).getChildNodes(), 0));
dims = sscanf(dims, '%d')';

results.Axes = populate(dom, 'Axes');
results.Data = populate(dom, 'Data');
for idx = 1:length(results.Data.values)
    results.Data.values{idx} = reshape(results.Data.values{idx}, dims);
end

if squeezeP
    % Remove any singleton dimensions
    singletonP = dims == 1;
    if any(singletonP)
        % Copy singletons to a constants structure and remove
        % them from the Axes structure
        for f = {'names', 'units', 'types', 'values'}
            f = f{1};
            results.Constants.(f) = results.Axes.(f)(singletonP);
            results.Axes.(f)(singletonP) = [];
        end
        for idx = 1:length(results.Data.values)
            results.Data.values{idx} = squeeze(results.Data.values{idx});
        end
        dims(singletonP) = [];
    end
    
end
results.dims = dims;

1;

function result = populate(dom, element)
% result = populate(dom, element)
% Given a dom with an element that has the following children:
% Names, Units, Types, and Values
% extract the data into a structure

path = sprintf('Grid/%s', element);
% Pull out the names, units, and types for axes
namesnode = dbXPathDomQuery(dom, sprintf('%s/Names/item', path));
result.names = getItems(namesnode);
unitsnode = dbXPathDomQuery(dom, sprintf('%s/Units/item', path));
result.units = getItems(unitsnode);
typesnode = dbXPathDomQuery(dom, sprintf('%s/Types/item', path));
result.types = getItems(typesnode);

% Pull out values for axes
valuesnodes = dbXPathDomQuery(dom, sprintf('%s/Values', path));
result.values = cell(valuesnodes.getLength(), 1);  % preallocate
for idx=1:length(result.values)  % populate
    if strcmp(result.types{idx}, 'String')
        values{idx} = getItems(valuesnodes.item(idx-1));
        if strcmp(result.units{idx}, 'UTC')
            result.values{idx} = dbISO8601toSerialDate(values{idx});
            result.types{idx} = 'datenum';
        end
    else
        result.values{idx} = sscanf(...
            char(...
              valuesnodes.item(idx-1).getFirstChild().getNodeValue()...
            ), '%g');
    end
end

function values = getItems(domarray, convert)
% Expecting a list of nodes with the same element, e.g.
%  <item> a </item>
%  <item> b </item>
% extract an array/vector of values.
% By default treats as characters and retruns a cell array.
% The optional convert allows specification of a different
% convervsion function, e.g. @double in which case a vector is
% returned.

len = domarray.getLength();

numeric = nargin > 1 && ~isequal(convert, @char);

if numeric
    values = zeros(len, 1);
    for idx=1:len
        values(idx) = convert(char(domarray.item(idx-1).item(0).getNodeValue()));
    end
else
    values = cell(len, 1);
    for idx=1:len
        values{idx} = char(domarray.item(idx-1).item(0).getNodeValue());
    end
end





