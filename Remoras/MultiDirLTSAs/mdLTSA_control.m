function mdLTSA_control(action,mySource)

global REMORA HANDLES

if ~exist('mySource','var')
    mySource = 'null';
end

if strcmp(action, '')
    % Note: could make this have an option to just refresh everything by making
    % these all into if rather than elseif
    
elseif strcmp(action,'setInDir')
    inDir = get(REMORA.mdLTSA_verify.inDirEdTxt, 'string');
    REMORA.mdLTSA.settings.inDir = inDir;
    
elseif strcmp(action, 'browseInDir')
    dir = uigetdir();
    if ~ isnumeric(dir)
        % user selected something
        REMORA.mdLTSA.settings.inDir = dir;
    end
    
    
    % 
% %%
% % --- Executes on button press in browse.
% function browse_Callback(hObject, eventdata, handles)
% % hObject    handle to browse (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% dir = uigetdir();
% if ~ isnumeric(dir)
%     % User selected something
%     set(handles.(mfilename).Directory, 'String', dir);
% end
% 

% elseif strcmp(action,'setOutDir')
%     outDir = get(REMORA.bm_verify.outDirEdTxt, 'string');
%     REMORA.bm.settings.outDir = outDir;
%       
% elseif strcmp(action,'setRegDate')
%     regdate = get(REMORA.bm_verify.regdateEdTxt, 'string');
%     REMORA.bm.settings.regdate = regdate;
%     
% elseif strcmp(action,'setThresh')
%     ThreshEdText = str2double(get(REMORA.bm_verify.ThreshEdText, 'string'));
%     REMORA.bm.settings.thresh = ThreshEdText;
%     
% elseif strcmp(action, 'setStartF1')
%     startF1EdText = str2double(get(REMORA.bm_verify.StartF1EdText, 'string'));
%     REMORA.bm.settings.startF(1,1) = startF1EdText;
%     
% elseif strcmp(action, 'setStartF2')
%     startF2EdText = str2double(get(REMORA.bm_verify.StartF2EdText, 'string'));
%     REMORA.bm.settings.startF(1,2) = startF2EdText;
% 
% elseif strcmp(action, 'setStartF3')
%     startF3EdText = str2double(get(REMORA.bm_verify.StartF3EdText, 'string'));
%     REMORA.bm.settings.startF(1,3) = startF3EdText;
% 
% elseif strcmp(action, 'setStartF4')
%     startF4EdText = str2double(get(REMORA.bm_verify.StartF4EdText, 'string'));
%     REMORA.bm.settings.startF(1,4) = startF4EdText;
% 
% elseif strcmp(action, 'setEndF1')
%     endF1EdText = str2double(get(REMORA.bm_verify.EndF1EdText, 'string'));
%     REMORA.bm.settings.endF(1,1) = endF1EdText;
%     
% elseif strcmp(action, 'setEndF2')
%     endF2EdText = str2double(get(REMORA.bm_verify.EndF2EdText, 'string'));
%     REMORA.bm.settings.endF(1,2) = endF2EdText;
% 
% elseif strcmp(action, 'setEndF3')
%     endF3EdText = str2double(get(REMORA.bm_verify.EndF3EdText, 'string'));
%     REMORA.bm.settings.endF(1,3) = endF3EdText;
% 
% elseif strcmp(action, 'setEndF4')
%     endF4EdText = str2double(get(REMORA.bm_verify.EndF4EdText, 'string'));
%     REMORA.bm.settings.endF(1,4) = endF4EdText;
% 
% elseif strcmp(action,'setSpecies')
%     species.val = get(REMORA.bm_verify.SpeciesChoice, 'Value');
%     species.opt = get(REMORA.bm_verify.SpeciesChoice,'string');
%     SpeciesChoice = species.opt{species.val};
%     REMORA.bm.settings.species = SpeciesChoice;
%     
%     
% elseif strcmp(action,'setSoundTrapdata')
%     SoundTrapdataCheckbox = get(REMORA.bm_verify.SoundTrapdataCheckbox, 'string');
%     REMORA.bm.settings.SoundTrap = SoundTrapdataCheckbox;
%     
% elseif strcmp(action,'setCsvFile')
%     csvCheckbox = get(REMORA.bm_verify.csvCheckbox, 'string');
%     REMORA.bm.settings.saveCsv = csvCheckbox;
    
elseif strcmp(action,'setXWAVdata')
    XWAVdataCheckbox = get(REMORA.mdLTSA_verify.XWAVdataCheckbox, 'string');
    REMORA.mdLTSA.settings.XWAVdata = XWAVdataCheckbox;

elseif strcmp(action,'setWAVdata')
    WAVdataCheckbox = get(REMORA.mdLTSA_verify.WAVdataCheckbox, 'string');
    REMORA.mdLTSA.settings.WAVdata = wAVdataCheckbox;

elseif strcmp(action,'RunBatchLTSA')
    close(REMORA.fig.mdLTSA.batch)
    mdLTSA_init_batch_detector;
end


