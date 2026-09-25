function rel = rel_subpath(root, child)
%REL_SUBPATH  The part of a path that sits below a root folder.
%
%   rel = rel_subpath('E:\HARP\SiteA', 'E:\HARP\SiteA\disk03')   ->  'disk03'
%   rel = rel_subpath('E:\HARP\SiteA', 'E:\HARP\SiteA')          ->  ''
%
% Used to mirror a source tree into a destination root:
%
%   thisOut = fullfile(destRoot, rel_subpath(srcRoot, listing(k).folder));
%
% Errors if child is not actually under root, because the alternative -- quietly
% returning something -- produces a destination path built from an absolute
% source path, which is how a mirrored copy ends up somewhere like
% D:\dest\E:\HARP\SiteA.
%
% WHY THIS EXISTS RATHER THAN strrep
%
% The obvious one-liner, strrep(child, root, ''), is wrong in three ways that
% all show up on real HARP paths:
%
%   * it replaces EVERY occurrence, not just the leading one, so a root that
%     appears again deeper in the path is deleted twice
%   * a trailing separator on root stops it matching at all, and the caller
%     gets the full absolute path back as a "relative" one
%   * Windows compares paths case-insensitively and strrep does not, so
%     'e:\harp' typed by the user fails to match 'E:\HARP' from dir()
%
% Any of the three silently produces a mangled destination rather than an error.
%
% See also AUDIODIR2FLAC, FLACDIR2AUDIO.

rel = '';

root  = local_norm(root);
child = local_norm(child);

if isempty(root) || isempty(child)
    error('rel_subpath:empty','Both a root and a child path are required.');
end

if local_same(root, child)
    return                          % child IS root: nothing below it
end

% Compare the child's leading characters against the root, then insist the next
% character is a separator. Without that check 'E:\Site1' would look like a
% parent of 'E:\Site10'.
n = numel(root);
if numel(child) <= n || ~local_same(child(1:n), root) ...
        || ~any(child(n+1) == '\/')
    error('rel_subpath:notUnder', ...
        '%s is not inside %s', child, root);
end

rel = child(n+2:end);
end


%% ================================================================== helpers
function p = local_norm(p)
%LOCAL_NORM  Absolute, native separators, no trailing separator.
if isempty(p) || ~ischar(p); p = ''; return; end

p = strtrim(p);

% Make it absolute. fullfile alone will not do this, and a relative root is a
% real case -- users type 'SiteA' having cd'd into the parent.
if ~local_isabs(p)
    p = fullfile(pwd, p);
end

p = strrep(p, '/', filesep);
p = strrep(p, '\', filesep);

% Strip trailing separators, but keep the one in a drive root like 'E:\'.
while numel(p) > 1 && p(end) == filesep && ~local_isdriveroot(p)
    p(end) = [];
end
end


function tf = local_isabs(p)
if ispc
    tf = (numel(p) >= 2 && p(2) == ':') ...          % E:\...
      || (numel(p) >= 2 && all(p(1:2) == '\')) ...   % \\server\share
      || (numel(p) >= 2 && all(p(1:2) == '/'));
else
    tf = ~isempty(p) && p(1) == '/';
end
end


function tf = local_isdriveroot(p)
tf = ispc && numel(p) == 3 && p(2) == ':' && p(3) == filesep;
end


function tf = local_same(a, b)
%LOCAL_SAME  Path comparison with the platform's own case rules.
if ispc
    tf = strcmpi(a, b);
else
    tf = strcmp(a, b);
end
end
