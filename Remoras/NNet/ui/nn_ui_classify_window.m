function nn_ui_classify_window

global REMORA


defaultPos = [0.35,.45,.3,.25];
initAxes = 0;
if isfield(REMORA.fig, 'nn')
    % check if the figure already exists. If so, don't move it.
    if isfield(REMORA.fig.nn, 'classify') && isvalid(REMORA.fig.nn.classify.figH)
        defaultPos = get(REMORA.fig.nn.classify.figH,'Position');
    else
        initAxes = 1;
    end
else 
    initAxes = 1;
end

if initAxes
    REMORA.fig.nn.classify.figH = figure;
    
    set(REMORA.fig.nn.train_net.figH,...
        'Units','normalized',...
        'ToolBar', 'none',...
        'MenuBar','none',...
        'NumberTitle','off','Name',...
        'Neural Net Tool - v1.0: Classify',...
        'Position',defaultPos,...
        'Visible','on');
end


%% Title
labelStr = 'Classification Options';
btnPos=[0 .9 1 .1];

REMORA.fig.nn.classify.headText = uicontrol(REMORA.fig.nn.train_net.figH, ...
    'Style','text', ...
    'Units','normalized', ...
    'Position',btnPos, ...
    'String',labelStr, ...
    'FontSize',12,...
    'FontUnits','normalized', ...
    'FontWeight','bold',...
    'Visible','on');

%Location of data to classify
%Search subfolders checkbox?
%Location of network to use

%Location to save labels
