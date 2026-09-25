function [usable, total, fsType, maxFileBytes] = disk_free(target)
%DISK_FREE  Space and limits of the volume holding a path.
%
%   usable = disk_free('E:\HARP\SiteA')
%   [usable, total, fsType, maxFileBytes] = disk_free(dest)
%
%   usable        bytes this user can still write, or NaN if it cannot be told
%   total         bytes on the volume, or NaN
%   fsType        'NTFS', 'exFAT', 'FAT32', ... or '' if unknown
%   maxFileBytes  largest single file the filesystem allows, or Inf if unknown
%                 or unlimited in practice
%
% `usable` is what the user can still write, which on a volume with quotas is
% less than the raw free space. That is the number a transfer has to respect.
%
% The path need not exist -- writing usually means creating folders that are not
% there yet -- so this walks up to the nearest existing ancestor.
%
% NaN MEANS UNKNOWN, AND CALLERS MUST SAY SO
%
% Some SMB shares report zero usable bytes rather than admitting they do not
% know. Returning 0 for that would refuse to run on a network share; returning
% Inf would silently switch off the guard on exactly the drives that fill up. So
% "unknown" is a third state, and a caller that gets NaN must tell the user it
% could not check rather than quietly proceeding.
%
% maxFileBytes matters for shipping drives: FAT32 caps a single file at 4 GiB,
% and a decompressed x.wav can exceed that. Hitting it mid-write looks exactly
% like a full disk.
%
% See also AUDIO_FILE_KIND, XWAV_CONVERT.

usable = NaN; total = NaN; fsType = ''; maxFileBytes = Inf;

if nargin < 1 || isempty(target) || ~ischar(target)
    return
end

% Walk up to something that exists. fileparts peels one level at a time and
% returns the same string twice once it can go no further.
probe = target;
while ~isempty(probe) && ~exist(probe,'dir')
    up = fileparts(probe);
    if strcmp(up, probe); break; end
    probe = up;
end
if isempty(probe) || ~exist(probe,'dir') || ~usejava('jvm')
    return
end

try
    f = java.io.File(probe);
    usable = double(f.getUsableSpace());
    total  = double(f.getTotalSpace());
    % Zero for both means the volume was not really inspected, not that it is
    % full. Report that as unknown.
    if total == 0
        usable = NaN; total = NaN;
    end
catch
    usable = NaN; total = NaN;
end

try
    st = java.nio.file.Files.getFileStore(java.io.File(probe).toPath());
    fsType = char(st.type());
catch
    fsType = '';
end

switch upper(fsType)
    case 'FAT32'
        maxFileBytes = 4*2^30 - 1;      % 4 GiB minus one byte
    case {'FAT','FAT16','MSDOS'}
        maxFileBytes = 2*2^30 - 1;
    otherwise
        maxFileBytes = Inf;             % NTFS, exFAT, APFS, ext4, and unknown
end
end
