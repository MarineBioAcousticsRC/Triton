function result = dbSpeciesAbbreviations(queryH, abbreviation_map_name)
% dbSpeciesAbbreviations(queryH, abbreviations)
% Given a queryH to a Tethys instance, either:
%
% 1 - If a abbreviation set name is provided, return a table
%     consisting of abbreviation, Latin name, and TSN.
% 2 - If no abbreviation set name is provided, return a string array containing the
%     names of abbreviation maps.

narginchk(1, 2)


map = containers.Map();    
map('namespaces') = 0;  % Strip namespaces from results

if nargin < 2
    map('return') = ["Abbreviations/Name"];
    json = jsonencode(map);
    result = queryH.QueryJSON(json);
    s = tinyxml2_tethys('parse', char(result), {});
    result = string(s.Name);
else
    % Build the JSON interface to XQuery and execut it
    err = dbParseOptions(queryH, "Abbreviations", map, "NA", ...
        "Abbreviations/Name", string(abbreviation_map_name), ...
        "return", "Abbreviations/Map");
    json = jsonencode(map);
    xml= queryH.QueryJSON(json);
    
    % Convert the result to a Matlab character array and process
    xml_char = char(xml);
    if strcmpi(xml_char, "<Result/>")
        error('Unable to retrieve abbreviation map "%s"', abbreviation_map_name);
    end
    s = tinyxml2_tethys('parse', xml_char, {'tsn', 'double'});  % to struct
    
    % Create a table and massage the data to make it look nice
    % Data that only occur sporadically (e.g., the Group attribute)
    % require special handling.
    
    result = struct2table(s.Return.Abbreviations.Map);
    result.Group = cell(height(result),0);  % Empty for all groups
    % Find where we have attributes and grab the Group
    if isfield(s.Return.Abbreviations.Map, 'completename_attr')
        attrP = arrayfun(@(x) isstruct(x.completename_attr), s.Return.Abbreviations.Map);
        groups = arrayfun(@(x) x.completename_attr.Group, s.Return.Abbreviations.Map(attrP), 'UniformOutput', false);
        result.Group(attrP) = groups;  % Populate groups with values
        % Remove completename attribute, we've processed it.
        result.completename_attr = [];
    end
    if isfield(s.Return.Abbreviations.Map', 'tsn')
        % Remove cell entries for taxonomic serial numbers (if present)
        result.tsn = cell2mat(result.tsn);
    end
    
end
    
