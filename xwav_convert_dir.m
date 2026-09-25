function report = xwav_convert_dir(indir, outdir, varargin)
%XWAV_CONVERT_DIR  Convert a whole folder tree, mirroring its structure.
%
%   report = xwav_convert_dir(src, dest, 'direction','compress')      % dry run
%   report = xwav_convert_dir(src, dest, 'direction','compress', 'go',true)
%
% Walks the source tree, converts every audio file, and writes the results into
% the destination under the same subfolder layout. Source and destination are
% usually different drives; that is the point.
%
% A bare call is a DRY RUN. It writes nothing and tells you what it would do,
% how much space it needs, and what it cannot handle. Pass 'go',true to convert.
%
% Options
%   'direction'    'compress' or 'expand' (required)
%   'go'           actually do it (default false)
%   'recursive'    walk subfolders (default true)
%   'overwrite'    'verified' (default) / 'skip' / 'replace' / 'error'
%   'keepInput'    keep the sources (default true -- these are transfers)
%   'minFree'      bytes to leave free on the destination (default 2 GiB)
%   'verify'       verify every conversion (default true)
%   'logfile'      where to write the log; chosen automatically if omitted
%   'plan'         a plan from xwav_convert_plan, to execute that exact snapshot
%   'progress'     handle called as tf = progress(fraction, message);
%                  return false to cancel. Used by the GUI; leave empty on the
%                  command line.
%   'flac'         path to the flac tool
%
% WHY THERE IS NO disp_msg OR waitbar IN HERE
%
% So it runs headless. disp_msg writes to Triton's message window and errors
% outright if that window does not exist, which would make this unusable from a
% script. Progress leaves through the 'progress' handle instead, and the GUI
% wrapper is what turns that into a bar on screen.
%
% RUNNING OUT OF ROOM STOPS THE RUN
%
% It does not skip the file and carry on. A full destination is a property of
% the destination, so every file after it would fail too, and a long tail of
% failures makes it impossible to tell "the drive filled" from "that file was
% bad". The run stops, the log is complete, and the report says how much more
% space is needed.
%
% See also XWAV_CONVERT_PLAN, XWAV_CONVERT, AUDIODIR2FLAC, FLACDIR2AUDIO.

p = inputParser;
addParameter(p,'direction','');
addParameter(p,'go',false);
addParameter(p,'recursive',true);
addParameter(p,'overwrite','verified');
addParameter(p,'keepInput',true);
addParameter(p,'minFree',2*2^30);
addParameter(p,'verify',true);
addParameter(p,'logfile','');
addParameter(p,'plan',[]);
addParameter(p,'progress',[]);
addParameter(p,'flac','');
parse(p,varargin{:});
opt = p.Results;

report = struct('plan',[], 'converted',0, 'skipped',0, 'failed',0, ...
                'bytesIn',0, 'bytesOut',0, 'stopped','', 'logfile','', ...
                'notAttempted',0, 'cancelled',false);

%% ---- the plan: given, or made now
if isempty(opt.plan)
    plan = xwav_convert_plan(indir, outdir, 'direction', opt.direction, ...
        'recursive', opt.recursive, 'minFree', opt.minFree, 'flac', opt.flac);
else
    plan = opt.plan;
end
report.plan = plan;

local_banner(plan, opt.go);

if ~isempty(plan.stoppers)
    fprintf('\n  Cannot start:\n');
    for k = 1:numel(plan.stoppers)
        fprintf('    %s\n', plan.stoppers{k});
    end
    fprintf('\n');
    return
end

if ~opt.go
    fprintf('\n  Dry run only. Add ''go'',true to convert.\n\n');
    return
end

%% ---- the log, decided and announced now rather than at the end
% A run that dies half way still has to leave a findable record, so the path is
% settled before any work happens and printed immediately.
report.logfile = local_logpath(opt.logfile, outdir, indir, plan.direction);
fprintf('  log: %s\n\n', report.logfile);
local_log(report.logfile, 'source,destination,kind,status,bytes_in,bytes_out,message', true);

%% ---- convert
ready = find(strcmp({plan.files.status},'ready'));
nReady = numel(ready);
budget = plan.dest.usable;          % NaN if it could not be read

for i = 1:nReady
    f = plan.files(ready(i));

    if ~isempty(opt.progress)
        keepGoing = opt.progress((i-1)/nReady, ...
            sprintf('%d of %d', i, nReady));
        if ~keepGoing
            report.cancelled = true;
            report.stopped = 'cancelled';
            report.notAttempted = nReady - i + 1;
            local_log(report.logfile, sprintf('"%s",,,not_attempted,,,cancelled', f.src));
            break
        end
    end

    [ok, out, info] = xwav_convert(f.src, ...
        'direction', plan.direction, ...
        'outdir',    fileparts(f.dst), ...
        'keepInput', opt.keepInput, ...
        'verify',    opt.verify, ...
        'minFree',   opt.minFree, ...
        'overwrite', opt.overwrite, ...
        'flac',      opt.flac);

    if ~isempty(info.stop)
        % Out of room. Stop rather than generating a tail of failures.
        report.stopped = info.stop;
        report.notAttempted = nReady - i + 1;
        local_log(report.logfile, sprintf('"%s","%s",%s,not_attempted,%d,,"%s"', ...
            f.src, f.dst, f.kind, f.bytesIn, info.stop));
        break
    end

    if ok && info.skipped
        report.skipped = report.skipped + 1;
        local_log(report.logfile, sprintf('"%s","%s",%s,skipped,%d,%d,"%s"', ...
            f.src, out, f.kind, info.bytesIn, info.bytesOut, info.why));
    elseif ok
        report.converted = report.converted + 1;
        report.bytesIn  = report.bytesIn  + info.bytesIn;
        report.bytesOut = report.bytesOut + info.bytesOut;
        if ~isnan(budget); budget = budget - info.bytesOut; end
        local_log(report.logfile, sprintf('"%s","%s",%s,converted,%d,%d,"%s"', ...
            f.src, out, f.kind, info.bytesIn, info.bytesOut, info.why));
        fprintf('  ok     %-52s %8.1f -> %8.1f MB\n', ...
            local_tail(f.src), info.bytesIn/1e6, info.bytesOut/1e6);
    else
        report.failed = report.failed + 1;
        local_log(report.logfile, sprintf('"%s","%s",%s,failed,%d,,"%s"', ...
            f.src, f.dst, f.kind, f.bytesIn, info.why));
        fprintf('  FAIL   %-52s %s\n', local_tail(f.src), info.why);
    end
end

% Everything the plan already knew it could not do.
for k = find(~strcmp({plan.files.status},'ready'))
    local_log(report.logfile, sprintf('"%s","%s",%s,failed,%d,,"%s"', ...
        plan.files(k).src, plan.files(k).dst, plan.files(k).kind, ...
        plan.files(k).bytesIn, plan.files(k).why));
end

% And what was deliberately left behind. Only audio is converted, so a
% deployment folder's notes, spreadsheets and LTSAs stay where they are -- but
% the log has to say so, or someone reading it later cannot tell the difference
% between "there was nothing else" and "something was missed".
if plan.totals.nOther > 0
    local_log(report.logfile, sprintf(['"%s",,,not_attempted,,,' ...
        '"%d non-audio file(s) in the tree were left where they are"'], ...
        plan.indir, plan.totals.nOther));
end

if ~isempty(opt.progress); opt.progress(1, 'finished'); end

%% ---- summary
fprintf('\n%s\n', repmat('-',1,70));
fprintf('  converted     : %d\n', report.converted);
fprintf('  skipped       : %d\n', report.skipped);
fprintf('  failed        : %d\n', report.failed + plan.totals.nProblem);
if report.notAttempted > 0
    fprintf('  NOT attempted : %d\n', report.notAttempted);
end
if report.bytesIn > 0
    fprintf('  %.2f GB -> %.2f GB (%.1f%%)\n', report.bytesIn/2^30, ...
        report.bytesOut/2^30, 100*report.bytesOut/report.bytesIn);
end
if ~isempty(report.stopped)
    fprintf('\n  STOPPED: %s\n', report.stopped);
    if ~report.cancelled
        fprintf('  Free some space and run it again -- finished files are kept\n');
        fprintf('  and checked, so it picks up where it stopped.\n');
    end
end
fprintf('  log: %s\n', report.logfile);
fprintf('%s\n\n', repmat('-',1,70));
end


%% ================================================================== helpers
function local_banner(plan, go)
fprintf('\n%s\n', repmat('-',1,70));
if go
    fprintf('  %s\n', local_tern(strcmp(plan.direction,'compress'), ...
        'Compressing to FLAC', 'Expanding from FLAC'));
else
    fprintf('  DRY RUN -- nothing will be written\n');
end
fprintf('  from : %s\n  to   : %s\n', plan.indir, plan.outdir);
fprintf('%s\n', repmat('-',1,70));
fprintf('  %d file(s) to convert, %.2f GB\n', plan.totals.nReady, ...
    plan.totals.bytesIn/2^30);
fprintf('  needs about %.2f GB at the destination%s\n', ...
    plan.totals.predictedOut/2^30, ...
    local_tern(plan.totals.exact, ' (exact)', ' at most'));
if ~isnan(plan.dest.usable)
    fprintf('  %.2f GB free there (%s)\n', plan.dest.usable/2^30, plan.dest.fsType);
end
if plan.totals.nOther > 0
    fprintf('  %d other file(s) in the tree will be left where they are\n', ...
        plan.totals.nOther);
end
if plan.totals.nProblem > 0
    fprintf('\n  %d file(s) cannot be converted:\n', plan.totals.nProblem);
    bad = find(~strcmp({plan.files.status},'ready'));
    for k = bad(1:min(10,numel(bad)))
        fprintf('    %-44s %s\n', local_tail(plan.files(k).src), plan.files(k).why);
    end
    if numel(bad) > 10
        fprintf('    ... and %d more, all listed in the log\n', numel(bad)-10);
    end
end
for k = 1:numel(plan.warnings)
    fprintf('\n  Note: %s\n', plan.warnings{k});
end
end


function pth = local_logpath(given, outdir, indir, direction)
%LOCAL_LOGPATH  Somewhere the log can actually be written.
if ~isempty(given); pth = given; return; end
stamp = datestr(now,'yyyymmdd_HHMMSS'); %#ok<TNOW1,DATST>
name  = sprintf('triton_%s_log_%s.csv', direction, stamp);
for cand = {outdir, indir, tempdir}
    d = cand{1};
    if isempty(d); continue; end
    if ~exist(d,'dir'); mkdir(d); end
    pth = fullfile(d, name);
    fid = fopen(pth,'a');
    if fid > 0; fclose(fid); return; end
end
pth = fullfile(tempdir, name);
end


function local_log(pth, line, isHeader)
%LOCAL_LOG  Append one line and close again.
%
% Opened and closed per line on purpose. A conversion takes seconds, so the
% cost is nothing, and it means a Ctrl-C or a MATLAB crash still leaves a
% complete log -- which matters most in exactly the runs that do not finish.
if nargin < 3; isHeader = false; end
mode = 'a'; if isHeader; mode = 'w'; end
fid = fopen(pth, mode);
if fid < 0; return; end
fprintf(fid, '%s\n', line);
fclose(fid);
end


function s = local_tail(p)
[~,n,e] = fileparts(p); s = [n e];
if numel(s) > 52; s = ['...' s(end-48:end)]; end
end


function v = local_tern(c,a,b)
if c; v = a; else; v = b; end
end
