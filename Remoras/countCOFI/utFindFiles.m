

function [PathFileList, FileList, PathList] = utFindFiles(SearchFileMask, SearchPathMask, SearchRecursiv),
% Find Files regarding a search mask 
% 
%  This function searches for files in the current directory /
%  a given directory: The serach can be recursively, depending 
%  on the provided parameters.
%  The search mask is relatively simple (just '*' as wildcard).
% 
%  Syntax:  [PathFileList, FileList, PathList] = utFindFiles(SearchFileMask, SearchPathMask, SearchRecursiv)
% 
%  Input parameter:
%    SearchFileMask - String or cell array of strings containing the file mask
%                        to search for {'*.m'; 'ma*'; '*am.mat'}
%                        if omitted or empty '*' is used
%                        if NaN (not a string): search for all directories
%    SearchPathMask - String or cell array of strings containing the path
%                        to search on
%                        Each path may contain as many masks (*) as necessary
%                        and also on lower levels {'v:\ge*\pl*\fritz'}, the extension 
%                        of the * is handled by the function
%                        special strings: '' or '.': current directory
%                        if omitted or empty '.' (current directory) is used
%    SearchRecursiv - Scalar indicating recursiv searching or not
%                        0: do not search recursively
%                        1: search recursively
%                        if omitted or empty 0 (no recursive search) is used
% 
%  Output parameter:
%    PathFileList- Cell array of string(s) containing the path and name of the found files
%    FileList    - Cell array of string(s) containing the name of the found files
%    PathList    - Cell array of string(s) containing the path of the found files
% 
%  Example:
% 
%    % Search in directories gea*\gr* and in geaobj for files with mask *an*.m and *objfun1*.mat
%    % not recursively
%    
%    >> [pfl, fl, pl] = ...
%         utFindFiles({'*am*.m'; '*objfun1*.mat'}, {'gea*\p*', 'geaobj\gr*'});
%       pfl = 
%           'geatbx\plotext\samdata.m'
%           'geatbx\plotext\sammon.m'
%           'geaobj\grafics\res_beasv_objfun1_var_2_01.mat'
%           'geaobj\grafics\res_beasv_objfun1c_var_2_01.mat'
%       fl = 
%           'samdata.m'
%           'sammon.m'
%           'res_beasv_objfun1_var_2_01.mat'
%           'res_beasv_objfun1c_var_2_01.mat'
%       pl = 
%           'geatbx\plotext\'
%           'geatbx\plotext\'
%           'geaobj\grafics\'
%           'geaobj\grafics\'
%           
% Author:   Hartmut Pohlheim
% History:  17.09.2000  file created
%           20.10.2002  check for cell array around SearchPathMask
%                          before check for NaN


% Test input parameters
   NAIN = nargin;
   if NAIN < 1, SearchFileMask = []; end
   % NaN must be kept for pure sub dir searching
   % if isnan(SearchFileMask), SearchFileMask = ''; end
   if isempty(SearchFileMask), SearchFileMask = ''; end

   if NAIN < 2, SearchPathMask = []; end
   if ~iscell(SearchPathMask),
      if isnan(SearchPathMask), SearchPathMask = ''; end
   end
   if isempty(SearchPathMask), SearchPathMask = ''; end

   if NAIN < 3, SearchRecursiv = []; end
   if isnan(SearchRecursiv), SearchRecursiv = 0; end
   if isempty(SearchRecursiv), SearchRecursiv = 0; end

   if ~(iscell(SearchFileMask)), SearchFileMask = {SearchFileMask}; end
   if ~(iscell(SearchPathMask)), SearchPathMask = {SearchPathMask}; end

   % Put cell array into 'one entry per row' order
   SearchFileMask = SearchFileMask(:);
   SearchPathMask = SearchPathMask(:);

% Preset result variables
   FileList = {}; PathFileList = {}; PathList = {};
   
% Check for path(s) with Mask ('*') and extend mask
   if any(findstr([SearchPathMask{:}], '*')),
      SearchPathMaskNew = {}; CurPathAdd = {};
      % Loop over all path(s)
      for ipnew = 1:length(SearchPathMask),
         CurPath = SearchPathMask{ipnew};
         % Look for mask in current path
         PosStar = findstr(CurPath, '*');
         % When mask found, Extend the path name
         if ~(isempty(PosStar)), CurPathAdd = dirextpath(CurPath);
         % Use the path as given
         else CurPathAdd = {CurPath}; end
         % Add checked/extended path to new path list
         SearchPathMaskNew = [SearchPathMaskNew; CurPathAdd];
      end
      SearchPathMask = SearchPathMaskNew;
   end
   % fprintf('SearchPathMask:\n   %s\n', prprintf('%s\n', SearchPathMask));

   % Loop over all paths
   runpath = 1; ipath = 1;
   if isempty(SearchPathMask), runpath = 0; end
   while runpath == 1,
      % Get name of current directory
      CurDirName = SearchPathMask{ipath};

      % Check for filesep at the end of the path name and add if missing
      if ~(isempty(CurDirName)),
         if ~(strcmp(CurDirName(end), filesep)), CurDirName = [CurDirName, filesep]; end
      end

      % Look for subdirectories below the current path name (only when recursiv)
      if SearchRecursiv == 1,
         % Get subdirectories/files of current path 
         CurDirResult = dir(CurDirName);
         if ~(isempty(CurDirResult)),
            % Look for subdirectories
            CurDir_SubDir = find([CurDirResult.isdir] == 1);
            if ~(isempty(CurDir_SubDir)),
               % Handle/Exclude the parent (..) and own (.) directory handle
               CurDirResult_SubDir = direxown(CurDirResult(CurDir_SubDir));
               % Add found sub-directories to SearchPathMask
               if ~(isempty(CurDirResult_SubDir)),
                  % Get the directory names
                  SearchPathMask = [SearchPathMask; strcat(CurDirName, {CurDirResult_SubDir.name}')];
                  % fprintf('size SearchPathMask: %s\n', prprintf(size(SearchPathMask)));
               end
            end
         end
      end 

      % Look through all file masks
      for imask = 1:length(SearchFileMask),
         % When file search mask is NaN, convert to empty string and set sub dir search
         if isnan(SearchFileMask{imask}), SearchFileMaskHere = ''; FMNaN = 1; 
         else SearchFileMaskHere = SearchFileMask{imask}; FMNaN = 0; end
         % Get the file/subdir list of the current directory
         CurDirResult = dir(fullfile(CurDirName, SearchFileMaskHere));
         
         % If something found, process it
         if ~(isempty(CurDirResult)),
            % fprintf('size CurDirResult: %s\n', prprintf(size(CurDirResult)));
            % Check for subdirectories in the current file list
            CurDir_SubDir = find([CurDirResult.isdir] == 1);
            if ~(isempty(CurDir_SubDir)),
               % When file search mask is/was NaN
               if FMNaN == 1,
                  % Handle/Exclude the parent (..) and own (.) directory handle
                  CurDirResult = direxown(CurDirResult(CurDir_SubDir));
               else
                  CurDirResult(CurDir_SubDir) = [];
               end
            end
            % Put found files into File and Path list
            if ~(isempty(CurDirResult)),
               CurDir_FileName = {CurDirResult.name}';
               FileList = [FileList; CurDir_FileName];
               PathList = [PathList; repmat({CurDirName}, [length(CurDirResult), 1])];
               PathFileList = [PathFileList; strcat({CurDirName}, CurDir_FileName)];
            end
         end
      end

      % Check, if all path are done
      if ipath < length(SearchPathMask), runpath = 1; ipath = ipath + 1; else runpath = 0; end

   end


% End of function




% private subfunction excluding '.' and '..' directories from dir result structure
%
%  Syntax:  NewDirStruct = direxown(DirStruct)

% Author:   Hartmut Pohlheim
% History:  18.09.2000  file created

function DirStruct = direxown(DirStruct)

   
% Check for empty directory structure
   if isempty(DirStruct), return; end

% Handle/Exclude the parent (..) and own (.) directory handle
   CurDir_Point = [];
   CurDir_Point = find(strcmp({DirStruct.name}, '.'));
   CurDir_Point = [CurDir_Point, find(strcmp({DirStruct.name}, '..'))];
   
% Delete the directory entries
   if ~(isempty(CurDir_Point)), DirStruct(CurDir_Point) = []; end


% End of private subfunction




% private subfunction extending a given path with mask
%
%  Syntax:  PathNames = dirextpath(PathName)

% Author:   Hartmut Pohlheim
% History:  18.09.2000  file created

function ExtPathNames = dirextpath(PathName)


% Preset variables
   ExtPathNames = {}; PrevPathNames = {};
% Divide path into parts
   if strcmp(PathName(end), filesep), PathName = PathName(1:end-1); end
   [CDNPath, CDNName, CDNExt] = fileparts(PathName);
   % When mask not only at last dir level, then call function recursively to extend path completely
   if ~(isempty(findstr(CDNPath, '*'))),
      PrevPathNames = dirextpath(CDNPath);
   % Otherwise, use the mask-free path 
   else
      PrevPathNames = {CDNPath};
      if ~(all(isempty(PrevPathNames{:}))), PrevPathNames = strcat(PrevPathNames, filesep); end,
   end
   
   % Look for mask in highest (last) directory level
   % When none found, extend the lower level path(s) with the mask free directory name
   if isempty(findstr([CDNName, CDNExt], '*')),
      ExtPathNames = strcat(PrevPathNames, [CDNName, CDNExt]);
   % When mask in highest level directory, search in directory using this mask
   else
      % Loop over all previous level directories
      for iprev = 1:length(PrevPathNames),
         % Path of current directory including mask of current level directory
         CurPath = strcat(PrevPathNames{iprev}, [CDNName, CDNExt]);
         % Get directory listing
         CDNPathResult = dir(CurPath);
         % Anything found
         if ~(isempty(CDNPathResult)),
            % Get just the directories
            CurDir_SubDir = find([CDNPathResult.isdir] == 1);
            % Handle/Exclude the parent (..) and own (.) directory handle
            if ~(isempty(CurDir_SubDir)),
               CDNPathResult = direxown(CDNPathResult(CurDir_SubDir));
               % Create found path names
               if ~(isempty(CDNPathResult)), 
                  ExtPathNames = [ExtPathNames; strcat(PrevPathNames{iprev}, strcat({CDNPathResult.name}', filesep))];
               end
            end
         % Return a warning when nothing found (comes too often, thus excluded
         else 
            % warning(sprintf('No path found matching the given path mask (%s)', CurPath));
         end
      end
   end


% End of private subfunction
