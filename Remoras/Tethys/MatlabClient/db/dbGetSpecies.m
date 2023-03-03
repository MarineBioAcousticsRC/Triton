function species = dbGetSpecies(queries, expedition, site)
% species = dbGetSpecies(queries, expedition, site)
% Determine which species have been detected
% for a given expedition and site.

if nargin > 1
    expedition = sprintf('Expedition = "%s"', expedition);
    if nargin > 2
        site = sprintf('and Site = "%s"', site);
    else
        site = [];
    end
else
    expedition = [];
end

if isempty(site) && isempty(expedition)
    options = '';
else
    options = sprintf('[%s %s]', expedition, site);
end
queryStr = sprintf(...
    'distinct-values(collection("Detections")/Detections/Deployment%s/../Detection/Species)', ...
    options);

species = cell(queries.Query(queryStr).split('\n'));

