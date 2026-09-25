function manifest = triton_harpproc_baseline(varargin)
%TRITON_HARPPROC_BASELINE  Fingerprint the HARPproc firmware table's behaviour.
%
%   triton_harpproc_baseline('harpproc','D:/Code/.../Remoras/HARPproc_260304')
%   triton_harpproc_baseline('harpproc',dirA,'out','tests/baseline/hp_A.json')
%
% The third recorder, alongside triton_baseline (reading) and
% triton_ltsa_baseline (LTSA generation). It covers the HARPproc Remora, which
% neither of the others can reach: HARPproc converts HRP to XWAV and lives
% outside the read and LTSA paths.
%
% WHAT IT COVERS, AND WHY THIS PART
%
% HARPproc decides how to interpret a disk from the recorder's firmware version,
% via ckFirmware.m reading table_ckFirmware.csv -- a 65-row table mapping
% firmware to channel count, sample rate, sector geometry, bits per sample,
% compression flag and type, and tail-block size. Everything about how an older
% or awkward dataset is handled is a row in that table.
%
% So the table *is* the behaviour, and the divergence between the HARPproc
% copies in the different Triton checkouts is largely different rows in it. This
% recorder walks every firmware version the table knows and records the
% parameters ckFirmware derives, which makes merging two tables a measurement
% rather than a judgement: if a row means the same thing in both, it produces
% the same fingerprint.
%
% It deliberately does not try to run a whole HRP-to-XWAV conversion. That needs
% real disk images and writes gigabytes; the table mapping is where the
% divergence actually is, and it is cheap and exact to check.
%
% Options
%   'harpproc' folder holding the HARPproc Remora to exercise (required)
%   'triton'   Triton tree to put on the path (default: the tree this is in)
%   'out'      manifest path (default: tests/baseline/harpproc_<timestamp>.json)
%
% See tests/README.md.

here = fileparts(mfilename('fullpath'));
tritonRoot = fileparts(here);

p = inputParser;
addParameter(p,'harpproc','');
addParameter(p,'triton','');
addParameter(p,'out','');
parse(p,varargin{:});
opt = p.Results;

if isempty(opt.harpproc)
    error('triton_harpproc_baseline: pass ''harpproc'' pointing at a HARPproc folder');
end
if ~exist(opt.harpproc,'dir')
    error('triton_harpproc_baseline: no such folder: %s', opt.harpproc);
end
if ~isempty(opt.triton); tritonRoot = opt.triton; end

if isempty(opt.out)
    opt.out = fullfile(here,'baseline', ...
        sprintf('harpproc_%s.json', datestr(now,'yyyymmdd_HHMMSS'))); %#ok<TNOW1,DATST>
end
outDir = fileparts(opt.out);
if ~isempty(outDir) && ~exist(outDir,'dir'); mkdir(outDir); end

restoredefaultpath;
addpath(tritonRoot);
addpath(fullfile(tritonRoot,'Settings'));
addpath(opt.harpproc);        % the copy under test wins on the path
addpath(here);

csvPath = fullfile(opt.harpproc,'table_ckFirmware.csv');
if ~exist(csvPath,'file')
    error('triton_harpproc_baseline: no table_ckFirmware.csv in %s', opt.harpproc);
end

fprintf('HARPproc firmware-table baseline\n');
fprintf('  harpproc : %s\n', opt.harpproc);
fprintf('  table    : %s\n', csvPath);
fprintf('  out      : %s\n\n', opt.out);

v = ver('MATLAB');
manifest = struct();
manifest.created  = datestr(now,'yyyy-mm-dd HH:MM:SS'); %#ok<TNOW1,DATST>
manifest.matlab   = v.Release;
manifest.harpproc = strrep(opt.harpproc,'\','/');
manifest.table_hash = tr_hash(local_read_text(csvPath));
manifest.cases    = {};

%% ---- every firmware version the table knows
versions = local_table_versions(csvPath);
fprintf('  %d firmware versions in the table\n\n', numel(versions));
fprintf('  %-14s %-4s %-9s %-6s %-6s %-8s %s\n', ...
    'firmware','nch','fs','cflag','ctype','compFact','result');

global PARAMS %#ok<GVMIS>
for k = 1:numel(versions)
    fw = versions{k};
    rec = struct('relpath', 'table_ckFirmware.csv', ...
                 'case',    sprintf('firmware_%s', fw), ...
                 'file',    fw, ...
                 'values',  struct(), 'error', '');
    try
        tr_headless_handles();
        PARAMS = [];
        PARAMS.head.firmwareVersion = fw;
        success = ckFirmware();
        if ~success
            rec.error = 'ckFirmware reported failure';
        else
            rec.values = struct( ...
                'nch',              local_g(PARAMS,'nch'), ...
                'fs',               local_g(PARAMS,'fs'), ...
                'nBits',            local_g(PARAMS,'nBits'), ...
                'bitsPerSamp',      local_g(PARAMS,'bitsPerSamp'), ...
                'cflag',            local_g(PARAMS,'cflag'), ...
                'ctype',            local_g(PARAMS,'ctype'), ...
                'compressionFactor',local_g(PARAMS,'compressionFactor'), ...
                'SATA_bool',        local_g(PARAMS,'SATA_bool'), ...
                'nsampPerRawFile',  local_g(PARAMS,'nsampPerRawFile'), ...
                'nsampPerSect',     local_g(PARAMS,'nsampPerSect'), ...
                'nsectPerRawFile',  local_g(PARAMS,'nsectPerRawFile'), ...
                'nBytesPerSect',    local_g(PARAMS,'nBytesPerSect'), ...
                'tailblk',          local_g(PARAMS,'tailblk'));
            fprintf('  %-14s %-4g %-9g %-6g %-6g %-8g ok\n', fw, ...
                rec.values.nch, rec.values.fs, rec.values.cflag, ...
                rec.values.ctype, rec.values.compressionFactor);
        end
    catch e
        rec.error = e.message;
        fprintf('  %-14s %-4s %-9s %-6s %-6s %-8s ERROR %s\n', fw, '-','-','-','-','-', e.message);
    end
    manifest.cases{end+1} = rec;
end

%% ---- a firmware the table does not know: the refusal must stay a refusal
rec = struct('relpath','table_ckFirmware.csv','case','firmware_unknown', ...
             'file','ZZ99999999','values',struct(),'error','');
try
    tr_headless_handles();
    PARAMS = [];
    PARAMS.head.firmwareVersion = 'ZZ99999999';
    success = ckFirmware();
    rec.values = struct('success', double(success));
    fprintf('\n  unknown firmware -> success flag %d (0 is correct: it should refuse)\n', success);
catch e
    rec.error = e.message;
    fprintf('\n  unknown firmware -> ERROR %s\n', e.message);
end
manifest.cases{end+1} = rec;

%% ---- write
txt = jsonencode(manifest);
fid = fopen(opt.out,'w');
if fid < 0; error('cannot write %s', opt.out); end
fwrite(fid, txt, 'char'); fclose(fid);

nerr = 0;
for k = 1:numel(manifest.cases)
    if ~isempty(manifest.cases{k}.error); nerr = nerr + 1; end
end
fprintf('\n%d cases recorded (%d with errors) -> %s\n', ...
    numel(manifest.cases), nerr, opt.out);

local_close_shim();
end


%% ================================================================== helpers
function vs = local_table_versions(csvPath)
%LOCAL_TABLE_VERSIONS  First column of the firmware table, skipping the header.
txt = local_read_text(csvPath);
lines = regexp(txt, '\r\n|\n|\r', 'split');
vs = {};
for k = 2:numel(lines)
    L = strtrim(lines{k});
    if isempty(L); continue; end
    parts = regexp(L, ',', 'split');
    fw = strtrim(parts{1});
    if ~isempty(fw); vs{end+1} = fw; end %#ok<AGROW>
end
end


function txt = local_read_text(p)
fid = fopen(p,'r'); txt = fread(fid,'*char')'; fclose(fid);
end


function v = local_g(s, f)
if isstruct(s) && isfield(s,f)
    v = double(s.(f));
    if isempty(v); v = NaN; end
else
    v = NaN;
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
