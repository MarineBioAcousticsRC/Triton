function sp_dt_HR_batch(fullFiles,fullLabels,p,encounterTimes)

N = size(fullFiles,1);
p.previousFs = 0; % make sure we build filters on first pass

% get file type list
fTypes = sp_io_getFileType(fullFiles);
parfor idx1 = 1:N % for each data file
    fprintf('beginning file %d of %d \n',idx1,N)
    %(has to be inside loop for parfor, ie, filters are rebuilt every time,
    % can be outside for regular for)
    pTemp = p;
    recFile = fullFiles{idx1};
    labelFile = fullLabels{idx1};
    matFileOut = strrep(labelFile,'.c','.mat');
    if ~pTemp.overwrite && exist(matFileOut, 'file') == 2
        fprintf('DetectionFile %s already exists.\n',matFileOut)
        fprintf('Overwrite option is false, skipping to next file.\n')
        continue
    end
    % read file header
    hdr = sp_io_readXWAVHeader(fullFiles{idx1}, pTemp,'fType', fTypes(idx1));

    if isempty(hdr)
        continue % skip if you couldn't read a header
    elseif hdr.fs ~= pTemp.previousFs
        % otherwise, if this is the first time through, build your filters,
        % only need to do this once though, so if you already have this
        % info, this step is skipped
        
        [previousFs,pTemp] = sp_fn_buildFilters(pTemp,hdr.fs);
        pTemp.previousFs = previousFs;
        
        pTemp = sp_fn_interp_tf(pTemp);
        if ~isfield(pTemp,'countThresh') || isempty(pTemp.countThresh)
            pTemp.countThresh = (10^((pTemp.dBppThreshold - median(pTemp.xfrOffset))/20))/2;
        end
    end
    starts = [];stops = [];
    if exist(labelFile,'file')
        % Read in the .c file produced by the short term detector.
        [starts,stops] = sp_io_readLabelFile(labelFile);
    else
        fprintf('No low res label file matching %s\n',recFile)
        continue
    end
    % Open xwav file
    fid = fopen(recFile, 'r');
    
    % Look for clicks, hand back parameters of retained clicks
    [cParams,f] = sp_dt_processHRstarts(fid,starts,stops,...
        pTemp,hdr,recFile);
    
    % Done with that file
    fclose(fid);
    fclose all;
    fprintf('done with %s\n', recFile);
    
    % Run post processing to remove rogue loner clicks, prior to writing
    % the remaining output files.
    clickTimes = sortrows(cParams.clickTimes);
    
    keepFlag = sp_dt_postproc(labelFile,clickTimes,p,hdr,encounterTimes);
    keepIdx = find(keepFlag==1);
    
    % save a mat file now, rather than recalculating later
    cParams.clickTimes = clickTimes(keepIdx,:);
    cParams.ppSignalVec = cParams.ppSignalVec(keepIdx,:);
    cParams.durClickVec = cParams.durClickVec(keepIdx,:);
    cParams.bw3dbVec = cParams.bw3dbVec(keepIdx,:);
    
    cParams.specClickTfVec = cParams.specClickTfVec(keepIdx,:);

    cParams.peakFrVec = cParams.peakFrVec(keepIdx,:);
    cParams.deltaEnvVec = cParams.deltaEnvVec(keepIdx,:);
    cParams.nDurVec = cParams.nDurVec(keepIdx,:);
    
    if ~isempty(keepIdx)
        cParams.yFiltVec = cParams.yFiltVec(keepIdx);
        cParams.yFiltBuffVec = cParams.yFiltBuffVec(keepIdx);

    else
        cParams.yFiltVec = {};
        cParams.yFiltBuffVec = {};
    end
    
    sp_fn_saveDets2mat(matFileOut,cParams,f,hdr,p);
end
