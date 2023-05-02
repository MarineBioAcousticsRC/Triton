function el_types = dbGetSchemaTypes(q, root_element)
% el_types = dbGetSchemaTypes(q, root_element)
% Determine element types from schema root element
% For internal use only

csv = q.getSchema(root_element);
csv_str = string(csv);

% Extract field names
csv_list = csv_str.splitlines();
fieldnames = csv_list(1).split(",");

% scan text, %q is possibly quoted text
hdrfmt = repmat("%q", length(fieldnames), 1);
hdrfmt = hdrfmt.join("");
data = textscan(csv_str, hdrfmt, 'Headerlines', 1, ...
    'EndOfLine', newline, 'Delimiter', ',');

% Convert to a table
schema = table(data{:}, 'VariableNames', fieldnames);

% Build up conversions
types = ["xs:double", "list(xs:double)", "xs:dateTime", "list(xs:dateTime)"];
convert_to = ["double", "double", "datetime", "datetime"];
el_types = cell(0,2);
for idx = 1:length(types)
    subtable = schema(strcmp(schema.type, types(idx)), :);
    N = height(subtable);
    if N > 0
        elements = cellfun(@(x) regexprep(x, ".*/", ""), subtable.path, ...
            'UniformOutput', false);
        to = repmat(convert_to(idx), length(elements), 1);
        el_types(end+1:end+N, :) = horzcat(elements, convertStringsToChars(to));
    end
end

