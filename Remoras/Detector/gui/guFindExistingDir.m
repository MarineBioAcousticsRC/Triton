function dir = guFindExistingDir(path, default)
% dir = guFindExistingDir(path)
% Given a file path, find the lowest existing directory along the path.
% If no such directory exists, return the default path if specified,
% otherwise [].

if nargin < 2
  default = [];
end

% While path is not a directory, 
dir = path;
while ~ isdir(dir) && ~ isempty(path)
  [dir, base] = fileparts(dir);
end

if isempty(dir)
  dir = default;
end
