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
    
elseif strcmp(action,'Save')
    
    REMORA.lt.lEdit.outDir = uigetdir('','Select directory where you want to save ID files');
    
    if isfield(REMORA.lt.lVis_det.detection,'labels')
        modLab = char(extractBefore(REMORA.lt.lVis_det.detection.files,'.tlab')); 
        saveTxt = [REMORA.lt.lEdit.outDir,'\',modLab,'_modID.mat'];
        detTimes = REMORA.lt.lEdit.detection;
        labels = REMORA.lt.lEdit.detectionLab;
        save(saveTxt,'detTimes','labels')
        disp('new IDs from label 1 detections saved!')
    end
    if isfield(REMORA.lt.lVis_det.detection2,'labels')
         modLab = char(extractBefore(REMORA.lt.lVis_det.detection2.files,'.tlab'));
        saveTxt = [REMORA.lt.lEdit.outDir,'\',modLab,'_modID.mat'];
        detTimes = REMORA.lt.lEdit.detection2;
        labels = REMORA.lt.lEdit.detection2Lab;
        save(saveTxt,'detTimes','labels')
        disp('new IDs from label 2 detections saved!')
    end
    if isfield(REMORA.lt.lVis_det.detection3,'labels')
        modLab = char(extractBefore(REMORA.lt.lVis_det.detection3.files,'.tlab'));
        saveTxt = [REMORA.lt.lEdit.outDir,'\',modLab,'_modID.mat'];
        detTimes = REMORA.lt.lEdit.detection3;
        labels = REMORA.lt.lEdit.detection3Lab;
        save(saveTxt,'detTimes','labels')
        disp('new IDs from label 3 detections saved!')
    end
    if isfield(REMORA.lt.lVis_det.detection4,'labels')
         modLab = char(extractBefore(REMORA.lt.lVis_det.detection4.files,'.tlab'));
        saveTxt = [REMORA.lt.lEdit.outDir,'\',modLab,'_modID.mat'];
        detTimes = REMORA.lt.lEdit.detection4;
        labels = REMORA.lt.lEdit.detection4Lab;
        save(saveTxt,'detTimes','labels')
        disp('new IDs from label 4 detections saved!')
    end
end