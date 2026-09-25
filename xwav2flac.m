function [ok, flacFile, msg] = xwav2flac(xwavFile, varargin)
%XWAV2FLAC  Compress one x.wav to x.flac.  (Kept for existing scripts.)
%
%   ok = xwav2flac('E:\HARP\SiteA\file.x.wav')
%   [ok, out, msg] = xwav2flac(f, 'keepXwav', false)
%
% **The name to use now is audio2flac**, which does the same thing and also
% handles plain .wav files. This wrapper stays because scripts, documentation
% and Remoras/HRP/write_hrp2xwavs all call it, and there is no reason to break
% them. Its options behave exactly as they always did.
%
%   'outdir'      where to write; default alongside the input
%   'keepXwav'    keep the original (default true)
%   'flac'        path to the flac tool
%   'verify'      verify before reporting success (default true)
%
% Everything it used to guarantee, it still guarantees: the x.wav is deleted
% only after both the audio and the preserved harp header have been checked.
% It now also refuses to start when the destination lacks room, and writes
% through a temporary name so a failure cannot leave a plausible-looking
% truncated file behind.
%
% See also AUDIO2FLAC, XWAV_CONVERT, AUDIODIR2FLAC.

p = inputParser;
addParameter(p,'outdir','');
addParameter(p,'keepXwav',true);
addParameter(p,'flac','');
addParameter(p,'verify',true);
parse(p,varargin{:});
opt = p.Results;

[ok, flacFile, info] = xwav_convert(xwavFile, ...
    'direction',  'compress', ...
    'outdir',     opt.outdir, ...
    'keepInput',  opt.keepXwav, ...
    'verify',     opt.verify, ...
    'flac',       opt.flac);

% The old contract was a message string, not a struct.
if ok && isempty(info.why)
    d = dir(flacFile);
    if isempty(d); msg = ''; else; msg = sprintf('%d bytes', d(1).bytes); end
else
    msg = info.why;
end
end
