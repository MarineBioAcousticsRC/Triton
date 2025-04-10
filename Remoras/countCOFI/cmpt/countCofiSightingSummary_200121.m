function [ spStr, spCounts, sightInfo ] = countCofiSightingSummary_200121(exFile)
%
% Generate visual detection summary table from countCofi expanded data
% Separate by Mys/Odont 
% Use to provide data for keeping tables 1-3 up to date after the switch
% was made to count cofi
%
% Use function countCofiCombineDailyEX_191120(idir) to combine daily
% expanded files into single text file if generating summary for entire
% cruise
%
% exFile = full pathname to count cofi expanded data file
% exFile = 'G:\Shared drives\MBARC_All\CalCOFI\code\fromBJT\countCOFI\expanded\CC-201708.txt';
%   example = 'D:\2018-06\expanded\CC-20180609.txt'
%
% spStr = Species codes, row aligned with spCounts
% spCounts = Sighting counts for cruise 
%   col1 = Total # sightings/groups
%   col2 = Total # of individuals
%
%
% 11/22/2019
% JST says that special handling needed for LB, UNZIPH,SC since species code is not 
% present in countCofi...observers enter blank species id or OTH, and mention
% species in comment when sighted
% unid_furseal missing as well but no one cares about pinnipeds :(
% 
% BJT bthayre@ucsd.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Only process southern transects, STransects = 1
% process all transects, STransects = 0
STransects = 0;

% species we care about 

spStr = {
    'BA';
    'BM';
    'BP';
    'ER';
    'MN'; 
    'ULW';
    'DC'; 
    'DD';
    'DSP';
    'GG';
    'GM';
    'LB';
    'LO';
    'OO';
    'PD';
    'PM';
    'SC';
    'TT';
    'UD';
    'ZICA';
    };


spCounts = zeros(length(spStr),2);  % col1 = number of sightings, col2 = number of individuals 

A = '%s ';
expFormatSpec =strtrim(repmat(A,1,60)); % this is the expanded data
onEffort = 1;

ffn = exFile;
fid = fopen(ffn,'r');
expData = textscan(fid,expFormatSpec,'Delimiter',',','CollectOutput',1);
fclose(fid);

expData = [ expData{:} ]; % flatten cell

%save header info and remove header rows
hdrIdxs = find(strcmp(expData(:,1),'EID'));
hdr = expData(hdrIdxs(1),:);
expData(hdrIdxs,:) = [];

% find comment column, and save comments...whitespace stripping can mess
% them up 
cmtCol = find(strcmpi(hdr,'X35')); % comment column
cmt = expData(:,cmtCol);

% remove whitespace padding from data...usually not an issue
expData = strip(expData);
expData(:,cmtCol) = cmt; % replace comment column with originals

fprintf('Input file %s\n', ffn);
fprintf('\t%d events\n', size(expData,1));

if onEffort 
    effCol = find(strcmpi(hdr,'eff'));
    onEffi = find(strcmpi(strip(expData(:,effCol)),'0'));
    expData = expData(onEffi,:);
    fprintf('\t%d on effort events\n', size(expData,1));
end

% Parse out sightings
evCol = find(strcmpi(hdr,'ev'));
siti = find(strcmpi(strip(expData(:,evCol)),'SIT')); % sightings
updi = find(strcmpi(strip(expData(:,evCol)),'UPD')); % sighting updates
sitData = expData(sort([siti;updi]), :); 

% Parse out Cetacean sightings...sighting # cumulative over cruise
% other taxa sightning # get reset each day
taxCol = find(strcmpi(hdr,'X1'));
taxi = find(strcmpi(strip(sitData(:,taxCol)),'CETA'));
sitData = sitData(taxi,:);

%%%% I think the manual has a typo in the expanded data/data format section
%%%% under SIT/UPD ( table 6 ), column X6 is skipped...so anything greater than X5 in
%%%% manual should be decremented by 1 ( i.e. column X18 is really X17 )
%%%% -BJT

snumCol = find(strcmpi(hdr,'X2')); % sighting # column
latCol = find(strcmpi(hdr,'y')); % lat column
lonCol = find(strcmpi(hdr,'x')); % lon column
dtCol =  find(strcmpi(hdr,'when'));% date time column
bestCol = find(strcmpi(hdr,'X13')); % best 
minCol = find(strcmpi(hdr,'X14')); % min 
maxCol = find(strcmpi(hdr,'X15')); % max
sp1Col = find(strcmpi(hdr, 'X17')); % species1 column
sp1PercCol = find(strcmpi(hdr,'X18')); % species1 group percentage column
sp2Col = find(strcmpi(hdr,'X19')); % species2 column
sp2PercCol = find(strcmpi(hdr,'X20')); % species 2 group percentage column

% get unique sightings
try
    sitNums = str2double(sitData(:,snumCol));
catch ME
    fprintf('Failed to convert sight numbers to double datatype!\n');
    fprintf('Raw sighting numbers:\n')
    disp(sitData(:,snumCol));
    fprint('%s\n', ME.message);
end 

sitNums = sort(unique(sitNums));

sightInfo = {}; % sighting data to be used for counts
              % goal is to identify one entry per sighting event to use
              % will then calculate counts from this cell array

for s=1:length(sitNums)
    sitn = num2str(sitNums(s));
    % get idxs of sighting with sightnumber = sitn
%    xsiti = find(strcmp(sitData(:,snumCol),sitn));
    xsiti = find(strcmp(strip(sitData(:,snumCol),'left','0'),sitn)); % sometimes leading zeros are preserved
    xsitData = sitData(xsiti,:); % sighting data for this sighting number
    % check if sighting info was updated
    updi = find(strcmp(xsitData(:,evCol),'UPD'));
    if length(updi) > 1 
%         fprintf('\tMULTIPLE UPDATES FOUND...USING LAST UPDATE');
%         fprintf('\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', ...
%             xsitData{updi(end),evCol},....
%             xsitData{updi(end),dtCol},....
%             xsitData{updi(end),latCol},...
%             xsitData{updi(end),lonCol},...
%             xsitData{updi(end),sp1Col},...
%             xsitData{updi(end),sp1PercCol},...
%             xsitData{updi(end),sp2Col},...
%             xsitData{updi(end),sp2PercCol},...
%             xsitData{updi(end),bestCol},...
%             xsitData{updi(end),minCol},...
%             xsitData{updi(end),maxCol},...
%             xsitData{updi(end),cmtCol} );
        sinfoi = updi(end);
    end
    
    if ~isempty(updi)
        sinfoi = updi(end); % use update if exists, last if there are multiple updates
    else
        sinfoi = size(xsitData,1); % otherwise use last SIT entry for sighting number
    end 

    fprintf('Sight #%s\n', sitn);
  
    if STransects % only include southern 6 CC transects
        % station info for line 76.7...don't include anything after this
        % station #, lat, lon 
        STLim = [
            100.0,33.38824,-124.32289;
            90.0,33.72158,-123.63335;
            80.0,34.05491,-122.94109;
            70.0,34.38824,-122.24608;
            60.0,34.72158,-121.54828;
            55.0,34.88824,-121.19831;
            51.0,35.02158,-120.91782;
            49.0,35.08824,-120.77740;
            ];
        
        % judge by first position in sighting info
        pos = [  str2double(xsitData{1,latCol}), str2double(xsitData{1,lonCol}) ]; 
        
        % fudge factor to allow for trip loitering around station
        ff = 0.1; % degrees
        
        % check if position NW of any of the 76.7 stations 
        NWb = arrayfun(@(x,y) pos(1) > x && pos(2) < y, STLim(:,2)+ff, STLim(:,3)+ff);
        if any(NWb)
            fprintf('\tpast line 76.7 skipping, %s - %s | %s\n',...
                datestr(xsitData{1,dtCol},'mm/dd/yyyy HH:MM:SS'), ...
                xsitData{1,latCol}, xsitData{1,lonCol});               
              % skip to next sighting number
            continue;
        end    
    end    
    
    % loop over sighting number events and print info
    if 1
        for x=1:length(xsiti) 
            if isempty(xsitData{sp1Col})
                1;
            end
            fprintf('\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', ...
                xsitData{x,evCol},....
                xsitData{x,dtCol},....
                xsitData{x,latCol},...
                xsitData{x,lonCol},...
                xsitData{x,sp1Col},...
                xsitData{x,sp1PercCol},...
                xsitData{x,sp2Col},...
                xsitData{x,sp2PercCol},...
                xsitData{x,bestCol},...
                xsitData{x,minCol},...
                xsitData{x,maxCol},...
                xsitData{x,cmtCol} );

%             fprintf('\t%s\t%s\n', xsitData{x,sp1Col},xsitData{x,sp2Col});
        end 
    end    
  
    
%     if strcmpi(sitn,'21')
%         1;
%     end
    
    % Sighting info to use for this sighting number
    sightInfo(end+1,:) = xsitData(sinfoi,:);
    
    if isempty(strip(sightInfo{end,sp1Col})) || strcmpi(strip(sightInfo{end,sp1Col}),'NA')
        fprintf('EMPTY SPECIES ID!\n');
        fprintf('Edit expanded file or skip this detection\n');
%         return
    end
    
    if strcmpi(strip(sightInfo{end,sp1Col}),'OTH') || strcmpi(strip(sightInfo{end,sp2Col}),'OTH')
        fprintf('OTH SPECIES!\n');
        fprintf('Edit expanded file or skip this detection\n');
%         return
    end
    
    % add check for mixed species group here
    if str2double(sightInfo{end,sp2PercCol}) > 0
%         spi = strcmpi(spStr,xsitData{x,sp1Col});
%         spC = str2double(sightInfo{sp1PercCol})/100;  % fraction of 100

        % Take sighting and break into two distinct sighting events for
        % counting
        spC1 = str2double(sightInfo{end,sp1PercCol})/100;
        spC2 = str2double(sightInfo{end,sp2PercCol})/100;
        
        spBest = str2double(sightInfo{end,bestCol});
        spMin = str2double(sightInfo{end,minCol});
        spMax = str2double(sightInfo{end,maxCol}); 
        
        sightInfoTemp1 = sightInfo(end,:);
        sightInfoTemp2 = sightInfo(end,:);
        
        % sort out species1
        sightInfoTemp1{sp1PercCol} = '100';
        sightInfoTemp1{sp2Col} = '';
        sightInfoTemp1{sp2PercCol} = '0';
        sightInfoTemp1{bestCol} = num2str(round(spC1*spBest));
        sightInfoTemp1{minCol} = num2str(round(spC1*spMin));
        sightInfoTemp1{maxCol} = num2str(round(spC1*spMax));
        sightInfo(end,:) = sightInfoTemp1; 
        
        % sort out species2 
        sightInfoTemp2{sp1Col} = sightInfoTemp2{sp2Col};
        sightInfoTemp2{sp1PercCol} = '100';
        sightInfoTemp2{sp2Col} = '';
        sightInfoTemp2{sp2PercCol} = '0';
        sightInfoTemp2{bestCol} = num2str(round(spC2*spBest));
        sightInfoTemp2{minCol}= num2str(round(spC2*spMin));
        sightInfoTemp2{maxCol} = num2str(round(spC2*spMax));   
        sightInfo(end+1,:) = sightInfoTemp2;
        
        % make 
%         fprintf('MIXED SPECIES!\n')
%         return
    end    
                                                                            
end

% Use representative sighting entries to do counts
% Loop over species of interest
for y=1:length(spStr)
    % strip whitespace off for species match
    sidx = find(strcmpi(spStr{y},strip(sightInfo(:,sp1Col)) ) );
    if isempty(sidx)
        continue
    else
        % get counts of species
        spTotal = sum(str2double(sightInfo(sidx,bestCol))); % best estimate of inidivudals sighted
        spN = length(sidx); % number of sightings/groups of species
        
        spCounts(y,1) = spN; 
        spCounts(y,2) = spTotal;
    end
end


disp('Groups')
disp(spCounts(:,1));
disp('Individuals') 
disp(spCounts(:,2));

1;