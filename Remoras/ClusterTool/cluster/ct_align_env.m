function envSetAlign = ct_align_env(envSet)

nEnv = size(envSet,1);
envLen = size(envSet,2);
midLine = envLen/2;
midLineBuff = round(midLine*.10);
[~,I] = max(envSet(:,midLine-midLineBuff:midLine+midLineBuff),[],2);
peakLoc = I+ (midLine-midLineBuff);
% peakLoc = (midLine-midLineBuff+I);
offsetIdx = peakLoc-midLine;
envSetAlign = zeros(size(envSet));
for iE =1:nEnv
    thisEnv = envSet(iE,:);
    % newEnv = zeros(size(thisEnv));
    if offsetIdx(iE)<0
        alignedIdx = 1:(peakLoc(iE)+midLine);
        thisEnvPadded = [zeros(1,abs(offsetIdx(iE))),thisEnv(alignedIdx)];
    else
        alignedIdx = (offsetIdx(iE)+1):envLen;
        thisEnvPadded = [thisEnv(alignedIdx),zeros(1,abs(offsetIdx(iE)))];
    end
    envSetAlign(iE,:) = thisEnvPadded;
end