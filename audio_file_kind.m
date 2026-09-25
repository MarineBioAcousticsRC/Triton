function [kind, info] = audio_file_kind(fullname)
%AUDIO_FILE_KIND  What is this file, really? Decided from its bytes.
%
%   [kind, info] = audio_file_kind('E:\HARP\SiteA\foo.wav')
%
%   kind   'xwav'   a RIFF wav carrying a harp chunk
%          'wav'    a RIFF wav without one
%          'xflac'  a flac carrying a preserved harp chunk
%          'flac'   a flac without one
%          'notaudio'  anything else, including unreadable
%
%   info   .bytes          size on disk
%          .decodedBytes   size this file would be as an uncompressed wav
%          .exact          is decodedBytes the real answer or an upper bound?
%          .encodable      can flac encode this? (false for e.g. 32-bit float)
%          .why            why not, when encodable is false
%          .fs .nch .nBits .totalSamples   when they could be read
%
% NEVER CLASSIFY BY FILE NAME
%
% A `.wav` may be an xwav that was renamed, and converting one down the plain
% path throws away its harp header silently. A `.flac` may be an x.flac. And
% `ExampleData/200kHz_xwavs/SOCAL_E_63_EN_LTSA_testSet.ltsa.wav` is an LTSA file
% wearing a `.wav` extension -- a directory walk will hand it to you, and it is
% not audio at all. So every decision here comes from the file's own bytes.
%
% SIZE PREDICTION
%
% decodedBytes is how the conversion can be costed before it runs:
%
%   xflac   the preserved RIFF header records the original file's own size.
%           Exact -- it is what the x.wav measured before compression.
%   flac    TotalSamples * channels * bytes per sample + 44. Exact to the byte
%           on every file tested, including a 518 MB recording.
%   wav/xwav  the file's own size; it is already decoded.
%
% See also DISK_FREE, XWAV_CONVERT, XWAV_CONTAINER.

kind = 'notaudio';
info = struct('bytes',NaN,'decodedBytes',NaN,'exact',false,'encodable',false, ...
              'why','','fs',NaN,'nch',NaN,'nBits',NaN,'totalSamples',NaN);

d = dir(fullname);
if isempty(d) || d(1).isdir
    info.why = 'no such file';
    return
end
info.bytes = d(1).bytes;

[container, fullname] = xwav_container(fullname);

switch container
    case 'wav'
        [kind, info] = local_wav(fullname, info);
    case 'flac'
        [kind, info] = local_flac(fullname, info);
    otherwise
        info.why = 'not a RIFF or flac file';
end
end


%% ================================================================== helpers
function [kind, info] = local_wav(f, info)
info.decodedBytes = info.bytes;     % already uncompressed
info.exact = true;

if local_harp_tag(f)
    kind = 'xwav';
else
    kind = 'wav';
end

% audioinfo is the cheapest way to learn whether flac can take this. It also
% catches a file that is RIFF but not readable audio.
try
    I = audioinfo(f);
    info.fs = I.SampleRate; info.nch = I.NumChannels;
    info.nBits = I.BitsPerSample; info.totalSamples = I.TotalSamples;
catch e
    kind = 'notaudio';
    info.why = ['not readable as audio: ' e.message];
    return
end

[info.encodable, info.why] = local_encodable(info);
end


function [kind, info] = local_flac(f, info)
if ck_xflac_isxwav(f)
    kind = 'xflac';
else
    kind = 'flac';
end
info.encodable = false;
info.why = 'already compressed';

% Exact answer first: the preserved RIFF chunk carries the original size.
info.decodedBytes = local_riff_size(f);
info.exact = ~isnan(info.decodedBytes);

try
    I = audioinfo(f);
    info.fs = I.SampleRate; info.nch = I.NumChannels;
    info.nBits = I.BitsPerSample; info.totalSamples = I.TotalSamples;
    if isnan(info.decodedBytes)
        if I.TotalSamples > 0
            info.decodedBytes = I.TotalSamples * I.NumChannels * ...
                floor(I.BitsPerSample/8) + 44;
            info.exact = true;
        else
            % A flac made from a stream records no sample count.
            info.decodedBytes = NaN; info.exact = false;
        end
    end
catch e
    if isnan(info.decodedBytes)
        kind = 'notaudio';
        info.why = ['not readable as audio: ' e.message];
    end
end
end


function [ok, why] = local_encodable(info)
%LOCAL_ENCODABLE  Will flac take this wav?
%
% Partner recordings are far more varied than HARP x.wavs, and two cases fail
% outright rather than degrading: flac cannot encode floating-point samples at
% all, and it only handles 4 to 32 bits per sample.
ok = true; why = '';
if ~isnan(info.nBits) && (info.nBits < 4 || info.nBits > 32)
    ok = false;
    why = sprintf('flac cannot encode %d-bit audio', info.nBits);
end
end


function tf = local_harp_tag(wavFile)
%LOCAL_HARP_TAG  Is the subchunk after 'fmt ' a harp chunk?
%
% A RIFF wav is 'RIFF' size 'WAVE' then subchunks. The first is 'fmt ' with a
% 16-byte body for PCM, putting the next subchunk's tag at offset 36 -- 'harp'
% in an x.wav, 'data' in a plain one. Cheap, and it is the same offset rdxwavhd
% reads.
tf = false;
fid = fopen(wavFile,'r');
if fid < 0; return; end
c = onCleanup(@() fclose(fid)); %#ok<NASGU>
if fseek(fid,36,'bof') ~= 0; return; end
tag = fread(fid,4,'*char');
tf = numel(tag) == 4 && strcmp(tag(:)','harp');
end


function bytes = local_riff_size(flacFile)
%LOCAL_RIFF_SIZE  Original wav size, from the RIFF chunk flac preserved.
%
% 'RIFF' + uint32 ChunkSize + 'WAVE'; ChunkSize counts everything after the
% first 8 bytes, so the whole file was ChunkSize + 8.
bytes = NaN;
try
    chunks = xflac_riff_chunks(flacFile);
catch
    return
end
for k = 1:numel(chunks)
    b = chunks{k};
    if numel(b) >= 8 && strcmp(char(b(1:4))','RIFF')
        v = double(typecast(uint8(b(5:8)),'uint32'));
        % Some writers put 0 or 0xFFFFFFFF here rather than a real size.
        if v > 0 && v < 4294967295
            bytes = v + 8;
        end
        return
    end
end
end
