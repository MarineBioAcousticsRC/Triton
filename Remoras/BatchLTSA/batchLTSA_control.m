function batchLTSA_control(action)
% BATCHLTSA_CONTROL Defines actions for batchLTSA Remora GUI
%
%   Syntax:
%       BATCHLTSA_CONTROL(action)
%
%   Description:
%       Triggers actions in response to changes in the GUI window setting
%       up the batchLTSA process (batchLTSA_init_gui.m)
%
%   Inputs:
%       action   output of a uicontrol call from batchLTSA_init_gui that
%                triggers defining some setting
%
%   Inputs:
%       calls global REMORA
%
%	Outputs:
%       updates global REMORA
%
%   Examples:
%
%   See also BATCHLTSA_INIT_GUI
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   Updated:   04 May 2025
%
%   Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global REMORA

if strcmp(action, '')
    % Note: could make this have an option to just refresh everything by making
    % these all into if rather than elseif

elseif strcmp(action,'setInDir')
    inDir = get(REMORA.batchLTSA_verify.inDirEdTxt, 'string');
    REMORA.batchLTSA.settings.inDir = inDir;

elseif strcmp(action, 'browseInDir')
    dir = uigetdir();
    if ~ isnumeric(dir)
        % user selected something
        set(REMORA.batchLTSA_verify.inDirEdTxt, 'string', dir);
        REMORA.batchLTSA.settings.inDir = dir;
    end

elseif strcmp(action, 'setDataType')
    dataType = get(REMORA.fig.dataType_buttongroup.SelectedObject, 'Tag');
    REMORA.batchLTSA.settings.dataType = dataType;

elseif strcmp(action, 'settave')
    tave = get(REMORA.batchLTSA_verify.taveEdTxt, 'string');
    REMORA.batchLTSA.settings.tave = tave;

elseif strcmp(action, 'setdfreq')
    dfreq = get(REMORA.batchLTSA_verify.dfreqEdTxt, 'string');
    REMORA.batchLTSA.settings.dfreq = dfreq;

elseif strcmp(action, 'setNumCh')
    numCh = get(REMORA.fig.numCh_buttongroup.SelectedObject, 'Tag');
    REMORA.batchLTSA.settings.numCh = numCh;

elseif strcmp(action, 'setWhCh')
    whCh = get(REMORA.batchLTSA_verify.whChEdTxt, 'string');
    whCh = str2double(whCh);
    REMORA.batchLTSA.settings.whCh = whCh;

elseif strcmp(action,'RunBatchLTSA')
    close(REMORA.fig.batchLTSA)
    % double check - not cancelled
    % REMORA.batchLTSA.cancelled = 0;
    batchLTSA_init_batch_ltsa;

elseif strcmp(action, 'cancelAll')
    closereq();
    REMORA.batchLTSA.cancelled = 1;
    disp_msg('Process cancelled');

end


