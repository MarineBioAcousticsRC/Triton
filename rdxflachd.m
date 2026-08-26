function rdxflachd
%RDXFLACHD  Read an x.flac header, giving the same PARAMS an x.wav would.
%
% An x.flac is an x.wav compressed with `flac --keep-foreign-metadata`. That
% flag stores the original RIFF chunks -- RIFF, fmt, harp and data -- inside the
% flac as APPLICATION metadata blocks with the id 'riff'. The harp chunk, with
% its whole raw-file directory, survives byte for byte.
%
% So an x.flac is logically an x.wav: same recording times, same raw files, same
% gain, same sample rate. Only the way samples are fetched differs. This
% function reads the header and leaves PARAMS exactly as rdxwavhd would, plus
% two fields that tell the read path how to get at the audio:
%
%   PARAMS.container         'flac'  (rdxwavhd leaves this 'wav')
%   PARAMS.raw.sampleStart   0-based sample offset of each raw file
%
% PARAMS.ftype stays 2. An x.flac *is* an xwav, and everything downstream that
% branches on ftype -- and there are more than forty such branches -- should
% carry on treating it as one. Only the handful of places that actually fetch
% audio need to know the difference, and they use xwav_read.
%
% The parsing itself is done by rdxwavhd, not repeated here. The reconstructed
% chunks are byte-identical to the original x.wav header, so the same code can
% and should read them: any future fix to rdxwavhd then applies to flac for
% free, and the two cannot drift apart. The chunks are written to a small
% temporary file for that purpose, since MATLAB cannot fopen a byte array.
%
% See also RDXWAVHD, XWAV_READ.

global PARAMS

flacFile = fullfile(PARAMS.inpath, PARAMS.infile);

%% ---- pull the preserved RIFF chunks out of the flac
try
    riff = local_riff_chunks(flacFile);
catch e
    disp_msg(['Error reading flac metadata: ', e.message]);
    return
end

if isempty(riff)
    disp_msg('Error - this flac carries no preserved RIFF metadata')
    disp_msg('  It was compressed without --keep-foreign-metadata, so the harp')
    disp_msg('  header is gone and the recording times cannot be recovered.')
    disp_msg('  Use Extras/ck_xflac_metadata.m to audit a folder for this.')
    return
end
if ~any(local_chunk_is(riff,'harp'))
    disp_msg('Error - preserved RIFF metadata contains no harp chunk')
    disp_msg('  This looks like a plain wav compressed to flac, not an x.flac.')
    return
end

%% ---- reassemble them into the original header and let rdxwavhd parse it
hdrBytes = cat(1, riff{:});

tmpFile = [tempname '.x.wav'];
fid = fopen(tmpFile,'w');
if fid < 0
    disp_msg('Error - cannot write a temporary file to read the flac header');
    return
end
fwrite(fid, hdrBytes, 'uint8');
fclose(fid);
cleanup = onCleanup(@() local_delete(tmpFile));

savedInpath = PARAMS.inpath;
savedInfile = PARAMS.infile;
[tp, tn, te] = fileparts(tmpFile);
PARAMS.inpath = [tp filesep];
PARAMS.infile = [tn te];

try
    rdxwavhd;                       % the real parser, unmodified
catch e
    PARAMS.inpath = savedInpath;
    PARAMS.infile = savedInfile;
    disp_msg(['Error parsing the flac''s harp header: ', e.message]);
    return
end

PARAMS.inpath = savedInpath;
PARAMS.infile = savedInfile;

if ~isfield(PARAMS,'xhd') || ~isfield(PARAMS.xhd,'byte_length')
    disp_msg('Error - the flac''s harp header did not parse');
    return
end

%% ---- flac-specific additions
PARAMS.container = 'flac';

% Sample offset of each raw file from the start of the audio. Derived from the
% cumulative byte lengths rather than from byte_loc: byte_loc records positions
% in the *original x.wav*, which do not exist in the compressed stream, whereas
% byte_length is a property of the data itself and is still true. The two agree
% on every file checked, but only one of them stays true after compression.
bytesPerSlice = double(PARAMS.nch) * double(PARAMS.samp.byte);
lengths = double(PARAMS.xhd.byte_length(:))';
PARAMS.raw.sampleStart = [0, cumsum(lengths(1:end-1))] ./ bytesPerSlice;

% Cross-check the header against the audio actually present. A mismatch means
% the flac was edited after conversion, or the header was already wrong.
try
    I = audioinfo(flacFile);
    expected = sum(lengths) / bytesPerSlice;
    if I.TotalSamples ~= expected
        disp_msg('Warning - flac audio length does not match its harp header')
        disp_msg(sprintf('  header describes %d samples, file holds %d', ...
            round(expected), I.TotalSamples));
    end
    if I.SampleRate ~= PARAMS.fs
        disp_msg(sprintf('Warning - flac sample rate %g differs from header %g', ...
            I.SampleRate, PARAMS.fs));
    end
catch
    % audioinfo failing is reported by the read path; the header is still good
end
end


%% ================================================================== helpers
function chunks = local_riff_chunks(f)
%LOCAL_RIFF_CHUNKS  Payloads of the APPLICATION blocks with id 'riff', in order.
chunks = {};
fid = fopen(f,'r');
if fid < 0; error('cannot open %s', f); end
c = onCleanup(@() fclose(fid));

magic = fread(fid,4,'*char')';
if ~strcmp(magic,'fLaC'); error('not a flac file'); end

while true
    h = fread(fid,4,'*uint8');
    if numel(h) < 4; break; end
    isLast = bitand(h(1),128) > 0;
    btype  = double(bitand(h(1),127));
    len    = double(h(2))*65536 + double(h(3))*256 + double(h(4));
    body   = fread(fid,len,'*uint8');
    if numel(body) < len; error('metadata block truncated'); end
    if btype == 2 && len >= 4 && strcmp(char(body(1:4))','riff')
        chunks{end+1} = body(5:end); %#ok<AGROW>
    end
    if isLast; break; end
end
end


function tf = local_chunk_is(chunks, tag)
tf = false(1,numel(chunks));
for k = 1:numel(chunks)
    b = chunks{k};
    if numel(b) >= 4 && strcmp(char(b(1:4))', tag); tf(k) = true; end
end
end


function local_delete(f)
if exist(f,'file'); delete(f); end
end
