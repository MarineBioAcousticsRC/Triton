function handle = ioResolveViewpath(fname, viewpath, varargin)
% handle = ioOpen_viewpath(fname, viewpath, OptArgs)
% Viewpath's provide a method for manipulating files across multiple
% directories.  This can be used to keep a directory pristine (e.g. data is
% stored in one directory, meta-data in another), permit multiple users
% to share common resources, etc.
%
% Given a file fname and a list of directories, attempt to open
% the file in one of the directories of viewpath.  fname may
% either contain a name relative to directories of the viewpath
% or may contain a fully qualified name that contains one of the 
% viewpath directories.
% 
% Regardless of whether or not the the name is fully qualified,
% the behavior is as follows:  
%
% For files that are opened only for reading, the viewpath is searched
% in reverse order until a file is found or the viewpath is exhausted.
% 
% For files that are opened for writing the path is searched in reverse
% order for the first existing instance of the file.  If it exists, the
% function attempts to open it.  Otherwise, the file will be opened
% relative to the last directory in the viewpath.  Any needed directories
% will be created.

error(nargchk(2,Inf,nargin));

if nargin < 3 
    ReadOnly = true;
elseif varargin{3} == 'r'
    ReadOnly = true;
else
    ReadOnly = false;
end

if ~ iscell(viewpath)
    error('viewpath must be a cell array of directories');
end

% Strip viewpath prefix if it is part of the filename ----

% find which viewpath dir fname is on (if any)
prefix = find(cellfun(@(x)isequal(x, 1), strfind(viewpath, fname)) == 1);
if ~ isempty(prefix)
    fname(1:length(viewpath{prefix})) = [];  % strip it out
end

% Search viewpath for file ---
found = false;
vdir = length(viewpath);
while ~ found && vdir > 0
    found = exist(fullfile(viewpath{vdir}, prefix), 'file');
    if ~ found
        vdir = vdir - 1;
    end
end

if ReadOnly
    if ~ found
        handle = -1;
    else
        handle = fopen(fullfile(viewpath{vdir}, fname), varargin{:});
    end
else
    % Open in the last directory of the viewpath ---
    fname = fullfile(viewpath{end}, fname);
    dir = fileparts(fname);
    if ~ exist(dir, 'dir')
        result = mkdir(dir);  % create needed directories
        if ~ result
            errror('Unable to create directory:  %s', dir);
        end
    end
    handle = fopen(fname, varargin{:});
end

    


    
