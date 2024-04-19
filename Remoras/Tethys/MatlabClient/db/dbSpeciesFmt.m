function libfmt = dbSpeciesFmt(varargin)
% dbSpeciesFmt(QueryHandler, Type, Format, Option)
% Sets the species naming format used for XQueries (tsn, Latin name, 
% abbreviation) as well as how those results will be displayed.
%
% QueryHandler is an optional query handler object produced by dbInit.
% If provided and Fromat is set to Abbrev, the name of the abbreviation
% map will be verified.  
%
% Type is 'Input' or 'Output' representing XQueries or Xquery results
% respectively
% Format indicates how the values are specified or reported, and is one of the following:
%  'tsn' - ITIS tsn
%  'Latin' - ITIS completename (Latin species/family/order/... name)
%  'Vernacular', Language - ITIS vernacular.  Language must be one of the
%     the following:  'English', 'French', 'Portugese', 'Spanish'.
%     Vernacular is only complete for English and will cause problems
%     for some queries when using other languages
%  'Abbrev', SpeciesAbbreviationMap - Use custom abbreviations based
%     on the specified abbreviaiton map
%
% To retrieve the current format, call with Type set to GetInput or 
% GetOutput.

% This is a bit kludgey.  We wanted to add the ability to 
% pass in a query handler to verify setting of abbreviations
% but wanted to make the code compatible with previous versions
% that did not require the query handler.
if isjava(varargin{1}) && strcmp('dbxml.Queries',class(varargin{1}))
    query_h = varargin{1};
    varargin(1) = [];
else
    query_h = [];
end

narginchk(1, Inf);
Type = varargin{1};
varargin(1) = [];


% defaults
persistent FromXQuery ToXQuery; 
if isempty(FromXQuery)
    FromXQuery = dbTsn2Name(query_h, 'Latin');
end
if isempty(ToXQuery)
    ToXQuery = dbName2Tsn(query_h, 'Latin');
end

switch(Type)
    case 'Input'
        ToXQuery = dbName2Tsn(query_h, varargin{:});
    case 'Output'
        FromXQuery = dbTsn2Name(query_h, varargin{:});
    case 'GetInput'
        libfmt = ToXQuery;
    case 'GetOutput'
        libfmt = FromXQuery;
    otherwise
        error('Bad Type');
end


