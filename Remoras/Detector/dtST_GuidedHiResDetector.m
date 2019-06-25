function dtST_GuidedHiResDetector()
% dtST_GuidedHiResDetector()
% Run short time guided high resolution click detection.

global PARAMS

1;


[BaseDir, Files, TimeRE] = getFiles;
if isempty(Files)
  return
else
  % Convert into full path (will want to do something else later on
  % so that we don't have hardcoded paths)
  for idx=1:length(Files)
    Files{idx} = fullfile(BaseDir, Files{idx});
  end
end

% default window size too small for this dialog, currently specifying
% position in normalized space but we might want to do it pixels...
handles.ContainingFig = figure( ...
    'Name', 'Short Time Guided High Resolution Click Detection', ...
    'Toolbar', 'None', 'Units', 'normalized', 'Position', [.1 .1 .7 .7], ...
    'MenuBar', 'none', 'NumberTitle', 'off');

% Add components of dialog
handles = guComponentLoad(handles.ContainingFig, [], handles, ...
    'guGetDir', BaseDir);
handles = guComponentLoad(handles.ContainingFig, [], handles, ...
    'guFeatureExtractionComponent');
handles = guComponentLoad(handles.ContainingFig, [], handles, ...
    'guConfirmComponent');

handles = guConfirmComponent('Verify_CallbackFcn', ...
    handles.ContainingFig, [], handles, @FeatExtractOkay);
handles = guComponentScale(handles.ContainingFig, [], handles);

guidata(handles.ContainingFig, handles);  % Save application data

uiwait(handles.ContainingFig);  % wait for okay/cancel

if ishandle(handles.ContainingFig)
  handles = guidata(handles.ContainingFig);     % get fresh copy of handles 
  % User did not press close box
  if ~ handles.guConfirmComponent.canceled
    FeatParams = guFeatureExtractionComponent('OutputFcn', handles.ContainingFig, ...
        [], handles);
    % Where will metadata be stored
    metaDir = guGetDir('guGetDir_OutputFcn', handles.ContainingFig, [], handles);

    delete(handles.ContainingFig);
    
    [filetype ext] = ioGetFileType(Files);

    % Build click label filenames
    if isempty(metaDir)
        labels = cell(size(Files));
    else
        % Search for labels in the metadir directory
        labels = strrep(Files, BaseDir, metaDir);
    end
    for idx=1:length(Files);
        labels{idx} = strrep(labels{idx}, ext{idx}, '.c');
    end

    % Populate optional arguments
    OptArgs = {};
    
    group = false;
    if isfield(FeatParams, 'maxsep_s')
      if FeatParams.maxsep_s > 0
          OptArgs{end+1} = 'MaxSep_s';
          OptArgs{end+1} = FeatParams.maxsep_s;
          group = true;
      end
    end
    if isfield(FeatParams, 'maxlen_s')
        if FeatParams.maxlen_s > 0
            OptArgs{end+1} = 'MaxClickGroup_s';
            OptArgs{end+1} = FeatParams.maxlen_s;
            group = true;
        end
    end
    if group
        OptArgs{end+1} = 'GroupAnnotExt';
        OptArgs{end+1} = 'gTg';
    end

    if isfield(FeatParams, 'meanssub')
      OptArgs{end+1} = 'MeansSub';
      OptArgs{end+1} = FeatParams.meanssub;
    end
    
    group = false;
    if isfield(FeatParams, 'FrameLength_us')
      OptArgs{end+1} = 'FrameLength_us';
      OptArgs{end+1} = FeatParams.FrameLength_us;
    end
    if isfield(FeatParams, 'FrameAdvance_us')
      OptArgs{end+1} = 'FrameAdvance_us';
      OptArgs{end+1} = FeatParams.FrameAdvance_us;
    end

    if isfield(FeatParams, 'MaxFramesPerClick')
        OptArgs{end+1} = 'MaxFramesPerClick';
        OptArgs{end+1} = FeatParams.MaxFramesPerClick;
    end
    if isfield(FeatParams, 'Narrowband')
        OptArgs{end+1} = 'FilterNarrowband';
        OptArgs{end+1} = FeatParams.Narrowband;
    end
     
%     if isfield(FeatParams, 'SpecAnalyRng')
%         OptArgs{end+1} = 'LowFreq';
%         OptArgs{end+1} = FeatParams.SpecAnalyRng(1)*1000;  % kHz -> Hz
%         OptArgs{end+1} = 'HighFreq';
%         OptArgs{end+1} = FeatParams.SpecAnalyRng(2)*1000;
%     end
    if isfield(FeatParams, 'PeakRange')
        OptArgs{end+1} = 'PeakFreqLim';
        OptArgs{end+1} = FeatParams.PeakRange*1000; % kHz -> Hz
    end
	
%     if isfield(FeatParams, 'Saturation')
%         OptArgs{end+1} = 'MinSaturationPerc';
%         OptArgs{end+1} = FeatParams.Saturation(1); % kHz -> Hz
%         OptArgs{end+1} = 'MaxSaturationPerc';
%         OptArgs{end+1} = FeatParams.Saturation(2); % kHz -> Hz
%         OptArgs{end+1} = 'ClickThreshold';
%         OptArgs{end+1} = FeatParams.Saturation(3); % kHz -> Hz
%     end
	
%     if isfield(FeatParams, 'Saturation')
% 		if FeatParams.EchoSounder
% 			OptArgs{end+1} = 'PingAnnotExt';
% 			OptArgs{end+1} = 'ech';
% 		end
%     end
    
    debug = false;
    if debug
      OptArgs{end+1} = 'Plot';
      OptArgs{end+1} = 2;       % 1 clicks only, 2 clicks+Teager
    end

    FeatureType = FeatParams.FeatureType;
    dtHighResClickBatch(Files, labels, ...
                        'DateRegexp', TimeRE, ...
                        'FeatureExt', FeatureType, ...
                        'FeatureId', FeatParams.FeatureID, ...
                        'ClickAnnotExt', 'cTg', ...
                        'Viewpath', {metaDir, BaseDir}, ...
                        OptArgs{:});
            
  else
    delete(handles.ContainingFig);
  end
  
end

% ----------------------------------------------------------------------
function [BaseDir, Files, TimeRE] = getFiles

handles.ContainingFig = figure( ...
    'Name', 'Short Time Guided High Resolution Click Detection', ...
    'Toolbar', 'None', 'Units', 'normalized', 'MenuBar', 'None', ...
    'NumberTitle', 'off');
handles = guComponentLoad(handles.ContainingFig, [], handles, ...
    'guFileComponent');
%  TODO fill in 'use files in long term spectral avg' and 'active' vs 'load'
% field here

% Register callback to extract timestamps from file list
handles = guComponentLoad(handles.ContainingFig, [], handles, 'guTimeEncoding');
set(handles.guFileComponent.specify_files_dir, 'String', pwd);
handles = guFileComponent('FileChangeCallback', handles, @guParseTimestamps);
% Register callback to change time encodings when user
% changes regexp
handles = guTimeEncoding('RegexpChangeCallback', handles, @guParseTimestamps);
handles = guComponentLoad(handles.ContainingFig, [], handles, ...
    'guConfirmComponent');
handles = guComponentScale(handles.ContainingFig, [], handles);
handles = guConfirmComponent('Verify_CallbackFcn', ...
    handles.ContainingFig, [], handles, @FilesOkay);

guidata(handles.ContainingFig, handles);  % Save application data
uiwait(handles.ContainingFig);  % wait for okay/cancel

BaseDir = [];
Files = [];
TimeRE = [];
if ishandle(handles.ContainingFig)
  handles = guidata(handles.ContainingFig);     % get fresh copy of handles 
  % User did not press close box
  if ~ handles.guConfirmComponent.canceled
    [Files, BaseDir] = guFileComponent('OutputFcn', ...
            handles.ContainingFig, [], handles);
    TimeRE = guTimeEncoding('OutputFcn', ...
            handles.guTimeEncoding.timeenc_panel, [], handles);
  end
  delete(handles.ContainingFig);
end


% ----------------------------------------------------------------------
% callbacks to check for errors when user presses okay

function result = FilesOkay(hObject, eventdata, handles)
% result = FilesOkay(hObject, eventdata, handles)
% Check if user has specified files.
[Files, BaseDir] = guFileComponent('OutputFcn', ...
    handles.ContainingFig, [], handles);
if isempty(Files)
    result = 'Specify files';
else
    result = [];
end

function result = FeatExtractOkay(hObject, eventdata, handles)
% result = ProceedOkay(hObject, eventdata, handles)
% Check if all components are populated properly for detection to proceed

errors = {};

% Verify that either the specified output directory or its parent is
% a directory
resultDir = guGetDir('guGetDir_OutputFcn', handles.ContainingFig, [], handles);
if ~ exist(resultDir, 'dir')
    % check parent
    [parent, child, ext] = fileparts(resultDir);
    if ~ exist(parent, 'dir')
        errors{end+1} = sprintf('output: %s or parent must exist', resultDir);
    end
end

% Verify that peak frequency ranges are in correct order
errors = verify_low_high(handles.guFeatureExtractionComponent.PeakLow, ...
    handles.guFeatureExtractionComponent.PeakHigh, ...
    'Peak frequency', errors); 
errors = verify_low_high(handles.guFeatureExtractionComponent.HPTranLow, ...
    handles.guFeatureExtractionComponent.HPTranHigh, ...
    'Highpass transition band', errors);

if length(errors)
    errstr = errors{1};
    if length(errors) > 1
        errstr = [errstr, sprintf(', %s', errors{2:end})];
    end
    result = sprintf('Specify valid %s', errstr);
else
    result = '';
end

function errors = verify_low_high(lowH, highH, rngtype, errors)
% errors = verify_low_high(lowH, highH, rngtype, errors)
% Given handles to text edit boxes representing the low and high
% end of a range, verify that the boxes are numeric and contain
% a non-zero range.

low = str2double(get(lowH, 'String'));
high = str2double(get(highH, 'String'));

if isempty(low)
    errors{end+1} = sprintf('%s: Bad low frequency', rngtype);
end
if isempty(high)
    errors{end+1} = sprintf('%s: Bad high frequency', rngtype);
elseif ~ isempty(low) && low >= high
        errors{end+1} = srpintf('%s: low >= high', rngtype);
end

