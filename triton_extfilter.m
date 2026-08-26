function ftstr = triton_extfilter(infile, ftype)
%TRITON_EXTFILTER  The file-name ending that matches files like the one open.
%
%   ftstr = triton_extfilter(PARAMS.infile, PARAMS.ftype)
%
% Used when stepping to the next or previous file in a folder, so that an
% x.flac steps to the next x.flac rather than finding nothing.
%
%   ftype 1   .wav
%   ftype 2   .x.wav or .x.flac, whichever the open file is
%   ftype 3   .flac
%
% Returns '' for anything else, and the caller reports that.
%
% The type-2 answer comes from the open file's own name rather than from a
% flag, for the same reason xwav_read decides that way: there is then nothing
% to keep in step with the file actually open.
%
% A folder holding both .x.wav and .x.flac -- which happens when an archive is
% converted with the originals kept -- steps through one or the other, not an
% interleaving of both. That is the useful behaviour: the two sets are the same
% recordings, so walking both would visit everything twice.
%
% See also MOTION, PICKXWAV, XWAV_READ.

ftstr = '';

switch ftype
    case 1
        ftstr = '.wav';
    case 2
        [~, ~, ext] = fileparts(infile);
        if strcmpi(ext, '.flac')
            ftstr = '.x.flac';
        else
            ftstr = '.x.wav';
        end
    case 3
        ftstr = '.flac';
end
end
