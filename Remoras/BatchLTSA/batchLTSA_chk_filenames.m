function batchLTSA_chk_filenames

% check filenames that they are what you want/expected

global PARAMS

% creates gui window check filenames
mycolor = [.8,.8,.8];
r = length(PARAMS.ltsa.outfiles) + 2;
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
    'Position', btnPos, 'MenuBar', 'none', 'NumberTitle', 'off');
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

fig_filenames = {};

% directory names and ed txt
for d = 1:length(PARAMS.ltsa.indirs)
    labelStr = PARAMS.ltsa.indirs(d);
    btnPos = [x(1), y(end-d), 2*bw, bh];
    uicontrol(fig, 'Units', 'normalized', 'BackgroundColor', mycolor,...
        'Position', btnPos, 'Style', 'text', 'String', labelStr,...
        'HorizontalAlign', 'left');
    
    % filenames
    labelStr = PARAMS.ltsa.outfiles(d);
    btnPos = [x(3), y(end-d), 2*bw, bh];
    fig_filenames{end+1} = uicontrol(fig, 'Units', 'normalized', 'Position', btnPos,...
        'Style', 'edit', 'String', labelStr); 
end

% go button
labelStr = 'Okay';
btnPos = [x(3), y(1), 2*bw, bh];
uicontrol(fig, 'Units', 'normalized', 'Position', btnPos,...
    'Style', 'push', 'String', labelStr, 'Callback', {@okay, fig, fig_filenames});
uiwait;
end


%% okay button
function okay(~, ~, fig, fig_filenames)

global PARAMS

% close figure and assign values
for d = 1:length(fig_filenames)
    PARAMS.ltsa.outfiles(d) = get(fig_filenames{d}, 'String');
end
close(fig);
end
