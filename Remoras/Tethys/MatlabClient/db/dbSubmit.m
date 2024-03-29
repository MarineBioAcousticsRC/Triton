function dbSubmit(varargin)
% dbSubmit(OptionalArgs, Files)
% Submit files to the database.  Files may be a single filename,
% a cell array of filenames, or omitted in which case a GUI prompts
% for a single file submission
% 
%
% The first Argument can be a query handler. If one is not given, a default
% will be generated.
%
% The following optional arguments only apply when files are passed in:
% 'Collection', name - To which collection will these be added.
%          Default is 'Detections'.
% 'Overwrite', true|false - Overwrite spreadsheet if it is already
%          in the repository
% 'Server', NameString - name of server or IP address
%           Use 'localhost' if the server is running the
%           same machine as where the client is executing.
% 'Port', N - port number on which server is running
%
% Files may be:
%   omitted - A dialog requests a file to upload
%   a string - Single file upload
%   or multiple files as a cell array, all of which are uploaded

% When invoked from a GUI, the first two arguments contain the 
% callback object and a reserved argument.  We remove these
queryH = [];
if length(varargin) >= 2 && isnumeric(varargin{1}) && ishandle(varargin{1})
    varargin(1:2) = [];
end

%check for handler as first argument, shift varargin if so
if ~isempty(varargin)
    if dbVerifyQueryHandler(varargin{1})
        queryH = varargin{1};
        varargin(1)=[];
    else
        queryH = [];  % empty handler, will be created or picked up from varargin
    end
end

% User passed in file list if # of args is odd & > 0
if ~isempty(varargin) && mod(length(varargin), 2) == 1
    % Remove final
    Files = varargin{end};
    if ischar(Files)
        Files = {Files};
    end
    varargin(end) = [];  % Only server options should remain
else
    Files = [];
end

% defaults
overwrite = false;  % don't overwrite
collection = 'Detections';

% Process non-server related optional arguments
idx = 1;

while idx < length(varargin) && ischar(varargin{idx})
    % Set options and eliminate from argument list so that
    % we may pass whatever remains to the server initialization
    switch varargin{idx}
        case 'Overwrite'
            overwrite = varargin{idx+1} ~= false;
            varargin(idx:idx+1) = [];
        case 'Collection'
            collection = varargin{idx+1};
            varargin(idx:idx+1) = [];
        otherwise
            idx = idx+2;
    end
end

if isempty(queryH)
    queryH = dbInit(varargin{:});
end

%import the function
import dbxml.uploader.*;

% Retrieve the uniform resource locator from query handler
url = char(queryH.getURLString());

if isempty(Files)
    global PARAMS;  % Triton parameters
    % no arguments, pop up dialog with directory set appropriately
    if exist('PARAMS', 'var') & isfield('PARAMS', 'indir')  % Triton initialized?
        wdir = PARAMS.indir;  %  use Triton directory
    else
        wdir = pwd;  % Use Matlab directory
    end
    dbxml.uploader.ImportFrame.launch(url, wdir);
else
    url = queryH.getURLString();  % Server address
    result = dbxml.uploader.Importer.ImportFiles(url, collection, ...
        Files, '', '', overwrite);
    fprintf('%s\n', char(result));
end
