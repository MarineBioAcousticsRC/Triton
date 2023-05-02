function dbParseUnmatchedErrors(err)
% dbParseUnmatchedErrors(err)
% Throw an error if the path query processor (dbParseOptions)
% was unable to determine the paths.  These will appear
% as unmatched entries in the err structure

if ~ isempty(err) && ~isempty(err.unmatched)
    msg = ["Unable to parse the following paths:"];
    for idx = 1:2:length(err.unmatched)
        if strcmp(err.unmatched{idx}, 'return')
            msg(end+1) = err.unmatched{idx+1};
        else
            msg(end+1) = err.unmatched{idx};
        end
    end
    message = strjoin(msg, "\n");
    error(sprintf(message));
end