function [Trues False Miss] = moreHumanPicks(dsize, msize, TnumStart_man, ...
    TnumStart_det)

clear False Trues Miss
t=0; %initialize counters
f=0; %initialize counters
m=0;
%False = zeros(size(TnumStart_det)); %preallocating space
%True = zeros(size(TnumStart_det)); %preallocating space

for k=1:dsize(1,1)
    currdiff=abs(TnumStart_man(:)-TnumStart_det(k));
    indtrue = find(currdiff<=datenum([0 0 0 0 0 4]));
    if size(indtrue,1)>0
        t = t+1;
        [val,ix] = min(currdiff(indtrue));
        Trues(t) = TnumStart_man(indtrue(ix));
    else f = f+1;
        False(f) = TnumStart_det(k);
    end    
end

exist Trues;
if ans==1
    [Miss I] = setdiff(TnumStart_man(:),Trues(:)); %finding the calls the detector didn't get
    % Miss(:,2) = TnumStart_det(I,2);  %can comment score in when more
    % detections than manual picks.
else Miss = TnumStart_det;
    Trues = [];
end
%Miss(:,2) = I;
exist False;
if ans==0
    False = [];
end

indt = find(Trues(:)~=0);
indf = find(False(:)~=0);
TrueStr = datestr(Trues(indt)); %matrix containing True calls
FalseStr = datestr(False(indf)); %matrix containg False calls

tsize=size(TrueStr,1);
fsize=size(FalseStr,1);
mval = msize-tsize;
fprintf('Missed calls: %g.\n ',mval(1,1));

% exist Miss;
% if ans == 1
%     %msize = find(isnan(Miss(:))~=1);
%     %MissStr = datestr(Miss(:,1)); %matrix containing Miss calls
%     %msize=size(not(isnan(Miss(:,1))));
%     msize = length(Miss);
%     fprintf('Missed calls: %g.\n ',msize(1,1));
% else msize = 0;
%     fprintf('Missed calls: %g.\n ',msize(1,1));
%     Miss = [];
% end

%datevec(Trues)

fprintf('True Calls: %g.\nFalse Calls: %g.\n ',...
    tsize(1,1),fsize(1,1));

%True_scores = True(:,2);
% False_scores = False(:,2);