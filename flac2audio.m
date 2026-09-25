function [ok, outFile, info] = flac2audio(inFile, varargin)
%FLAC2AUDIO  Expand one .flac or .x.flac back to wav.
%
%   ok = flac2audio('E:\HARP\SiteA\file.x.flac')
%   [ok, out] = flac2audio(f, 'outdir', d)
%
% An .x.flac becomes a .x.wav with its harp header restored exactly; a plain
% .flac becomes a .wav. The result is byte-identical to whatever was compressed
% in the first place.
%
% Before writing, the space needed is known exactly -- a flac records the size
% of the file it came from -- so this refuses rather than half-filling a drive.
%
% Options are passed straight through to xwav_convert; see its help for the
% full list. The ones that matter most:
%
%   'outdir'      where to write; default alongside the input
%   'keepInput'   keep the .flac (default true)
%   'minFree'     bytes to leave free on the destination (default 2 GiB)
%
% See also AUDIO2FLAC, FLACDIR2AUDIO, XWAV_CONVERT.

[ok, outFile, info] = xwav_convert(inFile, 'direction', 'expand', varargin{:});
end
