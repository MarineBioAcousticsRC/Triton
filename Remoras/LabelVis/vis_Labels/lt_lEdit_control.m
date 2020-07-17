function lt_lEdit_control(action)

global REMORA

if strcmp(action,'markFalse')
    check = get(REMORA.lt.lEdit_verify.falseCheck,'Value');
    if check
        lt_lEdit_mod_chLabels('false')
    end
elseif strcmp(action, 'mark1')
    check = get(REMORA.lt.lEdit_verify.oneCheck,'Value');
    if check
        lt_lEdit_mod_chLabels('one')
    end
elseif strcmp(action, 'mark2')
    check = get(REMORA.lt.lEdit_verify.twoCheck,'Value');
    if check
        lt_lEdit_mod_chLabels('two')
    end
elseif strcmp(action, 'mark3')
    check = get(REMORA.lt.lEdit_verify.threeCheck,'Value');
    if check
        lt_lEdit_mod_chLabels('three')
    end
elseif strcmp(action, 'mark4')
    check = get(REMORA.lt.lEdit_verify.fourCheck,'Value');
    if check
        lt_lEdit_mod_chLabels('four')
    end
elseif strcmp(action, 'mark5')
    check = get(REMORA.lt.lEdit_verify.fiveCheck,'Value');
    if check
        lt_lEdit_mod_chLabels('five')
    end
elseif strcmp(action, 'mark6')
    check = get(REMORA.lt.lEdit_verify.sixCheck,'Value');
    if check
        lt_lEdit_mod_chLabels('six')
    end
elseif strcmp(action, 'mark7')
    check = get(REMORA.lt.lEdit_verify.sevCheck,'Value');
    if check
        lt_lEdit_mod_chLabels('sev')
    end
elseif strcmp(action, 'mark8')
    check = get(REMORA.lt.lEdit_verify.eightCheck,'Value');
    if check
        lt_lEdit_mod_chLabels('eight')
    end
    
elseif strcmp(action,'Save')
    
    REMORA.lt.lEdit.outDir = uigetdir('','Select directory where you want to save ID files');
    
    if ~isempty(REMORA.lt.lEdit.detection)
        modLab = char(extractBefore(REMORA.lt.lVis_det.detection.files,'.tlab'));
        saveTxt = [REMORA.lt.lEdit.outDir,'\',modLab,'_modID.mat'];
        detTimes = REMORA.lt.lEdit.detection;
        labels = REMORA.lt.lEdit.detectionLab;
        save(saveTxt,'detTimes','labels')
        dispTxt = ['new IDs from label ',modLab,' saved!'];
        disp(dispTxt)
    end
    if ~isempty(REMORA.lt.lEdit.detection2)
        modLab = char(extractBefore(REMORA.lt.lVis_det.detection2.files,'.tlab'));
        saveTxt = [REMORA.lt.lEdit.outDir,'\',modLab,'_modID.mat'];
        detTimes = REMORA.lt.lEdit.detection2;
        labels = REMORA.lt.lEdit.detection2Lab;
        save(saveTxt,'detTimes','labels')
        dispTxt = ['new IDs from label ',modLab,' saved!'];
        disp(dispTxt)
    end
    if ~isempty(REMORA.lt.lEdit.detection3)
        modLab = char(extractBefore(REMORA.lt.lVis_det.detection3.files,'.tlab'));
        saveTxt = [REMORA.lt.lEdit.outDir,'\',modLab,'_modID.mat'];
        detTimes = REMORA.lt.lEdit.detection3;
        labels = REMORA.lt.lEdit.detection3Lab;
        save(saveTxt,'detTimes','labels')
        dispTxt = ['new IDs from label ',modLab,' saved!'];
        disp(dispTxt)
    end
    if ~isempty(REMORA.lt.lEdit.detection4)
        modLab = char(extractBefore(REMORA.lt.lVis_det.detection4.files,'.tlab'));
        saveTxt = [REMORA.lt.lEdit.outDir,'\',modLab,'_modID.mat'];
        detTimes = REMORA.lt.lEdit.detection4;
        labels = REMORA.lt.lEdit.detection4Lab;
        save(saveTxt,'detTimes','labels')
        dispTxt = ['new IDs from label ',modLab,' saved!'];
        disp(dispTxt)
    end
    if ~isempty(REMORA.lt.lEdit.detection5)
        modLab = char(extractBefore(REMORA.lt.lVis_det.detection5.files,'.tlab'));
        saveTxt = [REMORA.lt.lEdit.outDir,'\',modLab,'_modID.mat'];
        detTimes = REMORA.lt.lEdit.detection5;
        labels = REMORA.lt.lEdit.detection5Lab;
        save(saveTxt,'detTimes','labels')
        dispTxt = ['new IDs from label ',modLab,' saved!'];
        disp(dispTxt)
    end
    if ~isempty(REMORA.lt.lEdit.detection6)
        modLab = char(extractBefore(REMORA.lt.lVis_det.detection6.files,'.tlab'));
        saveTxt = [REMORA.lt.lEdit.outDir,'\',modLab,'_modID.mat'];
        detTimes = REMORA.lt.lEdit.detection6;
        labels = REMORA.lt.lEdit.detection6Lab;
        save(saveTxt,'detTimes','labels')
        dispTxt = ['new IDs from label ',modLab,' saved!'];
        disp(dispTxt)
    end
    if ~isempty(REMORA.lt.lEdit.detection7)
        modLab = char(extractBefore(REMORA.lt.lVis_det.detection7.files,'.tlab'));
        saveTxt = [REMORA.lt.lEdit.outDir,'\',modLab,'_modID.mat'];
        detTimes = REMORA.lt.lEdit.detection7;
        labels = REMORA.lt.lEdit.detection7Lab;
        save(saveTxt,'detTimes','labels')
        dispTxt = ['new IDs from label ',modLab,' saved!'];
        disp(dispTxt)
    end
    if ~isempty(REMORA.lt.lEdit.detection8)
        modLab = char(extractBefore(REMORA.lt.lVis_det.detection8.files,'.tlab'));
        saveTxt = [REMORA.lt.lEdit.outDir,'\',modLab,'_modID.mat'];
        detTimes = REMORA.lt.lEdit.detection8;
        labels = REMORA.lt.lEdit.detection8Lab;
        save(saveTxt,'detTimes','labels')
        dispTxt = ['new IDs from label ',modLab,' saved!'];
        disp(dispTxt)
    end
end