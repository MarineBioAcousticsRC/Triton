function countcofi2GMTSpeciesFiles(effFile,odir)
% BJT 
% ~08/08/2018
%
% Use this file to generate species sighting text files for use with 
% D:\Projects\CalCofi\code\GMT_DetectionMap_170908
%
% Intended to be run on count cofi "expanded" data
% ex: idir =
% 'D:\Projects\CalCofi\CalCofiDensityModeling\visualLogs\countCofiFiles\2017-11\expanded'
%

cruiseExpr = 'CC-([0-9]{6})';
cruiseNum = regexp(effFile, cruiseExpr, 'tokens', 'once');

if ~isempty(cruiseNum)
    cruiseNum = cruiseNum{1};
    cruiseNum = sprintf('%s-%s', cruiseNum(1:4), cruiseNum(5:6));
else
    error('Could not extract cruise number from effFile.');
end

% % expFormatSpec = '%d %.7f %.7f %s %s %.2f %.2f %s %s %s %s %s %s %s %.2f %s %d %.2f %s %.2f %.2f %d %.2f';
% expFormatSpec0 = '%d %.7f %.7f %s %s %.2f %.2f %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s'; % this is the basic info
A = '%s ';
% expXFormatSpec =strtrim(repmat(A,1,60)); % this is the expanded data
expFormatSpec =strtrim(repmat(A,1,60)); % this is the expanded data
% expFormatSpec = [ expFormatSpec0 ' ' expXFormatSpec ];
% need to be sure to convert indices 7+ to proper datatype when writing to
% xls

ffn = effFile
fid = fopen(ffn,'r');
expData = textscan(fid,expFormatSpec,'Delimiter',',','CollectOutput',1);
fclose(fid);

expData = [ expData{:} ]; % flatten cell

% remove header rows
hdrIdxs = find(strcmp(expData(:,1),'EID'));
expData(hdrIdxs,:) = [];

sitEffortIdxs = find(strcmp('SIT',expData(:,4)) & strcmp('0',expData(:,10))); % SIT code and On effort
lonidx = 2; 
latidx = 3;
sp1idx = 41;
sp2idx = 43;

sitData = cell(length(sitEffortIdxs),4); % lon/lat/sp1/sp2
sitData(:,1) = expData(sitEffortIdxs,lonidx);
sitData(:,2) = expData(sitEffortIdxs,latidx);
sitData(:,3) = expData(sitEffortIdxs,sp1idx);
sitData(:,4) = expData(sitEffortIdxs,sp2idx);
sitData = [ sitData(:,1), sitData(:,2), sitData(:,3);sitData(:,1), sitData(:,2), sitData(:,4)];
sitData(strcmp('',sitData(:,3)),:) = []; % remove empty 
sitData(strcmp('NA',sitData(:,3)),:) = []; % remove NA


clear expData


uSp = unique(sitData(:,3));

fprintf('Writing GMT species files for %s:\n',cruiseNum); 
fprintf('\t%s\n',uSp{:})

fprintf('Output Directory: %s\n', odir);
dcounter = 0;
for s=1:length(uSp)
    sp = uSp{s};
    spData = sitData(find(strcmp(sp,sitData(:,3))),1:2);
    sp = strtrim(sp);
    if strcmp(sp,'ZICA')
        sp = 'ZiCa';
%     elseif~ismember(sp,{'ULW','UD','ULD'}) % ULW,UD,ULD all caps for output file
    elseif ~ismember(sp,{'ULW','UD','ULD','UNID_CETAC','USM','USW','UNZIPH','USC','UC'}) % ULW,UD,ULD all caps for output file
        sp = lower(sp);
        idx=regexp([' ' sp],'(?<=\s+)\S','start')-1;        
        sp(idx)=upper(sp(idx));
    end
    ofn = sprintf('%s_%s.txt', cruiseNum,sp);
    offn = fullfile(odir,ofn);
    fod = fopen(offn,'w');
    cellfun(@(x,y) fprintf(fod,'%s\t%s\n',x,y), spData(:,1), spData(:,2));
    fclose(fod);
    fprintf('%s - %d detections\n', ofn, size(spData,1))
    dcounter = dcounter+size(spData,1);
end
fprintf('%d on-effort sightings\n', dcounter);

% 
% % prune sightings...
% % replace all NA with ''
% sitData(:,2=='NA') = '';
% 
% %both species fields empty...
% b1idxs = find(strcmp('',sitData(:,2
% disp('!');
