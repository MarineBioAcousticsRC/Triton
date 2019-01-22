function batchTestPrepHTKFiles_kmeans(segList,allfreq,fileName,species)
% function = prepHTKFiles(fileName, species)
global PARAMS masterVector
% Write Script and mlf files for HTK
% Load file
% Concatonnate all whistles end to end, in one column vector, keeping track
% of beginning and end indices
% save this to a .mfc file
% write a script file that contains filepath, filename, extension (.mfc)
% [beginning end] indices for each WHISTLE
% write a script file that contains filepath, filename, extension (.mfc)
% [beginning end] indices for each SEGMENT
% Write a MLF file containing order and category of whistle (eg. how many
% segments?)
% Write a MLF file containing order and category of segment (eg. how many
% up, down, flat)
%
% error(nargchk(1,2,nargin));
% if nargin < 2
%     if isempty(componentON)
%         componentON = true;
%     end
% end
close all
PARAMS.lengthUpdateIdx = masterVector.size; % Use this to know what to
% add onto indices when appending scp files in subsequent iterations

% load saved fitted tonals
% fitFile = loadFitFile(fileName);
% vertcat everything
% masterVector = [];
tonalsN = size(segList);
% j=1;
advance_ms = 2;
% fileName = fullfile(['F:\HTK_models','\',filename,'.txt']);


% index for growing segment start/end vectors

wsStartIdx = [];
segStartIdx = [];
wsEndIdx = [];
segEndIdx = [];
seg2Whs = []; % this stores the number of the whistle that the segment belongs to
whs2Seg = []; % this stores the position of the segment within the whistle
segShape ={};
segSlope=[];
segBW=[];

for k=1:tonalsN
    q = length(segStartIdx) + 1;
%     thisFreq = segList{k}.(name){1,2};
    segStartIdx(q,1) = masterVector.size; % build segment index
    segNum = numel(fieldnames(segList{k})); % figure out # of segments to deal with
    
    % keep adding up length of segments to keep track of what their
    % indices will be in the masterVector.
    for j = 1:segNum
        name = sprintf('Segments%d', j);
        segSize = length(segList{k}.(name){1,2});
        segEndIdx(q,1)= segStartIdx(q,1)+ segSize - 1;
        seg2Whs(q,1) = k;
        whs2Seg(q,1) = j;
%         segSlope(q,1) = segList{k}.(name){1,5};
%         segBW(q,1) = segList{k}.(name){1,4};
%         segDur(q,1) = segList{k}.(name){1,3};
        segShape(q) = segList{k}.(name){1,7};
        
        if j < segNum % as long as there's another segment, the first index
            %             %of that segment will be the last index +1
            q = length(segStartIdx) + 1;
            segStartIdx(q,1) = segEndIdx((q-1),1)+1;
        end
        %          segStartIdx(q,1) = segEndIdx((q-1),1)+1;
    end
 

  
%     plot(thisFreq - mean(thisFreq), 'og');
%     ttl=segShape(qstart:q);
%     title(ttl); 
%     pause
thisFreq = allfreq{:,k};

    if k == 1 
        wsStartIdx(k,1) = masterVector.size;
        for j=1:length(thisFreq(k))
            masterVector.add(thisFreq(j,1));
        end
        wsEndIdx(k,1) = (masterVector.size)-1;
        
    else
        wsStartIdx(k,1) = masterVector.size;
        for j=1:length(thisFreq)
            masterVector.add(thisFreq(j,1));
        end
        wsEndIdx(k,1) = (masterVector.size)-1;
    end
end

% if ~PARAMS.append % loop to make numbers increase accross files,
    % so they don't start back at w1s1 every time in scp
    PARAMS.lastWhsNum = max(seg2Whs);
% else
%     seg2Whs = seg2Whs + PARAMS.lastWhsNum;
%     PARAMS.firstWhsNum = PARAMS.lastWhsNum;
%     PARAMS.lastWhsNum = max(seg2Whs);
% end
% now write files - ugh
% % % % % % Need loop that builds the files if iteration =1 else
% appends!!!!
% component script files
[~, fitName] = fileparts(fileName);
% name the output file
scpFType = '.scp';
mfcFType = '.mfc';
mlfFtype = '.mlf';
gramFType = '.gram';

% if ~PARAMS.append
    % segments
    % PARAMS.fileNames.segSCPFileName = ([PARAMS.HTKFileName, '_seg', scpFType]); %name script file
    % whistles
    % PARAMS.fileNames.whsSCPFileName = ([PARAMS.HTKFileName, '_whs', scpFType]); %name script file
    PARAMS.fileNames.whsSCPFileName = ([PARAMS.HTKFileName, scpFType]); %name script file
    PARAMS.fileNames.mfcFileName = ([PARAMS.HTKFileName, mfcFType]); %name mfc file
    
    % Write segments script file
%     fod = fopen(PARAMS.fileNames.segSCPFileName,'w');
%     for k = 1:length(segStartIdx)
% %         fprintf(fod,'%s-w%ss%s=%s[%d,%d]\n', fitName, num2str(seg2Whs(k)),...
% %             num2str(whs2Seg(k)), PARAMS.fileNames.mfcFileName, segStartIdx(k,1), segEndIdx(k,1));
%         fprintf(fod,'%s_w%ss%s.mfc\n', fitName, num2str(seg2Whs(k)),...
%             num2str(whs2Seg(k)));
%     end
%     fclose(fod);
    
    % write full whistles script file
    fod2 = fopen(PARAMS.fileNames.whsSCPFileName,'w');
    for k = 1:length(wsStartIdx)
%         fprintf(fod2,'%s-w%s=%s[%d,%d]\n', fitName, num2str(k), PARAMS.fileNames.mfcFileName,...
%             wsStartIdx(k,1), wsEndIdx(k,1));
        fprintf(fod2,'%s_W%s.mfc\n', fitName, num2str(k));
    end
    fclose(fod2);
    
%     % write segment .mlf file
%     PARAMS.fileNames.mlfSegFileName = ([PARAMS.HTKFileName, '_seg', mlfFtype]); %name .mlf file
%     fod4 = fopen(PARAMS.fileNames.mlfSegFileName,'w');
%     for k = 1:length(segStartIdx)
%         if k == 1
%             fprintf(fod4,'#!MLF!#\n');
%         end
%         fprintf(fod4,'"%s_w%ss%s.lab"\n', fitName, num2str(seg2Whs(k)),...
%             num2str(whs2Seg(k)));
%         fprintf(fod4,'%s_%s\n', species, segShape{k});
%         fprintf(fod4,'.\n');
%     end
%     fclose(fod4);
    
    % write whistle .mlf file
    % PARAMS.fileNames.mlfWhsFileName = ([PARAMS.HTKFileName, '_whs', mlfFtype]); %name .mlf file
    PARAMS.fileNames.mlfWhsFileName = ([PARAMS.HTKFileName, mlfFtype]); %name .mlf file
    fod5 = fopen(PARAMS.fileNames.mlfWhsFileName,'w');
    for k = 1:length(wsStartIdx)
        if k == 1
            fprintf(fod5,'#!MLF!#\n');
        end
        fprintf(fod5,'"%s_W%s.lab"\n', fitName, num2str(k));
        segFind = find(seg2Whs==k);
        for j= 1:length(segFind)
            fprintf(fod5,'%s_%s\n', species, segShape{segFind(j)});
        end
        fprintf(fod5,'.\n');
    end
    fclose(fod5);
    
    % write whistle grammar file
    % PARAMS.fileNames.gramWhsFileName = ([PARAMS.HTKFileName, '_whs', gramFType]); %name .gram file
	PARAMS.fileNames.gramWhsFileName = ([PARAMS.HTKFileName, gramFType]); %name .gram file
    fod6 = fopen(PARAMS.fileNames.gramWhsFileName,'w');
    for k = 1:length(wsStartIdx)
        segFind = find(seg2Whs==k);
        for j= 1:length(segFind)
            fprintf(fod6,'%s_%s ', species, segShape{segFind(j)});
        end
        fprintf(fod6,'\n');
    end
    fclose(fod6);
    % end
    
%     % write segment grammar file
%     PARAMS.fileNames.gramSegFileName = ([PARAMS.HTKFileName, '_seg', gramFType]); %name .gram file
%     fod7 = fopen(PARAMS.fileNames.gramSegFileName,'w');
%     for k = 1:length(wsStartIdx)
%         segFind = find(seg2Whs==k);
%         for j= 1:length(segFind)
%             fprintf(fod7,'%s_%s ', species, segShape{segFind(j)});
%             fprintf(fod7,'\n');
%         end
%     end
%     fclose(fod7);
    
    % write HTK feature vectors
    for k = 1:length(wsStartIdx)
          PARAMS.fileNames.mfcFileName = sprintf('%s%s_W%s.mfc', PARAMS.outdir, fitName, num2str(k));
%         % do mean freq norm       
%         meanFreq = mean(fitFilenew.get(k-1).getThisTonal.get_freq);
%         spWriteFeatureDataHTK(PARAMS.fileNames.mfcFileName, ((fitFilenew.get(k-1).getThisTonal.get_freq) - meanFreq), advance_ms, 'USER');
        % do (natural) log and mean freq norm
        logFreq =log(allfreq{:,k});
        meanlogFreq = mean(logFreq);
        spWriteFeatureDataHTK(PARAMS.fileNames.mfcFileName, (logFreq - meanlogFreq), advance_ms, 'USER');
        % no normalization
%         spWriteFeatureDataHTK(PARAMS.fileNames.mfcFileName,(fitFilenew.get(k-1).getThisTonal.get_freq), advance_ms, 'USER');
%         % do (natural) log
%         logFreq =log(fitFilenew.get(k-1).getThisTonal.get_freq);
%         spWriteFeatureDataHTK(PARAMS.fileNames.mfcFileName, logFreq, advance_ms, 'USER');
    end
    
% else % append if already have files made from 1st iteration.
% %     % Write segments script file
% %     fod = fopen(PARAMS.fileNames.segSCPFileName,'a');
% %     for k = 1:length(segStartIdx)
% % %         fprintf(fod,'%s-w%ss%s=%s[%d,%d]\n', fitName, num2str(seg2Whs(k)),...
% % %             num2str(whs2Seg(k)), PARAMS.fileNames.mfcFileName, segStartIdx(k,1), segEndIdx(k,1));
% %         fprintf(fod,'%s_w%ss%s.mfc\n', fitName, num2str(seg2Whs(k)),...
% %             num2str(whs2Seg(k)));
% %     end
% %     fclose(fod);
%     
%     % write full whistles script file
%     fod2 = fopen(PARAMS.fileNames.whsSCPFileName,'a');
%     for k = 1:length(wsStartIdx)
% %         fprintf(fod2,'%s-w%s=%s[%d,%d]\n', fitName, num2str(k+PARAMS.firstWhsNum), PARAMS.fileNames.mfcFileName,...
% %             wsStartIdx(k,1), wsEndIdx(k,1));
%         fprintf(fod2,'%s_W%s.mfc\n', fitName, num2str(k+PARAMS.firstWhsNum));
%     end
%     fclose(fod2);
%     
% %     % write segment .mlf file
% %     % PARAMS.fileNames.mlfSegFileName = ([PARAMS.HTKFileName, '_seg', mlfFtype]); %name .mlf file
% %     fod4 = fopen(PARAMS.fileNames.mlfSegFileName,'a');
% %     for k = 1:length(segStartIdx)
% %         fprintf(fod4,'"%s_w%ss%s.lab"\n', fitName, num2str(seg2Whs(k)),...
% %             num2str(whs2Seg(k)));
% %         fprintf(fod4,'%s_%s\n', species, segShape{k});
% %         fprintf(fod4,'.\n');
% %     end
% %     fclose(fod4);
% %     
%     % write whistle .mlf file
%     % PARAMS.fileNames.mlfWhsFileName = ([PARAMS.HTKFileName, '_whs', mlfFtype]); %name .mlf file
%     fod5 = fopen(PARAMS.fileNames.mlfWhsFileName,'a');
%     for k = 1:length(wsStartIdx)
%         fprintf(fod5,'"%s_W%s.lab"\n', fitName, num2str(k+PARAMS.firstWhsNum));
%         segFind = find(seg2Whs==k + PARAMS.firstWhsNum);
%         for j= 1:length(segFind)
%             fprintf(fod5,'%s_%s\n', species, segShape{segFind(j)});
%         end
%         fprintf(fod5,'.\n');
%     end
%     fclose(fod5);
%     
%     % write grammar file
%     % PARAMS.fileNames.gramWhsFileName = ([PARAMS.HTKFileName, '_whs', gramFType]); %name .gram file
%     fod6 = fopen(PARAMS.fileNames.gramWhsFileName,'a');
%     for k = 1:length(wsStartIdx)
%         segFind = find(seg2Whs==k + PARAMS.firstWhsNum);
%         for j= 1:length(segFind)
%             fprintf(fod6,'%s_%s ', species, segShape{segFind(j)});
%         end
%         fprintf(fod6,'\n');
%     end
%     fclose(fod6);
%     % end
%     PARAMS.lengthUpdateIdx = length(masterVector); % Use this to know what to
%     
% %     % write segment grammar file
% %     % PARAMS.fileNames.gramSegFileName = ([PARAMS.HTKFileName, '_seg', gramFType]); %name .gram file
% %     fod7 = fopen(PARAMS.fileNames.gramSegFileName,'a');
% %     for k = 1:length(wsStartIdx)
% %         segFind = find(seg2Whs==k + PARAMS.firstWhsNum);
% %         for j= 1:length(segFind)
% %             fprintf(fod7,'%s_%s ', species, segShape{segFind(j)});
% %             fprintf(fod7,'\n');
% %         end
% %     end
% %     fclose(fod7);
%     
%     % write HTK feature vectors for full whistles
%     for k = 1:length(wsStartIdx)
%         PARAMS.fileNames.mfcFileName = sprintf('%s%s_W%s.mfc', PARAMS.outdir, fitName, num2str(k+PARAMS.firstWhsNum));
%        % do (natural) log and mean norm
%         logFreq =log(segList{k}.(name){1,2});
%         meanlogFreq = mean(logFreq);
%         spWriteFeatureDataHTK(PARAMS.fileNames.mfcFileName, (logFreq - meanlogFreq), advance_ms, 'USER');
% %        % do mean norm
% %         meanFreq = mean(fitFilenew.get(k-1).getThisTonal.get_freq);
% %         spWriteFeatureDataHTK(PARAMS.fileNames.mfcFileName, ((fitFilenew.get(k-1).getThisTonal.get_freq) - meanFreq), advance_ms, 'USER');
%        % no normalization
% %        spWriteFeatureDataHTK(PARAMS.fileNames.mfcFileName, (fitFilenew.get(k-1).getThisTonal.get_freq), advance_ms, 'USER');
% %        % do (natural) log
% %        logFreq =log(fitFilenew.get(k-1).getThisTonal.get_freq);
% %        spWriteFeatureDataHTK(PARAMS.fileNames.mfcFileName, logFreq, advance_ms, 'USER');
%     end
%     % add onto indices when appending scp files in subsequent iterations
% end

%    spWriteFeatureDataHTK(PARAMS.fileNames.mfcFileName, masterVector,
%    advance_ms, 'USER'); % moved to batch_whistle_to_HTK.m