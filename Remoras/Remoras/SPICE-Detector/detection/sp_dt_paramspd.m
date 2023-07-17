function sp_dt_paramspd(hObject,eventdata,action,userMode)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% dt_paramspd.m
% 
% Set Detection Parameter pull-down menus:
%   save parameter list
%   load parameter list
%
% 9/16/06 mss - from triton 1.5 paramspd.m
%
% Do not modify the following line, maintained by CVS
% $Id: dt_paramspd.m,v 1.10 2010/01/11 22:04:00 mroch Exp $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS HANDLES REMORA
thisPath = mfilename('fullpath');
settingsPath = fullfile(fileparts(fileparts(thisPath)),...
        'settings');
% load a saved parameters file (spectrogram)
if strcmp(action,'spice_settingsLoad')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dialogTitle1 = 'Open Detector Settings File';
    
    [REMORA.spice_dt.paramfile,REMORA.spice_dt.parampath] = ...
        uigetfile(fullfile(settingsPath,'*.m*'),dialogTitle1);
    % give user some feedback
    if isscalar(REMORA.spice_dt.paramfile)
      return    % User cancelled
    end
    sp_dt_load_settings(userMode)
% save a parameters file (spectrogram)
elseif strcmp(action,'spice_settingsSave')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    % user interface retrieve file to open through a dialog box
    dialogTitle2 = 'Parameter Save As';
    [REMORA.sp_dt.paramout,REMORA.sp_dt.parampath] = ...
        uiputfile(fullfile(settingsPath,'*.mat'),dialogTitle2);
    
    % if the cancel button is pushed, then no file is loaded
    % so exit this script
    if 0 == REMORA.sp_dt.paramout
        return
    end
    
    outFile = fullfile(REMORA.sp_dt.parampath,REMORA.sp_dt.paramout);
    detParams = REMORA.spice_dt.detParams;
    save(outFile,'detParams')

end

