function fmt = dbName2Tsn(query_h, NameType, OptArg)
% fn = dbTsnExpansion(query_h, NameType, OptArg)
% Returns the XQuery library function that will expand an ITIS
% taxonomic serial number to the desired type.
% NameType
%   'tsn' - Already specified as an ITIS tsn
%   'Latin' - ITIS Latin species name; ITIS's completename field
%   'Abbrev', SpeciesAbbrevMap
%       Default: 'SIO.SWAL.v1'
%       If a query handler is provided, checks to ensure that the
%       specified name is valid.
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
        if nargin < 3
            OptArg = 'SIO.SWAL.v1';
        end
        % Verify valid species abbreviation map if possible
        if ~ isempty(query_h)
            maps = dbSpeciesAbbreviations(query_h);
            valid = sum(strcmp(maps, OptArg));
            if valid == 0
                error('Species map %s does not exist.\nValid maps: %s ', ...
                    OptArg, strjoin(maps, ", "));
            end
        else
            warning(['Query handler not passed in, ', ...
                'unable to verify that Abbrev argument valid']);
        end
        fmt = sprintf('lib:abbrev2tsn("%%s", "%s")', OptArg);
    case 'Vernacular'
        if nargin < 3
            OptArg = 'English';
        end
        fmt = sprintf('lib:vernacular2tsn("%%s", "%s")', OptArg);
    otherwise
        error('Unknown name type');
end

if ~ isstring(fmt)
    fmt = string(fmt);
end
