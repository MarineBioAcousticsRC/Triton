function ec_mkTPWS

global REMORA

% pT = REMORA.ec.tp_params;

pT.inDir = 'O:\echoDet_Kona\HI17_echosounder';
pT.depName = 'Hawaii17';
pT.outFile = 'O:\echoDet_Kona\HI17_echosounder\TPWS';

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
            
            if ~isempty(dataSeg_final)
            %make timeseries same length
            dataS = horzcat(dataSeg_final{:});
            dataMod = [];
            for iT = 1:size(dataS,2)
                dataSeg = dataS{iT};
                midD = length(dataSeg)./2;
                if (midD-300)<1
                    lowId = 1;
                else
                    lowId = ceil(midD)-300;
                end
                highId = lowId + 599;
                
                dataMod(iT,:) = dataSeg(lowId:highId);
            end
            
            MTT = [MTT;cell2mat(horzcat(ED_stTimes_final{:}))'];
            MSP = [MSP;vertcat(spData_final{:})];
            %fix that removes extra things that were stored in
            %ppSignal_final
            MPPstore = [];
            %for each cell in the data segment
            iSuse = 1;
            while iSuse <= size(spData_final,2)
                %if the sizes of the cells are equal, save mpp as normal
                if size(spData_final{iSuse},1) == size(ppSignal_final{iSuse},2)
                MPPstore{iSuse} = ppSignal_final{iSuse};
                iSuse = iSuse + 1;
                %otherwise, delete this cell in ppSignal_final and try
                %again
                else
                    ppSignal_final{iSuse} = [];
                    ppSignal_final = ppSignal_final(~cellfun('isempty',ppSignal_final));
                    %try this one again
                end
            end
            %get MPP back out and remove empty cells
            MPPmat = cell2mat(MPPstore);
            
            MPP = [MPP;MPPmat'];
%              MPP = [MPP;horzcat(ppSignal_final{:})'];
            MSN = [MSN;dataMod];
            
            if size(MPP,1) ~= size(MSN,1)               
                error()
            end
            end
        end
    end
    
    outFile = [pT.outFile,'\',inFolders(iF).name,'_Delphin_TPWS1.mat'];
    save(outFile,'MTT','MSP','MSN','MPP','f','-v7.3')
    disp(['done with folder ',folder])
end
