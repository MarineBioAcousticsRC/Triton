function fmt = dbTsn2Name(ExpandTo, OptArg)
% fn = dbTsnExpansion(ExpandTo, OptArg)
% Returns the XQuery library function that will expand an ITIS
% taxonomic serial number to the desired type.
% ExpandTo:
%   'tsn' - Keep as an ITIS taxonomic serial number
%   'Latin' - ITIS Latin species name; ITIS's completename field
%   'Abbrev', SpeciesAbbrevMap
%       Default: 'SIO.SWAL.v1'
%   'Vernacular', Language - common name in specified language
%       ITIS fully supports English, and has limited support
%       for French, Portugese, and Italian.  When a language is
%       missing a vernacular entry, the completename is used.
%       Default: 'English'

switch ExpandTo
    case 'tsn'
        fmt = '%s';
    case 'Latin'
        fmt = 'lib:SpeciesIDtsn2name(%s)';
    case 'Abbrev'
        if nargin < 2
            OptArg = 'SIO.SWAL.v1';
        end        
        fmt = sprintf('lib:SpeciesIDtsn2abbrev(%%s, "%s")', OptArg);
    case 'Vernacular'
        if nargin < 2
            OptArg = 'English';
        end
        fmt = sprintf('lib:SpeciesIDtsn2vernacular(%%s, "%s")', OptArg);
    otherwise
        error('Unknown ITIS TSN expansion:  %s', char(ExpandTo));
end
