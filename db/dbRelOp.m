function ComparisonStr = dbRelOp(Element, XPathFmt, Comparison, default)
% comparison = dbRelOp(Parameter, XPathFmt, RelOp, defaultcomp)
% Helper function for translating  numeric comparisons into XQuery
% fragments.  Not intended to be called directly by the user.
%
% Element is a the XML element name
% XPathFmt is the a format string that qualifies the element
%  within the query.
% Comparison consists of either a:
%   scalar - queries for equality
%   cell array {operator, scalar} - Operator is a relational
%       operator in {'=', '<', '<=', '>', '>=', '!='} which is compared
%       to the specified scalar.
% default - default comparison '='

% Determine which operator will be used unless the user overrides
if nargin < 4
    operator = '=';
else
    operator = default;
end

% Qualify the element, e.g. $i/@attribute
lhs = sprintf(XPathFmt, Element);

if isscalar(Comparison) | ischar(Comparison)
    value = Comparison;
elseif  ~iscell(Comparison) | length(Comparison) ~= 2 | ...
         ~ischar(Comparison{1}) | ~isscalar(Comparison{2})
    error('%s: bad comparison specification', Element);
else
    operator = Comparison{1};
    value = Comparison{2};
end

if isnumeric(value)
    ComparisonStr = sprintf('number(%s) %s %f', lhs, operator, value);
else
    ComparisonStr = sprintf('%s %s %s', lhs, operator, value);
end

