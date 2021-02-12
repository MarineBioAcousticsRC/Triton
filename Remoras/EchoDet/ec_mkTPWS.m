function ec_mkTPWS

global REMORA

% pT = REMORA.ec.tp_params;

pT.inDir = 'E:\HI01-guiTest';
pT.depName = 'HAWAII01';
pT.outFile = 'E:\HI01-guiTest\TPWS';

if ~isdir(pT.outFile)
    mkdir(pT.outFile)
end

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
            
            %make timeseries same length
            dataS = horzcat(dataSeg_final{:});
            dataMod = [];
            for iT = 1:size(dataS,2)
                dataSeg = dataS{iT};
                midD = length(dataSeg)./2;
                if (midD-300)<1
                    lowId = 1;
                else
                    lowId = midD-300;
                end
                highId = lowId + 599;
                
                dataMod(iT,:) = dataSeg(lowId:highId);
            end
            
            MTT = [MTT;cell2mat(horzcat(ED_stTimes_final{:}))'];
            MSP = [MSP;vertcat(spData_final{:})];
            MPP = [MPP;horzcat(ppSignal_final{:})'];
            MSN = [MSN;dataMod];
        end
    end
    
    outFile = [pT.outFile,'\',inFolders(iF).name,'_Delphin_TPWS1.mat'];
    save(outFile,'MTT','MSP','MSN','MPP','f')
    disp(['done with folder ',folder])
end
