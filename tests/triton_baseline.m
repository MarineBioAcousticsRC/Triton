function manifest = triton_baseline(varargin)
%TRITON_BASELINE  Record what Triton currently produces, as a regression baseline.
%
%   triton_baseline
%   triton_baseline('data', 'D:\Code\Triton_remoras\ExampleData')
%   triton_baseline('out',  'tests/baseline/before.json')
%   triton_baseline('sets', {'200kHz_xwavs'})        % one folder, for a quick run
%
% Walks a folder of real recordings, drives Triton's own reading and analysis
% functions over each file, and writes a JSON manifest of fingerprints. Run it
% before a merge and again after; triton_compare tells you what moved.
%
% Nothing here reimplements Triton. It calls rdxwavhd, readseg, check_time,
% mkspecgram, read_ltsahead and read_ltsadata unmodified, with a small shim
% (tr_headless_handles) supplying the GUI handles those functions touch, so the
% numbers recorded are the ones users actually get.
%
% Large outputs -- audio segments, spectrograms, LTSA power -- are stored as MD5
% fingerprints plus a few summary statistics, not as arrays. That keeps the
% manifest small enough to commit while still detecting a single changed sample.
%
% Errors are recorded rather than thrown. A file that fails today and succeeds
% tomorrow is a change worth seeing, and one bad file should not abandon the run.
%
% Options
%   'triton' Triton tree to exercise (default: the tree this tests folder is in).
%            Use it to baseline another checkout against the same data, e.g.
%            triton_baseline('triton','D:/Code/Triton-HARPLab/triton1.95.20231113')
%   'data'   folder to walk (default: ExampleData beside this tests folder)
%   'out'    manifest path (default: tests/baseline/baseline_<timestamp>.json)
%   'sets'   cellstr of subfolder names to restrict to (default: all)
%   'tseg'   seconds of audio per read case (default: 2)
%   'nfft'   spectrogram length (default: 1000)
%   'maxfiles' cap per subfolder, for a fast smoke run (default: Inf)
%
% See tests/README.md.

%% ---------------------------------------------------------------- arguments
here = fileparts(mfilename('fullpath'));
tritonRoot = fileparts(here);

p = inputParser;
addParameter(p,'triton','');
addParameter(p,'data', fullfile(tritonRoot,'ExampleData'));
addParameter(p,'out',  '');
addParameter(p,'sets', {});
addParameter(p,'tseg', 2);
addParameter(p,'nfft', 1000);
addParameter(p,'maxfiles', Inf);
parse(p,varargin{:});
opt = p.Results;

if isempty(opt.out)
    opt.out = fullfile(here,'baseline', ...
        sprintf('baseline_%s.json', datestr(now,'yyyymmdd_HHMMSS'))); %#ok<TNOW1,DATST>
end
outDir = fileparts(opt.out);
if ~isempty(outDir) && ~exist(outDir,'dir'); mkdir(outDir); end

% Exercise the requested tree, not necessarily the one this file lives in, so
% one harness can baseline several checkouts against the same data. The path is
% reset first: leaving another Triton on it would silently mix the two, and
% which copy of a duplicated function wins would depend on path order.
if ~isempty(opt.triton)
    tritonRoot = opt.triton;
    if ~exist(fullfile(tritonRoot,'triton.m'),'file')
        error('triton_baseline: no triton.m in %s', tritonRoot);
    end
end
restoredefaultpath;
addpath(tritonRoot);
addpath(fullfile(tritonRoot,'Settings'));
addpath(fullfile(tritonRoot,'Extras'));
if exist(fullfile(tritonRoot,'Remoras'),'dir')
    addpath(genpath(fullfile(tritonRoot,'Remoras')));
end
addpath(here);

if ~exist(opt.data,'dir')
    error('triton_baseline: data folder not found: %s', opt.data);
end

fprintf('Triton regression baseline\n');
fprintf('  triton  : %s\n', tritonRoot);
fprintf('  data    : %s\n', opt.data);
fprintf('  out     : %s\n\n', opt.out);

%% ---------------------------------------------------------------- provenance
v = ver('MATLAB');
manifest = struct();
manifest.created      = datestr(now,'yyyy-mm-dd HH:MM:SS'); %#ok<TNOW1,DATST>
manifest.matlab       = v.Release;
manifest.triton_root  = strrep(tritonRoot,'\','/');
manifest.data_root    = strrep(opt.data,'\','/');
manifest.git_head     = local_git_head(tritonRoot);
manifest.settings     = struct('tseg_sec',opt.tseg,'nfft',opt.nfft);
manifest.cases        = {};

%% ---------------------------------------------------------------- walk sets
sets = dir(opt.data);
sets = sets([sets.isdir]);
sets = sets(~ismember({sets.name},{'.','..'}));
if ~isempty(opt.sets)
    sets = sets(ismember({sets.name}, opt.sets));
end
if isempty(sets)
    warning('triton_baseline: no matching subfolders under %s', opt.data);
end

for si = 1:numel(sets)
    setDir = fullfile(opt.data, sets(si).name);
    fprintf('--- %s ---\n', sets(si).name);

    files = local_cat(local_find(setDir,'*.x.wav'), local_find(setDir,'*.ltsa'));
    % plain wav/flac that are not x.wav
    for pat = {'*.wav','*.flac'}
        cand = local_find(setDir, pat{1});
        for k = 1:numel(cand)
            if isempty(files) || ~any(strcmpi({files.relpath}, cand(k).relpath))
                files = local_cat(files, cand(k));
            end
        end
    end

    if isfinite(opt.maxfiles) && numel(files) > opt.maxfiles
        files = files(1:opt.maxfiles);
    end

    for fi = 1:numel(files)
        f = files(fi);
        [~,~,ext] = fileparts(f.name);
        if strcmpi(ext,'.ltsa')
            recs = local_case_ltsa(f, opt);
        else
            recs = local_case_audio(f, opt, sets(si).name);
        end
        for r = 1:numel(recs)
            recs{r}.set = sets(si).name;
            manifest.cases{end+1} = recs{r};
        end
    end
end

%% ---------------------------------------------------------------- write
txt = jsonencode(manifest);
fid = fopen(opt.out,'w');
if fid < 0; error('triton_baseline: cannot write %s', opt.out); end
fwrite(fid, txt, 'char');
fclose(fid);

nerr = 0;
for k = 1:numel(manifest.cases)
    if ~isempty(manifest.cases{k}.error); nerr = nerr + 1; end
end
fprintf('\n%d cases recorded (%d with errors) -> %s\n', ...
    numel(manifest.cases), nerr, opt.out);

local_close_shim();
end


%% ==================================================================== audio
function recs = local_case_audio(f, opt, setName)
%LOCAL_CASE_AUDIO  Header + several reads + one spectrogram for one audio file.
global PARAMS DATA %#ok<GVMIS>

recs = {};
isXwav = ~isempty(regexpi(f.name,'\.x\.wav$'));
isFlac = ~isempty(regexpi(f.name,'\.flac$'));

% ---- header
rec = local_blank(f, 'header');
try
    tr_headless_handles();
    PARAMS = [];
    PARAMS.inpath = [f.folder filesep];
    PARAMS.infile = f.name;
    if isXwav
        PARAMS.ftype = 2; rdxwavhd;
    elseif isFlac
        % flac has no RIFF header; it is read through audioread, so take
        % the parameters from audioinfo and use ftype 3 as filepd now does.
        PARAMS.ftype = 3;
        I = audioinfo(fullfile(PARAMS.inpath,PARAMS.infile));
        rec.values = struct( ...
            'ftype',        PARAMS.ftype, ...
            'SampleRate',   I.SampleRate, ...
            'NumChannels',  I.NumChannels, ...
            'BitsPerSample',I.BitsPerSample, ...
            'duration_sec', I.Duration, ...
            'compression',  I.CompressionMethod);
        fprintf('  %-52s header ok (flac)\n', f.name);
        recs{end+1} = rec;
        recs = [recs, local_case_flac_read(f, opt, I)];
        return
    else
        PARAMS.ftype = 1; rdwavhd;
    end
    % rdwavhd fills PARAMS.xhd but leaves fs/nch/nBits/start to initdata, so
    % read the header fields directly and only use the derived ones when set.
    rec.values = struct( ...
        'ftype',        PARAMS.ftype, ...
        'SampleRate',   double(PARAMS.xhd.SampleRate), ...
        'NumChannels',  double(PARAMS.xhd.NumChannels), ...
        'BitsPerSample',double(local_get(PARAMS.xhd,'BitsPerSample',NaN)), ...
        'AudioFormat',  double(PARAMS.xhd.AudioFormat));
    if isfield(PARAMS,'fs');    rec.values.fs    = PARAMS.fs;    end
    if isfield(PARAMS,'nch');   rec.values.nch   = PARAMS.nch;   end
    if isfield(PARAMS,'nBits'); rec.values.nBits = PARAMS.nBits; end
    if isfield(PARAMS,'start') && isfield(PARAMS.start,'dnum')
        rec.values.start_dnum_hex = sprintf('%bx', PARAMS.start.dnum);
    end
    if isXwav
        rec.values.nRawFiles   = double(PARAMS.xhd.NumOfRawFiles);
        rec.values.byte_loc1   = double(PARAMS.xhd.byte_loc(1));
        rec.values.byte_len1   = double(PARAMS.xhd.byte_length(1));
        rec.values.xgain1      = PARAMS.xgain(1);
        rec.values.dnumStart_hash = tr_hash(PARAMS.raw.dnumStart);
        rec.values.dnumEnd_hash   = tr_hash(PARAMS.raw.dnumEnd);
        rec.values.nRaw_timing    = numel(PARAMS.raw.dnumStart);
    end
    fprintf('  %-52s header ok\n', f.name);
catch e
    rec.error = local_why(e);
    fprintf('  %-52s header ERROR %s\n', f.name, rec.error);
    recs{end+1} = rec;
    return                      % without a header nothing else can run
end
recs{end+1} = rec;

if ~isXwav
    return   % readseg's plain-wav path needs GUI state we deliberately do not shim
end

% ---- reads at deterministic offsets through the file
nRaw = numel(PARAMS.raw.dnumStart);
segIdx = unique([1, max(1,round(nRaw/2)), max(1,nRaw-1)]);
for si = 1:numel(segIdx)
    idx = segIdx(si);
    offsetSec = (PARAMS.raw.dnumStart(idx) - PARAMS.start.dnum) * 86400;
    label = sprintf('read_seg%d', idx);
    rec = local_blank(f, label);
    try
        local_setup_read(f, isXwav);
        PARAMS.tseg.sec  = opt.tseg;
        PARAMS.plot.dnum = PARAMS.start.dnum + offsetSec/86400;
        PARAMS.plot.dvec = datevec(PARAMS.plot.dnum);
        readseg;
        rec.values = struct( ...
            'offset_sec',   offsetSec, ...
            'tseg_sec',     opt.tseg, ...
            'rows',         size(DATA,1), ...
            'cols',         size(DATA,2), ...
            'data_hash',    tr_hash(DATA), ...
            'data_min',     min(DATA(:)), ...
            'data_max',     max(DATA(:)), ...
            'data_sum',     sum(DATA(:)), ...
            'currentIndex', PARAMS.raw.currentIndex, ...
            'delimit_hash', tr_hash(local_get(PARAMS.raw,'delimit_time',[])), ...
            'n_delimit',    numel(local_get(PARAMS.raw,'delimit_time',[])));
        fprintf('  %-52s %-12s %dx%d %s\n', f.name, label, ...
            size(DATA,1), size(DATA,2), rec.values.data_hash(1:8));
    catch e
        rec.error = e.message;
        fprintf('  %-52s %-12s ERROR %s\n', f.name, label, e.message);
    end
    recs{end+1} = rec; %#ok<AGROW>
end

% ---- one spectrogram, from the start of the file
rec = local_blank(f, 'specgram');
try
    local_setup_read(f, isXwav);
    PARAMS.tseg.sec  = opt.tseg;
    PARAMS.plot.dnum = PARAMS.start.dnum;
    PARAMS.plot.dvec = datevec(PARAMS.plot.dnum);
    readseg;
    PARAMS.nfft    = opt.nfft;
    PARAMS.overlap = 0;
    PARAMS.freq0   = 0;
    PARAMS.freq1   = PARAMS.fs/2;
    PARAMS.ch      = 1;
    mkspecgram;
    rec.values = struct( ...
        'nfft',      opt.nfft, ...
        'pwr_hash',  tr_hash(PARAMS.pwr), ...
        'pwr_rows',  size(PARAMS.pwr,1), ...
        'pwr_cols',  size(PARAMS.pwr,2), ...
        'f_hash',    tr_hash(PARAMS.f(:)), ...
        't_hash',    tr_hash(PARAMS.t(:)), ...
        'fimin',     local_get(PARAMS,'fimin',NaN), ...
        'fimax',     local_get(PARAMS,'fimax',NaN));
    fprintf('  %-52s specgram     %dx%d %s\n', f.name, ...
        size(PARAMS.pwr,1), size(PARAMS.pwr,2), rec.values.pwr_hash(1:8));
catch e
    rec.error = e.message;
    fprintf('  %-52s specgram     ERROR %s\n', f.name, e.message);
end
recs{end+1} = rec;
end


%% ===================================================================== ltsa
function recs = local_case_flac_read(f, opt, I)
%LOCAL_CASE_FLAC_READ  Drive readseg's ftype==3 path over a flac file.
%
% flac carries no harp header, so there is no per-raw-file timing to walk;
% reads are taken at fixed offsets into the file instead.
global PARAMS DATA %#ok<GVMIS>

recs = {};
offsets = unique([0, floor(I.Duration/2), max(0, floor(I.Duration) - opt.tseg - 1)]);

for si = 1:numel(offsets)
    label = sprintf('flac_read_%ds', offsets(si));
    rec = local_blank(f, label);
    try
        % Faithful startup order: initparams then initdata, exactly as the
        % application does, rather than a hand-picked field list. initdata
        % reads the flac through audioinfo and readseg through audioread.
        tr_headless_handles();
        PARAMS = [];
        initparams;
        PARAMS.inpath = [f.folder filesep];
        PARAMS.infile = f.name;
        PARAMS.ftype  = 3;
        PARAMS.start.dnum = datenum([0 1 1 0 0 0]);
        PARAMS.start.dvec = datevec(PARAMS.start.dnum);
        PARAMS.tseg.sec   = opt.tseg;
        initdata;
        PARAMS.plot.dnum  = PARAMS.start.dnum + offsets(si)/86400;
        PARAMS.plot.dvec  = datevec(PARAMS.plot.dnum);
        readseg;
        rec.values = struct( ...
            'offset_sec', offsets(si), ...
            'tseg_sec',   opt.tseg, ...
            'rows',       size(DATA,1), ...
            'cols',       size(DATA,2), ...
            'data_hash',  tr_hash(DATA), ...
            'data_min',   min(DATA(:)), ...
            'data_max',   max(DATA(:)), ...
            'data_sum',   sum(DATA(:)));
        fprintf('  %-52s %-16s %dx%d %s\n', f.name, label, ...
            size(DATA,1), size(DATA,2), rec.values.data_hash(1:8));
    catch e
        rec.error = local_why(e);
        fprintf('  %-52s %-16s ERROR %s\n', f.name, label, rec.error);
    end
    recs{end+1} = rec; %#ok<AGROW>
end
end


function recs = local_case_ltsa(f, opt) %#ok<INUSD>
%LOCAL_CASE_LTSA  Header fields and one block of power for one .ltsa file.
global PARAMS %#ok<GVMIS>

recs = {};
rec = local_blank(f, 'ltsa_header');
try
    tr_headless_handles();
    PARAMS = [];
    initparams;   % faithful startup order; supplies ltsa.tseg.step and friends
    PARAMS.ltsa.inpath = [f.folder filesep];
    PARAMS.ltsa.infile = f.name;
    read_ltsahead;
    rec.values = struct( ...
        'ver',          PARAMS.ltsa.ver, ...
        'dirStartLoc',  PARAMS.ltsa.dirStartLoc, ...
        'dataStartLoc', PARAMS.ltsa.dataStartLoc, ...
        'tave',         PARAMS.ltsa.tave, ...
        'dfreq',        PARAMS.ltsa.dfreq, ...
        'fs',           PARAMS.ltsa.fs, ...
        'nfft',         PARAMS.ltsa.nfft, ...
        'nf',           PARAMS.ltsa.nf, ...
        'nrftot',       PARAMS.ltsa.nrftot, ...
        'nxwav',        PARAMS.ltsa.nxwav, ...
        'ch',           PARAMS.ltsa.ch, ...
        'byteloc_hash', tr_hash(PARAMS.ltsa.byteloc), ...
        'nave_hash',    tr_hash(PARAMS.ltsa.nave), ...
        'nave_sum',     sum(double(PARAMS.ltsa.nave)));
    fprintf('  %-52s ltsa header  v%d nf=%d nrftot=%d\n', f.name, ...
        PARAMS.ltsa.ver, PARAMS.ltsa.nf, PARAMS.ltsa.nrftot);
catch e
    rec.error = e.message;
    fprintf('  %-52s ltsa header  ERROR %s\n', f.name, e.message);
    recs{end+1} = rec;
    return
end
recs{end+1} = rec;

% ---- read a bounded block of power from the start
rec = local_blank(f, 'ltsa_data');
try
    % read_ltsadata works out plotStartRawIndex/Bin itself from plot.dnum,
    % the way init_ltsadata leaves things (init_ltsadata.m:33-34).
    % Real sequence is read_ltsahead -> init_ltsadata -> read_ltsadata
    % (filepd.m, 'openltsa'). init_ltsadata sets plotStartRawIndex and the
    % plot times that read_ltsadata and check_ltsa_time then rely on.
    PARAMS.ltsa.tseg.hr   = 1;
    PARAMS.ltsa.tseg.sec  = 3600;
    init_ltsadata;
    read_ltsadata;
    rec.values = struct( ...
        'pwr_hash', tr_hash(PARAMS.ltsa.pwr), ...
        'pwr_rows', size(PARAMS.ltsa.pwr,1), ...
        'pwr_cols', size(PARAMS.ltsa.pwr,2), ...
        'pwr_min',  min(PARAMS.ltsa.pwr(:)), ...
        'pwr_max',  max(PARAMS.ltsa.pwr(:)), ...
        'finite_fraction', sum(isfinite(PARAMS.ltsa.pwr(:))) / numel(PARAMS.ltsa.pwr));
    fprintf('  %-52s ltsa data    %dx%d %s\n', f.name, ...
        size(PARAMS.ltsa.pwr,1), size(PARAMS.ltsa.pwr,2), rec.values.pwr_hash(1:8));
catch e
    rec.error = e.message;
    fprintf('  %-52s ltsa data    ERROR %s\n', f.name, e.message);
end
recs{end+1} = rec;
end


%% ================================================================== helpers
function local_setup_read(f, isXwav)
%LOCAL_SETUP_READ  PARAMS as initdata would leave it, minus the GUI fields.
%
% initdata.m also touches ~15 GUI handles irrelevant to reading, so only the
% PARAMS fields that affect the read are set here. Everything that decides
% which bytes are read comes from rdxwavhd and readseg themselves.
global PARAMS %#ok<GVMIS>

tr_headless_handles();
PARAMS = [];
PARAMS.inpath = [f.folder filesep];
PARAMS.infile = f.name;
if isXwav
    PARAMS.ftype = 2; rdxwavhd;
else
    PARAMS.ftype = 1; rdwavhd;
end
PARAMS.ch          = 1;
PARAMS.samp.head   = 0;
PARAMS.samp.null   = 0;
PARAMS.fmax        = PARAMS.fs/2;
PARAMS.freq0       = 0;
PARAMS.freq1       = PARAMS.fs/2;
PARAMS.start.dvec  = datevec(PARAMS.start.dnum);
PARAMS.plot.dvec   = PARAMS.start.dvec;
PARAMS.plot.dnum   = PARAMS.start.dnum;
PARAMS.save.dnum   = PARAMS.start.dnum;
PARAMS.plot.initbytel  = PARAMS.xhd.byte_loc(1);
PARAMS.plot.bytelength = PARAMS.plot.initbytel;
PARAMS.tseg.step   = -1;
PARAMS.filter      = 0;
PARAMS.tf.flag     = 0;
end


function msg = local_why(e)
%LOCAL_WHY  Prefer Triton's own explanation over the downstream MATLAB error.
%
% When a core function declines to read a file it usually says so through
% disp_msg and returns, leaving PARAMS incomplete. The MATLAB error that
% follows ("Unrecognized field name fs") describes our access, not the cause.
% If the shim's message window captured anything, report that instead.
global HANDLES %#ok<GVMIS>
msg = e.message;
try
    if isstruct(HANDLES) && isfield(HANDLES,'msg') && ishandle(HANDLES.msg)
        captured = get(HANDLES.msg,'String');
        if ~isempty(captured)
            if ~iscell(captured); captured = cellstr(captured); end
            msg = strtrim(strjoin(captured(:)', ' | '));
        end
    end
catch
end
end


function rec = local_blank(f, label)
rec = struct('relpath', strrep(f.relpath,'\','/'), ...
             'file',    f.name, ...
             'case',    label, ...
             'values',  struct(), ...
             'error',   '');
end


function out = local_cat(varargin)
%LOCAL_CAT  Concatenate file-listing structs, tolerating empty results.
out = struct('name',{},'folder',{},'relpath',{});
for k = 1:numel(varargin)
    v = varargin{k};
    if isempty(v); continue; end
    for j = 1:numel(v)
        out(end+1) = struct('name',v(j).name,'folder',v(j).folder, ...
                            'relpath',v(j).relpath); %#ok<AGROW>
    end
end
end


function out = local_find(root, pat)
%LOCAL_FIND  Recursive file search returning name/folder/relpath, sorted.
out = struct('name',{},'folder',{},'relpath',{});
stack = {root};
while ~isempty(stack)
    d = stack{end}; stack(end) = [];
    listing = dir(d);
    for k = 1:numel(listing)
        if any(strcmp(listing(k).name,{'.','..'})); continue; end
        full = fullfile(d, listing(k).name);
        if listing(k).isdir
            stack{end+1} = full; %#ok<AGROW>
        elseif ~isempty(regexpi(listing(k).name, ...
                ['^' regexptranslate('wildcard',pat) '$']))
            rel = strrep(full, [root filesep], '');
            out(end+1) = struct('name',listing(k).name,'folder',d,'relpath',rel); %#ok<AGROW>
        end
    end
end
if ~isempty(out)
    [~,ord] = sort({out.relpath});
    out = out(ord);
end
end


function v = local_get(s, f, d)
if isstruct(s) && isfield(s,f); v = s.(f); else; v = d; end
end


function h = local_git_head(root)
h = '';
try
    [st, out] = system(sprintf('git -C "%s" rev-parse --short HEAD', root));
    if st == 0; h = strtrim(out); end
catch
end
end


function local_close_shim()
global HANDLES %#ok<GVMIS>
try
    if isstruct(HANDLES) && isfield(HANDLES,'fig') && isfield(HANDLES.fig,'headless') ...
            && ishandle(HANDLES.fig.headless)
        close(HANDLES.fig.headless);
    end
catch
end
HANDLES = [];
end
