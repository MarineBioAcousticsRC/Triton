function make_pad_fixture(varargin)
%MAKE_PAD_FIXTURE  Build the synthetic files that exercise calc_ltsa's padding.
%
%   make_pad_fixture
%   make_pad_fixture('outdir','tests/fixtures')
%
% calc_ltsa pads the final spectral average of a raw file with zeros when that
% average holds fewer samples than nfft -- the `dsz < nfft` branch. That branch
% is where the four Triton checkouts differ, and it carries the misplaced-bracket
% bug found on six branches:
%
%     if length(data(1,:) == length(dz(1,:)))     % always true
%
% None of the real example data reaches the branch, because every raw file's
% sample count happens to be a whole multiple of nfft. These fixtures reach it.
%
% TWO FILE TYPES ARE NEEDED, not one.
%
% The broken form is only *wrong* for a row vector. For wav and flac input
% calc_ltsa holds the samples as a column, so both the correct and the broken
% test concatenate vertically and the output is identical -- verified. For x.wav
% input the samples arrive as a row (`data = data(ch,:)`), and there the correct
% form appends horizontally while the broken form appends vertically, which is a
% dimension mismatch. So the x.wav fixture is the one that exposes the bug and
% the wav fixture is the one that proves the harmless case stays harmless.
%
% SIZING, at the harness defaults tave = 5 s and dfreq = 100 Hz
%
%   wav   fs = 10000  ->  nfft = 100,  per average = 50000 samples
%         50050 samples  ->  1 average + 50 left,  50 < 100, pads
%
%   x.wav fs = 30000  ->  nfft = 300,  per average = 150000 samples
%         150250 samples per raw file  ->  1 average + 250 left, 250 < 300, pads
%         150250 is also a multiple of 250, which the HARP sector geometry
%         requires: samples per raw = write_length * blksz, blksz = (512-12)/2
%         for one channel (ck_ltsaparams.m:50).
%
% Signals are deterministic sums of tones plus a slow chirp -- no random numbers
% -- so the files are byte-reproducible on any MATLAB release and the LTSAs have
% real spectral structure. The generated files are committed; this script records
% their provenance and lets them be rebuilt.
%
% See tests/README.md.

here = fileparts(mfilename('fullpath'));

p = inputParser;
addParameter(p,'outdir', fullfile(here,'fixtures'));
parse(p,varargin{:});
root = p.Results.outdir;

wavDir  = fullfile(root,'pad_wav');
xwavDir = fullfile(root,'pad_xwav');
for d = {wavDir, xwavDir}
    if ~exist(d{1},'dir'); mkdir(d{1}); end
end

%% ------------------------------------------------------------------ wav pair
fprintf('wav (column-vector path, padding harmless):\n');
fs = 10000; nsamp = 50050;
specs = { 'SYNTH_PAD_260101_000000.wav', [ 440 1200 3300], [0.35 0.20 0.10]; ...
          'SYNTH_PAD_260101_000006.wav', [ 700 1900 2600], [0.30 0.18 0.14] };
for k = 1:size(specs,1)
    y = local_signal(nsamp, fs, specs{k,2}, specs{k,3});
    outpath = fullfile(wavDir, specs{k,1});
    audiowrite(outpath, y, fs, 'BitsPerSample', 16);
    I = audioinfo(outpath);
    fprintf('  %-34s %d samples, %g Hz, %.4f s\n', specs{k,1}, ...
        I.TotalSamples, I.SampleRate, I.Duration);
end
local_report(nsamp, fs, 100, 5);

%% ---------------------------------------------------------------- x.wav pair
fprintf('\nx.wav (row-vector path, padding exposes the bug):\n');
fsx = 30000; nsampx = 150250;   % multiple of 250, and 250 short of 150000
xspecs = { 'SYNTH_PADX_260101_000000.x.wav', [ 900 4200 9000], [0.34 0.21 0.11]; ...
           'SYNTH_PADX_260101_000010.x.wav', [1500 5100 7300], [0.29 0.19 0.15] };
starts = { [2026 1 1 0 0 0], [2026 1 1 0 0 10] };
for k = 1:size(xspecs,1)
    y = local_signal(nsampx, fsx, xspecs{k,2}, xspecs{k,3});
    outpath = fullfile(xwavDir, xspecs{k,1});
    local_write_xwav(outpath, y, fsx, starts{k});
    d = dir(outpath);
    fprintf('  %-34s %d samples, %g Hz, %d bytes\n', xspecs{k,1}, ...
        nsampx, fsx, d.bytes);
end
local_report(nsampx, fsx, 100, 5);
end


%% ================================================================== helpers
function y = local_signal(n, fs, tones, amps)
%LOCAL_SIGNAL  Deterministic int16 test signal: tones plus a slow chirp.
t = (0:n-1)' / fs;
x = zeros(n,1);
for j = 1:numel(tones)
    x = x + amps(j) * sin(2*pi*tones(j)*t);
end
inst = 0.03*fs + 0.15*fs * (t / t(end));      % chirp, scaled to the rate
x = x + 0.08 * sin(2*pi*cumsum(inst)/fs);
x = x / max(abs(x)) * 0.8;                    % headroom, no clipping
y = int16(round(x * 32767));
end


function local_report(nsamp, fs, dfreq, tave)
%LOCAL_REPORT  Show the arithmetic, so a reader can check it rather than trust it.
nfft   = floor(fs/dfreq);
cfact  = tave*fs/nfft;
perAve = nfft*cfact;
rem_   = mod(nsamp, perAve);
fprintf('  nfft %d, cfact %g, %d samples per average\n', nfft, cfact, perAve);
fprintf('  %d samples = %d full + %d left over; %d < %d so it pads: %s\n', ...
    nsamp, floor(nsamp/perAve), rem_, rem_, nfft, ...
    string(rem_ > 0 && rem_ < nfft));
end


function local_write_xwav(path, y, fs, startVec)
%LOCAL_WRITE_XWAV  Write a one-channel 16-bit version-1 x.wav.
%
% Byte layout per docs/formats/xwav.md in the Python port, which was derived
% from rdxwavhd.m. One raw file, so the padding case sits at the end of it.

nch  = 1;
bits = 16;
bps  = bits/8;
nRaw = 1;

harpFixed = 64;                 % version 0/1 harp chunk, no per-channel fields
rawEntry  = 32;
harpSize  = harpFixed - 8 + nRaw*rawEntry;
headerSize= 12 + 24 + harpFixed + nRaw*rawEntry + 8;

rawBytes  = numel(y) * nch * bps;
dataSize  = rawBytes * nRaw;

% HARP sector geometry: samples per raw = write_length * blksz  (blksz = 250)
blksz = (512 - 12)/2;
writeLength = rawBytes / (bps * blksz);
if mod(writeLength,1) ~= 0
    error('make_pad_fixture: %d samples is not a whole number of sectors', numel(y));
end

fid = fopen(path,'w');
if fid < 0; error('make_pad_fixture: cannot write %s', path); end

fwrite(fid,'RIFF','char');
fwrite(fid, headerSize - 8 + dataSize, 'uint32');
fwrite(fid,'WAVE','char');

fwrite(fid,'fmt ','char');
fwrite(fid, 16, 'uint32');
fwrite(fid, 1, 'uint16');                  % AudioFormat, PCM
fwrite(fid, nch, 'uint16');
fwrite(fid, fs, 'uint32');
fwrite(fid, fs*nch*bps, 'uint32');         % ByteRate
fwrite(fid, nch*bps, 'uint16');            % BlockAlign
fwrite(fid, bits, 'uint16');

fwrite(fid,'harp','char');
fwrite(fid, harpSize, 'uint32');
fwrite(fid, 1, 'uint8');                   % WavVersionNumber
local_fixed(fid,'1.0synth01',10);          % FirmwareVersionNumber
local_fixed(fid,'SYNT',4);                 % InstrumentID
local_fixed(fid,'PADT',4);                 % SiteName
local_fixed(fid,'PADFIXTR',8);             % ExperimentName
fwrite(fid, 1, 'uint8');                   % DiskSequenceNumber
local_fixed(fid,'PX000001',8);             % DiskSerialNumber
fwrite(fid, nRaw, 'uint16');
fwrite(fid, -11795000, 'int32');           % Longitude, deg * 1e5
fwrite(fid,   3275000, 'int32');           % Latitude
fwrite(fid,      1000, 'int16');           % Depth [m]
fwrite(fid, zeros(1,8), 'uint8');          % Reserved

% raw-file table: year is offset from 2000, matching rdxwavhd
fwrite(fid, startVec(1) - 2000, 'uint8');
fwrite(fid, startVec(2), 'uint8');
fwrite(fid, startVec(3), 'uint8');
fwrite(fid, startVec(4), 'uint8');
fwrite(fid, startVec(5), 'uint8');
fwrite(fid, startVec(6), 'uint8');
fwrite(fid, 0, 'uint16');                  % ticks [ms]
fwrite(fid, headerSize, 'uint32');         % byte_loc
fwrite(fid, rawBytes, 'uint32');           % byte_length
fwrite(fid, writeLength, 'uint32');
fwrite(fid, fs, 'uint32');                 % sample_rate
fwrite(fid, 1, 'uint8');                   % gain
fwrite(fid, zeros(1,7), 'uint8');          % pad the entry to 32 bytes

fwrite(fid,'data','char');
fwrite(fid, dataSize, 'uint32');

pos = ftell(fid);
if pos ~= headerSize
    fclose(fid);
    error('make_pad_fixture: header is %d bytes, expected %d', pos, headerSize);
end

fwrite(fid, y, 'int16');
fclose(fid);
end


function local_fixed(fid, s, n)
%LOCAL_FIXED  Write a fixed-width, zero-padded character field.
b = zeros(1,n,'uint8');
c = uint8(s);
b(1:min(n,numel(c))) = c(1:min(n,numel(c)));
fwrite(fid, b, 'uint8');
end
