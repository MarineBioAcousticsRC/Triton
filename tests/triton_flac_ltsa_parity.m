function report = triton_flac_ltsa_parity(xwavDir, varargin)
%TRITON_FLAC_LTSA_PARITY  Does an LTSA built from x.flac match one from x.wav?
%
%   triton_flac_ltsa_parity('E:\data\SomeSite\xwavs')
%   triton_flac_ltsa_parity(d, 'flac', 'C:\path\to\flac.exe', 'keep', true)
%
% triton_flac_parity answers "can Triton read an x.flac correctly". This
% answers the harder question: can Triton *generate* from one. LTSA creation is
% a separate path -- get_headers reads the harp directory itself, calc_ltsa
% walks it with its own byte arithmetic -- so reading working does not imply
% generating works.
%
% The test converts a directory of x.wav to x.flac, builds an LTSA from each,
% and compares them. The spectral data must be byte-identical: same recordings,
% same averaging, so the same numbers. The stored file names differ by
% extension and nothing else, so the header is compared field by field instead
% of byte by byte.
%
% Generation is driven by tests/triton_ltsa_baseline, the same code the
% regression harness uses, so this cannot pass while the harness would fail.
%
% Needs the flac command-line tool.
%
% See also TRITON_FLAC_PARITY, TRITON_LTSA_BASELINE, XWAV_READ.

p = inputParser;
addParameter(p,'flac','C:\Program Files\flac-1.4.3-win\Win64\flac.exe');
addParameter(p,'workdir','');
addParameter(p,'keep',false);
addParameter(p,'tave',5);
addParameter(p,'dfreq',100);
parse(p,varargin{:});
opt = p.Results;

here = fileparts(mfilename('fullpath'));
addpath(here); addpath(fileparts(here));

if ~exist(xwavDir,'dir'); error('no such directory: %s', xwavDir); end
if ~exist(opt.flac,'file')
    error(['flac tool not found at %s\n' ...
           'Pass its location with the ''flac'' option.'], opt.flac);
end

d = dir(fullfile(xwavDir,'*.x.wav'));
d = d(~[d.isdir]);
if numel(d) < 2
    error('need at least 2 .x.wav files in %s (found %d)', xwavDir, numel(d));
end

if isempty(opt.workdir)
    opt.workdir = fullfile(tempdir, ['flac_ltsa_' datestr(now,'yyyymmdd_HHMMSS')]); %#ok<TNOW1,DATST>
end

% The harness walks one root and treats each immediate subfolder as a set, so
% both containers have to sit under a common root. The x.wavs are copied rather
% than linked: a junction needs privileges this may not have, and these test
% directories are small.
root    = fullfile(opt.workdir,'parity');
wavDir  = fullfile(root,'as_xwav');
flacDir = fullfile(root,'as_xflac');
if ~exist(wavDir,'dir');  mkdir(wavDir);  end
if ~exist(flacDir,'dir'); mkdir(flacDir); end

fprintf('x.flac LTSA parity check\n  source : %s\n  %d x.wav files\n\n', ...
    xwavDir, numel(d));

report = struct('checks',{{}}, 'pass',0, 'fail',0, 'workdir',opt.workdir);

%% ---- stage both containers
totIn = 0; totOut = 0;
for k = 1:numel(d)
    src = fullfile(xwavDir, d(k).name);
    copyfile(src, fullfile(wavDir, d(k).name));
    [~, stem] = fileparts(d(k).name);          % strips .wav, leaves name.x
    dst = fullfile(flacDir, [stem '.flac']);   % -> name.x.flac
    cmd = sprintf('"%s" --channel-map=none --keep-foreign-metadata-if-present -f -s -o "%s" "%s"', ...
        opt.flac, dst, src);
    [st, out] = system(cmd);
    if st ~= 0 || ~exist(dst,'file')
        error('flac conversion failed on %s:\n%s', d(k).name, out);
    end
    a = dir(src); b = dir(dst);
    totIn = totIn + a.bytes; totOut = totOut + b.bytes;
end
fprintf('  converted %d files, %.1f MB -> %.1f MB (%.1f%% saved)\n\n', ...
    numel(d), totIn/1e6, totOut/1e6, 100*(1-totOut/totIn));

%% ---- build both LTSAs with the real generation path
jsonOut = fullfile(opt.workdir,'ltsa_parity.json');
M = triton_ltsa_baseline('data', root, 'fixtures', false, ...
        'out', jsonOut, 'workdir', fullfile(opt.workdir,'ltsa'), ...
        'keep', true, 'tave', opt.tave, 'dfreq', opt.dfreq);

W = local_pick(M,'xwav');
F = local_pick(M,'xflac');

if isempty(W)
    report = local_note(report,'x.wav LTSA built',false,'no xwav case produced');
end
if isempty(F)
    report = local_note(report,'x.flac LTSA built',false,'no xflac case produced');
end
if isempty(W) || isempty(F); local_finish(report,opt); return; end

for c = {W F}
    if ~isempty(c{1}.error)
        report = local_note(report,['LTSA built: ' c{1}.kind],false,c{1}.error);
    else
        report = local_note(report,['LTSA built: ' c{1}.kind],true, ...
            sprintf('%d files, %d bytes', c{1}.values.n_files_used, c{1}.values.file_bytes));
    end
end
if report.fail > 0; local_finish(report,opt); return; end

%% ---- the thing that must match: the spectra
report = local_note(report,'spectral data identical', ...
    strcmp(W.values.power_hash, F.values.power_hash), ...
    sprintf('%d vs %d bytes', W.values.power_bytes, F.values.power_bytes));

%% ---- and the numbers the header is built from
same = {'nave_sum','nave_hash','dnumStart_hash','write_len_hash', ...
        'nrftot','nxwav','n_files_used','nfft','cfact','nfreq','fs', ...
        'nch','nBits','blksz','tave','dfreq','dur','header_len'};
for k = 1:numel(same)
    f = same{k};
    if ~isfield(W.values,f) || ~isfield(F.values,f); continue; end
    report = local_note(report, f, isequal(W.values.(f), F.values.(f)), ...
        local_show(W.values.(f), F.values.(f)));
end

% The header bytes themselves differ, and should: they carry the input file
% names, and 'x.flac' is a byte longer than 'x.wav'. Everything the header is
% computed from is checked above, so a difference here is expected, not a
% failure -- it is reported only so it is not mistaken for one later.
if ~strcmp(W.values.header_hash, F.values.header_hash)
    fprintf('\n  (header bytes differ, as expected: they store the file names)\n');
end

local_finish(report, opt);
end


%% ================================================================== helpers
function c = local_pick(M, kind)
c = [];
for k = 1:numel(M.cases)
    if strcmp(M.cases{k}.kind, kind); c = M.cases{k}; return; end
end
end

function s = local_show(a, b)
if isequal(a,b)
    if isnumeric(a) && isscalar(a); s = num2str(a); else; s = ''; end
else
    s = [local_str(a) ' vs ' local_str(b)];
end
end

function s = local_str(v)
if ischar(v); s = v;
elseif isnumeric(v) && isscalar(v); s = num2str(v);
elseif isnumeric(v); s = mat2str(size(v));
else; s = class(v);
end
end

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
    fprintf('\n  An LTSA generated from x.flac is the same LTSA, spectrum for\n');
    fprintf('  spectrum, as one generated from the x.wav it came from.\n');
end
if ~opt.keep && exist(opt.workdir,'dir')
    rmdir(opt.workdir,'s');
elseif exist(opt.workdir,'dir')
    fprintf('  files left in %s\n', opt.workdir);
end
end
