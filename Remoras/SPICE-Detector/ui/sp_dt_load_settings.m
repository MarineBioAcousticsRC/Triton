function sp_dt_load_settings

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