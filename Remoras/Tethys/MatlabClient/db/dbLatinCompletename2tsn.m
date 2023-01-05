function tabular = dbLatinCompletename2tsn(queryH, names)
% tabular = dbLatinCompletename2tsn(q, names)
% Given a single Latin completename, a cell array of character strings,
% or an array of type string, return the list of TSNs that corresponds
% to each of the species names
%
% Returns a table containing completename (Latin) and corresponding TSN

if iscell(names) || ischar(names)
    names = string(names);
end

map = containers.Map();    
map('namespaces') = 0;  % Strip namespaces from results

% Create something like:  ("Kogia", "Grampus griseus")
%formatted_names = strjoin(names, '", "' );;
%value = sprintf('("%s")', formatted_names);
args = {"ranks/rank/completename", names, ...
    "return", "ranks/rank/tsn", ...
    "return", "ranks/rank/completename"};
dbParseOptions(queryH, "ranks", map, "tsn", args{:});

json = jsonencode(map);

 
result = queryH.QueryJSON(json);
 % Convert the result to a Matlab character array and process 
 xml_char = char(result);
 var_names = {'VariableNames', {'completename', 'tsn'}};
 if startsWith(xml_char, "<Result/>", 'IgnoreCase', true)
     bad_names = strjoin(names, "', '");
     fprintf("No Latin completenames found for '%s'", bad_names)
     tabular = cell2table(cell(0,2), var_names{:});
 else
    conversions = { 'tsn', 'double' };
    s = tinyxml2_tethys('parse', char(xml_char), conversions);
    % Extract inforamtion
    tabular = table(...
        cellstr([s.Return.ranks.rank.completename]'), ...
        cell2mat([s.Return.ranks.rank.tsn]'),var_names{:});
        
    if height(tabular) ~= length(names)
        bad_names = strjoin(setdiff(names, tabular.completename), "', '");
        warning("Unknown Latin completename(s): '%s'", bad_names);
    end
 end

