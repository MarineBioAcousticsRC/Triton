function handle = ioOpenViewpath(fname, viewpath, varargin)
% handle = ioOpenViewpath(fname, viewpath, OptArgs)
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
% until a file is found or the viewpath is exhausted.
% 
% For files that are opened for writing the path is searched for the 
% first existing instance of the file.  If it exists, the
% function attempts to open it.  Otherwise, the file will be opened
% relative to the first directory in the viewpath.  Any needed directories
% will be created.  This occurs even if the open fails.
%
% See also:  ioSearchViewpath, ioGetWriteNameViewpath
%
% Do not modify the following line, maintained by CVS
% $Id: ioOpenViewpath.m,v 1.1 2009/08/22 19:00:12 mroch Exp $

error(nargchk(2,Inf,nargin));

if nargin < 3 
    ReadOnly = true;
elseif varargin{1} == 'r'
    ReadOnly = true;
else
    ReadOnly = false;
end


if ReadOnly
    % try to locate file
    fname = ioSearchViewpath(fname, viewpath);
    if isempty(fname)
        handle = -1;
    else
        handle = fopen(fname, varargin{:});
    end
else
    % Determine to where we will write, creating any needed directories
    fname = ioGetWriteNameViewpath(fname, viewpath, true);
    handle = fopen(fname, varargin{:});
end

    


    
