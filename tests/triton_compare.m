function report = triton_compare(beforeFile, afterFile, varargin)
%TRITON_COMPARE  Say what changed between two triton_baseline manifests.
%
%   triton_compare('tests/baseline/before.json', 'tests/baseline/after.json')
%   r = triton_compare(before, after, 'verbose', false);
%
% Prints one line per case whose output moved, naming the field and showing the
% old and new values, then a summary. Returns a struct with the details so it
% can be used in a script.
%
% A case is identified by its file path plus its case name, so cases can be
% added or removed between runs without confusing the comparison -- those are
% reported separately from cases that genuinely changed.
%
% Interpreting the result
%   changed   Triton now produces different output for the same input. If you
%             did not mean to change behaviour, this is a regression. If you
%             did, check the direction is the one you intended.
%   appeared  a case that errored before and works now, or a new file
%   vanished  a case that worked before and errors now, or a removed file
%
% Options
%   'verbose'  print unchanged cases too (default false)
%   'tol'      relative tolerance for numeric comparison (default 0, exact)
%
% See tests/README.md.

p = inputParser;
addParameter(p,'verbose',false);
addParameter(p,'tol',0);
parse(p,varargin{:});
opt = p.Results;

before = local_load(beforeFile);
after  = local_load(afterFile);

fprintf('Comparing Triton output\n');
fprintf('  before : %s   (%s, %s, git %s)\n', beforeFile, local_get(before,'created','?'), ...
    local_get(before,'matlab','?'), local_str(local_get(before,'git_head','-')));
fprintf('  after  : %s   (%s, %s, git %s)\n\n', afterFile, local_get(after,'created','?'), ...
    local_get(after,'matlab','?'), local_str(local_get(after,'git_head','-')));

bKeys = local_keys(before);
aKeys = local_keys(after);

report = struct('changed',{{}}, 'appeared',{{}}, 'vanished',{{}}, ...
                'unchanged',0, 'n_before',numel(bKeys), 'n_after',numel(aKeys));

% ---- cases present in both
common = intersect(bKeys, aKeys);
for k = 1:numel(common)
    key = common{k};
    b = local_case(before, key);
    a = local_case(after,  key);

    diffs = {};

    % error state first -- an error appearing or clearing is the loudest signal
    if ~isequal(local_str(b.error), local_str(a.error))
        diffs{end+1} = struct('field','error', ...
            'before',local_str(b.error), 'after',local_str(a.error)); %#ok<AGROW>
    end

    fields = union(fieldnames_safe(b.values), fieldnames_safe(a.values));
    for fi = 1:numel(fields)
        f = fields{fi};
        hasB = isfield(b.values,f); hasA = isfield(a.values,f);
        if ~hasB || ~hasA
            diffs{end+1} = struct('field',f, ...
                'before',local_fmt(local_get(b.values,f,'<absent>')), ...
                'after', local_fmt(local_get(a.values,f,'<absent>'))); %#ok<AGROW>
            continue
        end
        vb = b.values.(f); va = a.values.(f);
        if ~local_equal(vb, va, opt.tol)
            diffs{end+1} = struct('field',f, ...
                'before',local_fmt(vb),'after',local_fmt(va)); %#ok<AGROW>
        end
    end

    if isempty(diffs)
        report.unchanged = report.unchanged + 1;
        if opt.verbose
            fprintf('  ok       %s\n', key);
        end
    else
        report.changed{end+1} = struct('key',key,'diffs',{diffs});
        fprintf('  CHANGED  %s\n', key);
        for di = 1:numel(diffs)
            fprintf('             %-18s %s  ->  %s\n', ...
                diffs{di}.field, diffs{di}.before, diffs{di}.after);
        end
    end
end

% ---- cases only on one side
onlyAfter  = setdiff(aKeys, bKeys);
onlyBefore = setdiff(bKeys, aKeys);
for k = 1:numel(onlyAfter)
    report.appeared{end+1} = onlyAfter{k};
    fprintf('  APPEARED %s\n', onlyAfter{k});
end
for k = 1:numel(onlyBefore)
    report.vanished{end+1} = onlyBefore{k};
    fprintf('  VANISHED %s\n', onlyBefore{k});
end

% ---- summary
fprintf('\n');
fprintf('  unchanged : %d\n', report.unchanged);
fprintf('  changed   : %d\n', numel(report.changed));
fprintf('  appeared  : %d\n', numel(report.appeared));
fprintf('  vanished  : %d\n', numel(report.vanished));
if isempty(report.changed) && isempty(report.vanished)
    fprintf('\n  No regressions: every case that ran before produces identical output.\n');
else
    fprintf('\n  Review the entries above before merging.\n');
end
end


%% ================================================================== helpers
function m = local_load(f)
if ~exist(f,'file'); error('triton_compare: no such manifest: %s', f); end
fid = fopen(f,'r'); txt = fread(fid,'*char')'; fclose(fid);
m = jsondecode(txt);
if ~isfield(m,'cases'); error('triton_compare: %s is not a baseline manifest', f); end
end


function keys = local_keys(m)
cases = local_cases(m);
keys = cell(numel(cases),1);
for k = 1:numel(cases)
    keys{k} = sprintf('%s :: %s', cases{k}.relpath, cases{k}.case);
end
end


function c = local_case(m, key)
cases = local_cases(m);
for k = 1:numel(cases)
    if strcmp(sprintf('%s :: %s', cases{k}.relpath, cases{k}.case), key)
        c = cases{k}; return
    end
end
error('triton_compare: case not found: %s', key);
end


function cases = local_cases(m)
% jsondecode gives a cell array when case structs differ in fields, a struct
% array when they happen to match. Normalise to a cell array.
if iscell(m.cases)
    cases = m.cases;
else
    cases = num2cell(m.cases);
end
end


function f = fieldnames_safe(s)
if isstruct(s); f = fieldnames(s); else; f = {}; end
end


function v = local_get(s, f, d)
if isstruct(s) && isfield(s,f); v = s.(f); else; v = d; end
end


function tf = local_equal(a, b, tol)
if ischar(a) || ischar(b)
    tf = isequal(local_str(a), local_str(b));
    return
end
if ~isequal(size(a), size(b)); tf = false; return; end
if isempty(a); tf = true; return; end
if tol <= 0
    tf = isequaln(a, b);
else
    scale = max(max(abs(double(a(:)))), max(abs(double(b(:)))));
    if scale == 0; scale = 1; end
    tf = all(abs(double(a(:)) - double(b(:))) <= tol * scale) ...
         || isequaln(a, b);
end
end


function s = local_str(x)
if isempty(x); s = ''; elseif ischar(x); s = x; else; s = local_fmt(x); end
end


function s = local_fmt(x)
if ischar(x)
    s = x;
elseif isempty(x)
    s = '[]';
elseif isscalar(x)
    if x == fix(x) && abs(x) < 1e15
        s = sprintf('%d', x);
    else
        s = sprintf('%.10g', x);
    end
else
    s = ['[' strtrim(sprintf('%.10g ', double(x(:)'))) ']'];
    if numel(s) > 60; s = [s(1:57) '...']; end
end
end
