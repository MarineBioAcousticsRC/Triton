%created by MAZ on 11/12/2020 to get echosounder detections into ID file
%format to examine in labelVis
function ec_getIDtimes

global REMORA

p2 = REMORA.ec.id_params;

if ~isdir(p2.outDir)
    mkdir(p2.outDir)
end

if p2.runonSub
    inFolds = dir(fullfile(p2.inDir,p2.inPref));
    if isempty(inFolds)
        disp('No folders found! Check file path and prefix.')
    end
    
    for iF = 1:size(inFolds,1)
        curFold = inFolds(iF).name;
        
        inAll = dir(fullfile(p2.inDir,curFold,'*echo.mat'));
        
        if isempty(inAll)
            disp('No files found! Check file path.')
        end
        
        allTimes = [];
        
        for i = 1:length(inAll)
            inFile = fullfile(inAll(i).folder,inAll(i).name);
            load(inFile)
            
            ED_allTimes = [ED_stTimes_final{:}];
            
            if ~isempty(ED_allTimes)
                ED_allTimes = vertcat(ED_allTimes{:});
                
                allTimes = [allTimes;ED_allTimes];
            end
            
            disp(['done with file ',inAll(i).name])
        end
        
        zID = [allTimes,ones(1,length(allTimes))'];
        
        outFile = [p2.outDir,'\',curFold,'_ID1.mat'];
        
        save(outFile,'zID')
        
        disp(['Done with folder ',inAll(i).folder])
    end
    
else
    inAll = dir(fullfile(p2.inDir,'*echo.mat'));
    
    if isempty(inAll)
        disp('No files found! Check file path.')
    end
    
    allTimes = [];
    
    for i = 1:length(inAll)
        inFile = fullfile(inAll(i).folder,inAll(i).name);
        load(inFile)
        
        ED_allTimes = [ED_stTimes_final{:}];
        
        if ~isempty(ED_allTimes)
            ED_allTimes = vertcat(ED_allTimes{:});
            
            allTimes = [allTimes;ED_allTimes];
        end
        
        disp(['done with file ',inAll(i).name])
    end
    
    zID = [allTimes,ones(1,length(allTimes))'];
    
    outFile = [p2.outDir,'\',p2.outName,'_ID1.mat'];
    
    save(outFile,'zID')
    
    disp(['Done with folder ',inAll(i).folder])
end

disp('Done generating ID files')
