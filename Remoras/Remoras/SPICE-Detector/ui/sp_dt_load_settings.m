function sp_dt_load_settings(userMode)

global REMORA
[~,~,fileType] = fileparts(REMORA.spice_dt.paramfile);
% Input could be a .m file or a .mat file
if strcmp(fileType,'.mat')
    % it's a mat file, so load it
    p = load(fullfile(REMORA.spice_dt.parampath,REMORA.spice_dt.paramfile));
    REMORA.spice_dt.detParams = p.detParams;
elseif strcmp(fileType,'.m')
    currentFolder = pwd; % store original dir
    cd(fullfile(REMORA.spice_dt.parampath)) %change just to run
    run(REMORA.spice_dt.paramfile)
    REMORA.spice_dt.detParams = detParams;
    cd(currentFolder) % point back to original dir
else
    error('Unknown input file type. Expecting .mat or .m')
end
REMORA.spice_dt.detParams.rebuildFilter = 1;

if strcmp(userMode,'interactiveMode')
% refresh gui values:
set(REMORA.spice_dt.PPThresholdEdTxt,'String',num2str(REMORA.spice_dt.detParams.dBppThreshold))
set(REMORA.spice_dt.MinBandPassEdText,'String',num2str(REMORA.spice_dt.detParams.bpRanges(1,1)))
set(REMORA.spice_dt.MaxBandPassEdText,'String',num2str(REMORA.spice_dt.detParams.bpRanges(1,2)))
set(REMORA.spice_dt.MinClickDurEdText,'String',num2str(REMORA.spice_dt.detParams.delphClickDurLims(1,1)))
set(REMORA.spice_dt.MaxClickDurEdText,'String',num2str(REMORA.spice_dt.detParams.delphClickDurLims(1,2)))
set(REMORA.spice_dt.MinPeakFreqEdTxt,'String',num2str(REMORA.spice_dt.detParams.cutPeakBelowKHz))
set(REMORA.spice_dt.MaxPeakFreqEdTxt,'String',num2str(REMORA.spice_dt.detParams.cutPeakAboveKHz))
set(REMORA.spice_dt.MinEvEdTxt,'String',num2str(REMORA.spice_dt.detParams.dEvLims(1)))
set(REMORA.spice_dt.MaxEvEdTxt,'String',num2str(REMORA.spice_dt.detParams.dEvLims(2)))
set(REMORA.spice_dt.clipThresholdEdTxt,'String',num2str(REMORA.spice_dt.detParams.clipThreshold))
sp_dt_motion('refresh')
elseif strcmp(userMode,'batchMode')
% set(REMORA.spice_dt_verify.baseDirEdTxt,'String',num2str(REMORA.spice_dt.detParams.baseDir))
% set(REMORA.spice_dt_verify.outDirEdTxt,'String',num2str(REMORA.spice_dt.detParams.outDir))
% set(REMORA.spice_dt_verify.TFPathEdTxt,'String',num2str(REMORA.spice_dt.detParams.tfFullFile))
% set(REMORA.spice_dt_verify.deployNameEdTxt,'String',num2str(REMORA.spice_dt.detParams.depl))
% set(REMORA.spice_dt_verify.channelEdTxt,'String',num2str(REMORA.spice_dt.detParams.channel))
% set(REMORA.spice_dt_verify.overwriteCheck,'Value',REMORA.spice_dt.detParams.overwrite)
% set(REMORA.spice_dt_verify.PPThresholdEdTxt,'String',num2str(REMORA.spice_dt.detParams.dBppThreshold))
% set(REMORA.spice_dt_verify.SNRThresholdRadio,'Value',REMORA.spice_dt.detParams.snrDet)
% set(REMORA.spice_dt_verify.SNRThresholdEdTxt,'String',num2str(REMORA.spice_dt.detParams.snrThresh))
% set(REMORA.spice_dt_verify.MinBandPassEdText,'String',num2str(REMORA.spice_dt.detParams.bpRanges(1,1)))
% set(REMORA.spice_dt_verify.MaxBandPassEdText,'String',num2str(REMORA.spice_dt.detParams.bpRanges(1,2)))
% set(REMORA.spice_dt_verify.MinClickDurEdText,'String',num2str(REMORA.spice_dt.detParams.delphClickDurLims(1,1)))
% set(REMORA.spice_dt_verify.MaxClickDurEdText,'String',num2str(REMORA.spice_dt.detParams.delphClickDurLims(1,2)))
% set(REMORA.spice_dt_verify.MinPeakFreqEdTxt,'String',num2str(REMORA.spice_dt.detParams.cutPeakBelowKHz))
% set(REMORA.spice_dt_verify.MaxPeakFreqEdTxt,'String',num2str(REMORA.spice_dt.detParams.cutPeakBelowKHz))
    sp_ui_check_detParams([],[],REMORA.fig.spice_dt_verify)
else 
    error('unknown usermode %s',userMode)
end