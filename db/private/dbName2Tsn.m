function fmt = dbName2Tsn(NameType, OptArg)
% fn = dbTsnExpansion(ExpandTo, OptArg)
% Returns the XQuery library function that will expand an ITIS
% taxonomic serial number to the desired type.
% Name type
%   'tsn' - Already specified as an ITIS tsn
%   'Latin' - ITIS Latin species name; ITIS's completename field
%   'Abbrev', SpeciesAbbrevMap
%       Default: 'SIO.SWAL.v1'
%   'Vernacular', Language - common name in specified language
%       ITIS fully supports English, and has limited support
%       for French, Portugese, and Italian.  When a language is
%       missing a vernacular entry, the completename is used.
%       Default: 'English'

switch NameType
    case 'tsn'
        fmt = '%f';
    case 'Latin'
        fmt = 'lib:completename2tsn("%s")';
    case 'Abbrev'
        if nargin < 2
            OptArg = 'SWAL.SIO.vq';
        end        
        fmt = sprintf('lib:abbrev2tsn("%%s", "%s")', OptArg);
    case 'Vernacular'
        if nargin < 2
            OptArg = 'English';
        end
        fmt = sprintf('lib:vernacular2tsn("%%s", "%s")', OptArg);
    otherwise
        error('Unknown name type');
end
