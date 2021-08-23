function  precheck = batchLTSA_chk_filenames(precheck)

% check filenames that they are what you want/expected

global PARAMS REMORA

% creates gui window check filenames
mycolor = [.8,.8,.8];
r = length(precheck.outfiles) + 2;
c = 3;
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
    'Position', btnPos, 'MenuBar', 'none', 'NumberTitle', 'off');
movegui(gcf, 'center');

% entry labels
labelStr = 'Directory Name';
btnPos = [x(1), y(end), 2*bw, bh];
uicontrol(fig, 'Units', 'normalized', 'BackgroundColor', mycolor,...
    'Position', btnPos, 'Style', 'text', 'String', labelStr);

labelStr = 'filename';
btnPos = [x(3), y(end), bw, bh];
uicontrol(fig, 'Units', 'normalized', 'BackgroundColor', mycolor,...
    'Position', btnPos, 'Style', 'text', 'String', labelStr);

fig_filenames = {};

% directory names and ed txt
for d = 1:length(precheck.indirs)
    labelStr = precheck.indirs(d);
    btnPos = [x(1), y(end-d), 2*bw, bh];
    uicontrol(fig, 'Units', 'normalized', 'BackgroundColor', mycolor,...
        'Position', btnPos, 'Style', 'text', 'String', labelStr,...
        'HorizontalAlign', 'left');
    
    % tave
    labelStr = precheck.outfiles(d);
    btnPos = [x(3), y(end-d), bw, bh];
    fig_filenames{end+1} = uicontrol(fig, 'Units', 'normalized', 'Position', btnPos,...
        'Style', 'edit', 'String', labelStr);
    
    % dfreq
    labelStr = REMORA.batchLTSA.settings.dfreq;
    btnPos = [x(3)+x(2)*0.5, y(end-d), 0.5*bw, bh];
    fig_dfreqs{end+1} = uicontrol(fig, 'Units', 'normalized', 'Position', btnPos,...
        'Style', 'edit', 'String', labelStr);
end

% go button
labelStr = 'Okay';
btnPos = [x(3), y(1), bw, bh];
uicontrol(fig, 'Units', 'normalized', 'Position', btnPos,...
    'Style', 'push', 'String', labelStr, 'Callback', {@okay, fig, fig_taves, fig_dfreqs});
uiwait;
end


%% okay button
function okay(~, ~, fig, fig_taves, fig_dfreqs)

global PARAMS

% close figure and assign values
PARAMS.ltsa.taves = zeros(length(fig_taves), 1);
PARAMS.ltsa.dfreqs = zeros(length(fig_dfreqs), 1);
for d = 1:length(fig_taves)
    PARAMS.ltsa.taves(d) = str2double(get(fig_taves{d}, 'String'));
    PARAMS.ltsa.dfreqs(d) = str2double(get(fig_dfreqs{d}, 'String'));
end
close(fig);
end
