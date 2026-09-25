function plan = xwav_convert_plan(indir, outdir, varargin)
%XWAV_CONVERT_PLAN  Work out the whole job before any of it is done.
%
%   plan = xwav_convert_plan(srcdir, destdir, 'direction', 'compress')
%
% Walks the tree once, decides what every file is, works out where it would go
% and how big it would be, and collects everything that would go wrong. Nothing
% is written.
%
% The result is a snapshot. The confirmation a user sees and the run that
% follows both come from this same object, so the numbers on screen are the
% numbers used -- rather than two separate walks of a tree that may be on a
% network share and may not agree.
%
% Options
%   'direction'   'compress' or 'expand' (required)
%   'recursive'   walk subfolders (default true)
%   'flac'        path to the flac tool
%
% Returns
%   plan.files      struct array: src, dst, kind, bytesIn, predictedOut,
%                   status ('ready'|'problem'), why
%   plan.stoppers   cell array of reasons the whole run must not start
%   plan.warnings   cell array of things worth saying but not fatal
%   plan.totals     nReady, nProblem, nOther, bytesIn, predictedOut, exact
%   plan.dest       usable, total, fsType, maxFileBytes
%
% See also XWAV_CONVERT_DIR, XWAV_CONVERT, AUDIO_FILE_KIND.

p = inputParser;
addParameter(p,'direction','');
addParameter(p,'recursive',true);
addParameter(p,'minFree',2*2^30);
addParameter(p,'flac','');
parse(p,varargin{:});
opt = p.Results;

if ~any(strcmpi(opt.direction,{'compress','expand'}))
    error('xwav_convert_plan:direction', ...
        'direction must be ''compress'' or ''expand''');
end
direction = lower(opt.direction);

plan = struct('files',struct('src',{},'dst',{},'kind',{},'bytesIn',{}, ...
                             'predictedOut',{},'status',{},'why',{}), ...
              'stoppers',{{}}, 'warnings',{{}}, 'direction',direction, ...
              'indir',indir, 'outdir',outdir, ...
              'totals',struct('nReady',0,'nProblem',0,'nOther',0, ...
                              'bytesIn',0,'predictedOut',0,'exact',true), ...
              'dest',struct('usable',NaN,'total',NaN,'fsType','','maxFileBytes',Inf));

%% ---- things that stop the whole run
if ~exist(indir,'dir')
    plan.stoppers{end+1} = sprintf('no such folder: %s', indir); return
end
if isempty(outdir)
    plan.stoppers{end+1} = 'no destination folder given'; return
end

overlapWhy = local_overlap(indir, outdir);
if ~isempty(overlapWhy)
    plan.warnings{end+1} = overlapWhy;
end

[exe, whyNot] = flac_exe(opt.flac);
if isempty(exe)
    plan.stoppers{end+1} = whyNot; return
end

[plan.dest.usable, plan.dest.total, plan.dest.fsType, plan.dest.maxFileBytes] = ...
    disk_free(outdir);
if isnan(plan.dest.usable)
    plan.warnings{end+1} = ['Cannot read free space on the destination. ' ...
        'The space check will be skipped -- watch the drive yourself.'];
end

%% ---- walk
if opt.recursive
    listing = dir(fullfile(indir,'**','*'));
else
    listing = dir(fullfile(indir,'*'));
end
listing = listing(~[listing.isdir]);

% Mac-written drives leave AppleDouble stubs beside every real file; they are
% not audio and flac would only report a confusing parse error.
listing = listing(cellfun(@(n) ~strncmp(n,'._',2), {listing.name}));
% Leftovers from a killed run. Reported, not converted.
isTmp = cellfun(@(n) strncmp(n,'__triton_tmp__',14), {listing.name});
if any(isTmp)
    plan.warnings{end+1} = sprintf(['%d leftover __triton_tmp__ file(s) from ' ...
        'an interrupted run are in the source tree and will be ignored.'], sum(isTmp));
    listing = listing(~isTmp);
end

nOther = 0;
dsts = {};
for k = 1:numel(listing)
    src = fullfile(listing(k).folder, listing(k).name);

    [kind, info] = audio_file_kind(src);
    if strcmp(kind,'notaudio')
        nOther = nOther + 1; continue
    end
    wantCompressed = any(strcmp(kind,{'flac','xflac'}));
    if strcmp(direction,'compress') && wantCompressed
        nOther = nOther + 1; continue     % already compressed; not this job
    end
    if strcmp(direction,'expand') && ~wantCompressed
        nOther = nOther + 1; continue
    end

    rec = struct('src',src,'dst','','kind',kind,'bytesIn',info.bytes, ...
                 'predictedOut',NaN,'status','ready','why','');

    % Where it goes: the same place below the destination root that it sits
    % below the source root.
    try
        rel = rel_subpath(indir, listing(k).folder);
    catch e
        rec.status = 'problem'; rec.why = e.message;
        plan.files(end+1) = rec; continue %#ok<AGROW>
    end
    thisOut = fullfile(outdir, rel);
    rec.dst = fullfile(thisOut, xwav_outname(src, kind, direction));

    if strcmp(direction,'compress')
        rec.predictedOut = info.bytes;          % upper bound
        plan.totals.exact = false;
    else
        rec.predictedOut = info.decodedBytes;   % exact, from the header
        if isnan(rec.predictedOut); plan.totals.exact = false; end
    end

    % --- per-file problems
    if strcmp(direction,'compress') && ~info.encodable
        rec.status = 'problem'; rec.why = info.why;
    elseif numel(rec.dst) > 259 && ispc
        % The destination path is almost always longer than the source: same
        % relative part, a different and often deeper root. flac's Windows
        % build is not long-path aware, so this fails late and confusingly.
        rec.status = 'problem';
        rec.why = sprintf('destination path is %d characters, over the 259 Windows limit', ...
            numel(rec.dst));
    elseif any(double(rec.dst) > 127) || any(double(src) > 127)
        % MATLAB's system() hands the command to cmd.exe in the ANSI code page,
        % so a non-ASCII name arrives at flac mangled and unfindable.
        rec.status = 'problem';
        rec.why = 'name contains non-ASCII characters, which the flac command line cannot carry';
    elseif any(strcmp(rec.dst, dsts))
        rec.status = 'problem';
        rec.why = 'two source files would produce this same output name';
    end

    if strcmp(rec.status,'ready')
        dsts{end+1} = rec.dst; %#ok<AGROW>
        if ~isnan(rec.predictedOut) && rec.predictedOut > plan.dest.maxFileBytes
            plan.warnings{end+1} = sprintf(['%s would be %.2f GB, which may ' ...
                'exceed what %s allows in one file'], listing(k).name, ...
                rec.predictedOut/2^30, plan.dest.fsType);
        end
    end
    plan.files(end+1) = rec; %#ok<AGROW>
end

%% ---- totals
ready = strcmp({plan.files.status},'ready');
plan.totals.nReady   = sum(ready);
plan.totals.nProblem = sum(~ready);
plan.totals.nOther   = nOther;
plan.totals.bytesIn  = sum([plan.files(ready).bytesIn]);
pr = [plan.files(ready).predictedOut];
plan.totals.predictedOut = sum(pr(~isnan(pr)));

if plan.totals.nReady == 0
    plan.stoppers{end+1} = 'nothing to convert in this folder';
end

% The whole-tree budget, so the user is told before anything starts rather
% than finding out at the first file. The per-file guard in xwav_convert still
% runs on every file -- this is the warning, that is the enforcement.
if ~isnan(plan.dest.usable)
    if plan.totals.predictedOut >= plan.dest.usable
        plan.stoppers{end+1} = sprintf(['not enough room: needs about %.1f GB, ' ...
            '%.1f GB free on the destination'], ...
            plan.totals.predictedOut/2^30, plan.dest.usable/2^30);
    elseif plan.dest.usable - plan.totals.predictedOut < opt.minFree
        plan.stoppers{end+1} = sprintf(['would leave less than the %.1f GB ' ...
            'reserve: needs about %.1f GB, %.1f GB free on the destination'], ...
            opt.minFree/2^30, plan.totals.predictedOut/2^30, plan.dest.usable/2^30);
    end
end
end


%% ================================================================== helpers
function why = local_overlap(indir, outdir)
%LOCAL_OVERLAP  Do the source and destination sit on top of one another?
%
% Reported, not refused. Converting a folder in place is legitimate and
% long-standing -- it is what xwavdir2flac has always done -- and it is safe,
% because a run only considers files going the direction it is going: a
% compress run classifies the flac files it produces as already compressed and
% steps over them. The plan is also a single snapshot taken before anything is
% written, so a run cannot discover its own output part way through.
%
% Still worth saying out loud, because a destination nested inside the source
% is rarely what someone meant.
%
% Canonical paths, because Z:\data, \\server\share\data and a subst'ed D:\data
% can all be the same folder, and a junction can make a tree appear to contain
% itself.
why = '';
a = local_canon(indir); b = local_canon(outdir);
if isempty(a) || isempty(b); return; end
if local_eq(a,b)
    why = 'Source and destination are the same folder: converting in place.';
elseif local_under(b,a)
    why = ['The destination is inside the source folder. That works, but the ' ...
           'converted files will sit inside the tree they came from.'];
elseif local_under(a,b)
    why = 'The source folder is inside the destination folder.';
end
end


function c = local_canon(p)
c = '';
if isempty(p); return; end
try
    c = char(java.io.File(p).getCanonicalPath());
catch
    try
        c = rel_subpath(p, p); %#ok<NASGU>  % only to normalise
        c = p;
    catch
        c = p;
    end
end
while numel(c) > 1 && (c(end) == '\' || c(end) == '/')
    c(end) = [];
end
end


function tf = local_eq(a,b)
if ispc; tf = strcmpi(a,b); else; tf = strcmp(a,b); end
end


function tf = local_under(parent, child)
%LOCAL_UNDER  Is child inside parent?
n = numel(parent);
tf = numel(child) > n && local_eq(child(1:n), parent) && any(child(n+1) == '\/');
end
