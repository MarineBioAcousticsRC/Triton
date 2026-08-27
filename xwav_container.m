function [kind, fullname] = xwav_container(fullname)
%XWAV_CONTAINER  Is this file stored as a wav or as a flac? Ask the file.
%
%   [kind, fullname] = xwav_container(fullname)
%
% kind is 'flac', 'wav' or 'unknown', decided from the first four bytes:
% 'fLaC' or 'RIFF'. The cleaned-up path is returned as well, and callers should
% use that rather than the one they passed in.
%
% WHY NOT THE FILE EXTENSION
%
% Because Triton stores file names in padded char matrices. PARAMS.ltsahd.fname
% is created as char(zeros(n,80)) and each name written into the leading
% columns, so every row carries trailing null characters. Pass such a row
% through fileparts and the extension comes back as '.flac' followed by nulls,
% which matches nothing. The file is then read as though it were a wav: fopen
% accepts the padded name, fread returns compressed frames interpreted as
% int16, and the result is plausible-looking noise with no error anywhere.
%
% That is the worst kind of failure, and it is not hypothetical -- it is what
% happened the first time the Soundscape-Metrics LTSA code called xwav_read,
% because that code addresses files by ltsahd row.
%
% Reading the magic bytes costs four bytes and cannot be fooled by padding, by
% a renamed file, or by a caller that guesses wrong. Trailing whitespace and
% nulls are stripped from the name too, since a padded row is what most of
% Triton has to offer.
%
% 'unknown' means the file could not be opened or is shorter than four bytes.
% Callers report that rather than guessing, because guessing is what this
% function exists to stop.
%
% See also XWAV_READ, XWAV_HDRFILE.

kind = 'unknown';

% Strip the padding first: deblank removes trailing whitespace and nulls, which
% is what a char-matrix row arrives with.
fullname = deblank(fullname);

fid = fopen(fullname,'r');
if fid < 0
    return
end
c = onCleanup(@() fclose(fid)); %#ok<NASGU>

magic = fread(fid,4,'*uint8');
if numel(magic) < 4
    return
end

switch char(magic(:)')
    case 'fLaC'
        kind = 'flac';
    case 'RIFF'
        kind = 'wav';
end
end
