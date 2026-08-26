function [hdrFile, keeper] = xwav_hdrfile(fullname)
%XWAV_HDRFILE  A path whose bytes are the x.wav header, for wav or flac alike.
%
%   [hdrFile, keeper] = xwav_hdrfile(fullname)
%
% Triton reads the harp header by seeking to fixed byte offsets: channel count
% at 22, bits per sample at 34, raw-file count at 80, then the raw-file
% directory from 100. That code is spread over rdxwavhd, get_headers and
% calc_ltsa and it is correct, well exercised, and not worth rewriting.
%
% An x.flac has the same bytes -- flac --keep-foreign-metadata stores the
% original RIFF chunks as APPLICATION blocks with the id 'riff' -- but they are
% not at those offsets and cannot be seeked to. So instead of teaching every
% caller a second way to read a header, this hands back a path that can be
% opened and seeked exactly as before:
%
%   .wav    the file itself; nothing is copied and keeper is empty
%   .flac   a small temporary file holding the reassembled chunks, which are
%           byte-identical to the original x.wav header
%
% Callers keep their existing fopen/fseek/fread untouched. The two containers
% therefore cannot drift apart: there is only one parser, and a fix to it
% reaches flac for free.
%
% KEEPER MUST BE HELD, AND MUST BE MENTIONED AGAIN. It is an onCleanup that
% deletes the temporary file when destroyed, and MATLAB destroys such an object
% as soon as it can prove the variable is never read again -- which, if nothing
% below mentions it, is immediately. The file would then be gone before it was
% read. Ending with `clear keeper` is both the tidy-up and the mention that
% keeps it alive until then:
%
%   [hf, keeper] = xwav_hdrfile(f);
%   fid = fopen(hf,'r');
%   ...
%   fclose(fid);
%   clear keeper
%
% Errors rather than returning empty, because every caller needs the header and
% none of them can carry on without it.
%
% See also RDXFLACHD, XWAV_READ, GET_HEADERS, CALC_LTSA.

keeper = [];

[~, ~, ext] = fileparts(fullname);
if ~strcmpi(ext, '.flac')
    hdrFile = fullname;
    return
end

chunks = xflac_riff_chunks(fullname);
if isempty(chunks)
    error('xwav_hdrfile:noMetadata', ...
        ['%s carries no preserved RIFF metadata.\n' ...
         'It was compressed without --keep-foreign-metadata, so the harp\n' ...
         'header is gone. Use Extras/ck_xflac_metadata.m to audit a folder.'], ...
        fullname);
end

hdrFile = [tempname '.x.wav'];
fid = fopen(hdrFile,'w');
if fid < 0
    error('xwav_hdrfile:cannotWrite', ...
        'Cannot write a temporary file to read the header of %s', fullname);
end
fwrite(fid, cat(1, chunks{:}), 'uint8');
fclose(fid);

keeper = onCleanup(@() local_delete(hdrFile));
end


function local_delete(f)
% A failure here is not worth a warning: the file is in the temp directory, it
% is a few kilobytes, and the caller has finished with it either way.
try %#ok<TRYNC>
    if exist(f,'file'); delete(f); end
end
end
