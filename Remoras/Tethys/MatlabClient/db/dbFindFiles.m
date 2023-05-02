function fileList = dbFindFiles(varargin)
% files = dbFindFiles(OptionalArgs)
% A case insensitive search to find files match filePattern.
%
% Optional arguments:
%   'Pattern', pattern - Search pattern.  Default is wildcard search '*.*'
%       Use a cell array to specify multiple patterns.
%   'Path', path - Relative or absolute path from where search is started
%       Asks user if not specified.
%   'PatternMode, mode - How is pattern interpreted?
%       'wildcard' (default) - wild-card searches where * will 
%           match anything e.g. 'j*y' matches 'joey', 'july', 'jy', ...
%       'regexp' - Regular expression search.  See regexpi help for details
%           e.g. '^[af].*\.xls' matches Excel files beginning with either 
%                   A,a,F or f such as foobar.xls or Apple.xls
%   'ExtendList', cellarr - resultant fileList will contain everything
%        in cellarr and whatever would have normally been returned.
%   'PathMode', mode - Do we look for patterns on?
%       'file' (default) - patten match on file without directories
%       'path' - pattern match on entire path to file
%   'Type', type - Entries to be added must be:
%        'file' (default) - Matches are only valid if entry is a file
%        'dir' - Matches are only valid if entry is a directory
%                This is usually used with PathMode 'file' to match
%                only the directory name.
%
% author: Azim Jinha (2011)
% modifications: Marie A Roch (2014-2018)
%   - stopped translating the filePatterns each time
%   - Ability to search for directories
%   - Use of keyword/value arugments

% Process arguments
searchPath = [];
pattern = '*.*';
patternMode = 'wildcard';
pathMode = 'file';
fileList = {};
entryType = 'file';

% for error checking
patternValid = {'wildcard', 'regexp'};
pathModeValid = {'file', 'path'};
entryTypeValid = {'file', 'dir'};

   
vidx = 1;
while vidx <= length(varargin)
    switch varargin{vidx}
        case 'Pattern'
            pattern = varargin{vidx+1};
            vidx = vidx + 2;            
        case 'Path'
            searchPath = varargin{vidx+1};
            if ~isdir(searchPath)
                error('Path specification is not a directory');
            end
            vidx = vidx + 2;
            
        case 'PatternMode'
            patternMode = varargin{vidx+1};
            if ~any(strcmp(patternValid, patternMode))
                error('bad PatternMode specification');
            end
            vidx = vidx + 2;
            
        case 'PathMode'
            pathMode = varargin{vidx+1};
            if ~any(strcmp(pathModeValid, pathMode))
                error('bad pathMode specification');
            end
            vidx = vidx + 2;
            
        case 'ExtendList'
            fileList = varargin{vidx+1};
            if ~iscell(fileList)
                error('ExtendList must be a cell array of strings')
            end
            vidx = vidx + 2;
            
        case 'Type'
            entryType = varargin{vidx+1};
            if ~any(strcmp(entryTypeValid, entryType))
                error('bad entryType specification');
            end
            vidx = vidx + 2;            
        otherwise
            error('Bad optional argument at position %d', vidx)
    end
end

%*** searchPath ***
if isempty(searchPath)
    searchPath = uigetdir('Select Path to search');
end

if ~iscell(pattern)
    % if only one file pattern is entered make sure it 
    % is still a cell-string.
    pattern = {pattern};
end

% *** patternMode ***
switch lower(patternMode)
case 'wildcard'
    % convert wild-card file patterns to regular expressions
    fileRegExp=cell(length(pattern(:)));
    for i=1:length(pattern(:))
        fileRegExp{i}=regexptranslate(patternMode,pattern{i});
    end
    % Change patternmode so that recursive calls do not retranslate.
    pattern = fileRegExp;
    patternMode = 'regexp';
otherwise
    % assume that the file pattern(s) are regular expressions
    fileRegExp = pattern;
end

% is fileList a nx1 cell array
if size(fileList,2)>1, fileList = fileList'; end 
if ~isempty(fileList) && min(size(fileList))>1
    error('input ExtendList should be a nx1 cell array'); 
end


% Perform file search
% Get the parent directory contents
dirContents = dir(searchPath);

if ~isempty(dirContents)
    % Construct paths
    newPaths = ...
        cellfun(@(x) fullfile(searchPath, x), {dirContents.name}, ...
        'UniformOutput', false);
    if size(newPaths, 2) > 1
        newPaths = newPaths';
    end
    matched = false(size(dirContents));  % assume none matched for now
    switch pathMode
        case 'file'
            matchOn = {dirContents.name};
        case 'path'
            matchOn = newPaths;
        otherwise
            error('Bad pathMode');
    end
    for i=1:length(dirContents)
        % don't process current/parent/private directories
        % (anything starting with a .)
        if ~strncmpi(dirContents(i).name,'.',1)
            if dirContents(i).isdir
                if strcmp(entryType, 'dir')
                    % User want directory matches
                    for jj=1:length(fileRegExp)
                        matched(i) = ~isempty(...
                            regexpi(matchOn{i},fileRegExp{jj}));
                        if matched(i), break; end
                    end
                end
                fileList = dbFindFiles(...
                    'Path', newPaths{i}, ...
                    'Pattern', pattern, ...
                    'PatternMode', patternMode, ...
                    'PathMode', pathMode, ...
                    'ExtendList', fileList, ...
                    'Type', entryType);
            elseif strcmp(entryType, 'file')
                for jj=1:length(fileRegExp)
                    matched(i) = ~isempty(regexpi(matchOn{i}, ...
                                             fileRegExp{jj}));
                    if matched(i), break; end
                end
            end
        end
    end
    fileList = [fileList; newPaths(matched)];  %#ok<AGROW>

end