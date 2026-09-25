function xwav_convert_gui(direction)
%XWAV_CONVERT_GUI  Menu front end for folder-tree flac conversion.
%
%   xwav_convert_gui('compress')   % .wav/.x.wav  ->  .flac/.x.flac
%   xwav_convert_gui('expand')     % the reverse
%
% Asks for a source folder and a destination folder, works out the whole job,
% shows what it found and what it needs, and converts only once the user has
% agreed to it.
%
% All of the work is done by xwav_convert_dir, which has no GUI dependency at
% all. This function exists to collect two folder names, put a number in front
% of the user before anything is written, and turn progress into a bar. Anyone
% who prefers the command line can call audiodir2flac or flacdir2audio directly
% and never come near this.
%
% See also AUDIODIR2FLAC, FLACDIR2AUDIO, XWAV_CONVERT_DIR.

global PARAMS HANDLES %#ok<GVMIS>

if ~any(strcmpi(direction,{'compress','expand'}))
    error('xwav_convert_gui:direction','direction must be compress or expand');
end
direction = lower(direction);
isComp = strcmp(direction,'compress');

%% ---- where from, where to
if isfield(PARAMS,'convert') && isfield(PARAMS.convert,'lastIn')
    startIn = PARAMS.convert.lastIn;
else
    startIn = pwd;
end

if isComp
    srcPrompt = 'Select the folder of WAV / XWAV files to compress';
    dstPrompt = 'Select where the FLAC files should go';
else
    srcPrompt = 'Select the folder of FLAC / XFLAC files to expand';
    dstPrompt = 'Select where the WAV files should go';
end

indir = uigetdir(startIn, srcPrompt);
if isequal(indir,0) || strcmp(num2str(indir),'0')
    disp_msg('Cancelled'); return
end

if isfield(PARAMS,'convert') && isfield(PARAMS.convert,'lastOut')
    startOut = PARAMS.convert.lastOut;
else
    startOut = indir;
end
outdir = uigetdir(startOut, dstPrompt);
if isequal(outdir,0) || strcmp(num2str(outdir),'0')
    disp_msg('Cancelled'); return
end

PARAMS.convert.lastIn  = indir;
PARAMS.convert.lastOut = outdir;

%% ---- work the whole job out before doing any of it
disp_msg('Looking at the folder ...')
plan = xwav_convert_plan(indir, outdir, 'direction', direction);

if ~isempty(plan.stoppers)
    msg = sprintf('%s\n', plan.stoppers{:});
    disp_msg('Cannot start:')
    for k = 1:numel(plan.stoppers); disp_msg(['  ' plan.stoppers{k}]); end
    errordlg(msg, 'Cannot start');
    return
end

%% ---- show the numbers and get a yes
lines = {};
if isComp
    lines{end+1} = sprintf('Compress %d file(s) to FLAC.', plan.totals.nReady);
else
    lines{end+1} = sprintf('Expand %d file(s) from FLAC.', plan.totals.nReady);
end
lines{end+1} = '';
lines{end+1} = sprintf('From : %s', indir);
lines{end+1} = sprintf('To   : %s', outdir);
lines{end+1} = '';
lines{end+1} = sprintf('Source data      : %.2f GB', plan.totals.bytesIn/2^30);
if plan.totals.exact
    lines{end+1} = sprintf('Space needed     : %.2f GB (exact)', plan.totals.predictedOut/2^30);
else
    lines{end+1} = sprintf('Space needed     : %.2f GB at most', plan.totals.predictedOut/2^30);
end
if ~isnan(plan.dest.usable)
    lines{end+1} = sprintf('Free at the destination : %.2f GB', plan.dest.usable/2^30);
else
    lines{end+1} = 'Free space at the destination could not be read.';
end
if plan.totals.nOther > 0
    lines{end+1} = '';
    lines{end+1} = sprintf('%d other file(s) will be left where they are.', plan.totals.nOther);
end
if plan.totals.nProblem > 0
    lines{end+1} = sprintf('%d file(s) cannot be converted and will be listed in the log.', ...
        plan.totals.nProblem);
end
for k = 1:numel(plan.warnings)
    lines{end+1} = ''; lines{end+1} = plan.warnings{k}; %#ok<AGROW>
end
lines{end+1} = '';
lines{end+1} = 'The originals are not deleted.';

answer = questdlg(lines, 'Convert this folder?', 'Convert', 'Cancel', 'Convert');
if ~strcmp(answer,'Convert')
    disp_msg('Cancelled'); return
end

%% ---- run it, with a bar and a way out
if isComp; title = ' Compressing to FLAC '; else; title = ' Expanding from FLAC '; end
h = loadbar(title);
stopFlag = local_add_cancel(h);

report = xwav_convert_dir(indir, outdir, ...
    'direction', direction, ...
    'go',        true, ...
    'plan',      plan, ...
    'progress',  @(frac,msg) local_progress(h, stopFlag, frac, msg, title));

if ishandle(h); close(h); end

%% ---- say what happened
disp_msg(' ')
disp_msg(sprintf('Converted %d, skipped %d, failed %d', ...
    report.converted, report.skipped, report.failed + plan.totals.nProblem));
if report.bytesIn > 0
    disp_msg(sprintf('%.2f GB -> %.2f GB', report.bytesIn/2^30, report.bytesOut/2^30));
end
if ~isempty(report.stopped)
    disp_msg(['STOPPED: ' report.stopped]);
    if ~report.cancelled
        disp_msg('Free some space and run it again - finished files are kept and');
        disp_msg('checked, so it carries on from where it stopped.');
        warndlg({'The run stopped early:', '', report.stopped, '', ...
                 'Finished files are kept and checked, so running it again', ...
                 'carries on from where it stopped.'}, 'Stopped');
    end
end
disp_msg(['Log: ' report.logfile]);
end


%% ================================================================== helpers
function keepGoing = local_progress(h, stopFlag, frac, msg, title)
%LOCAL_PROGRESS  Drive the bar, and report whether Cancel has been pressed.
keepGoing = true;
if ~ishandle(h); keepGoing = false; return; end
if ~isempty(stopFlag) && ishandle(stopFlag) && get(stopFlag,'UserData')
    keepGoing = false; return
end
loadbar(sprintf('%s%s, %d%% complete', title, msg, round(frac*100)), h, frac);
drawnow limitrate
end


function btn = local_add_cancel(h)
%LOCAL_ADD_CANCEL  Put a Cancel button on the waitbar.
%
% A folder run can take hours, and the alternative is training people to press
% Ctrl-C -- which in MATLAB does not reliably stop the flac process already
% writing a file, and can leave a part-written one behind. The button is
% checked between files, where stopping is always clean.
%
% loadbar itself is untouched: the button is added to the figure it returns.
btn = [];
try
    p = get(h,'Position');
    set(h,'Position',[p(1) p(2) p(3) p(4)+28]);
    btn = uicontrol('Parent',h,'Style','pushbutton','String','Cancel', ...
        'Units','pixels','Position',[p(3)/2-40 6 80 22], ...
        'UserData',0, 'Callback',@(s,~) set(s,'UserData',1,'String','Stopping...'));
catch
    btn = [];      % no cancel button; the run still works
end
end
