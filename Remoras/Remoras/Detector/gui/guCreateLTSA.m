function ltsainfo = guCreateLTSA()
% ltsainfo = guCreateLTSA
% Prompt user for information necessary to create an LTSA file.
% Returns an ltsainfo structure with information necessary to
% create an LTSA.

global PARAMS

handles.ContainingFig = figure(...
    'Name', 'Long Term Spectral Average', 'Toolbar', 'None', ...
    'MenuBar', 'none', 'NumberTitle', 'off', ...
    'Units', 'normalized', 'Position', [.1 .1 .7 .7]);


% Add components of dialog

% File selection
handles = guComponentLoad(handles.ContainingFig, [], handles, ...
    'guFileComponent');
% Register callback to extract timestamps from file list
handles = guComponentLoad(handles.ContainingFig, [], handles, 'guTimeEncoding');
set(handles.guFileComponent.specify_files_dir, 'String', pwd);
handles = guFileComponent('FileChangeCallback', handles, @guParseTimestamps);
% Register callback to change time encodings when user
% changes regexp
handles = guTimeEncoding('RegexpChangeCallback', handles, @guParseTimestamps);
% disable specify by LTSA
guFileComponent('force_specify_files_only', handles);
handles = guComponentLoad(handles.ContainingFig, [], handles, ...
                          'guLTSAParams');
handles = guComponentLoad(handles.ContainingFig, [], handles, ...
    'guConfirmComponent');
% add callback to check if parameters okay
handles = guConfirmComponent('Verify_CallbackFcn', handles.ContainingFig, [], ...
                   handles, @ProceedOkay);

handles = guComponentScale(handles.ContainingFig, [], handles);
guidata(handles.ContainingFig, handles) % Save data
uiwait(handles.ContainingFig);  % wait for okay/cancel

if ishandle(handles.ContainingFig)
  % User did not press close box
  handles = guidata(handles.ContainingFig);     % get fresh copy of handles 
  if ~ handles.guConfirmComponent.canceled
    % User pressed okay, set up LTSA
    [Files, BaseDir, SelectedFilesIdx] = ...
        guFileComponent('OutputFcn', handles.ContainingFig, [], handles);
    [ftype, datatype, interval_s, bin_width_Hz] = ...
        guLTSAParams('OutputFcn', handles.ContainingFig, [], handles);

    
    if isfield(PARAMS, 'ltsa')  % Default fields from current LTSA
      ltsainfo = init_ltsaparams(PARAMS);
    else
      ltsainfo = init_ltsaparams();
    end
    ltsainfo.ltsa.fname = Files;
    ltsainfo.ltsa.indir = BaseDir;
    dates = get(handles.guTimeEncoding.re, 'UserData');
    ltsainfo.ltsahd.dnumStart = dates(SelectedFilesIdx);
    ltsainfo.ltsa.dtype = datatype;
    ltsainfo.ltsa.ftype = ftype;
    ltsainfo.ltsa.fnameTimeRegExp{1} = ...
        guTimeEncoding('OutputFcn', handles.guTimeEncoding.timeenc_panel, ...
                       [], handles);
    delete(handles.ContainingFig);  % No longer need dialog
    mk_ltsa(ltsainfo);  % create it
  else
    delete(handles.ContainingFig);  % Remove dialog
  end
end


function result = ProceedOkay(hObject, eventdata, handles)
% result = ProceedOkay(hObject, eventdata, handles)
% Check if all components are populated properly for detection to proceed

Problems = '';
[Files, BaseDir, Selected] = guFileComponent('OutputFcn', ...
    handles.ContainingFig, [], handles);
if isempty(Files)
  Problems = 'No files. ';
else
    % Check if files of right type
    FileTypes = ioGetFileType(Files);
    [ftype, datatype, interval_s, bin_width_Hz] = ...
        guLTSAParams('OutputFcn', handles.ContainingFig, [], handles);
    Bad = sum(FileTypes ~= ftype);
    if Bad
      Problems = 'Bad audio format. ';
    end
    
    % Check for files that are too long
    ver = ioVersionInfoLTSA;  % get most recent version header info
    filelen = zeros(size(Selected));  % compute file lengths
    for i=1:length(Files)
        filelen(i) = length(Files{i});
    end
    TooLong = find(filelen > ver.fnamelen);
    if ~ isempty(TooLong)
        % unselect files that are too long 
        Problems = [sprintf('%sName > %d characters, unselected ', ...
            Problems, ver.fnamelen), sprintf('%d ', Selected(TooLong))];
        Selected(TooLong) = [];
        set(handles.(mfilename).filelist, 'Value', Selected);
    end
end
if isempty(Problems)
    result = '';
else
    result = sprintf('Error(s):  %s', Problems);
end

