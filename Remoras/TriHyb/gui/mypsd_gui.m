function mypsd_gui
global REMORA

% Colors
bgColor       = [0.90, 0.94, 0.98];   % Main background
textColor     = [0.1, 0.2, 0.4];      % Label text
buttonColor   = [0.25, 0.45, 0.70];   % Buttons: darker blue
buttonFontColor = [1, 1, 1];           % White button text

% Base figure size (pixels)
figWidthPx = 900;
figHeightPx = 800;

% Create main GUI figure with normalized units for resizing support
REMORA.mypsd.gui.fig = figure('Name', 'TriHyb: HARP Hybrid Millidecade Products', ...
    'NumberTitle', 'off', 'MenuBar', 'none', ...
    'ToolBar', 'none', 'Color', bgColor, ...
    'Units', 'normalized', ...
    'Position', [0.3, 0.05, 0.5, 0.8]);  % normalized screen fraction

tabGroup = uitabgroup(REMORA.mypsd.gui.fig, 'Units', 'normalized', 'Position', [0 0 1 1]);

%% === TAB 1: Metadata Compiler ===
tab1 = uitab(tabGroup, 'Title', 'Metadata Compiler', 'BackgroundColor', bgColor, 'Units', 'normalized');

% === Load logo and alpha ===
logoPath = fullfile(fileparts(mfilename('fullpath')), 'MBARC_logo.png');
[logoImg, ~, alpha] = imread(logoPath);

% Rotate 180 deg to fix upside-down + flipped problem
logoImg = flipud(logoImg);
if exist('alpha', 'var')
    alpha = flipud(alpha);
end

% Create panel top right (normalized position)
logoPanel = uipanel(tab1, ...
    'Units', 'normalized', ...
    'Position', [0, 0.87, 0.24, 0.19], ...
    'BackgroundColor', bgColor, ...
    'BorderType', 'none');

% Create axes
logoAxes = axes('Parent', logoPanel, ...
    'Units', 'normalized', ...
    'Position', [0, 0, 1, 1], ...
    'Color', 'none');

% Display image with alpha
hImg = image('CData', logoImg, 'Parent', logoAxes);
if exist('alpha', 'var')
    set(hImg, 'AlphaData', alpha);
end

% Fix axes orientation
set(logoAxes, 'YDir', 'normal');

% Clean axes
axis(logoAxes, 'image');
axis(logoAxes, 'off');

fontSize = 10;

% Define metadata fields
longFields = {'Title', 'Summary', 'History', 'Source', 'Acknowledgements'};
shortFields = {
    'Citation', 'Comment', 'Conventions', 'Creator_Name', 'Creator_Role', ...
    'Creator_URL', 'ID', 'Publisher_URL', 'Institution', ...
    'Instrument', 'Keywords', 'Keywords_Vocabulary', 'License', ...
    'Naming_Authority', 'Product_Version', ...
    'Publisher_Name', 'References'
    };

% Layout parameters (normalized relative to 900x800 px base)
longLabelX = 30 / figWidthPx;
longEditX = 180 / figWidthPx;
longEditWidth = 660 / figWidthPx;
longFieldHeight = 45 / figHeightPx;
label_width = 180 / figWidthPx;
edit_width = 220 / figWidthPx;
edit_height = 25 / figHeightPx;
col1_x = 30 / figWidthPx;
col2_x = 450 / figWidthPx;
spacing = 15 / figHeightPx;

% Y position starts near top (convert from pixels)
yPos = (750) / figHeightPx;

% Add title to Tab 1
uicontrol(tab1, 'Style', 'text', ...
    'String', 'Compile HARP Hybrid Millidecade Metadata', ...
    'Units', 'normalized', ...
    'Position', [150/figWidthPx, (yPos - 30/figHeightPx), 600/figWidthPx, 30/figHeightPx], ...
    'FontSize', 14, 'FontWeight', 'bold', ...
    'BackgroundColor', bgColor, ...
    'ForegroundColor', textColor, ...
    'HorizontalAlignment', 'center');

yPos = yPos - (80 / figHeightPx);

% Long multi-line fields
for i = 1:length(longFields)
    field = longFields{i};
    switch field
        case 'Title'
            defaultStr = {};
        case 'Summary'
            defaultStr = {};
        case 'Acknowledgements'
            defaultStr = {};
        case 'History'
            defaultStr = {};
        case 'Source'
            defaultStr = {};
        otherwise
            defaultStr = '';
    end

    uicontrol(tab1, 'Style', 'text', ...
        'String', [strrep(field, '_', ' '), ':'], ...
        'Units', 'normalized', ...
        'Position', [longLabelX, yPos, label_width, 30/figHeightPx], ...
        'BackgroundColor', bgColor, ...
        'ForegroundColor', textColor, ...
        'HorizontalAlignment', 'left', 'FontWeight', 'bold', ...
        'FontSize', fontSize);

    REMORA.mypsd.gui.(field) = uicontrol(tab1, 'Style', 'edit', ...
        'Max', 3, 'Min', 0, ...
        'Units', 'normalized', ...
        'Position', [longEditX, yPos - 15/figHeightPx, longEditWidth, longFieldHeight], ...
        'FontSize', fontSize, ...
        'HorizontalAlignment', 'left', 'String', defaultStr);

    yPos = yPos - longFieldHeight - spacing;
end

% Short fields layout start below long fields
% Calculate y base for short fields (yPos currently after last long field)
for i = 1:length(shortFields)
    field = shortFields{i};
    switch lower(field)
        case {'source'}
            defaultStr = {[]};
        case 'creator_name'
            defaultStr = {};
        case 'institution'
            defaultStr = {};
        case 'instrument'
            defaultStr = {};
        case 'keywords'
            defaultStr = {};
        case 'keywords_vocabulary'
            defaultStr = {};
        case 'conventions'
            defaultStr = {};
        case 'creator_url'
            defaultStr = {};
        case 'naming_authority'
            defaultStr = {};
        case 'publisher_url'
            defaultStr = {};
        case 'publisher_name'
            defaultStr = {};
        otherwise
            defaultStr = '';
    end

    col = mod(i-1, 2);
    row = floor((i-1)/2);
    x = col1_x + col * (col2_x - col1_x);
    y = yPos - row * (40/figHeightPx);

    uicontrol(tab1, 'Style', 'text', ...
        'String', [strrep(field, '_', ' '), ':'], ...
        'Units', 'normalized', ...
        'Position', [x, y, label_width, 30/figHeightPx], ...
        'BackgroundColor', bgColor, ...
        'ForegroundColor', textColor, ...
        'FontSize', fontSize, ...
        'HorizontalAlignment', 'left', 'FontWeight', 'bold');

    REMORA.mypsd.gui.(field) = uicontrol(tab1, 'Style', 'edit', ...
        'Units', 'normalized', ...
        'Position', [x + label_width + 5/figWidthPx, y + 5/figHeightPx, edit_width, edit_height], ...
        'FontSize', fontSize, ...
        'HorizontalAlignment', 'left', 'String', defaultStr);



end

% Add "Import from CSV" button
uicontrol(tab1, 'Style', 'pushbutton', ...
    'String', 'Import from .xlsx file', ...
    'Units', 'normalized', ...
    'Position', [(figWidthPx/2 - 110) / figWidthPx, 10 / figHeightPx, 220 / figWidthPx, 35 / figHeightPx], ...
    'BackgroundColor', [0.40, 0.75, 0.40], ...
    'ForegroundColor', buttonFontColor, ...
    'FontWeight', 'bold', ...
    'FontSize', fontSize, ...
    'Callback', @import_csv_callback);

%% === TAB 2: HMD Controls ===
tab2 = uitab(tabGroup, 'Title', 'Compute HMD', 'BackgroundColor', bgColor, 'Units', 'normalized');

% Create panel top right for logo
logoPanel = uipanel(tab2, ...
    'Units', 'normalized', ...
    'Position', [0, 0.87, 0.24, 0.19], ...
    'BackgroundColor', bgColor, ...
    'BorderType', 'none');

% Create axes for logo
logoAxes = axes('Parent', logoPanel, ...
    'Units', 'normalized', ...
    'Position', [0, 0, 1, 1], ...
    'Color', 'none');

% Display logo image with alpha
hImg = image('CData', logoImg, 'Parent', logoAxes);
if exist('alpha', 'var')
    set(hImg, 'AlphaData', alpha);
end

% Fix axes orientation
set(logoAxes, 'YDir', 'normal');
axis(logoAxes, 'image');
axis(logoAxes, 'off');

% Layout constants normalized (based on original pixel values)
leftMargin = 85 / figWidthPx;
yStep = 50 / figHeightPx;
yBase = 660 / figHeightPx;

% Title text
uicontrol(tab2, 'Style', 'text', ...
    'String', 'Compute HARP Hybrid Millidecade Products', ...
    'Units', 'normalized', ...
    'Position', [ (100 + 85) / figWidthPx, 700 / figHeightPx, 500 / figWidthPx, 40 / figHeightPx], ...
    'FontSize', 14, 'FontWeight', 'bold', ...
    'BackgroundColor', bgColor, ...
    'ForegroundColor', textColor, ...
    'HorizontalAlignment', 'center');

function createField(tab, labelStr, defaultVal, ypos, browseCallback, editWidthPx)
    if nargin < 6, editWidthPx = 500; end
    if nargin < 5, browseCallback = []; end

    labelPos = [60 / figWidthPx, ypos, 150 / figWidthPx, 28 / figHeightPx];
    editPos = [(140 + 85) / figWidthPx, ypos, editWidthPx / figWidthPx, 28 / figHeightPx];
    btnPos = [(670 + 85) / figWidthPx, ypos, 90 / figWidthPx, 28 / figHeightPx];

    uicontrol(tab, 'Style', 'text', 'String', labelStr, ...
        'Units', 'normalized', ...
        'Position', labelPos, ...
        'BackgroundColor', bgColor, 'ForegroundColor', textColor, ...
        'HorizontalAlignment', 'left', 'FontWeight', 'bold', ...
        'FontSize', fontSize);

    hEdit = uicontrol(tab, 'Style', 'edit', ...
        'Units', 'normalized', ...
        'Position', editPos, 'HorizontalAlignment', 'left', ...
        'String', defaultVal);

    if ~isempty(browseCallback)
        uicontrol(tab, 'Style', 'pushbutton', 'String', 'Browse', ...
            'Units', 'normalized', ...
            'Position', btnPos, ...
            'BackgroundColor', buttonColor, 'ForegroundColor', buttonFontColor, ...
            'FontWeight', 'bold', ...
            'Callback', @(~,~) browseCallback(hEdit));
    end

    REMORA.mypsd.gui.(matlab.lang.makeValidName(labelStr)) = hEdit;
end

function browse_dir(editHandle)
    path = uigetdir('', 'Select Directory');
    if isequal(path, 0)
        return;
    end
    set(editHandle, 'String', path);
end

function browse_tf_file(editHandle)
    [file, path] = uigetfile('*.tf', 'Select Transfer Function File');
    if isequal(file, 0)
        return;
    end
    set(editHandle, 'String', fullfile(path, file));
end



% Create all fields with labels, default values, and browse buttons where needed
yCurrent = yBase;
createField(tab2, 'Input Directory:', '', yCurrent, @browse_dir);

yCurrent = yCurrent - yStep;

createField(tab2, 'Filename pattern:', '*df20*', yCurrent);

yCurrent = yCurrent - yStep;
createField(tab2, 'Output Directory:', '', yCurrent, @browse_dir);

yCurrent = yCurrent - yStep;
createField(tab2, 'Transfer Function File:', ...
    '', ...
    yCurrent, @browse_tf_file, 500);

yCurrent = yCurrent - yStep;
createField(tab2, 'Organization:', '', yCurrent);

yCurrent = yCurrent - yStep;
createField(tab2, 'Project:', '', yCurrent);

yCurrent = yCurrent - yStep;
createField(tab2, 'Site Name:', '', yCurrent);

yCurrent = yCurrent - yStep;
createField(tab2, 'Site Location:', '[dd.dddd, dd.ddd]', yCurrent);

yCurrent = yCurrent - yStep;
createField(tab2, 'Deployment #:', '', yCurrent);

yCurrent = yCurrent - yStep;
labelWidthPx = 165;
editWidthPx = 100;
fieldHeightPx = 28;
xStart1Px = 60;
xStart2Px = xStart1Px + labelWidthPx + editWidthPx + 60;  % 

% Normalize positions
labelWidth = labelWidthPx / figWidthPx;
editWidth  = editWidthPx / figWidthPx;
fieldHeight = fieldHeightPx / figHeightPx;
xStart1 = xStart1Px / figWidthPx;
xStart2 = xStart2Px / figWidthPx;


% Deployment Start Date
uicontrol(tab2, 'Style', 'text', ...
    'Units', 'normalized', ...
    'String', 'Deployment Start Date:', ...
    'Position', [xStart1, yCurrent, labelWidth, fieldHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', bgColor, ...
    'ForegroundColor', textColor, ...
    'FontWeight', 'bold', 'FontSize', fontSize);

REMORA.mypsd.gui.startDep = uicontrol(tab2, 'Style', 'edit', ...
    'Units', 'normalized', ...
     'HorizontalAlignment','left', ...
    'Position', [xStart1 + labelWidth, yCurrent, editWidth, fieldHeight], ...
    'String', 'YYMMDD');

% Deployment End Date
uicontrol(tab2, 'Style', 'text', ...
    'Units', 'normalized', ...
    'String', 'Deployment End Date:', ...
    'Position', [xStart2, yCurrent, labelWidth, fieldHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', bgColor, ...
    'ForegroundColor', textColor, ...
    'FontWeight', 'bold', 'FontSize', fontSize);

REMORA.mypsd.gui.endDep = uicontrol(tab2, 'Style', 'edit', ...
    'Units', 'normalized', ...
    'HorizontalAlignment','left', ...
    'Position', [xStart2 + labelWidth, yCurrent, editWidth, fieldHeight], ...
    'String', 'YYMMDD');

yCurrent = yCurrent - yStep;  % Move down one more row


% Start Frequency label + edit
uicontrol(tab2, 'Style', 'text', ...
    'Units', 'normalized', ...
    'String', 'Start Frequency (Hz):', ...
    'Position', [xStart1, yCurrent, labelWidth, fieldHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', bgColor, ...
    'ForegroundColor', textColor, ...
    'FontWeight', 'bold', 'FontSize', fontSize);

REMORA.mypsd.gui.startFreq = uicontrol(tab2, 'Style', 'edit', ...
    'Units', 'normalized', ...
    'HorizontalAlignment','left', ...
    'Position', [xStart1 + labelWidth, yCurrent, editWidth, fieldHeight], ...
    'String', '10');

% End Frequency label + edit
uicontrol(tab2, 'Style', 'text', ...
    'Units', 'normalized', ...
    'String', 'End Frequency (Hz):', ...
    'Position', [xStart2, yCurrent, labelWidth, fieldHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', bgColor, ...
    'ForegroundColor', textColor, ...
    'FontWeight', 'bold', 'FontSize', fontSize);

REMORA.mypsd.gui.endFreq = uicontrol(tab2, 'Style', 'edit', ...
    'Units', 'normalized', ...
    'HorizontalAlignment','left', ...
    'Position', [xStart2 + labelWidth, yCurrent, editWidth, fieldHeight], ...
    'String', '1000');


yCurrent = yCurrent - yStep;
createField(tab2, 'Minimum effort for minute bin (%):', '50', yCurrent, [], 90);


% remove FIFO option
REMORA.mypsd.gui.rmvFifoCheckbox = uicontrol(tab2, 'Style', 'checkbox', ...
    'String', 'Remove FIFO', ...
    'Value', 0, ...   % unchecked by default
    'Units', 'normalized', ...
    'Position', [ ...
    xStart2 + labelWidth, ...   % same column as End Frequency edit box
    yCurrent, ...               % same row as minimum effort
    editWidth, ...              % match edit box width
    fieldHeight ], ...
    'BackgroundColor', bgColor, ...
    'ForegroundColor', textColor, ...
    'FontWeight', 'bold', ...
    'FontSize', fontSize, ...
    'Callback', @rmvFifoCallback);

REMORA.mypsd.gui.rmvFifo = 0;   % initialize value

%disp(fieldnames(REMORA.mypsd.gui))

% Compute Button centered at bottom
uicontrol(tab2, 'Style', 'pushbutton', ...
    'String', 'Compute HMD', ...
    'Units', 'normalized', ...
    'Position', [ (300 + 85) / figWidthPx, 20 / figHeightPx, 140 / figWidthPx, 40 / figHeightPx], ...
    'BackgroundColor', [0.40, 0.75, 0.40], ...
    'ForegroundColor', buttonFontColor, ...
    'FontWeight', 'bold', 'FontSize', 11, ...
    'Callback', @mypsd_compute_callback);

end


function import_csv_callback(~, ~)
    global REMORA

    [file, path] = uigetfile('*.xlsx', 'Select Metadata Excel File');
    if isequal(file, 0)
        return; % User canceled
    end

    fullFile = fullfile(path, file);
    try
        data = readtable(fullFile);
    catch ME
        errordlg(['Failed to read file: ', ME.message], 'Import Error');
        return;
    end

    % Loop through table variables and update GUI fields if they match
    fieldNames = data.Properties.VariableNames;

    for i = 1:length(fieldNames)
        fieldName = matlab.lang.makeValidName(fieldNames{i});
        if isfield(REMORA.mypsd.gui, fieldName)
            val = data{1, i};  % Only use the first row
            if iscell(val), val = val{1}; end
            set(REMORA.mypsd.gui.(fieldName), 'String', val);
        end
    end

end
function rmvFifoCallback(src, ~)
    global REMORA
    REMORA.mypsd.gui.rmvFifo = logical(get(src, 'Value'));
end
