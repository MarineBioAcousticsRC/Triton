function sp_dt_TPWS_control(action)

global REMORA

if strcmp(action, '')
% Note: could make this have an option to just refresh everything by making
% these all into if rather than elseif
elseif strcmp(action, 'setTPWSBaseDir')
    baseDir = get(REMORA.spice_dt_mkTPWS.baseDirEdTxt,'String');
    REMORA.spice_dt.mkTPWS.baseDir = baseDir;
   
elseif strcmp(action, 'setTPWSOutDir')
    outDir = get(REMORA.spice_dt_mkTPWS.outDirEdTxt,'String');
    REMORA.spice_dt.mkTPWS.outDir = outDir;
   
elseif strcmp(action, 'setTPWSFilterString')
    filterString = get(REMORA.spice_dt_mkTPWS.filterStringEdTxt,'String');
    REMORA.spice_dt.mkTPWS.filterString = filterString;
    
elseif strcmp(action, 'setTPWSspName')
    spName = get(REMORA.spice_dt_mkTPWS.spNameEdTxt,'String');
    REMORA.spice_dt.mkTPWS.spName = spName;
    
elseif strcmp(action, 'setTPWSminRL')
    minDBpp = get(REMORA.spice_dt_mkTPWS.minRLEdTxt,'String');
    if ~isempty(minDBpp)
        minDBpp = str2num(minDBpp);
        REMORA.spice_dt.mkTPWS.minDBpp = minDBpp;
    else
        REMORA.spice_dt.mkTPWS.minDBpp = [];
    end
elseif strcmp(action, 'setSubDirTF')
     subDirTF = get(REMORA.spice_dt_mkTPWS.subDirCheckBox,'Value');
     REMORA.spice_dt.mkTPWS.subDirTF = subDirTF;

elseif strcmp(action, 'setTsWin')
     tsWin = get(REMORA.spice_dt_mkTPWS.tsWinEdTxt ,'String');
     REMORA.spice_dt.mkTPWS.tsWin = str2num(tsWin);
     
elseif strcmp(action, 'run_mkTPWS')
    sp_dt_mkTPWS
    close(REMORA.fig.sp_dt_mkTPWS)
    disp_msg('Done generating TPWS files.')
    disp('Done generating TPWS files.')
end