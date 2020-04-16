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
    disp('working on it!')
end