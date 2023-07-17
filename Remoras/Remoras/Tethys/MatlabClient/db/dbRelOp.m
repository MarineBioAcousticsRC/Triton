function ComparisonStr = dbRelOp(Element, XPathFmt, Comparison)
% comparison = dbRelOp(Parameter, XPathFmt, RelOp)
% Helper function for translating comparisons into XQuery
% fragments.  Not intended to be called directly by the user.
%
% Check equality of XML element with the string or scalar value in
% Comparison
% 
% Other types of relational checks can be made by setting Comparison to a
% cell array.  The first element should be a valid XQuery relative
% operator:
%    '=', '<', '<=', '>', '>=', '!='
% 
% Any of these operators can be preprended by 'num' or 'datetime' to
% attempt to convert both the left and right hand sides of the comparison
% to an appropriate type.  This is only really needed for UserDefined
% parameters where the database does not know the type of the data and will
% assume it to be a string.
%
% XPathFmt is an sprintf format string that allows the eleement to 
% be placed within an XQuery path.  
%
% Example:  Select $detection/Parameter/MinHz > 5000
% dbRelOp('MinHz', '$detection/Parameter/%s', {'>', 5000})



% Determine if user wants a relative operator other than
% equality.
if iscell(Comparison)
    len = length(Comparison);
    switch len
        case 1
            op = '=';
            value = Comparison{1};
        case 2
            op = Comparison{1};
            value = Comparison{2};
        otherwise
            error('Comparison cell arrays must be of length 1 or 2');
    end
else
    op = '=';
    value = Comparison;
end

% See if user wants to type cast
[match, start, stop] = regexpi(op, '\s*(?<cast>num|dateTime)\s*', 'names');
if ~ isempty(match)
    % User provided a cast field, note the cast type and remove from
    % hte operator.
    casttype = lower(match.cast);  % lower case
    op(start:stop) = [];  % cut out matched text
    
    switch casttype
        % Won't be here if one these doesn't match
        case 'num'
            casttype = 'xs:double';
        case 'datetime'
            casttype = 'xs:dateTime';
    end
else
    casttype = '';
end

% Qualify the element using the format string
% e.g. '$i/%s' -->  $i/@someattribute
% We may override this for UserDefined cases
lhs = sprintf(XPathFmt, Element);

% When the element being queried is a child of UserDefined,
% the type is not defined by the schema and we will need to 
% cast the left-hand-side of the relop if:
%   1 - User specified a cast type OR
%   2 - We can infer the type from the right hand side
if ~isempty(strfind(XPathFmt, 'UserDefined/'))
    % We have not type information for UserDefined elements
    % Try to infer what the user is expecting from the value that
    % they passed in.
    
    if ~isempty(casttype)
        lhs = wrap(sprintf(XPathFmt, Element), casttype);
    elseif isnumeric(value)
        lhs = wrap(sprintf(XPathFmt, Element), 'xs:double');
    end
end

if isscalar(value)  
        switch casttype
            % If user cast to a dateTime and passed in a scalar,
            % we'll assume that it is a Matlab serial date and
            % convert to ISO8601
            case 'xs:dateTime'
                valstr = sprintf('"%s"', dbSerialDateToISO8601(value));
                rhs = wrap(valstr, casttype);
            otherwise
                rhs = sprintf('%f', value);
        end
else
    switch casttype
        case 'xs:dateTime'
            rhs = wrap(sprintf('"%s"', value), casttype);
        otherwise
            rhs = sprintf('"%s"', value);  % add quotes for string
    end
end

% if isnumeric(rhs)
%     ComparisonStr = sprintf('number(%s) %s %f', lhs, op, rhs);
% else
%     ComparisonStr = sprintf('%s %s %s', lhs, op, rhs);
% end
ComparisonStr = sprintf('%s %s %s', lhs, op, rhs);

function wrapped = wrap(element, type)
% wrapped = wrap(element, type)
% formatting function, e.g. 
%   wrap('boo', 'xs:double') --> 'xs:double(boo)'
    wrapped = sprintf('%s(%s)', type, element);
    
function wrapped = wrap_str(element, type)
% wrapped = wrap(element, type)
% formatting function, e.g. 
%   wrap_str('2017-01-01', 'xs:timestamp') --> 'xs:dateTime("2017-01-01")'
    wrapped = sprintf('%s("%s")', type, element);
