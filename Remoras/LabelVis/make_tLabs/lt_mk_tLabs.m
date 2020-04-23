function lt_mk_tLabs(varargin)


%%%%created by MAZ on 3/13/2020 to speed up input into ioWriteLabel
p = varargin{1};
if isempty(p.timeOffset)
    p.timeOffNum = 0;
else
    p.timeOffNum = datenum(p.timeOffset,0,0,0,0,0);
end

%%load files of interest
if p.TPWStype
    fileNames = dir(fullfile(p.filePath,[p.filePrefix,'*_TPWS',...
        p.TPWSitr,'.mat']));
    type = '_TPWS';
elseif p.TDtype
    fileNames = dir(fullfile(p.filePath,[p.filePrefix,'*_TD',...
        p.TPWSitr,'.mat']));
    type = '_TD';
elseif p.IDtype
    fileNames = dir(fullfile(p.filePath,[p.filePrefix,'*_ID',...
        p.TPWSitr,'.mat']));
    type = '_ID';
elseif p.FDtype
    fileNames = dir(fullfile(p.filePath,[p.filePrefix,'*_FD',...
        p.TPWSitr,'.mat']));
    type = '_FD';
end

if isempty(fileNames)
    disp('No files found! Check file path')
else
    disp('beginning tLab creation...')
end

for iFile = 1:size(fileNames,1)
    thisFile = fullfile(fileNames(iFile).folder,fileNames(iFile).name);
    p.outPrefix = char(extractBefore(fileNames(iFile).name,type)); %used to name output file
    load(thisFile)
    % saveDir = p.saveDir; %where to save
    % filePrefix = p.filePrefix ; %what do you want your file to be called?
    % filePath = p.filePath; %TPWS file to load
    % FDpath = p.FDpath; %FD file to load
    
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
    if p.IDtype
        %%slightly different procedure if ID files
        if isempty(zID)
            disp('zID empty! Skipping file...')
        else
            disp('using ID file to make tlabs')
            labelCol = zID(:,2);
            labelType = unique(labelCol);
            
            for iLab = 1:size(labelType,1)
                labelTimes = zID(find(zID(:,2)==labelType(iLab)),1);
                tTimeS = labelTimes - p.timeOffNum;
                %dur = .0001; %what duration do you want for your clicks?
                tTimeE = tTimeS + datenum(0,0,0,0,0,p.dur);
                
                tfullTimes = [tTimeS,tTimeE];
                
                p.trueLabel = num2str(labelType(iLab));
                fileNameT = [p.outPrefix,'_',p.trueLabel,'_labels'];
                fileNT = [p.saveDir,'\',fileNameT,'.tlab'];
                
                
                %create your label file using ioWriteLabel!
                dispText1 = ['Creating ',p.trueLabel,' labels...'];
                disp(dispText1)
                lt_ioWriteLabel(fileNT,tfullTimes,p.trueLabel,'Binary',true);
            end
        end
    else
        if p.TPWStype %if loaded file is a TPWS file
            if p.rmvFDs
                FD = fullfile(p.filePath,[p.outPrefix,'_FD',p.TPWSitr,'.mat']);
                load(FD)
                
                tTimeS = setdiff(MTT,zFD,'rows')- p.timeOffNum;
                disp('using difference in MTT and zFD to find true labels from TPWS')
            else
                disp('using full TPWS file to make tlabs')
                tTimeS = MTT - p.timeOffNum;
            end
        elseif p.FDtype
            tTimeS = zFD- p.timeOffNum;
            disp('using FD file to make tlabs')
        elseif p.TDtype
            tTimeS = zTD - p.timeOffNum;
            disp('using TD file to make tlabs')
        end
        
        %tlabel = 'true';
        fileNameT = [p.outPrefix,'_',p.trueLabel,'_labels'];
        
        fileNT = [p.saveDir,'\',fileNameT,'.tlab'];
        
        
        %dur = .0001; %what duration do you want for your clicks?
        tTimeE = tTimeS + datenum(0,0,0,0,0,p.dur);
        
        tfullTimes = [tTimeS,tTimeE];
        
        %create your label file using ioWriteLabel!
        dispText1 = ['Creating ',p.trueLabel,' labels...'];
        disp(dispText1)
        lt_ioWriteLabel(fileNT,tfullTimes,p.trueLabel,'Binary',true);
    end
    dispText2 = ['Done with file ',p.outPrefix,' labels'];
    disp(dispText2)
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
