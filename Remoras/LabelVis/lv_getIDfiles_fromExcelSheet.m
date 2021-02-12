
[fileN,folder] = uigetfile({'*.xlsx','*.xls'},'Select Excel Spreadsheet to Convert to tLabs');
% labelRow = 'SpeciesCode';
outDir = uigetdir('','Select folder to save output files in');
outPref = char(extractBefore(fileN,'.'));

T = readtable(fullfile(folder,fileN));

labelMat = table2array(T(:,3));
callT = table2array(T(:,4));
% labelMat = cell2mat(labelMat);
timesMat = table2array(T(:,5:6));
timesAll = datenum(timesMat);

%convert times to matlab
timesallTri = timesAll - datenum(2000,0,0,0,0,0);
labels = unique(labelMat);
callType = unique(callT);
labelType = labels(~cellfun('isempty',labels));



labelCols = timesallTri;

for iLab = 1:size(labelType,1)
    labelN = labelType{iLab};
    labelIdx = find(strcmp(labelMat,labelN));
    for iC = 1:size(callType,1)
        CT = callType{iC};
        callIdx = find(strcmpi(callT,CT));
        finalIdx = intersect(labelIdx,callIdx);
        
        if ~isempty(finalIdx)
            CT = convertChar(CT);
            
            tfullTimes = timesallTri(finalIdx,:);
            %only keep longest of overlapping detections
            
            for iDT = 1:(size(tfullTimes,1)-1)
                if (iDT + 1) <= size(tfullTimes,1)
                    startCur = tfullTimes(iDT,1);
                    endCur = tfullTimes(iDT,2);
                    startNext = tfullTimes(iDT+1,1);
                    endNext = tfullTimes(iDT+1,2);
                    if (startNext<=startCur && startCur<=endNext) || ...
                            (startNext <= endCur && endCur<= endNext)|| (startCur <= startNext && endCur >= endNext)
                        timeS = min(tfullTimes(iDT+1,1),tfullTimes(iDT,1));
                        timeE = max(tfullTimes(iDT+1,2),tfullTimes(iDT,2));
                        tfullTimes(iDT,:) = [timeS,timeE];
                        tfullTimes(iDT+1,:) = [];
                    end
                end
            end
%                     if tfullTimes(iDT+1,1)  tfullTimes(iDT,1) %if there's an overlap in starts
%                         curDur = tfullTimes(iDT,2) - tfullTimes(iDT,1);
%                         nextDur = tfullTimes(iDT+1,2) - tfullTimes(iDT+1,1);
%                         if nextDur > curDur %if next detection is bigger, get rid of this one
%                             tfullTimes(iDT,:) = [];
%                             %figure out which start to keep 
%                         elseif nextDur < curDur %if current detection is bigger, get rid of next one
%                             tfullTimes(iDT+1,:) = [];
%                         elseif nextDur == curDur %if they're equal don't do anything
%                             tfullTimes(iDT,:) = tfullTimes(iDT,:);
%                         end
%                     end
%                 end
%             end
%             [~,idU] = unique(tfullTimes(:,1));
%             if length(idU) ~= size(tfullTimes,1)
%                 dupIdx = setdiff(1:size(tfullTimes,1),idU);
%                 %get differences to find longest detection
%                 dupDur = tfullTimes(dupIdx,2) - tfullTimes(dupIdx,1);
%                 maxDurIdx = find(dupDur == max(dupDur));
%                 rmvIdx = dupIdx(~maxDurIdx);
%                 tfullTimes(rmvIdx,:) = [];
%             end
            
            fileNameT = [outPref,'_',labelN,'_',CT,'_labels'];
            fileNT = [outDir,'\',fileNameT,'.tlab'];
            fullLabel = [labelN,'_',CT];
            
            %create your label file using ioWriteLabel!
            dispText1 = ['Creating ',fullLabel,' labels...'];
            disp(dispText1)
            lt_ioWriteLabel(fileNT,tfullTimes,fullLabel,'Binary',true);
        end
    end
end


