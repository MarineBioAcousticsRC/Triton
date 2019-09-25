% merge_airguns
% Script that is designed to merge output from xcorr_airgun_df100 after GPLreview.

clearvars

% STUFF TO MODIFY:
inDir = 'G:\SOCAL_N_63\SOCAL_N_63_Airguns'; % Location of the files to be merged.
fileNameStart = 'SOCAL_N_63'; % Give the first few letters of the file name you want to merge.
inFiles = dir(fullfile(inDir,strcat(fileNameStart,'*')));
outputFileName = 'Merged_SOCAL_N_63_AirgunDetections.csv';
boutGap = 15; % Minimum gap between detections in minutes.
% Detections separated by more than this are considered separate bouts.

groupPeriod = boutGap/60/24; % Convert gap into MatLab datenumber.

expTimes = [];
nFiles = length(inFiles);
fprintf('Found %.0f detection files\n', nFiles)
for j = 1:nFiles
    % Load the data in.
    inData = load(fullfile(inDir,inFiles(j).name),'bt');
    if ~isempty(inData.bt) % If there's data in bt.
        % Find detections flagged as "true"
        goodDetFlag = inData.bt(:,3) == 1;
        
        % Concatonnate the good detection times with previous ones.
        expTimes =[expTimes;inData.bt(goodDetFlag,4:5)];
    end
end

if isempty(expTimes)
   disp('No true detections in this folder. No output file produced.')
   return
else 
   fprintf('Found %.0f verified detections\n',length(expTimes(:,1)))
end

% Check for times that = 0 (Why is this happening?) For some reason there
% are detections with a start time of 0 and an end time of 0? Must be
% something to do with GPL possibly? (1/24/2018). 

% Modified by Kait.

zeroTimes1 = find(expTimes(:,1)==0);
zeroTimes2 = find(expTimes(:,2)==0);
zeroTimes = union(zeroTimes1,zeroTimes2);
if ~isempty(zeroTimes)
    warning('Found %.0f detection times == 0, removing them.', length(zeroTimes));
    expTimes(zeroTimes,:) = [];
end

% Make sure detections are sorted in time:

[~,k1]=sort(expTimes(:,1));
expTimes =expTimes(k1,:);

detGaps = diff(expTimes(:,1));
boutGaps = find(detGaps>groupPeriod);
boutStart = [expTimes(1);expTimes(boutGaps+1)];   % Start time of bout.
boutEnd = [expTimes(boutGaps);expTimes(end)];   % End time of bout.

fprintf('Found %.0f bouts\n',length(boutStart))

% Write output file.

outFileName = fullfile(inDir,outputFileName);
fprintf('Writing output file to: %s\n',outFileName)
dlmwrite(outFileName,m2xdate([boutStart,boutEnd]),'precision',50);

% Next Steps: 
% 1) Open output CSV in Excel, convert dates to mm/dd/yyyy HH:MM:SS format.
% 2) Paste the two columns into a Triton-Style Spreadsheet.
% 3) Modify the spreadsheet metadata tab to match the appropriate
% deployment.
% 4) Upload to Tethys through Triton.


