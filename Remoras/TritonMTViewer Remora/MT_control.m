function MT_control(action,mySource)

global REMORA HANDLES

if ~exist('mySource','var')
    mySource = 'null';
end

if strcmp(action, '')
    % Note: could make this have an option to just refresh everything by making
    % these all into if rather than elseif
    
% elseif strcmp(action,'setInDir')
%     inDir = get(REMORA.bm_verify.inDirEdTxt, 'string');
%     REMORA.bm.settings.inDir = inDir;
%     
% elseif strcmp(action,'setOutDir')
%     outDir = get(REMORA.bm_verify.outDirEdTxt, 'string');
%     REMORA.bm.settings.outDir = outDir;
      
elseif strcmp(action,'tagchoice')
     tag.val = get(REMORA.MT_verify.tagchoice, 'Value');
    tag.opt = get(REMORA.MT_verify.tagchoice,'string');
    tagchoice = tag.opt{tag.val};
    REMORA.MT.settings.tagchoice = tagchoice;
    
elseif strcmp(action,'sethighpass')
    highpass = str2double(get(REMORA.MT_verify.highpassEdTxt, 'string'));
    REMORA.MT.settings.highpass = highpass;
    
elseif strcmp(action,'setlowpass')
    lowpass = str2double(get(REMORA.MT_verify.lowpassEdTxt, 'string'));
    REMORA.MT.settings.lowpass = lowpass;
    
elseif strcmp(action, 'setBinsize')
    bin = str2double(get(REMORA.MT_verify.binsizeEdTxt, 'string'));
    REMORA.MT.settings.bin = bin;
    
elseif strcmp(action, 'setFs')
    fs = str2double(get(REMORA.MT_verify.fsEdText, 'string'));
    REMORA.MT.settings.fs = fs;

elseif strcmp(action, 'setFilter')
    filter = str2double(get(REMORA.MT_verify.filterEdText, 'string'));
    REMORA.MT.settings.filter = filter;

elseif strcmp(action, 'setMinDepth')
    minDepth = str2double(get(REMORA.MT_verify.minDepthEdText, 'string'));
    REMORA.MT.settings.minDepth = minDepth;

elseif strcmp(action, 'setMinPitch')
    minPitch = str2double(get(REMORA.MT_verify.minPitchEdText, 'string'));
    REMORA.MT.settings.minPitch = minPitch;
    
elseif strcmp(action, 'setMinSpeed')
    minSpeed = str2double(get(REMORA.MT_verify.minSpeedEdText, 'string'));
    REMORA.MT.settings.minSpeed = minSpeed;

elseif strcmp(action, 'setMinTime')
    minTime = str2double(get(REMORA.MT_verify.minTimeEdText, 'string'));
    REMORA.MT.settings.minTime = minTime;

    
elseif strcmp(action,'RunSpeedCalc')
    close(REMORA.fig.MT.speed)
    speedcalc;
end


