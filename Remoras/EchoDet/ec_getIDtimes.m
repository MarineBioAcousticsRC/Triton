%created by MAZ on 11/12/2020 to get echosounder detections into ID file
%format to examine in labelVis
function ec_getIDtimes

global REMORA

p2 = REMORA.ec.id_params;

inAll = dir(fullfile(p2.inDir,'*echo.mat'));
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

outFile = [p2.inDir,'\',p2.outName,'_ID1.mat'];

save(outFile,'zID')

disp(['Done with folder ',inAll(i).folder])
