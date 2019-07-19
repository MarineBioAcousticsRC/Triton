function dtLTSAShipDetector()
% dtShortTimeDetector()
% Run short time detection.

% default window size too small for this dialog, currently specifying
% position in normalized space but we might want to do it pixels...
handles.ContainingFig = figure('Name', 'Short Time Spectrum Detection', ...
    'Toolbar', 'None', 'Units', 'normalized', 'Position', [.1 .1 .7 .7], ...
    'MenuBar', 'none', 'NumberTitle', 'off');

% If we have an open LTSA, use the input directory to initialize the path
% to the metadata directory, save other directory in case user switches
global PARAMS REMORA
if isempty(PARAMS.ltsa.inpath) || isempty(PARAMS.ltsa.infile)
    BaseDir = pwd;  % No LTSA, use current directory
else
    BaseDir = PARAMS.ltsa.inpath;
end

% Add components of dialog
handles = guComponentLoad(handles.ContainingFig, [], handles, ...
                          'guDetectionParmComponent', 'ltsa');
handles = guComponentLoad(handles.ContainingFig, [], handles, ...
    'guGetDir', BaseDir);
set(handles.guGetDir.directory_panel, 'Title', 'Metadata');
handles = guComponentLoad(handles.ContainingFig, [], handles, ...
    'guFileComponent');
handles = guComponentLoad(handles.ContainingFig, [], handles, ...
    'guGuidedSearchComponent', ...
    {'Long Term Spectral Avg (LTSA) detections'});
handles = guComponentLoad(handles.ContainingFig, [], handles, ...
    'guConfirmComponent');
% Add callback to permit verification when user presses okay
handles = guConfirmComponent('Verify_CallbackFcn', ...
    handles.ContainingFig, [], handles, @ProceedOkay);

handles = guComponentScale(handles.ContainingFig, [], handles);

guidata(handles.ContainingFig, handles);  % Save application data

uiwait(handles.ContainingFig);  % wait for okay/cancel

INITIAL = PARAMS;

if ishandle(handles.ContainingFig)
    handles = guidata(handles.ContainingFig);     % get fresh copy of handles
    % User did not press close box
    if ~ handles.guConfirmComponent.canceled
        [Files, BaseDir] = guFileComponent(...
            'OutputFcn', handles.ContainingFig, [], handles);
%         SearchType = guGuidedSearchComponent(...
%             'OutputFcn', handles.ContainingFig, [], handles);
%         Parameters = guDetectionParmComponent(...
%             'OutputFcn', handles.ContainingFig, [], handles);
%         Ltsahdr = guFileComponent('LTSAHeader', handles.ContainingFig, [], handles);
        MetaDir = guGetDir(...
            'guGetDir_OutputFcn', handles.ContainingFig, [], handles);
        
        delete(handles.ContainingFig);
        [tffile, tfpath] = uigetfile('*.tf','Load Transfer Function File');

        REMORA.ship_dt.ltsa.inpath = PARAMS.ltsa.inpath;
        REMORA.ship_dt.ltsa.infile = PARAMS.ltsa.infile;
        REMORA.ship_dt.settings.tfFullFile = fullfile(tfpath,tffile);
        REMORA.ship_dt.settings.outpath = MetaDir;
        
        fn_getLTSAHeader;

        dtShip_batch;
    else
        delete(handles.ContainingFig);
    end
    
end

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