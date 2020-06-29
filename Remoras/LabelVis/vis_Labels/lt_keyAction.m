function lt_keyAction(varargin)

global REMORA

REMORA.lt.lVis_det.cc = get(gcf,'CurrentCharacter');


if strcmp(REMORA.lt.lVis_det.cc,'c')
    [x,y] = ginput;
    REMORA.lt.lEdit.xchSt = min(x);
    REMORA.lt.lEdit.xchEd = max(x);
    REMORA.lt.lEdit.ychSt = min(y);
    REMORA.lt.lEdit.ychEd = max(y);
    
    lt_init_lEdit_window
    
elseif strcmp(REMORA.lt.lVis_det.cc,'l')
    [x,y] = ginput;
    REMORA.lt.lEdit.xchSt = min(x);
    REMORA.lt.lEdit.xchEd = max(x);
    REMORA.lt.lEdit.ychSt = min(y);
    REMORA.lt.lEdit.ychEd = max(y);
    
    lt_init_lEdit_window_LTSA
    %     mod_chLabels
    %     REMORA.lt.lVis_det.detection.chLab = 1;
    %
    %     lt_lVis_plot_WAV_labels
end



