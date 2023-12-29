function merged = dbMergeStructures(array, field)
% merged = dbMergeStructures(array, field)
% Substructures are not always homogeneous.
% We might have an array with field a:  array.a
% which itself might be composed of substructures where
% array(1).a and array(2).a do not share the same fields.
% merge_structures finds all common fields, creates dummy values,
% and returns an array merged which is an array of the array.a
% substructures.  
% 
% This is most useful when structures are approximately
% homogeneous and differ only in a couple of fields.


N = length(array);
fields = containers.Map();

% Pass 1, determine all of the names
for idx=1:N
    f = fieldnames(array(idx).(field));
    for f_idx = 1:length(f)
        if ~ fields.isKey(f{f_idx})
            % note the value the first time we see one of these
            fields(f{f_idx}) = array(idx).(field).(f{f_idx});  
        end
    end
end

% Pass 2, add missing things
expected = fields.keys();
for idx=1:N
    f = fieldnames(array(idx).(field));
    missing = setdiff(expected, f);
    if length(missing) > 0
        for m_idx = 1:length(missing)
            fmissing = missing{m_idx};
            eg_value = fields(fmissing);
            if isstruct(eg_value)
                array(idx).(field).(fmissing) = struct();
            elseif iscell(eg_value)
                array(idx).(field).(fmissing) = {};
            elseif ischar(eg_value)
                array(idx).(field).(fmissing) = '';
            elseif isnumeric(eg_value)
                array(idx).(field).(fmissing) = NaN;
            end
        end
    end
end

merged = [array.(field)];





