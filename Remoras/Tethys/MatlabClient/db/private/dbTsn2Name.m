function fmt = dbTsn2Name(query_h, ExpandTo, OptArg)
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
        fmt = 'lib:tsn2completename(%s)';
    case 'Abbrev'
        if nargin < 2
            OptArg = 'SIO.SWAL.v1';
        end        
        % Verify valid species abbreviation map if possible
        if ~ isempty(query_h)
            maps = dbSpeciesAbbreviations(query_h);
            valid = sum(strcmp(maps, OptArg));
            if valid == 0
                error('Species map %s does not exist.  Valid maps %s ', ...
                    OptArg, strjoin(maps, ", "));
            end
        else
            warning(['Query handler not passed in, ', ...
                'unable to verify that Abbrev argument valid']);
        end
        fmt = sprintf('lib:tsn2abbrev(%%s, "%s")', OptArg);
    case 'Vernacular'
        if nargin < 2
            OptArg = 'English';
        end
        fmt = sprintf('lib:tsn2vernacular(%%s, "%s")', OptArg);
    otherwise
        error('Unknown ITIS TSN expansion:  %s', char(ExpandTo));
end

if ~isstring(fmt)
    fmt = string(fmt);
end