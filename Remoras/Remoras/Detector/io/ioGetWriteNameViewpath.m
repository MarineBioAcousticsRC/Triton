function fname_out = ioGetWriteNameViewpath(fname, viewpath, createdir)
% fname = ioGetWriteNameViewpath(fname, viewpath, createdir)
% Given a filename fname, determine what the absolute path would
% be if we called ioOpenViewpath(fname, viewpath).  
%
% When the optional argument createdir is set to true (default false),
% any directories in fname_out that do not exist will be created.
%
% This function is intended to be used when a function requires
% a viewpathed file name but we do not wish to modify the function.
% 
% See also:  ioOpenViewpath, ioSearchViewpath
%
% Do not modify the following line, maintained by CVS
% $Id: ioGetWriteNameViewpath.m,v 1.1 2009/08/22 19:00:12 mroch Exp $

[fname_out, fname_rel] = ioSearchViewpath(fname, viewpath);
if isempty(fname_out)
    % Unable to find file, set up to write to the first component of the
    % view path if it exists, otherwise just use what the user gave us
    if isempty(viewpath)
        fname_out = fname_rel;
    else
        fname_out = fullfile(viewpath{1}, fname_rel);
    end
    % Add directories if needed and requested
    if createdir
        dir = fileparts(fname_out);
        if ~ exist(dir, 'dir')
            result = mkdir(dir);  % create needed directories
            if ~ result
                errror('Unable to create directory:  %s', dir);
            end
        end
    end
end
