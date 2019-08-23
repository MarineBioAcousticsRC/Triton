function [distClickE,rows1,cols1,iciMode] = ct_ici_dist_mode(iciMode,maxDiff)
% iciNorm = iciMat./repmat(sum(iciMat,2),1,size(iciMat,2));

%[~,iciModeIdx] = max(iciMat,[],2);
%iciMode = barInt(iciModeIdx) + ((barInt(2)-barInt(1))/2);

tempN = size(iciMode,1);
offaxN = ((tempN.^2)-tempN)./2;

rows1 = zeros(offaxN, 1);
cols1 = zeros(offaxN, 1);
n = 1;

for itrA = 1:size(iciMode,1)-1  
    for itrB = itrA+1:size(iciMode,1)
        rows1(n) = itrA;
        cols1(n) = itrB;
        n = n+1;
    end
end
distClick = pdist(iciMode','euclidean');

distClickE = exp(-distClick./maxDiff);

