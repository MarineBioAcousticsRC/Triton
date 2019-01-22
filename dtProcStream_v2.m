function dtProcStream()
% dtProcStream()
% Run short time detection, automatically followed by the Hi Res detector.


%% Short Time Detector Parameters/GUIs
% default window size too small for this dialog, currently specifying
% position in normalized space but we might want to do it pixels...
handles.ContainingFig = figure('Name', 'Short Time Spectrum Detection', ...
    'Toolbar', 'None', 'Units', 'normalized', 'Position', [.1 .1 .7 .7], ...
    'MenuBar', 'none', 'NumberTitle', 'off');

% If we have an open LTSA, use the input directory to initialize the path
% to the metadata directory, save other directory in case user switches
global PARAMS 
if isempty(PARAMS.ltsa.inpath) || isempty(PARAMS.ltsa.infile)
    BaseDir = pwd;  % No LTSA, use current directory
else
    BaseDir = PARAMS.ltsa.inpath;
end

% Add components of dialog
handles = guComponentLoad(handles.ContainingFig, [], handles, ...
    'guDetectionParmComponent', 'short-time-spectrum');
handles = guComponentLoad(handles.ContainingFig, [], handles, ...
    'guGetDir', BaseDir);
set(handles.guGetDir.directory_panel, 'Title', 'Metadata');
handles = guComponentLoad(handles.ContainingFig, [], handles, ...
    'guFileComponent');
handles = guComponentLoad(handles.ContainingFig, [], handles, ...
    'guGuidedSearchComponent', ...
    {'Long Term Spectral Avg (LTSA) detections'});
handles = guComponentLoad(handles.ContainingFig, [], handles, 'guTimeEncoding');
set(handles.guFileComponent.specify_files_dir, 'String', pwd);
handles = guFileComponent('FileChangeCallback', handles, @guParseTimestamps);
% Register callback to change time encodings when user
% changes regexp
handles = guTimeEncoding('RegexpChangeCallback', handles, @guParseTimestamps);
TimeRE = guTimeEncoding('OutputFcn', ...
            handles.guTimeEncoding.timeenc_panel, [], handles);
handles = guComponentLoad(handles.ContainingFig, [], handles, ...
    'guConfirmComponent');
        
% Add callback to permit verification when user presses okay
handles = guConfirmComponent('Verify_CallbackFcn', ...
    handles.ContainingFig, [], handles, @ProceedOkay);

handles = guComponentScale(handles.ContainingFig, [], handles);

guidata(handles.ContainingFig, handles);  % Save application data

uiwait(handles.ContainingFig);  % wait for okay/cancel

if ishandle(handles.ContainingFig)
    handles = guidata(handles.ContainingFig);     % get fresh copy of handles
    % User did not press close box
    if ~ handles.guConfirmComponent.canceled
        [STS_files, BaseDir] = guFileComponent(...
            'OutputFcn', handles.ContainingFig, [], handles);
        SearchType = guGuidedSearchComponent(...
            'OutputFcn', handles.ContainingFig, [], handles);
        Parameters = guDetectionParmComponent(...
            'OutputFcn', handles.ContainingFig, [], handles);
        MetaDir = guGetDir(...
            'guGetDir_OutputFcn', handles.ContainingFig, [], handles);
        
        delete(handles.ContainingFig);
        
        % Might make sense to move the Metadata selection to hear as
        % we already know the BaseDir...
        
        % Get labels associated with files.
        Labels = guNameToPattern(STS_files);
%         if ~ isempty(Labels)
%             dtST_batch(BaseDir, Files, Labels, SearchType, Parameters, ...
%                 'Viewpath', {MetaDir, BaseDir});
%         end
    else
        % if user pressed cancel, abort the whole processing strea,
        delete(handles.ContainingFig);
        return
    end
else
    % return if the window was closed
    return
end 

%% Hi res detector parameters/GUI
HiRes_files = {};
for idx=1:length(STS_files)
    HiRes_files{idx} = fullfile(BaseDir, STS_files{idx});
end

% make sure other figure is gone before loading new one
clear handles;

% default window size too small for this dialog, currently specifying
% position in normalized space but we might want to do it pixels...
handles.ContainingFig = figure( ...
    'Name', 'Short Time Guided High Resolution Click Detection V2', ...
    'Toolbar', 'None', 'Units', 'normalized', 'Position', [.1 .1 .7 .7], ...
    'MenuBar', 'none', 'NumberTitle', 'off');

% Add components of dialog
handles = guComponentLoad(handles.ContainingFig, [], handles, ...
    'guGetDir', BaseDir);
handles = guComponentLoad(handles.ContainingFig, [], handles, ...
    'guFeatureExtractionComponent_v2');
handles = guComponentLoad(handles.ContainingFig, [], handles, ...
    'guConfirmComponent');

handles = guConfirmComponent('Verify_CallbackFcn', ...
    handles.ContainingFig, [], handles, @FeatExtractOkay_v2);
handles = guComponentScale(handles.ContainingFig, [], handles);

guidata(handles.ContainingFig, handles);  % Save application data

uiwait(handles.ContainingFig);  % wait for okay/cancel


if ishandle(handles.ContainingFig)
  handles = guidata(handles.ContainingFig);     % get fresh copy of handles 
  % User did not press close box
  if ~ handles.guConfirmComponent.canceled
    FeatParams = guFeatureExtractionComponent_v2('OutputFcn', handles.ContainingFig, ...
        [], handles);
    % Where will metadata be stored
    metaDir = guGetDir('guGetDir_OutputFcn', handles.ContainingFig, [], handles);

    delete(handles.ContainingFig);
    
    [filetype ext] = ioGetFileType(HiRes_files);

    % Build click label filenames
    if isempty(metaDir)
        labels = cell(size(HiRes_files));
    else
        % Search for labels in the metadir directory
        labels = strrep(HiRes_files, BaseDir, metaDir);
    end
    for idx=1:length(HiRes_files);
        labels{idx} = strrep(labels{idx}, ext{idx}, '.c');
    end


 % Populate optional arguments
    OptArgs = {};
    
    group = false;
%     if isfield(FeatParams, 'maxsep_s')
%       if FeatParams.maxsep_s > 0
%           OptArgs{end+1} = 'MaxSep_s';
%           OptArgs{end+1} = FeatParams.maxsep_s;
%           group = true;
%       end
%     end
%     if isfield(FeatParams, 'maxlen_s')
%         if FeatParams.maxlen_s > 0
%             OptArgs{end+1} = 'MaxClickGroup_s';
%             OptArgs{end+1} = FeatParams.maxlen_s;
%             group = true;
%         end
%     end
%     if group
%         OptArgs{end+1} = 'GroupAnnotExt';
%         OptArgs{end+1} = 'gTg';
%     end

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
%     if isfield(FeatParams, 'Narrowband')
%         OptArgs{end+1} = 'FilterNarrowband';
%         OptArgs{end+1} = FeatParams.Narrowband;
%     end
     
    if isfield(FeatParams, 'SpecAnalyRng')
        OptArgs{end+1} = 'LowFreq';
        OptArgs{end+1} = FeatParams.SpecAnalyRng(1)*1000;  % kHz -> Hz
        OptArgs{end+1} = 'HighFreq';
        OptArgs{end+1} = FeatParams.SpecAnalyRng(2)*1000;
    end
    if isfield(FeatParams, 'PeakRange')
        OptArgs{end+1} = 'LowPeakLimitHz';
        OptArgs{end+1} = FeatParams.PeakRange(1)*1000; % kHz -> Hz
        OptArgs{end+1} = 'HighPeakLimitHz';
        OptArgs{end+1} = FeatParams.PeakRange(2)*1000; % kHz -> Hz
    end
	
    1;
    
    if isfield(FeatParams, 'Saturation')
        OptArgs{end+1} = 'MinSaturationPerc';
        OptArgs{end+1} = FeatParams.Saturation(1); % kHz -> Hz
        OptArgs{end+1} = 'MaxSaturationPerc';
        OptArgs{end+1} = FeatParams.Saturation(2); % kHz -> Hz
        OptArgs{end+1} = 'ClickThreshold';
        OptArgs{end+1} = FeatParams.Saturation(3); % kHz -> Hz
    end
	
    if isfield(FeatParams, 'Saturation')
		if FeatParams.EchoSounder
			OptArgs{end+1} = 'PingAnnotExt';
			OptArgs{end+1} = 'ech';
		end
    end
    
    debug = false;
    if debug
      OptArgs{end+1} = 'Plot';
      OptArgs{end+1} = 2;       % 1 clicks only, 2 clicks+Teager
    end

    FeatureType = FeatParams.FeatureType;
    1;        
  else
      % if user pressed cancel, return
    delete(handles.ContainingFig);
    return
  end
else
  % if user closed the figure, return
  return
end

% once we have everything we need, perform STS followed by Hi res
if ~ isempty(Labels)
    % STS
    dtST_batch(BaseDir, STS_files, Labels, SearchType, Parameters, ...
        'Viewpath', {MetaDir, BaseDir});
end
1;
% % Hi res
%    dtHighResClickBatch(HiRes_files, labels, ...
%                     'DateRegexp', TimeRE, ...
%                     'FeatureExt', FeatureType, ...
%                     'FeatureId', FeatParams.FeatureID, ...
%                     'ClickAnnotExt', 'cTg', ...
%                     'Viewpath', {metaDir, BaseDir}, ...
%                     OptArgs{:});
    dtShortHighRes(HiRes_files, ...
                        'DateRegexp', TimeRE, ...
                        'FeatureExt', FeatureType, ...
                        'ClickAnnotExt', 'cTg', ...
                        'Viewpath', {metaDir, BaseDir}, ...
                        OptArgs{:});
            
% Add callback to check for errors when user presses okay
function result = ProceedOkay(hObject, eventdata, handles)
% result = ProceedOkay(hObject, eventdata, handles)
% Check if all components are populated properly for detection to proceed

Problems = '';
Files = guFileComponent('OutputFcn', handles.ContainingFig, [], handles);
if isempty(Files)
  Problems = 'No files. ';
end

if isempty(Problems)
    result = '';
else
    result = sprintf('Error(s):  %s', Problems);
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

function result = FeatExtractOkay_v2(hObject, eventdata, handles)
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
errors = verify_low_high(handles.guFeatureExtractionComponent_v2.PeakLow, ...
    handles.guFeatureExtractionComponent_v2.PeakHigh, ...
    'Peak frequency', errors); 
errors = verify_low_high(handles.guFeatureExtractionComponent_v2.HPTranLow, ...
    handles.guFeatureExtractionComponent_v2.HPTranHigh, ...
    'Highpass transition band', errors)

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
    

