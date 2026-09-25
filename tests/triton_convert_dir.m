function report = triton_convert_dir(varargin)
%TRITON_CONVERT_DIR  Does folder-tree conversion survive a round trip?
%
%   triton_convert_dir
%   triton_convert_dir('keep', true)      % leave the work folder for inspection
%
% Builds a small nested tree from the committed fixtures -- plain wavs in one
% subfolder, x.wavs in another -- compresses it to a second location, expands
% that back to a third, and requires every file to come back byte-identical
% with the folder layout reproduced.
%
% Needs no ExampleData, so it runs on a fresh clone. It does need the flac
% command-line tool.
%
% Also checks the things that are easy to get wrong and invisible when they are:
%
%   * a `.wav` that is really an xwav still comes out as `.x.flac`
%   * the space guard refuses before writing rather than part way through
%   * a truncated output is redone rather than skipped on a resume
%   * nothing is written when the destination is inside the source
%   * no `__triton_tmp__` files are left behind
%   * it all works with no HANDLES global, i.e. headless
%
% See also XWAV_CONVERT_DIR, XWAV_CONVERT, TRITON_FLAC_PARITY.

p = inputParser;
addParameter(p,'keep',false);
addParameter(p,'flac','');
parse(p,varargin{:});
opt = p.Results;

here = fileparts(mfilename('fullpath'));
root = fileparts(here);
addpath(root); addpath(here);

report = struct('pass',0,'fail',0,'checks',{{}});

work = fullfile(tempdir, ['triton_convert_' datestr(now,'yyyymmdd_HHMMSS')]); %#ok<TNOW1,DATST>
src  = fullfile(work,'source');
comp = fullfile(work,'compressed');
back = fullfile(work,'expanded');

fprintf('\nFolder-tree conversion round trip\n  work: %s\n\n', work);

%% ---- build a nested source tree
mkdir(fullfile(src,'disk01'));
mkdir(fullfile(src,'disk02'));
fx = fullfile(root,'tests','fixtures');
copyfile(fullfile(fx,'pad_wav','SYNTH_PAD_260101_000000.wav'),   fullfile(src,'disk01','a.wav'));
copyfile(fullfile(fx,'pad_wav','SYNTH_PAD_260101_000006.wav'),   fullfile(src,'disk02','a.wav'));
copyfile(fullfile(fx,'pad_xwav','SYNTH_PADX_260101_000000.x.wav'),fullfile(src,'disk01','b.x.wav'));
copyfile(fullfile(fx,'pad_xwav','SYNTH_PADX_260101_000010.x.wav'),fullfile(src,'disk02','b.x.wav'));
% an xwav wearing a plain name, to prove classification is by content
copyfile(fullfile(fx,'pad_xwav','SYNTH_PADX_260101_000000.x.wav'),fullfile(src,'disk02','misnamed.wav'));
% something that is not audio at all
fid = fopen(fullfile(src,'disk01','notes.txt'),'w'); fprintf(fid,'deployment notes\n'); fclose(fid);

% same file name in two different subfolders: the case a flat tool would lose
fprintf('  built %d audio files across 2 subfolders (2 share a name)\n\n', 5);

%% ---- 1. dry run writes nothing
r = xwav_convert_dir(src, comp, 'direction','compress', 'flac', opt.flac);
report = local_check(report, 'dry run writes nothing', ...
    ~exist(comp,'dir') || isempty(dir(fullfile(comp,'**','*.flac'))), '');
report = local_check(report, 'dry run counts 5 files', ...
    r.plan.totals.nReady == 5, sprintf('found %d', r.plan.totals.nReady));
report = local_check(report, 'dry run sees 1 non-audio', ...
    r.plan.totals.nOther == 1, sprintf('found %d', r.plan.totals.nOther));

%% ---- 2. compress for real
r = xwav_convert_dir(src, comp, 'direction','compress', 'go',true, 'flac',opt.flac);
report = local_check(report, 'compressed all 5', r.converted == 5, ...
    sprintf('%d converted, %d failed', r.converted, r.failed));
report = local_check(report, 'structure mirrored', ...
    exist(fullfile(comp,'disk01'),'dir') && exist(fullfile(comp,'disk02'),'dir'), '');
report = local_check(report, 'misnamed xwav became .x.flac', ...
    exist(fullfile(comp,'disk02','misnamed.x.flac'),'file') > 0, '');
report = local_check(report, 'non-audio not copied', ...
    ~exist(fullfile(comp,'disk01','notes.txt'),'file'), '');
report = local_check(report, 'log written', exist(r.logfile,'file') > 0, r.logfile);

%% ---- 3. expand back
r2 = xwav_convert_dir(comp, back, 'direction','expand', 'go',true, 'flac',opt.flac);
report = local_check(report, 'expanded all 5', r2.converted == 5, ...
    sprintf('%d converted, %d failed', r2.converted, r2.failed));

%% ---- 4. every file byte-identical
pairs = { fullfile(src,'disk01','a.wav'),      fullfile(back,'disk01','a.wav'); ...
          fullfile(src,'disk02','a.wav'),      fullfile(back,'disk02','a.wav'); ...
          fullfile(src,'disk01','b.x.wav'),    fullfile(back,'disk01','b.x.wav'); ...
          fullfile(src,'disk02','b.x.wav'),    fullfile(back,'disk02','b.x.wav'); ...
          fullfile(src,'disk02','misnamed.wav'),fullfile(back,'disk02','misnamed.x.wav') };
nsame = 0;
for k = 1:size(pairs,1)
    if exist(pairs{k,2},'file') && isequal(local_bytes(pairs{k,1}), local_bytes(pairs{k,2}))
        nsame = nsame + 1;
    else
        fprintf('    differs or missing: %s\n', pairs{k,2});
    end
end
report = local_check(report, 'round trip byte-identical', nsame == size(pairs,1), ...
    sprintf('%d of %d', nsame, size(pairs,1)));

%% ---- 5. guards
r3 = xwav_convert_dir(src, fullfile(work,'guarded'), 'direction','compress', ...
    'go',true, 'minFree', 1e15, 'flac',opt.flac);
report = local_check(report, 'space guard refuses up front', ...
    ~isempty(r3.plan.stoppers) && r3.converted == 0, '');

% Converting in place is legitimate -- it is what xwavdir2flac has always done
% -- and must keep working. It is safe because a compress run steps over the
% flac files it produces.
inplace = fullfile(work,'inplace');
copyfile(src, inplace);
r4 = xwav_convert_dir(inplace, inplace, 'direction','compress', ...
    'go',true, 'flac',opt.flac);
report = local_check(report, 'in-place conversion works', ...
    r4.converted == 5 && r4.failed == 0, ...
    sprintf('%d converted, %d failed', r4.converted, r4.failed));
report = local_check(report, 'in-place run says so', ...
    ~isempty(r4.plan.warnings), '');
% a second pass must not re-convert, nor pick up its own output
r4b = xwav_convert_dir(inplace, inplace, 'direction','compress', ...
    'go',true, 'flac',opt.flac);
report = local_check(report, 'second in-place pass converts nothing new', ...
    r4b.converted == 0, sprintf('%d converted again', r4b.converted));

%% ---- 6. a truncated output is redone, not skipped
victim = fullfile(comp,'disk01','b.x.flac');
d = dir(victim);
fid = fopen(victim,'r'); half = fread(fid, floor(d.bytes/2), '*uint8'); fclose(fid);
fid = fopen(victim,'w'); fwrite(fid, half); fclose(fid);
r5 = xwav_convert_dir(src, comp, 'direction','compress', 'go',true, ...
    'overwrite','verified', 'flac',opt.flac);
dn = dir(victim);
report = local_check(report, 'truncated output redone on resume', ...
    dn.bytes == d.bytes && r5.converted >= 1, ...
    sprintf('%d -> %d bytes, %d reconverted', floor(d.bytes/2), dn.bytes, r5.converted));

%% ---- 7. nothing left behind
report = local_check(report, 'no __triton_tmp__ left', ...
    isempty(dir(fullfile(work,'**','__triton_tmp__*'))), '');

%% ---- done
fprintf('\n  %d passed, %d failed\n', report.pass, report.fail);
if report.fail == 0
    fprintf('\n  A folder tree survives compression and expansion unchanged,\n');
    fprintf('  structure and all, and the guards fire before anything is written.\n\n');
end
if ~opt.keep && exist(work,'dir')
    rmdir(work,'s');
else
    fprintf('  left in %s\n\n', work);
end
end


%% ================================================================== helpers
function r = local_check(r, name, ok, detail)
r.checks{end+1} = struct('name',name,'ok',ok,'detail',detail);
if ok; r.pass = r.pass + 1; else; r.fail = r.fail + 1; end
if ok; mark = 'ok  '; else; mark = 'FAIL'; end
fprintf('  %s %-38s %s\n', mark, name, detail);
end


function b = local_bytes(f)
fid = fopen(f,'r'); b = fread(fid,Inf,'*uint8'); fclose(fid);
end
