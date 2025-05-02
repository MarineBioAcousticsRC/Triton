function batchLTSA_chk_ltsa_params(dirs)

global REMORA

disp_msg('Check LTSA settings for each directory. To skip a directory, set tave, dfreq, ch blank.');
% creates gui window to define ltsa settings
mycolor = [.8,.8,.8];
r = length(dirs) + 2;
c = 10;
h = 0.025*r;
w = 0.03*c;

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
fig = figure('Name', 'Check taves, dfreqs, chs', 'Units', 'normalized', ...
    'Position', btnPos, 'MenuBar', 'none', 'NumberTitle', 'off');
movegui(gcf, 'center');

% entry labels
labelStr = 'Directory Name';
btnPos = [x(1), y(end), 7*bw, bh];
uicontrol(fig, 'Units', 'normalized', 'BackgroundColor', mycolor,...
    'Position', btnPos, 'Style', 'text', 'String', labelStr);

labelStr = 'tave';
btnPos = [x(8), y(end), bw, bh];
uicontrol(fig, 'Units', 'normalized', 'BackgroundColor', mycolor,...
    'Position', btnPos, 'Style', 'text', 'String', labelStr);

labelStr = 'dfreq';
btnPos = [x(9), y(end), bw, bh];
uicontrol(fig, 'Units', 'normalized', 'BackgroundColor', mycolor,...
    'Position', btnPos, 'Style', 'text', 'String', labelStr);

labelStr = 'ch';
btnPos = [x(10), y(end), bw, bh];
uicontrol(fig, 'Units', 'normalized', 'BackgroundColor', mycolor,...
    'Position', btnPos, 'Style', 'text', 'String', labelStr);


fig_taves = cell(length(dirs), 1);
fig_dfreqs = cell(length(dirs), 1);
fig_chs = cell(length(dirs), 1);

% directory names and ed txt
for d = 1:length(dirs)
    labelStr = dirs(d);
    btnPos = [x(1), y(end-d), 7*bw, bh];
    uicontrol(fig, 'Units', 'normalized', 'BackgroundColor', mycolor,...
        'Position', btnPos, 'Style', 'text', 'String', labelStr,...
        'HorizontalAlign', 'left');
    
    % tave
    labelStr = REMORA.batchLTSA.settings.tave;
    btnPos = [x(8), y(end-d), bw, bh];
    fig_taves{d} = uicontrol(fig, 'Units', 'normalized', 'Position', btnPos,...
        'Style', 'edit', 'String', labelStr);
    
    % dfreq
    labelStr = REMORA.batchLTSA.settings.dfreq;
    btnPos = [x(9), y(end-d), bw, bh];
    fig_dfreqs{d} = uicontrol(fig, 'Units', 'normalized', 'Position', btnPos,...
        'Style', 'edit', 'String', labelStr);

    % ch
    labelStr = REMORA.batchLTSA.settings.whCh;
    btnPos = [x(10), y(end-d), bw, bh];
    fig_chs{d} = uicontrol(fig, 'Units', 'normalized', 'Position', btnPos,...
        'Style', 'edit', 'String', labelStr);
end

% go button
labelStr = 'Okay';
btnPos = [x(8), y(1), bw*3, bh];
uicontrol(fig, 'Units', 'normalized', 'Position', btnPos,...
    'Style', 'push', 'String', labelStr, 'Callback', ...
    {@okay, fig, fig_taves, fig_dfreqs, fig_chs});

% cancel button
labelStr = 'Cancel';
btnPos = [x(1), y(1), bw*3, bh];
uicontrol(fig, 'Units', 'normalized', 'Position', btnPos,...
    'Style', 'push', 'String', labelStr, 'Callback', 'batchLTSA_control(''cancelAll'')');

uiwait;

end


%% okay button
function okay(~, ~, fig, fig_taves, fig_dfreqs, fig_chs)

global REMORA

% double check - not cancelled
REMORA.batchLTSA.cancelled = 0;

% close figure and assign values
REMORA.batchLTSA.ltsa.taves = zeros(length(fig_taves), 1);
REMORA.batchLTSA.ltsa.dfreqs = zeros(length(fig_dfreqs), 1);
REMORA.batchLTSA.ltsa.chs = zeros(length(fig_chs), 1);
for d = 1:length(fig_taves)      
    REMORA.batchLTSA.ltsa.taves(d) = str2double(get(fig_taves{d}, 'String'));
    REMORA.batchLTSA.ltsa.dfreqs(d) = str2double(get(fig_dfreqs{d}, 'String'));
    REMORA.batchLTSA.ltsa.chs(d) = str2double(get(fig_chs{d}, 'String'));
end

%id any blank/dirs to skip
dirToSkip = isnan(REMORA.batchLTSA.ltsa.taves) | isnan(REMORA.batchLTSA.ltsa.dfreqs) | ...
    isnan(REMORA.batchLTSA.ltsa.chs);
if any(dirToSkip)
    REMORA.batchLTSA.ltsa.indirs = REMORA.batchLTSA.ltsa.indirs(~dirToSkip);
    REMORA.batchLTSA.ltsa.outdirs = REMORA.batchLTSA.ltsa.outdirs(~dirToSkip);
    REMORA.batchLTSA.ltsa.taves = REMORA.batchLTSA.ltsa.taves(~dirToSkip);
    REMORA.batchLTSA.ltsa.dfreqs = REMORA.batchLTSA.ltsa.dfreqs(~dirToSkip);
    REMORA.batchLTSA.ltsa.chs = REMORA.batchLTSA.ltsa.chs(~dirToSkip);
end
close(fig);
end


