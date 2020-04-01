function lt_mk_tLabs(varargin)


%%%%created by MAZ on 3/13/2020 to speed up input into ioWriteLabel
p = varargin{1};

disp('beginning tLab creation...')

% saveDir = p.saveDir; %where to save
% filePrefix = p.filePrefix ; %what do you want your file to be called?
% filePath = p.filePath; %TPWS file to load
% FDpath = p.FDpath; %FD file to load

%load in files to make labels from
load(p.filePath);

%create save directory if doesn't exist
if ~exist(p.saveDir,'dir')
    mkdir(p.saveDir)
end


%use mod data if loaded
if exist('MTT_shortMod')
    MTT = MTT_shortMod;
    %     zFD = [0];
end


%make true labels
if ~exist('zID')
    if exist('MSP') %if loaded file is a TPWS file
        if p.rmvFDs
            load(p.FDpath)
            tTimeS = setdiff(MTT,zFD,'rows')- p.timeOffset;
            disp('using difference in MTT and zFD to find true labels from TPWS')
        else
            disp('using full TPWS file to make tlabs')
            tTimeS = MTT - p.timeOffset;
        end
    elseif exist('zFD')
        tTimeS = zFD- p.timeOffset;
    elseif exist('zTD')
        tTimeS = zTD - p.timeOffset;
    end
    
    %tlabel = 'true';
    fileNameT = [p.filePrefix,'_',p.trueLabel,'_labels'];
    
    fileNT = [p.saveDir,'\',fileNameT,'.tlab'];
    
    
    %dur = .0001; %what duration do you want for your clicks?
    tTimeE = tTimeS + datenum(0,0,0,0,0,p.dur);
    
    tfullTimes = [tTimeS,tTimeE];
    
    %create your label file using ioWriteLabel!
    dispText1 = ['Creating ',p.trueLabel,' labels...'];
    disp(dispText1)
    lt_ioWriteLabel(fileNT,tfullTimes,p.trueLabel,'Binary',true);
    
    
    %%slightly different procedure if ID files
else
    labelCol = zID(:,2);
    labelType = unique(labelCol);
    
    for iLab = 1:size(labelType,1)
        labelTimes = zID(find(zID(:,2)==labelType(iLab)),1);
        tTimeS = labelTimes - p.timeOffset;
        %dur = .0001; %what duration do you want for your clicks?
        tTimeE = tTimeS + datenum(0,0,0,0,0,p.dur);
        
        tfullTimes = [tTimeS,tTimeE];
        
        p.trueLabel = num2str(labelType(iLab));
        fileNameT = [p.filePrefix,'_',p.trueLabel,'_labels'];
        fileNT = [p.saveDir,'\',fileNameT,'.tlab'];
        
        
        %create your label file using ioWriteLabel!
        dispText1 = ['Creating ',p.trueLabel,' labels...'];
        disp(dispText1)
        lt_ioWriteLabel(fileNT,tfullTimes,p.trueLabel,'Binary',true);
    end
end
end

% %%%make false labels if false detections exist
% if p.falseL
%     if size(zFD,1)<= 1
%         disp('WARNING: no false labels found in TPWS!')
%     else
%         fileNameF = [filePrefix,p.falseLabel,'_labels'];
%         fTimeS = zFD - p.timeOffset;
%         fileNF = [baseDir,'\',fileNameF,'.tlab'];
%         fTimeE = fTimeS + datenum(0,0,0,0,0,p.dur);
%         ffullTimes = [fTimeS,fTimeE];
%
%         %false labels
%         dispTxt2 = ['Creating ',p.falseLabel,' labels'];
%         disp(dispTxt2)
%         lt_ioWriteLabel(fileNF,ffullTimes,p.falseLabel,'Binary',true);
%     end
% end
%
