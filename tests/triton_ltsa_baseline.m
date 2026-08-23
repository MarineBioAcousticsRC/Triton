function manifest = triton_ltsa_baseline(varargin)
%TRITON_LTSA_BASELINE  Generate LTSAs and fingerprint them, as a regression baseline.
%
%   triton_ltsa_baseline
%   triton_ltsa_baseline('triton','D:/Code/Triton-HARPLab/triton1.95.20231113')
%   triton_ltsa_baseline('sets',{'Duty_cycled_df20_xwavs_and_LTSA'})
%
% The companion to triton_baseline. That one covers *reading* -- headers, audio,
% spectrograms, and LTSAs that already exist. This one covers *making* an LTSA,
% which is the other half of Triton's core and the half where the four checkouts
% are known to disagree: calc_ltsa, write_ltsahead, get_headers and
% ck_ltsaparams are only reachable this way.
%
% For each directory of recordings it builds an LTSA into a temporary folder and
% records a fingerprint of the resulting file -- the header block and the power
% block separately, so a change in one is distinguishable from a change in the
% other -- plus the derived parameters the pipeline computed along the way.
%
% mk_ltsa cannot be used directly: it asks for the directory and the averaging
% parameters through dialogs. Those two steps are replaced here by setting the
% same PARAMS fields the dialogs set, listed under 'what the dialogs would do'
% below. Every step that computes anything -- get_headers, ck_ltsaparams,
% write_ltsahead, calc_ltsa -- is the real function, unmodified.
%
% Options
%   'triton'  tree to exercise (default: the tree this tests folder is in)
%   'data'    folder to walk (default: ExampleData beside this tests folder)
%   'out'     manifest path (default: tests/baseline/ltsa_<timestamp>.json)
%   'sets'    cellstr of subfolder names to restrict to (default: all)
%   'tave'    seconds per time average (default: 5)
%   'dfreq'   frequency bin size in Hz (default: 100)
%   'workdir' where LTSAs are built (default: a temp folder, removed afterwards)
%   'keep'    true to leave the generated LTSAs in place for inspection
%   'fixtures' include tests/fixtures in the walk (default true). Those are
%            committed and tiny, so the padding case runs without the example
%            data being present at all.
%
% See tests/README.md.

%% ---------------------------------------------------------------- arguments
here = fileparts(mfilename('fullpath'));
tritonRoot = fileparts(here);

p = inputParser;
addParameter(p,'triton','');
addParameter(p,'data', fullfile(tritonRoot,'ExampleData'));
addParameter(p,'out','');
addParameter(p,'sets',{});
addParameter(p,'tave',5);
addParameter(p,'dfreq',100);
addParameter(p,'workdir','');
addParameter(p,'keep',false);
addParameter(p,'fixtures',true);
parse(p,varargin{:});
opt = p.Results;

if ~isempty(opt.triton)
    tritonRoot = opt.triton;
    if ~exist(fullfile(tritonRoot,'triton.m'),'file')
        error('triton_ltsa_baseline: no triton.m in %s', tritonRoot);
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

if isempty(opt.out)
    opt.out = fullfile(here,'baseline', ...
        sprintf('ltsa_%s.json', datestr(now,'yyyymmdd_HHMMSS'))); %#ok<TNOW1,DATST>
end
outDir = fileparts(opt.out);
if ~isempty(outDir) && ~exist(outDir,'dir'); mkdir(outDir); end

cleanupWork = false;
if isempty(opt.workdir)
    opt.workdir = fullfile(tempdir, sprintf('triton_ltsa_%s', ...
        datestr(now,'yyyymmdd_HHMMSS'))); %#ok<TNOW1,DATST>
    cleanupWork = ~opt.keep;
end
if ~exist(opt.workdir,'dir'); mkdir(opt.workdir); end

fprintf('Triton LTSA generation baseline\n');
fprintf('  triton  : %s\n', tritonRoot);
fprintf('  data    : %s\n', opt.data);
fprintf('  workdir : %s\n', opt.workdir);
fprintf('  out     : %s\n\n', opt.out);

v = ver('MATLAB');
manifest = struct();
manifest.created     = datestr(now,'yyyy-mm-dd HH:MM:SS'); %#ok<TNOW1,DATST>
manifest.matlab      = v.Release;
manifest.triton_root = strrep(tritonRoot,'\','/');
manifest.data_root   = strrep(opt.data,'\','/');
manifest.git_head    = local_git_head(tritonRoot);
manifest.settings    = struct('tave',opt.tave,'dfreq',opt.dfreq);
manifest.cases       = {};

%% ---------------------------------------------------------------- walk sets
% Roots to walk: the example data, plus the committed fixtures. The fixtures
% carry cases the real recordings do not reach -- see tests/README.md.
roots = {};
if exist(opt.data,'dir'); roots{end+1} = opt.data; end
fixRoot = fullfile(here,'fixtures');
if opt.fixtures && exist(fixRoot,'dir'); roots{end+1} = fixRoot; end
if isempty(roots)
    error('triton_ltsa_baseline: nothing to walk (data folder missing, fixtures off)');
end

sets = struct('name',{},'root',{});
for ri = 1:numel(roots)
    listing = dir(roots{ri});
    listing = listing([listing.isdir]);
    listing = listing(~ismember({listing.name},{'.','..'}));
    for li = 1:numel(listing)
        sets(end+1) = struct('name',listing(li).name,'root',roots{ri}); %#ok<AGROW>
    end
end
if ~isempty(opt.sets)
    sets = sets(ismember({sets.name}, opt.sets));
end

for si = 1:numel(sets)
    setDir = fullfile(sets(si).root, sets(si).name);

    % One case per directory that holds recordings of a single type, since an
    % LTSA is built from a whole directory rather than one file.
    for spec = { {'xwav','*.x.wav',2}, {'wav','*.wav',1}, {'flac','*.flac',3} }
        kind = spec{1}{1}; pat = spec{1}{2}; ftype = spec{1}{3};
        dirs = local_dirs_with(setDir, pat, kind);
        for di = 1:numel(dirs)
            rec = local_build_one(dirs{di}, kind, ftype, opt);
            if isempty(rec); continue; end
            rec.set = sets(si).name;
            manifest.cases{end+1} = rec;
        end
    end
end

%% ---------------------------------------------------------------- write
txt = jsonencode(manifest);
fid = fopen(opt.out,'w');
if fid < 0; error('triton_ltsa_baseline: cannot write %s', opt.out); end
fwrite(fid, txt, 'char'); fclose(fid);

nerr = 0;
for k = 1:numel(manifest.cases)
    if ~isempty(manifest.cases{k}.error); nerr = nerr + 1; end
end
fprintf('\n%d LTSAs attempted (%d with errors) -> %s\n', ...
    numel(manifest.cases), nerr, opt.out);

if cleanupWork && exist(opt.workdir,'dir')
    rmdir(opt.workdir,'s');
    fprintf('removed %s\n', opt.workdir);
elseif opt.keep
    fprintf('generated LTSAs left in %s\n', opt.workdir);
end

local_close_shim();
end


%% ============================================================ build one LTSA
function rec = local_build_one(indir, kind, ftype, opt)
%LOCAL_BUILD_ONE  Drive the real LTSA pipeline over one directory.
global PARAMS HANDLES %#ok<GVMIS>

rel = strrep(indir, '\', '/');
% Same identity fields as triton_baseline (relpath + case) so one
% comparison tool serves both recorders.
rec = struct('relpath', rel, ...
             'case',    sprintf('ltsa_gen_%s', kind), ...
             'file',    local_tail(indir), ...
             'kind',    kind, 'ftype', ftype, ...
             'values',  struct(), 'error', '');

outfile = sprintf('regress_%s_%s.ltsa', kind, local_safe(indir));
outpath = fullfile(opt.workdir, outfile);
if exist(outpath,'file'); delete(outpath); end

try
    tr_headless_handles();
    PARAMS = [];
    initparams;

    init_ltsaparams;

    % ---- what the dialogs would do: get_ltsadir sets indir/ftype/fname/gen
    PARAMS.ltsa.indir = indir;
    PARAMS.ltsa.ftype = ftype;
    d = dir(fullfile(indir, local_pat(kind)));
    d = d(~[d.isdir]);
    if isempty(d); rec = []; return; end
    names = sort({d.name});
    PARAMS.ltsa.fname = char(names{:});
    PARAMS.ltsa.nxwav = numel(names);
    PARAMS.ltsa.gen   = 1;

    % ---- the real header pass
    get_headers;
    if PARAMS.ltsa.gen == 0
        rec.error = local_why_msg('get_headers declined the directory');
        return
    end

    % ---- what the dialogs would do: get_ltsaparams sets tave/dfreq/dtype/ch
    PARAMS.ltsa.tave  = opt.tave;
    PARAMS.ltsa.dfreq = opt.dfreq;
    if ftype == 2
        PARAMS.ltsa.dtype = 1;      % harp data, 12 byte raw-file header
    else
        PARAMS.ltsa.dtype = 4;      % wav or flac, no raw-file header
    end
    PARAMS.ltsa.ch = 1;

    % ---- the real parameter check and the real writers
    ck_ltsaparams;

    PARAMS.ltsa.outdir  = opt.workdir;
    PARAMS.ltsa.outfile = outfile;   % set so write_ltsahead skips its dialog
    write_ltsahead;
    headerBytes = local_read_bytes(outpath);

    calc_ltsa;

    rec.values = local_describe(outpath, numel(headerBytes));
    % Field names differ between the generation and reading paths (nfreq here,
    % nf when reading back), and not every field exists for every file type,
    % so read them defensively rather than assuming a fixed set.
    L  = PARAMS.ltsa;
    LH = local_getf(PARAMS,'ltsahd',struct());
    rec.values.tave          = local_getf(L,'tave',NaN);
    rec.values.dfreq         = local_getf(L,'dfreq',NaN);
    rec.values.nfft          = local_getf(L,'nfft',NaN);
    rec.values.cfact         = local_getf(L,'cfact',NaN);
    rec.values.nfreq         = local_getf(L,'nfreq',local_getf(L,'nf',NaN));
    rec.values.fs            = local_getf(L,'fs',NaN);
    rec.values.nch           = local_getf(L,'nch',NaN);
    rec.values.nBits         = local_getf(L,'nBits',NaN);
    rec.values.blksz         = local_getf(L,'blksz',NaN);
    rec.values.dtype         = local_getf(L,'dtype',NaN);
    rec.values.dur           = local_getf(L,'dur',NaN);
    rec.values.ver           = local_getf(L,'ver',NaN);
    rec.values.nrftot        = local_getf(L,'nrftot',NaN);
    rec.values.nxwav         = local_getf(L,'nxwav',NaN);
    rec.values.n_files_used  = size(local_getf(L,'fname',''),1);
    nave = local_getf(LH,'nave',[]);
    rec.values.nave_sum      = sum(double(nave));
    rec.values.nave_hash     = tr_hash(double(nave));
    rec.values.dnumStart_hash= tr_hash(local_getf(LH,'dnumStart',[]));
    rec.values.write_len_hash= tr_hash(double(local_getf(LH,'write_length',[])));

    fprintf('  %-58s %-5s hdr %s  pwr %s  %d files\n', ...
        local_tail(indir), kind, rec.values.header_hash(1:8), ...
        rec.values.power_hash(1:8), rec.values.n_files_used);
catch e
    rec.error = local_why(e);
    fprintf('  %-58s %-5s ERROR %s\n', local_tail(indir), kind, rec.error);
end
end


%% ================================================================== helpers
function v = local_describe(f, headerLen)
%LOCAL_DESCRIBE  Fingerprint the header block and the power block separately.
%
% Splitting them means a change in the computed spectra is distinguishable from
% a change in the metadata written around it, which matters when the two are
% maintained by different code.
d = dir(f);
raw = local_read_bytes(f);
v = struct();
v.file_bytes  = d.bytes;
v.header_len  = headerLen;
v.header_hash = tr_hash(double(raw(1:min(headerLen,numel(raw)))));
if numel(raw) > headerLen
    pwr = raw(headerLen+1:end);
    v.power_hash  = tr_hash(double(pwr));
    v.power_bytes = numel(pwr);
    % int8 dB values; summarise so a diff shows the direction of a change
    pv = double(typecast(uint8(pwr),'int8'));
    v.power_min  = min(pv);
    v.power_max  = max(pv);
    v.power_mean = mean(pv);
else
    v.power_hash  = 'empty';
    v.power_bytes = 0;
    v.power_min = NaN; v.power_max = NaN; v.power_mean = NaN;
end
end


function b = local_read_bytes(f)
fid = fopen(f,'r');
if fid < 0; b = uint8([]); return; end
b = fread(fid,Inf,'*uint8');
fclose(fid);
b = b(:)';
end


function out = local_dirs_with(root, pat, kind)
%LOCAL_DIRS_WITH  Directories under root holding at least two matching files.
%
% Two, not one: an LTSA over a single file exercises far less of the pipeline
% (no raw-file boundaries between files) and the duty-cycled sets are where the
% interesting behaviour lives.
out = {};
stack = {root};
while ~isempty(stack)
    d = stack{end}; stack(end) = [];
    listing = dir(d);
    for k = 1:numel(listing)
        if any(strcmp(listing(k).name,{'.','..'})); continue; end
        if listing(k).isdir
            stack{end+1} = fullfile(d, listing(k).name); %#ok<AGROW>
        end
    end
    hits = dir(fullfile(d, pat));
    hits = hits(~[hits.isdir]);
    if strcmp(kind,'wav')
        % *.wav also matches *.x.wav; keep only the plain ones
        hits = hits(cellfun(@(n) isempty(regexpi(n,'\.x\.wav$')), {hits.name}));
    end
    if numel(hits) >= 2
        out{end+1} = d; %#ok<AGROW>
    end
end
out = sort(out);
end


function pat = local_pat(kind)
switch kind
    case 'xwav'; pat = '*.x.wav';
    case 'flac'; pat = '*.flac';
    otherwise;   pat = '*.wav';
end
end


function s = local_safe(p)
s = regexprep(p, '[^A-Za-z0-9]+', '_');
if numel(s) > 60; s = s(end-59:end); end
end


function s = local_tail(p)
parts = regexp(strrep(p,'\','/'), '/', 'split');
parts = parts(~cellfun(@isempty,parts));
n = min(2, numel(parts));
s = strjoin(parts(end-n+1:end), '/');
end


function v = local_getf(s,f,d)
if isstruct(s) && isfield(s,f); v = s.(f); else; v = d; end
end


function msg = local_why(e)
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


function msg = local_why_msg(fallback)
global HANDLES %#ok<GVMIS>
msg = fallback;
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
