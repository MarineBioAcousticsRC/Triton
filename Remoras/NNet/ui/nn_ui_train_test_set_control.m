function nn_ui_train_test_set_control(hObject,eventdata,myEvent)

global REMORA

if strcmp(myEvent, 'setBinLevel')
    REMORA.nn.train_test_set.binTF = ...
        get(REMORA.fig.nn.nn_train_test_set.binCheckTxt,'Value');
    
elseif strcmp(myEvent, 'setClickLevel')
    REMORA.nn.train_test_set.clickTF = ...
        get(REMORA.fig.nn.nn_train_test_set.clickCheckTxt,'Value');
    
elseif strcmp(myEvent, 'setInDir')
    REMORA.nn.train_test_set.inDir = ...
        get(REMORA.fig.nn.nn_train_test_set.inDirEdTxt,'String');
    
elseif strcmp(myEvent, 'setSaveDir')
    REMORA.nn.train_test_set.outDir = ...
        get(REMORA.fig.nn.nn_train_test_set.saveDirEdTxt,'String');
    
elseif strcmp(myEvent, 'setSaveName')
    REMORA.nn.train_test_set.saveName = ...
        get(REMORA.fig.nn.nn_train_test_set.saveNameEdTxt,'String');
    
elseif strcmp(myEvent, 'setTrainPerc')
    REMORA.fig.nn.nn_train_test_set.trainPercent = ...
        str2num(get(REMORA.fig.nn.nn_train_test_set.trainPercEdTxt,'String'));
    
    if REMORA.fig.nn.nn_train_test_set.trainPercent>1
        % make it a fraction if needed.
        REMORA.fig.nn.nn_train_test_set.trainPercent = ...
            REMORA.fig.nn.nn_train_test_set.trainPercent/100;
    end
elseif strcmp(myEvent, 'setTrainSize')
    REMORA.fig.nn.nn_train_test_set.nExamples = ...
        str2num(get(REMORA.fig.nn.nn_train_test_set.trainSizeEdTxt,'String'));
    
elseif strcmp(myEvent, 'setBoutGap')
    REMORA.fig.nn.nn_train_test_set.boutGap = ...
        str2num(get(REMORA.fig.nn.nn_train_test_set.boutGapEdTxt,'String'));
    
elseif strcmp(myEvent, 'Run')
    if REMORA.nn.train_test_set.binTF
        REMORA.nn.train_train_set.savedTrainFile_bin = [];
        REMORA.nn.train_test_set.savedTrainFile_bin = [];
        
        [REMORA.nn.train_test_set.savedTrainFile_bin,...
            REMORA.nn.train_test_set.savedTestFile_bin] = nn_fn_balanced_input_bin(...
            REMORA.nn.train_test_set.inDir,...
            REMORA.nn.train_test_set.saveDir,...
            REMORA.nn.train_test_set.saveName,...
            REMORA.nn.train_test_set.trainPercent,...
            REMORA.nn.train_test_set.nExamples,...
            REMORA.nn.train_test_set.boutGap);
        fprintf('Bin-level training and test sets saved to: \n')
        fprintf('% s\n',REMORA.nn.train_test_set.saveDir)
    end
    
    if REMORA.nn.train_test_set.clickTF
        REMORA.nn.train_train_set.savedTrainFile_det = [];
        REMORA.nn.train_test_set.savedTrainFile_det = [];
        
        [REMORA.nn.train_test_set.savedTrainFile_det,...
            REMORA.nn.train_test_set.savedTestFile_det] = nn_fn_balanced_input(...
            REMORA.nn.train_test_set.inDir,...
            REMORA.nn.train_test_set.saveDir,...
            REMORA.nn.train_test_set.saveName,...
            REMORA.nn.train_test_set.trainPercent,...
            REMORA.nn.train_test_set.nExamples,...
            REMORA.nn.train_test_set.boutGap);
        fprintf('Detection-level training and test sets saved to: \n')
        fprintf('% s\n',REMORA.nn.train_test_set.saveDir);
    end
    
else
    error('Unrecognized callback')
end

