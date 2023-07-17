function mergedParams = sp_merge_detParams(newParams,oldParams)

oldFields = fieldnames(oldParams);
newFields = fieldnames(newParams);
commonParams = intersect(newFields,oldFields);
diffParams = setdiff(oldFields,newFields);
mergedParams = oldParams;% start with the original params
% Then replace anything that is set in new params. 

for iParam = 1:length(commonParams)
    mergedParams = setfield(mergedParams,commonParams{iParam},...
        getfield(newParams,commonParams{iParam}));
end

if ~isempty(diffParams)
    warning('on')
    warning('Some parameters were not included in new settings file.')
    warning('Default values will be used for:')
    diffParams
    warning('off')
end