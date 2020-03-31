function [Trues False Miss] = moreDetPicks(dsize, msize, TnumStart_man, ...
       TnumStart_det)

   clear False Trues Miss
t=0; %initialize counters
f=0; %initialize counters
m=0; 
%size(TnumStart_det)
False = zeros(size(TnumStart_det)); %preallocating space
Trues = zeros(size(TnumStart_det)); %preallocating space
Miss = zeros(size(TnumStart_man)); %preallocating space

for k=1:msize(1,1)
    %for i=1:dsize(1,1)
        currdiff=abs(TnumStart_det(:)-TnumStart_man(k));
        indtrue = find(currdiff<=datenum([0 0 0 0 0 4]));
        if size(indtrue,1)>0
            t = t+1;
            [val,ix] = min(currdiff(indtrue));
            Trues(t) = TnumStart_det(indtrue(ix));
         else m = m+1;
             Miss(m) = TnumStart_man(k);
        end
        clear indtrue;
end

exist Trues;
if ans==1
    [False I] = setdiff(TnumStart_det(:),Trues(:)); %finding the calls the detector didn't get
else False = TnumStart_det;
    Trues = [];
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
% Miss = nonzeros(Miss);
% if ans == 1
%     mval = length(Miss);
%     fprintf('Missed calls: %g.\n ',mval(1,1));
% else mval = 0;
%     fprintf('Missed calls: %g.\n ',mval(1,1));
%     Miss = [];
% end

% 

Trues = nonzeros(Trues);
%datevec(Trues)
% 
 fprintf('True Calls: %g.\nFalse Calls: %g.\n ',... 
     tsize(1,1),fsize(1,1));

% True_scores = True(:,2);
% False_scores = False(:,2);