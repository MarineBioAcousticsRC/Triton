function report = triton_flac_parity(xwavFile, varargin)
%TRITON_FLAC_PARITY  Does an x.flac give the same data as its x.wav?
%
%   triton_flac_parity('path/to/file.x.wav')
%   triton_flac_parity(f, 'flac', 'C:/Program Files/flac-1.4.3-win/Win64/flac.exe')
%
% The acceptance test for reading x.flac natively. Not "does the file round
% trip" -- that is a property of the flac tool, and it does. The question here
% is whether the *header still means the same thing*: pick a window of time,
% find it using the x.wav header the way readseg does, find the same window
% using the x.flac header, and check the waveforms match sample for sample.
%
% If they do, the harp header survives compression in a usable form and Triton
% can work from x.flac without converting back.
%
% Checks, in order:
%   1  header parity   -- every field rdxflachd derives matches rdxwavhd
%   2  timing parity   -- raw-file start and end times match exactly
%   3  waveform parity -- samples read for the same time window match, at
%                         several positions including across a raw-file boundary
%   4  round trip      -- decompressing reproduces the x.wav byte for byte
%
% Needs the flac command-line tool, which is what performs the conversion;
% MATLAB's audiowrite cannot write the APPLICATION metadata blocks that carry
% the harp header.
%
% See tests/README.md.

global PARAMS %#ok<GVMIS>

p = inputParser;
addParameter(p,'flac','C:\Program Files\flac-1.4.3-win\Win64\flac.exe');
addParameter(p,'workdir','');
addParameter(p,'keep',false);
parse(p,varargin{:});
opt = p.Results;

here = fileparts(mfilename('fullpath'));
tritonRoot = fileparts(here);
addpath(tritonRoot); addpath(here);

if ~exist(xwavFile,'file'); error('no such file: %s', xwavFile); end
if ~exist(opt.flac,'file')
    error(['flac tool not found at %s\n' ...
           'Pass its location with the ''flac'' option.'], opt.flac);
end

if isempty(opt.workdir)
    opt.workdir = fullfile(tempdir, ['flac_parity_' datestr(now,'yyyymmdd_HHMMSS')]); %#ok<TNOW1,DATST>
end
if ~exist(opt.workdir,'dir'); mkdir(opt.workdir); end

[~, stem, ext] = fileparts(xwavFile);
fprintf('x.flac parity check\n  source : %s%s\n\n', stem, ext);

report = struct('checks',{{}}, 'pass',0, 'fail',0);

%% ---- convert
flacFile = fullfile(opt.workdir, [stem '.x.flac']);
% --channel-map=none is required for anything above 2 channels: the x.wav fmt
% chunk declares plain PCM, and the WAV spec wants WAVE_FORMAT_EXTENSIBLE past
% stereo, so flac refuses with "cannot assign channels". The flag tells it not
% to apply channel-assignment rules. Verified harmless for mono -- the round
% trip is byte-identical with and without it -- so it is used unconditionally
% rather than only for multichannel files.
cmd = sprintf('"%s" --channel-map=none --keep-foreign-metadata-if-present -f -s -o "%s" "%s"', ...
    opt.flac, flacFile, xwavFile);
[st, out] = system(cmd);
if st ~= 0 || ~exist(flacFile,'file')
    error('flac conversion failed:\n%s', out);
end
a = dir(xwavFile); b = dir(flacFile);
fprintf('  compressed %d -> %d bytes (%.1f%% saved)\n\n', ...
    a.bytes, b.bytes, 100*(1 - b.bytes/a.bytes));

%% ---- 1. header parity
PARAMS = []; PARAMS.inpath = [fileparts(xwavFile) filesep];
PARAMS.infile = [stem ext]; PARAMS.ftype = 2;
rdxwavhd;
W = PARAMS;

PARAMS = []; PARAMS.inpath = [opt.workdir filesep];
PARAMS.infile = [stem '.x.flac']; PARAMS.ftype = 2;
rdxflachd;
F = PARAMS;

if ~isfield(F,'xhd') || ~isfield(F.xhd,'byte_length')
    report = local_note(report,'header parses',false,'rdxflachd produced no header');
    local_finish(report, opt); return
end
report = local_note(report,'header parses',true,'');

fields = {'nch','fs','nBits'};
for k = 1:numel(fields)
    ok = isequal(W.(fields{k}), F.(fields{k}));
    report = local_note(report, ['PARAMS.' fields{k}], ok, ...
        sprintf('%g vs %g', double(W.(fields{k})(1)), double(F.(fields{k})(1))));
end
xf = {'NumOfRawFiles','byte_length','sample_rate','gain','SampleRate','NumChannels'};
for k = 1:numel(xf)
    ok = isequal(W.xhd.(xf{k}), F.xhd.(xf{k}));
    report = local_note(report, ['xhd.' xf{k}], ok, '');
end

%% ---- 2. timing parity
report = local_note(report,'raw start times', isequal(W.raw.dnumStart, F.raw.dnumStart), '');
report = local_note(report,'raw end times',   isequal(W.raw.dnumEnd,   F.raw.dnumEnd), '');
report = local_note(report,'file start time', isequal(W.start.dnum,    F.start.dnum), '');

%% ---- 3. waveform parity: same time window, both containers
nraw = double(W.xhd.NumOfRawFiles);
sampPerRaw = double(W.xhd.byte_length(1)) / (double(W.nch)*double(W.samp.byte));
nWant = min(20000, floor(sampPerRaw/2));

cases = { 'first raw, start',        1, 0; ...
          'first raw, mid',          1, floor(sampPerRaw/2); ...
          'middle raw',              max(1,round(nraw/2)), 17; ...
          'last raw',                nraw, 0 };
if nraw > 1
    % straddle a raw-file boundary: start near the end of raw 1 and read past it
    cases(end+1,:) = { 'across a boundary', 1, sampPerRaw - floor(nWant/2) };
end

for k = 1:size(cases,1)
    label = cases{k,1}; ri = cases{k,2}; skip = cases{k,3};
    PARAMS = W; dw = xwav_read(ri, skip, nWant);
    PARAMS = F; df = xwav_read(ri, skip, nWant);
    if isempty(dw) && isempty(df)
        report = local_note(report, ['waveform: ' label], true, 'both empty');
    elseif ~isequal(size(dw), size(df))
        report = local_note(report, ['waveform: ' label], false, ...
            sprintf('sizes %s vs %s', mat2str(size(dw)), mat2str(size(df))));
    else
        ok = isequal(dw, df);
        if ok
            report = local_note(report, ['waveform: ' label], true, ...
                sprintf('%d samples identical', size(dw,1)));
        else
            nd = sum(dw(:) ~= df(:));
            report = local_note(report, ['waveform: ' label], false, ...
                sprintf('%d of %d samples differ, max |diff| %g', ...
                nd, numel(dw), max(abs(dw(:)-df(:)))));
        end
    end
end

%% ---- 4. round trip
backFile = fullfile(opt.workdir, [stem '.back' ext]);
cmd = sprintf('"%s" -d --keep-foreign-metadata-if-present -f -s -o "%s" "%s"', ...
    opt.flac, backFile, flacFile);
[st, out] = system(cmd);
if st ~= 0
    report = local_note(report,'round trip', false, strtrim(out));
else
    report = local_note(report,'round trip', ...
        isequal(local_md5(xwavFile), local_md5(backFile)), 'byte comparison');
end

local_finish(report, opt);
end


%% ================================================================== helpers
function r = local_note(r, name, ok, detail)
r.checks{end+1} = struct('name',name,'ok',ok,'detail',detail);
if ok; r.pass = r.pass + 1; else; r.fail = r.fail + 1; end
fprintf('  %-4s %-24s %s\n', local_mark(ok), name, detail);
end

function s = local_mark(ok)
if ok; s = 'ok'; else; s = 'FAIL'; end
end

function local_finish(r, opt)
fprintf('\n  %d passed, %d failed\n', r.pass, r.fail);
if r.fail == 0
    fprintf('\n  The x.flac header means the same thing as the x.wav header,\n');
    fprintf('  and the same time window yields the same samples from both.\n');
end
if ~opt.keep && exist(opt.workdir,'dir')
    rmdir(opt.workdir,'s');
end
end

function h = local_md5(f)
fid = fopen(f,'r'); b = fread(fid,Inf,'*uint8'); fclose(fid);
md = java.security.MessageDigest.getInstance('MD5');
md.update(b);
h = lower(reshape(dec2hex(typecast(md.digest(),'uint8'),2).',1,[]));
end
