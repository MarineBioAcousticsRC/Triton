function chunks = xflac_riff_chunks(fullname)
%XFLAC_RIFF_CHUNKS  The RIFF chunks flac preserved inside an x.flac, in order.
%
%   chunks = xflac_riff_chunks('file.x.flac')
%
% Returns a cell array of uint8 column vectors, one per APPLICATION metadata
% block carrying the id 'riff' -- that is, the RIFF, fmt, harp and data chunk
% headers of the original x.wav, stored verbatim by
% `flac --keep-foreign-metadata`. Concatenated they reproduce the x.wav header
% byte for byte.
%
% Empty means the flac was compressed without that flag and its harp header is
% gone for good.
%
% Only the metadata blocks are walked; the compressed audio is never touched,
% so this is fast even on a large file.
%
% See also XWAV_HDRFILE, RDXFLACHD, CK_XFLAC_METADATA.

chunks = {};

fullname = deblank(fullname);   % names arrive as padded char-matrix rows
fid = fopen(fullname,'r');
if fid < 0
    error('xflac_riff_chunks:cannotOpen','cannot open %s', fullname);
end
c = onCleanup(@() fclose(fid)); %#ok<NASGU>

magic = fread(fid,4,'*char')';
if ~strcmp(magic,'fLaC')
    error('xflac_riff_chunks:notFlac','%s is not a flac file', fullname);
end

while true
    h = fread(fid,4,'*uint8');
    if numel(h) < 4; break; end
    isLast = bitand(h(1),128) > 0;
    btype  = double(bitand(h(1),127));
    len    = double(h(2))*65536 + double(h(3))*256 + double(h(4));
    body   = fread(fid,len,'*uint8');
    if numel(body) < len
        error('xflac_riff_chunks:truncated','metadata block truncated in %s', fullname);
    end
    if btype == 2 && len >= 4 && strcmp(char(body(1:4))','riff')
        chunks{end+1} = body(5:end); %#ok<AGROW>
    end
    if isLast; break; end
end
end
