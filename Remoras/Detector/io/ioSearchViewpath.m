function [fname_full, fname_rel] = ioSearchViewpath(fname, viewpath)
% [fname_full, idx, fname_rel] = ioSearchViewpath(fname, viewpath)
% Search the viewpath for the specified file.
%
% fname is the file to be located and viewpath is a cell array of
% directories that will be searched for the file.  The file is first
% stripped of any matching prefix from the viewpath directories.  
% What is left is the relative filename, fname_rel.  
%
% The viewpath is searched for fname_rel.  If viewpath{n}
% is a prefix of the filename, fname_rel will be the filename
% stripped of the prefix.  fname_full is the path to the file
% qualified by the viewpath directory.
%
% Example 1:
% ioSearchViewPath('b/jo.txt', {'a/alpha', 'b', 'c'})
% Directories a, b, and c are searched in the order specified for jo.txt 
%
% If directory a contained jo.txt:
%   fname_full = 'a/alpha/jo.txt'
%   fname_rel = 'jo.txt'
%
% If no directory contained jo.txt:
%   fname_full = []
%   fname_rel = 'jo.txt'
%
% Example 2:
% ioSearchViewPath('d/jo.txt', {'a/alpha', 'b', 'c'})
% Directories a, b, and c are searched in the order specified for d/jo.txt 
%
% If directory c contained d/jo.txt
%   fname_full = 'c/d/jo.txt'
%   fname_rel = 'd/jo.txt'
%
% If no directory contained d/jo.txt:
%   fname_full = []
%   fname_rel = 'd/jo.txt'
%
% Note:  For empty viewpaths: {}
%   fname_full = fname when fname exists, [] otherwise
%   fname_rel = fname
%
% See also:  ioOpenViewpath, ioGetWriteNameViewpath
%
% Do not modify the following line, maintained by CVS
% $Id: ioSearchViewpath.m,v 1.1 2009/08/22 19:00:12 mroch Exp $
if ~ iscell(viewpath)
    error('viewpath must be a cell array of directories');
end

1;

if isempty(viewpath)
    if exist(fname, 'file')
        fname_full = fname;
    else
        fname_full = [];
    end
    fname_rel = fname;
else
    % Strip viewpath prefix if it is part of the filename ----
    
    % find which viewpath dir fname is on (if any)
    vp_idx = prefix(fname, viewpath);
    if vp_idx
        % find position just past matching part of string + file separator
        last = length(viewpath{vp_idx});
        if length(fname) > last && fname(last+1) == filesep
            last = last + 1;
        end

        if last < length(fname)
            fname_rel = fname(last+1:end);  % pull out rest
        else
            fname_rel = [];
        end
    else
        % Could not find a viewpath prefix, assume relative to viewpath
        fname_rel = fname;
    end
    
    % Search viewpath for file ---
    found = false;
    vdir = 1;
    while ~ found && vdir <= length(viewpath)
        found = exist(fullfile(viewpath{vdir}, fname_rel), 'file');
        if ~ found
            vdir = vdir + 1;
        end
    end
    
    if found
        fname_full = fullfile(viewpath{vdir}, fname_rel);
    else
        fname_full = [];
    end
end
