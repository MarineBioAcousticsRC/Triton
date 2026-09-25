function report = audiodir2flac(srcdir, destdir, varargin)
%AUDIODIR2FLAC  Compress a whole folder tree to flac, keeping its structure.
%
%   audiodir2flac('E:\HARP\SiteA', 'F:\ToPartner')              % dry run
%   audiodir2flac('E:\HARP\SiteA', 'F:\ToPartner', 'go', true)  % do it
%
% Walks the source tree, converts every .wav and .x.wav it finds, and writes the
% results into the destination under the same subfolder layout -- so a
% deployment folder with one subfolder per disk arrives looking the same.
%
% A bare call is a DRY RUN: it writes nothing and reports what it would do, how
% much space it needs and what it cannot handle. Add 'go',true to convert.
%
% Sources are never deleted. This is a transfer, not an in-place conversion.
%
% Options are passed straight through to xwav_convert_dir; see its help for the
% full list. The ones that matter most:
%
%   'go'          actually convert (default false)
%   'overwrite'   'verified' (default) re-does an output that fails its check
%   'minFree'     bytes to leave free on the destination (default 2 GiB)
%   'recursive'   walk subfolders (default true)
%
% See also FLACDIR2AUDIO, AUDIO2FLAC, XWAV_CONVERT_DIR, XWAV_CONVERT_PLAN.

% One argument means convert in place, which is what the older xwavdir2flac
% did and is still a reasonable thing to want.
if nargin < 2 || isempty(destdir)
    destdir = srcdir;
end

report = xwav_convert_dir(srcdir, destdir, 'direction', 'compress', varargin{:});
end
