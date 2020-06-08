function bm_kernel_control(action,~)

global REMORA

if strcmp(action,'')
    
elseif strcmp(action,'setKernelDir')
    kernelDir = get(REMORA.bm.kernel_verify.kernelDirEdTxt, 'string');
    REMORA.bm.settings.kernelDir = kernelDir;
    
elseif strcmp(action, 'setKernelID')
    kernelID = get(REMORA.bm.kernel_verify.kernelIDEdTxt, 'string');
    REMORA.bm.settings.kernelID = kernelID;
    
% elseif strcmp(action, 'setKernelDepl')
%     kernelDepl = get(REMORA.bm.kernel_verify.kernelDeplEdTxt, 'string');
%     REMORA.bm.settings.kernelDepl = kernelDepl;
    
elseif strcmp(action, 'RunKernelCalc')
    close(REMORA.fig.bm.kernel)
    bm_loadKernelPicks;
end