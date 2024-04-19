function dbParseUnrecoverableErrorCheck(err)
% dbParseUnrecoverableErrorCheck(err)
% Parses the error output of dbParseOptions and throws an error
% if the erorr is something that cannot possibly be fixed
% This only checks for errors due to ambiguous names and
% specifying selection criteria for schema elements that should
% not have values
if ~isempty(err)
    throw_error = false;
    if ~isempty(err.ambiguous.candidates)
        err_msg = "The following elements were ambiguous:\n";
        
        for idx = 1:length(err.ambiguous.candidates)
            pattern = err.ambiguous.directives((idx-1)*2+1);
            if strcmp(pattern, 'return')
                pattern = "A return value was ambiguous. ";
            end
            err_msg = err_msg + pattern + "It matched: " + ...
                strjoin(err.ambiguous.candidates{idx}, ", ") + "\n";
        end
        throw_error = true;
    else
        err_msg = "";
    end
    
    if ~isempty(err.not_selectable)
        err_msg = err_msg + ...
            "The following elements were used as selection criteria, " + ...
            "but are not defined in the schema as containing values\n" + ...
            "(execute dbOpenSchemaDescription to see the schema) :\n";
        err_msg = err_msg + strjoin(err.not_selectable, "\n");
        throw_error = true;
    end
    
    if throw_error
        error(sprintf(err_msg));
    end
end
            