function [ok, outFile, info] = audio2flac(inFile, varargin)
%AUDIO2FLAC  Compress one .wav or .x.wav to flac, losslessly and verified.
%
%   ok = audio2flac('E:\HARP\SiteA\file.x.wav')
%   [ok, out] = audio2flac(f, 'outdir', d, 'keepInput', false)
%
% Handles both kinds. An .x.wav becomes a .x.flac with its harp header intact;
% a plain .wav becomes a .flac. Which one you have is read from the file, not
% from its name, so a renamed xwav is still treated as an xwav.
%
% The original is removed only when 'keepInput' is false AND the conversion has
% been verified -- both the audio and the preserved header.
%
% Options are passed straight through to xwav_convert; see its help for the
% full list. The ones that matter most:
%
%   'outdir'      where to write; default alongside the input
%   'keepInput'   keep the original (default true)
%   'minFree'     bytes to leave free on the destination (default 2 GiB)
%
% See also FLAC2AUDIO, AUDIODIR2FLAC, XWAV_CONVERT.

[ok, outFile, info] = xwav_convert(inFile, 'direction', 'compress', varargin{:});
end
