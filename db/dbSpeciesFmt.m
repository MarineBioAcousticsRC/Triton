function libfmt = dbSpeciesFmt(Type, Format, varargin)
% dbSpeciesFmt(Type, Format, Option)
% Sets the species naming format used for XQueries (tsn, Latin name, 
% abbreviation) as well as how those results will be displayed.
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
%  'Abbrev', SpeciesAbbreviaitonMap - Use custom abbreviations based
%     on the specified abbreviaiton map
%
% To retrieve the current format, call with Type set to GetInput or 
% GetOutput.


% defaults
persistent FromXQuery ToXQuery; 
if isempty(FromXQuery)
    FromXQuery = dbTsn2Name('Latin');
end
if isempty(ToXQuery)
    ToXQuery = dbName2Tsn('Latin');
end

switch(Type)
    case 'Input'
        ToXQuery = dbName2Tsn(Format, varargin{:});
    case 'Output'
        FromXQuery = dbTsn2Name(Format, varargin{:});
    case 'GetInput'
        libfmt = ToXQuery;
    case 'GetOutput'
        libfmt = FromXQuery;
    otherwise
        error('Bad Type');
end

