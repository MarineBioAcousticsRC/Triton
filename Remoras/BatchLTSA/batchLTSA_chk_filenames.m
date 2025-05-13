function batchLTSA_chk_filenames
% BATCHLTSA_CHK_FILENAMES   Check and/or modify output LTSA filenames
%
%   Syntax:
%       BATCHLTSA_CHK_FILENAMES
%
%   Description:
%       GUI window that displays the assembled LTSA output filenames (using
%       a prefix from the directory plus the time average, frequency
%       average, and channel (if multichannel data). The user has the
%       option to manually modify the filenames individually.
%
%   Inputs:
%       calls global REMORA
%
%	Outputs:
%       updates global REMORA
%
%   Examples:
%
%   See also
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   Updated:   04 May 2025
%
%   Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global REMORA

disp_msg('Check output filenames. Edit as needed.');
if strcmp(REMORA.batchLTSA.settings.numCh, 'multi') && ...
        REMORA.batchLTSA.settings.whCh == 0
    disp_msg(['Multichannel files with ''ch0'' will have ''0'' replaced ', ...
        'by actual channel number.']);
end

% creates gui window check filenames
mycolor = [.8,.8,.8];
r = length(REMORA.batchLTSA.ltsa.outfiles) + 2;
c = 4;
h = 0.025*r;
w = 0.09*c;

bh = 1/r;
bw = 1/c;

y = zeros(1, r);
for ri = 2:r
    y(ri) = 1/r + y(ri-1);
end

x = zeros(1, r);
for ci = 2:c
    x(ci) = 1/c + x(ci-1);
end

btnPos = [0,0,w,h];
fig = figure('Name', 'Check LTSA filenames', 'Units', 'normalized', ...
    'Position', btnPos, 'MenuBar', 'none', 'NumberTitle', 'off', ...
    'CloseRequestFcn', @onClose);
movegui(gcf, 'center');

% entry labels
labelStr = 'Directory Name';
btnPos = [x(1), y(end), 2*bw, bh];
uicontrol(fig, 'Units', 'normalized', 'BackgroundColor', mycolor,...
    'Position', btnPos, 'Style', 'text', 'String', labelStr);

labelStr = 'Filename';
btnPos = [x(3), y(end), 2*bw, bh];
uicontrol(fig, 'Units', 'normalized', 'BackgroundColor', mycolor,...
    'Position', btnPos, 'Style', 'text', 'String', labelStr);

fig_filenames = cell(length(REMORA.batchLTSA.ltsa.indirs), 1);

% directory names and ed txt
for d = 1:length(REMORA.batchLTSA.ltsa.indirs)
    labelStr = REMORA.batchLTSA.ltsa.indirs(d);
    btnPos = [x(1), y(end-d), 2*bw, bh];
    uicontrol(fig, 'Units', 'normalized', 'BackgroundColor', mycolor,...
        'Position', btnPos, 'Style', 'text', 'String', labelStr,...
        'HorizontalAlign', 'left');

    % filenames
    labelStr = REMORA.batchLTSA.ltsa.outfiles(d);
    btnPos = [x(3), y(end-d), 2*bw, bh];
    fig_filenames{d} = uicontrol(fig, 'Units', 'normalized', 'Position', btnPos,...
        'Style', 'edit', 'String', labelStr);
end

% okay button
labelStr = 'Okay';
btnPos = [x(3), y(1), 2*bw, bh];
uicontrol(fig, 'Units', 'normalized', 'Position', btnPos,...
    'Style', 'push', 'String', labelStr, 'Callback', ...
    @(src, event) okay(src, event, fig, fig_filenames));

% cancel button
labelStr = 'Cancel';
btnPos = [x(1), y(1), bw, bh];
uicontrol(fig, 'Units', 'normalized', 'Position', btnPos,...
    'Style', 'push', 'String', labelStr, 'Callback','batchLTSA_control(''cancelAll'')');

% set flag for window close
setappdata(fig, 'closed', false);

% wait for user input
uiwait(fig);

% delete if closed by X or okay
if ishandle(fig) && getappdata(fig, 'closed')
    delete(fig);
end

end

%% okay button
function okay(~, ~, fig, fig_filenames)
% local function to assign updated LTSA filenames after OKAY is pressed
% ~, ~ are src, event that aren't needed

global REMORA

% close figure and assign values
for d = 1:length(fig_filenames)
    REMORA.batchLTSA.ltsa.outfiles(d) = get(fig_filenames{d}, 'String');
end

setappdata(fig, 'closed', true);
uiresume(fig);

end

%% window closed
function onClose(src, ~)

global REMORA
% treat as if cancelled
REMORA.batchLTSA.cancelled = 1;

% trigger closing figurea
setappdata(src, 'closed', true);
uiresume(src);  % resume execution

end