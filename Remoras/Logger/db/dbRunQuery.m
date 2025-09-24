function results = dbRunQuery(query_eng, query_txt, varargin)
% results = dbRunQuery(query_eng, query_txt, OptionalArgs)
% Run the query contained in the string query_txt.  Optional arguments
%
% 'AsDOM', true | false(default) - Return the results as a
%   document object model (DOM).
% 'FormatOutput', true | false(default) - Format XML results
%   to be more easily readable by humans.  Note that the output
%   must be a valid XML document to be formatted.
% 'FormatQuery', CellArrayOfArgs - When present, it is assumed
%   that the query file contains sprintf formatting symbols (e.g.
%   %s for string, %f for floating point).  The query is formatted
%   using the arguments in the cell array.  See Matlab's sprintf
%   for more details on formatting instructions.
% 'SaveTo', outputname - Write the results to the specified XML file
% 'TyNamespace' true | false(default) - Prefix the Tethys namespace 
%   and libraries to the query
% Return the results as a text XML document unless the
% optional asdom parameter is true in which case a 
% document object model representation of the
% results is returned.

error(nargchk(2, inf, nargin));

% defaults
asdom = false;
query_fmt = [];
pretty = false;
saveto = [];
TyNamespace = false;

vidx = 1;
while vidx < length(varargin)
    switch varargin{vidx}
        case 'AsDOM'
            asdom = varargin{vidx+1}; vidx=vidx+2;
        case 'FormatOutput'
            pretty = varargin{vidx+1}; vidx=vidx+2;
        case 'FormatQuery'
            query_fmt = varargin{vidx+1}; vidx=vidx+2;
            if ~ iscell(query_fmt)
                error('FormatQuery requires a cell array')
            end
        case 'SaveTo'
            saveto = varargin{vidx+1}; vidx=vidx+2;
            if ~ ischar(saveto)
                error('SaveTo expects a filename');
            end
        case 'TyNamespace'
            TyNamespace = varargin{vidx+1}; vidx=vidx+2;
        otherwise
            error('Bad argument')
    end
end



if ~ isempty(query_fmt)
    query_txt = sprintf(query_txt, query_fmt{:});
end


if asdom
    if TyNamespace
        error('Prefix of Tethys namespace not yet supported for DOM');
    end
    results = query_eng.QueryReturnDoc(query_txt);
else
    % get response from server
    switch TyNamespace
        case true
            response = query_eng.QueryTethys(query_txt);
        case false
            response = query_eng.Query(query_txt);
    end
    if pretty
        % make it pretty
        results = char(query_eng.xmlpp(response));
    else
        results = char(response);
    end
end

if saveto
    if asdom
        warning('Skipping saving XML file, cannot save DOM');
    else
        % Save XML document to a file
        fileH = fopen(saveto, 'w');
        fwrite(fileH, char(query_eng.xmlpp(results)));
        fclose(fileH);
    end
end


