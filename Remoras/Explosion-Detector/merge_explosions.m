% merge_explosions.m merges explosion files from the same site from
% different analysts to pick up any missed detections ran by different
% detector settings in xcorr_explosion_p2_v4.m.

% Edits made by Kait Frasier & Macey Rafter (1/31/2018).

% Input folder containing old explosion files:
inDirOld = 'E:\Explosions\LJ39P';
inFilesOld = dir(strcat(inDirOld,'\*.mat'));

% Input folder containing new explosion files:
inDirNew = 'E:\Explosions\LJ39P_version2';
inFilesNew = dir(strcat(inDirNew,'\*.mat'));

if length(inFilesOld) ~= length(inFilesNew)
    warning('Number of files differs between both folders. This is a bad sign.')
end

% Output folder:
outputFolder = ('E:\Explosions\MergedFiles\Merged_LJ39P');
if ~exist(outputFolder,'dir')
    mkdir(outputFolder);
end

% For each file in inDirOld, find the file with the same
% name in inDirNew:
for iFile =1:length(inFilesOld)
    btOld = load(fullfile(inDirOld,inFilesOld(iFile).name));
    if ~isempty(btOld.bt)
        % Load both:
        % (This assumes that each file in "old" has an exact match in "new". It
        % would be wise to check that the file actually exists in "new" before
        % loading it.)
        btNew = load(fullfile(inDirNew,inFilesOld(iFile).name));
        
        % Find all the lines in both:
        [~,ia,~] = intersect(btOld.bt(:,1:2),btNew.bt(:,1:2),'rows');
        % Find all the lines in new only:
        [~,ib] = setdiff(btNew.bt(:,1:2),btOld.bt(:,1:2),'rows');
        % Merge them into a new bt matrix:
        % (All of the parameters of each of the detection files listed below).
        bt = [btOld.bt(ia,:);btNew.bt(ib,:)];
        allSmpPts = [btOld.allSmpPts(ia,:);btNew.allSmpPts(ib,:)];
        allExp = [btOld.allExp(ia,:);btNew.allExp(ib,:)];
        allCorrVal = [btOld.allCorrVal(ia,:);btNew.allCorrVal(ib,:)];
        allDur = [btOld.allDur(ia,:);btNew.allDur(ib,:)];
        allRmsNBefore = [btOld.allRmsNBefore(ia,:);btNew.allRmsNBefore(ib,:)];
        allRmsNAfter = [btOld.allRmsNAfter(ia,:);btNew.allRmsNAfter(ib,:)];
        allRmsDet = [btOld.allRmsDet(ia,:);btNew.allRmsDet(ib,:)];
        allPpNBefore = [btOld.allPpNBefore(ia,:);btNew.allPpNBefore(ib,:)];
        allPpNAfter = [btOld.allPpNAfter(ia,:);btNew.allPpNAfter(ib,:)];
        allPpDet = [btOld.allPpDet(ia,:);btNew.allPpDet(ib,:)];
        
        % Sort all of the parameters by start time:
        [bt,index] = sortrows(bt,1);
        allSmpPts = allSmpPts(index,:);
        allExp = allExp(index,:);
        allCorrVal = allCorrVal(index,:);
        allDur = allDur(index,:);
        allRmsNBefore = allRmsNBefore(index,:);
        allRmsNAfter = allRmsNAfter(index,:);
        allRmsDet = allRmsDet(index,:);
        allPpNBefore = allPpNBefore(index,:);
        allPpNAfter = allPpNAfter(index,:);
        allPpDet = allPpDet(index,:);
        
        parm = btNew.parm;
        rawStart = btNew.rawStart;
        rawDur = btNew.rawDur;
        
        % Save bt to new file (not sure if we need to also store other
        % variables).
    else
        % if btOld is empty, then just load and save everything from btNew
        load(fullfile(inDirNew,inFilesOld(iFile).name))
    end
    % save output to new file in different folder, same name.
    save(fullfile(outputFolder,inFilesOld(iFile).name),'bt','allSmpPts',...
        'allExp','allCorrVal','allDur','allRmsNBefore','allRmsNAfter','allRmsDet',...
        'allPpNBefore','allPpNAfter','allPpDet','parm','rawStart','rawDur')
end
