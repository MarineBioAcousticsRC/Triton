function dtLongTimeDetector
% dtLongTimeDetector
% Perform long term spectral average detections

% Make default figure N% larger for nice layouts on small screens
Position = get(0, 'defaultFigurePosition');
Position(4) = round(Position(4).*1.2);

handles.ContainingFig = figure('Name', 'Long Term Spectral Average Detection', ...
                               'Toolbar', 'None', 'MenuBar', 'none', ...
                               'NumberTitle', 'off', 'Position', Position);

% Add components of dialog
handles = guComponentLoad(handles.ContainingFig, [], handles, ...
                          'guDetectionParmComponent', 'ltsa');
handles = guComponentLoad(handles.ContainingFig, [], handles, ...
    'guFileComponent');
% Turn off selection of non LTSA files
guFileComponent('SpecifyFilesVisibility', ...
                handles.ContainingFig, [], handles, false);
handles = guComponentLoad(handles.ContainingFig, [], handles, ...
    'guConfirmComponent');
handles = guComponentScale(handles.ContainingFig, [], handles);
handles = guConfirmComponent('Verify_CallbackFcn', ...
    handles.ContainingFig, [], handles, @ProceedOkay);
guidata(handles.ContainingFig, handles);  % Save application data

uiwait(handles.ContainingFig);  % wait for okay/cancel


if ishandle(handles.ContainingFig)
  handles = guidata(handles.ContainingFig);     % get fresh copy of handles 
  % User did not press close box
  if ~ handles.guConfirmComponent.canceled
    % Retrieve user specified parameters
    Files = guFileComponent('OutputFcn', handles.ContainingFig, [], handles);
    Parameters = guDetectionParmComponent('OutputFcn', handles.ContainingFig, ...
                                          [], handles);
    ltsahdr = guFileComponent('LTSAHeader', handles.ContainingFig, [], handles);
    delete(handles.ContainingFig);
    
    dtLTSA_batch(ltsahdr, Parameters, Files);
  else
    delete(handles.ContainingFig);
  end
end



% ----------------------------------------------------------------------
% Add callback to check for errors when user presses okay
function result = ProceedOkay(hObject, eventdata, handles)
% result = ProceedOkay(hObject, eventdata, handles)
% Check if all components are populated properly for detection to proceed

Problems = '';
Files = guFileComponent('OutputFcn', handles.ContainingFig, [], handles);
if isempty(Files)
  Problems = sprintf('%sNo files. ', Problems);
end
Parameters = guDetectionParmComponent('OutputFcn', handles.ContainingFig, ...
                                      [], handles);
if isempty(Parameters)
  Problems = sprintf('%sNo detection parameters. ', Problems);
end


if isempty(Problems)
    result = '';
else
    result = sprintf('Error(s):  %s', Problems);
end
