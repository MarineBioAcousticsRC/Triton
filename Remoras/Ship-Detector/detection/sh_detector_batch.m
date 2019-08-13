function sh_detector_batch
% sh_detector_batch.m

global REMORA

% detection parameters (%%%%%%%%% parameters to add in the settings file)
% % % % REMORA.sh.settings.REWavExt= '(\.x)?\.wav';   % data files must end in this regular expression
% % % % REMORA.sh.settings.RELtsaExt = '.s';   % Ship - Long term detection label extension

% get detection parameters
sec2dnum = 60*60*24; % conversion factor to get from seconds to matlab datenum
durWind = REMORA.sh.settings.durWind;
slide = REMORA.sh.settings.slide;
errorRange = REMORA.sh.settings.errorRange;
tave = REMORA.sh.ltsa.tave;
minPassage = REMORA.sh.settings.minPassage/sec2dnum;

tic;  % Note start time

% Initialize
populateTimes = [];
populateLabels = {};
newperc = 0;

% how many windows will be used to process ltsa
TotalWindows = ceil(REMORA.sh.ltsa.durtot/durWind);

disp('Start processing...')
fprintf('Running Ship batch detection for %d files\n',REMORA.sh.ltsa.nxwav)

% get ltsa window motion parameters
dnumSnippet = REMORA.sh.ltsa.dnumStart(1);

for itr1 = 1:TotalWindows
    
    %%% Detect ships 
    % Apply detector to the central window (of size durWind) and to the
    % overlapping windows of "slide" seconds before and after start of the 
    % central window
    
    % Read the spectral data of the snippet of data and apply detector
    % Central Window
    [pwr,startIndex,startBin] = sh_get_pwr_window(dnumSnippet); 
    [ships,labels,~] = sh_passage_detector(pwr,0);
    dnumShips = (ships./sec2dnum)*tave + dnumSnippet; % convert to actual times
    
    % Previous Window
    dnumPrevSnippet = dnumSnippet - datenum([0 0 0 0 0 slide]);
    
    % If earlier than start of ltsa, previous window will be the same like the central window
    if dnumPrevSnippet < REMORA.sh.ltsa.start.dnum
       dnumPrevSnippet = REMORA.sh.ltsa.start.dnum; 
    end
    [pwr,~,~] = sh_get_pwr_window(dnumPrevSnippet); 
    [shipsPrev,labelsPrev,~] = sh_passage_detector(pwr,0);
    dnumShipsPrev = (shipsPrev./sec2dnum)*tave + dnumPrevSnippet; % convert to actual times
    
    % Posterior window
    dnumPostSnippet = dnumSnippet + datenum([0 0 0 0 0 slide]);
    
    % If past the end of ltsa, posterior window will be the same like the central window
    if dnumPostSnippet > REMORA.sh.ltsa.end.dnum
       dnumPostSnippet = dnumSnippet; 
    end
    [pwr,~,~] = sh_get_pwr_window(dnumPostSnippet); 
    [shipsPost,labelsPost,~] = sh_passage_detector(pwr,0);
    dnumShipsPost = (shipsPost./sec2dnum)*tave + dnumPostSnippet;
    
    
    %%% Compare overlapping windows
    % Select detections that appear at central window and at least in one
    % of the overlapping windows, if not detected in the central window
    % because is cut at the edge, get times from the overlapping window
    selectShips = [];
    selectLabels = {};
    % create combination
    comb = ~[isempty(dnumShips) isempty(dnumShipsPrev) isempty(dnumShipsPost)];
    if isequal(comb,[1 1 1]) || isequal(comb,[1 1 0]) || isequal(comb,[1 0 1])
        for itr2 = 1:size(dnumShips,1)
            if  sum([~isempty(dnumShipsPrev) & abs(dnumShips(itr2,1) - dnumShipsPrev(:,1)) <= errorRange | ...
                    abs(dnumShips(itr2,2) - dnumShipsPrev(:,2)) <= errorRange ; ...
                    ~isempty(dnumShipsPost) & abs(dnumShips(itr2,1) - dnumShipsPost(:,1)) <= errorRange | ...
                    abs(dnumShips(itr2,2) - dnumShipsPost(:,2)) <= errorRange])
                selectShips = [selectShips; dnumShips(itr2,:)];
                selectLabels = [selectLabels; labels{itr2}];
            end
        end
        % if there are detection at the edges include them as well
        if size(dnumShips,1) ~= size(dnumShipsPrev,1)
            for itr2prev = 1: size(dnumShipsPrev,1)
                onEdge = find(dnumShipsPrev(itr2prev,1) < dnumSnippet & dnumShipsPrev(itr2prev,2) > dnumSnippet); % start before the central window and the end in the central window
                if onEdge
                    selectShips = [selectShips; dnumSnippet,dnumShipsPrev(itr2prev,2)];
                    selectLabels = [selectLabels; labelsPrev{itr2prev}];
                end
            end
        end
        % if there are detection at the edges include them as well
        if size(dnumShips,1) ~= size(dnumShipsPost,1)
           for itr2post = 1: size(dnumShipsPost,1) 
               endSnippet = dnumSnippet + datenum([0 0 0 0 0 durWind]);
               onEdge = find(dnumShipsPost(itr2post,1) <= endSnippet & dnumShipsPost(itr2post,2) > endSnippet); % the start have to be in the central window and the end passed
               if onEdge
                   selectShips = [selectShips; dnumShipsPost(itr2post,1), endSnippet];
                   selectLabels = [selectLabels; labelsPost{itr2post}];
               end
           end
        end
    end
    if isequal(comb,[0 1 0]) || isequal(comb,[0 1 1])
        % detection at the left edge of the window
        for itr3 = 1:size(dnumShipsPrev,1)
            onEdge = find(dnumShipsPrev(itr3,1) < dnumSnippet & dnumShipsPrev(itr3,2) > dnumSnippet); % start before the central window and the end in the central window
            if onEdge
                selectShips = [selectShips; dnumSnippet,dnumShipsPrev(itr3,2)]; 
                selectLabels = [selectLabels; labelsPrev{itr3}];
            end
        end
    end
    if isequal(comb,[0 0 1]) || isequal(comb,[0 1 1])
        % detection at the right edge of the window
        for itr4 = 1:size(dnumShipsPost,1)
            endSnippet = dnumSnippet + datenum([0 0 0 0 0 durWind]);
            onEdge = find(dnumShipsPost(itr4,1) <= endSnippet & dnumShipsPost(itr4,2) > endSnippet); % the start have to be in the central window and the end passed
            if onEdge
                selectShips = [selectShips; dnumShipsPost(itr4,1), endSnippet]; 
                selectLabels = [selectLabels; labelsPost{itr4}];
            end
        end
    end

    if ~isempty(selectShips)
        %%% Populate data to save to corresponding files 
        % Convert all ship_s from matlab times to real times
        populateTimes = [populateTimes; selectShips + datenum([2000,0,0])];
        populateLabels = [populateLabels; selectLabels];
    end
    
    % only text will be displayed in command window if number increased
    perc = round(itr1/TotalWindows*100);
    if perc ~= newperc
        newperc = perc; 
        progress = [num2str(newperc),'%'];
        fprintf('   %s completed\n',progress)
    end

    itr1 = itr1 + 1;
    dnumSnippet = sh_read_time_window(startIndex,startBin);
end

if ~isempty(populateTimes)
    [~,I] = sort(populateTimes(:,1));
    shipTimes = populateTimes(I,:);
    shipLabels = populateLabels(I);
    
    if size(shipTimes,1) > 1
        remove = find((shipTimes(2:end,1) - shipTimes(1:end-1,2)) < minPassage)';
        if ~isempty(remove)
            selStart = shipTimes(:,1); selStart(remove+1) = [];
            selEnd = shipTimes(:,2); selEnd(remove) = [];
            shipTimes = [selStart, selEnd];
            % compare if labels are different
            reLabel = ~strcmp(shipLabels(remove+1),shipLabels(remove));
            % different label, one was detected as ship, so keep it as
            % ship, end is deleted
            shipLabels(remove(reLabel == 1)) = {'ship'};
            shipLabels(remove+1) = []; % remove second
        end
    end
    % save all detections with real datenums in a mat file
    filename = split(REMORA.sh.ltsa.infile,'.ltsa');
    matname = ['Ship_detections_',filename{1},'.mat'];
    save(fullfile(REMORA.sh.settings.outDir,matname),'shipTimes',...
        'shipLabels','-mat','-v7.3');
    fprintf('Detections saved at: %s\n',fullfile(REMORA.sh.settings.outDir,matname));
    
    % save labels
    if REMORA.sh.settings.saveLabels
        labelname = ['Ship_labels_',filename{1},'.tlab'];
        sh_write_labels(fullfile(REMORA.sh.settings.outDir,labelname), shipTimes - datenum([2000 0 0 0 0 0]), shipLabels, 'Binary', true);
        fprintf('Labels saved at: %s\n',fullfile(REMORA.sh.settings.outDir,labelname));
    end

else
    fprintf('No detections in file: %s\n',...
        fullfile(REMORA.sh.ltsa.inpath,REMORA.sh.ltsa.infile))
end

fprintf('LTSA batch detection completed (%d files, processing time: %s)\n', ...
    REMORA.sh.ltsa.nxwav, sectohhmmss(toc));

