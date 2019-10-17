function sh_detector_batch
% sh_detector_batch.m

global REMORA

% get detection parameters
sec2dnum = 60*60*24; % conversion factor to get from seconds to matlab datenum
durWind = REMORA.sh.settings.durWind;
slide = REMORA.sh.settings.slide;
tave = REMORA.sh.ltsa.tave;
minPassage = REMORA.sh.settings.minPassage;

tic;  % Note start time

% Initialize
populateTimes = [];
populateLabels = {};
shipTimes = [];
shipLabels = {};
newperc = 0;

% how many windows will be used to process ltsa
% TotalWindows = ceil(REMORA.sh.ltsa.durtot/durWind);
TotalWindows = length(REMORA.sh.ltsa.dnumStart(1):datenum([0 0 0 0 0 slide]):REMORA.sh.ltsa.end.dnum);

fprintf('Running Ship batch detection for %d files\n',REMORA.sh.ltsa.nxwav)
disp('Check bar progress window')

% get ltsa window motion parameters
dnumSnippet = REMORA.sh.ltsa.dnumStart(1);
progressh = waitbar(0,'Start processing...','Name',sprintf('Processing file: %s',REMORA.sh.ltsa.infile));
t = toc;
for itr1 = 1:TotalWindows
    
    %%% Detect ships
    % Apply detector to the central window (of size durWind and to the
    % overlapping windows of "slide" seconds before and after start of the
    % central window
    
    % Read the spectral data of the snippet of data and apply detector
    % Central Window
    [pwr,startIndex,startBin] = sh_get_pwr_window(dnumSnippet);
    [ships,labels,~] = sh_passage_detector(pwr,0);
    dnumShips = (ships./sec2dnum)*tave + dnumSnippet; % convert to actual times
    
    
    if ~isempty(dnumShips)
        %%% Populate data to save to corresponding files
        % Convert all ship_s from matlab times to real times
        populateTimes = [populateTimes; dnumShips + datenum([2000,0,0])];
        populateLabels = [populateLabels; labels];
    end
    
    % only text will be displayed in command window if number increased
    perc = round(itr1/TotalWindows*100);
    if perc ~= newperc
        newperc = perc;
        waitbar(newperc/100,progressh,sprintf('%d%% completed',newperc))
    end
    
    dnumSnippet = sh_read_time_window(startIndex,startBin);
end

if ~isempty(populateTimes)
    
    %%% Merge detections from overlapping windows
    waitbar(1,progressh,'Merging detections from overlapping windows')
    
%     nline  = repmat((1:size(populateTimes,1))',1,2);
%     figure,plot(populateTimes',nline','o-')
    
    % find union of intervals
    populateTimes = sort(populateTimes,2);
    nrow = size(populateTimes,1);
    [populateTimes, ind] = sort(populateTimes(:));
    n = [(1:nrow) (1:nrow)]';
    n = n(ind);
    c = [ones(1,nrow) -ones(1,nrow)]';
    c = c(ind);
    csc = cumsum(c); % =0 at upper end of new interval(s)
    irit = find(csc==0);
    ilef = [1; irit+1];
    ilef(end) = []; % no new interval starting at the very end
    
    % merge detections that are separate less than minPassage
    if length(ilef) > 1
        remove = find(populateTimes(ilef(2:end))- populateTimes(irit(1:end-1))...
            < datenum([0 0 0 0 0 minPassage]));
        ilef(remove+1) = [];
        irit(remove) = [];
    end
    % shipTimes is start and end points of the new intervals
    shipTimes = [populateTimes(ilef) populateTimes(irit)];
    
    % shipTimesIndex is the corresponding indices of the start and end points
    % in terms of what row of x they occurred in.
    shipTimesIndex = [n(ilef) n(irit)];
    
    %%%% organize labels
    shipLabels =  repmat({'unknown'},size(populateTimes,1),1);
    diffCol = shipTimesIndex(:,2) - shipTimesIndex(:,1);
    % overlapping times that have the same labels
    idxOld = shipTimesIndex(diffCol == 0,1); % index previous matrix
    idxNew = find(diffCol == 0); % index to new matrix
    shipLabels(idxNew) = populateLabels(idxOld);
    % overlapping times that have different labels, store the most frequent
    % label
    rowDiff = find(diffCol ~= 0);
    for itr2 = 1:length(rowDiff)
        ovrlapLabels = populateLabels(...
            shipTimesIndex(rowDiff(itr2),1):shipTimesIndex(rowDiff(itr2),2));
        caseA = sum(strcmp(ovrlapLabels,'ambient'));
        caseS = sum(strcmp(ovrlapLabels,'ship'));
        if caseA > caseS
            shipLabels(rowDiff(itr2)) = {'ambient'};
        elseif caseA < caseS
            shipLabels(rowDiff(itr2)) = {'ship'};
        else % if they are equal, prioritize ship (may change this to unknown)
            shipLabels(rowDiff(itr2)) = {'ship'};
        end
    end 
end

close(progressh);
disp('Prepare to store detections....')

if ~isempty(shipTimes)
    % save all detections with real datenums in a mat file
    filename = split(REMORA.sh.ltsa.infile,'.ltsa');
    matname = ['Ship_detections_',filename{1},'.mat'];
    settings = REMORA.sh.settings;
    % remove padded text
    shipLabels(strcmp(shipLabels,'unknown')) = [];
    save(fullfile(REMORA.sh.settings.outDir,matname),'shipTimes',...
        'shipLabels','settings','-mat','-v7.3');
    fprintf('Detections saved at: %s\n',fullfile(REMORA.sh.settings.outDir,matname));
    
    labelname = ['Ship_labels_',filename{1},'.tlab'];
    sh_write_labels(fullfile(REMORA.sh.settings.outDir,labelname), shipTimes - datenum([2000 0 0 0 0 0]), shipLabels, 'Binary', true);
    fprintf('Labels saved at: %s\n',fullfile(REMORA.sh.settings.outDir,labelname));

    % create csv file
    if REMORA.sh.settings.saveCsv
        csvname = ['Ship_detections_',filename{1},'.csv'];
        sh_write_csv_file(fullfile(REMORA.sh.settings.outDir,csvname),shipTimes,shipLabels)
        fprintf('Labels saved at: %s\n',fullfile(REMORA.sh.settings.outDir,labelname));
    end
    
else
    fprintf('No detections in file: %s\n',...
        fullfile(REMORA.sh.ltsa.inpath,REMORA.sh.ltsa.infile))
end

fprintf('LTSA batch detection completed (%d files, processing time: %s)\n', ...
    REMORA.sh.ltsa.nxwav, sectohhmmss(toc));

