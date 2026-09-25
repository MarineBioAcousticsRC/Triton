function report = flacdir2audio(srcdir, destdir, varargin)
%FLACDIR2AUDIO  Expand a whole folder tree of flac back to wav, keeping its structure.
%
%   flacdir2audio('F:\FromPartner', 'E:\HARP\SiteA')              % dry run
%   flacdir2audio('F:\FromPartner', 'E:\HARP\SiteA', 'go', true)  % do it
%
% The reverse of audiodir2flac. .x.flac becomes .x.wav with the harp header
% restored; plain .flac becomes .wav.
%
% A bare call is a DRY RUN. Run it first: expanding multiplies the data by
% roughly two, and the dry run reports the space needed EXACTLY rather than as
% an estimate, because each flac records the size of the file it came from.
%
% If the destination runs short part way, the run stops cleanly rather than
% leaving a trail of half-written files, and says how much more room is needed.
%
% Options are passed straight through to xwav_convert_dir; see its help for the
% full list. The ones that matter most:
%
%   'go'          actually convert (default false)
%   'overwrite'   'verified' (default) re-does an output that fails its check
%   'minFree'     bytes to leave free on the destination (default 2 GiB)
%   'recursive'   walk subfolders (default true)
%
% See also AUDIODIR2FLAC, FLAC2AUDIO, XWAV_CONVERT_DIR, XWAV_CONVERT_PLAN.

% One argument means expand in place, for symmetry with audiodir2flac. Worth
% thinking twice about, since expanding roughly doubles the data where it sits
% -- but a bare call is a dry run, so the size is on screen before anything
% happens.
if nargin < 2 || isempty(destdir)
    destdir = srcdir;
end

report = xwav_convert_dir(srcdir, destdir, 'direction', 'expand', varargin{:});
end
