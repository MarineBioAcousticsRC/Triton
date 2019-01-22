function results = dbRunQueryFile(query_eng, filename, varargin)
% results = dbRunQueryFile(query_eng, filename, OptionalArgs)
% Run the query contained in filename.  Optional arguments
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
%  'SaveTo', outputname - Write the results to the specified XML file
% Return the results as a text XML document unless the
% optional asdom parameter is true in which case a 
% document object model representation of the
% results is returned.

error(nargchk(2, inf, nargin));

fileH = fopen(filename, 'r');
if fileH ~= -1
  query_txt = fread(fileH, Inf, 'uchar=>char');
  fclose(fileH);
else
  error('Unable to open %s\n', filename);
end

results = dbRunQuery(query_eng, query_txt, varargin{:});
