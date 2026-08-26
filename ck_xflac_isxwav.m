function tf = ck_xflac_isxwav(fullname)
%CK_XFLAC_ISXWAV  Is this flac a compressed xwav rather than a plain flac?
%
%   tf = ck_xflac_isxwav('file.flac')
%
% True when the file carries a harp chunk preserved by
% `flac --keep-foreign-metadata`, meaning it is an x.wav that was compressed
% and still knows its raw-file structure and recording times.
%
% The distinction matters at open time. A plain flac has no header, so Triton
% takes the start time from the file name; an x.flac has the real deployment
% timing in its harp chunk. Reading one as the other produces a display that
% looks entirely normal and is wrong by however much the recorder's clock
% drifted, with nothing to indicate it. So the decision is made from the file's
% contents rather than from its name, which anyone can rename.
%
% Never errors: anything unreadable is simply not an xwav, and the caller is
% about to try opening it anyway and will report a real failure then.
%
% See also XFLAC_RIFF_CHUNKS, CK_XFLAC_METADATA, RDXFLACHD.

tf = false;
try
    chunks = xflac_riff_chunks(fullname);
catch
    return
end
for k = 1:numel(chunks)
    b = chunks{k};
    if numel(b) >= 4 && strcmp(char(b(1:4))','harp')
        tf = true;
        return
    end
end
end
