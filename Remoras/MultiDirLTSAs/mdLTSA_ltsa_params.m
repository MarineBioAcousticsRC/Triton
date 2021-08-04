function mdLTSA_ltsa_params(dirs) 

% creates gui window to define ltsa settings
mycolor = [.8,.8,.8];
r = length(dirs) + 2;
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
fig = figure('Name', 'Check taves and dfreqs', 'Units', 'normalized', ...
    'Position', btnPos, 'MenuBar', 'none', 'NumberTitle', 'off');
movegui(gcf, 'center');

% entry labels
labelStr = 'Directory Name';
btnPos = [x(1), y(end), 2*bw, bh];
uicontrol(fig, 'Units', 'normalized', 'BackgroundColor', mycolor,...
    'Position', btnPos, 'Style', 'text', 'String', labelStr);

labelStr = 'tave';
btnPos = [x(3), y(end), 0.5*bw, bh];
uicontrol(fig, 'Units', 'normalized', 'BackgroundColor', mycolor,...
    'Position', btnPos, 'Style', 'text', 'String', labelStr);

labelStr = 'dfreq';
btnPos = [x(3)+x(2)*0.5, y(end), 0.5*bw, bh];
uicontrol(fig, 'Units', 'normalized', 'BackgroundColor', mycolor,...
    'Position', btnPos, 'Style', 'text', 'String', labelStr);

fig_taves = {};
fig_dfreqs = {};

% directory names and ed txt
for d = 1:length(dirs)
    labelStr = dirs(d);
    btnPos = [x(1), y(end-d), 2*bw, bh];
    uicontrol(fig, 'Units', 'normalized', 'BackgroundColor', mycolor,...
        'Position', btnPos, 'Style', 'text', 'String', labelStr,...
        'HorizontalAlign', 'left');
    
    % tave
    labelStr = '5';
    btnPos = [x(3), y(end-d), 0.5*bw, bh];
    fig_taves{end+1} = uicontrol(fig, 'Units', 'normalized', 'Position', btnPos,...
        'Style', 'edit', 'String', labelStr);
    
    % dfreq
    labelStr = '100';
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



function okay(~, ~, fig, fig_taves, fig_dfreqs)

global PARAMS

% close figure and assign values
PARAMS.ltsa.taves = zeros(length(fig_taves), 1);
PARAMS.ltsa.dfreqs = zeros(length(fig_dfreqs), 1);
for d = 1:length(fig_taves)
    PARAMS.ltsa.taves(d) = str2num(get(fig_taves{d}, 'String'));
    PARAMS.ltsa.dfreqs(d) = str2num(get(fig_dfreqs{d}, 'String'));
end
close(fig);
end
