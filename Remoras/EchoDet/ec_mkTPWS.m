function ec_mkTPWS

global REMORA

% pT = REMORA.ec.tp_params;

pT.inDir = 'E:\echoTests\echoLowT\HI01-guiTest';
pT.depName = 'HAWAII01';
pT.outFile = 'E:\echoTests\echoLowT\HI01-guiTest\TPWS';

depName = pT.depName;

inFolders = dir([pT.inDir,'\',pT.depName,'*']);

for iF = 1:size(inFolders,1)
    MTT = [];
    MSP = [];
    MSN = [];
    MPP = [];
    f = [];
    
    folder = fullfile(inFolders(iF).folder,inFolders(iF).name);
    
    allFiles = dir(folder);
    for iFile = 1:size(allFiles,1)
        if ~allFiles(iFile).isdir
            fileN = fullfile(allFiles(iFile).folder,allFiles(iFile).name);
            load(fileN)
            
            MTT = [MTT;cell2mat(horzcat(ED_stTimes_final{:}))'];
            MSP = [MSP;vertcat(spData_final{:})];
            MPP = [MPP;horzcat(ppSignal_final{:})'];
            MSN = [MSN;vertcat(dataSeg_final{:})];
        end
    end
    
    outFile = [pT.outFile,'\',inFolders(iF).name,'_Delphin_TPWS1.mat'];
    save(outFile,'MTT','MSP','MSN','MPP','f')
    disp(['done with folder ',folder])
end
