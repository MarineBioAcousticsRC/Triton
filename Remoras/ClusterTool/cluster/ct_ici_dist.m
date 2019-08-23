function [distClickE, rows1,cols1] = ct_ici_dist(iciNorm)
%iciNorm = iciMat./repmat(sum(iciMat,2),1,size(iciMat,2));

tempN = size(iciNorm,1);
offaxN = ((tempN.^2)-tempN)./2;

rows1 = zeros(offaxN, 1);
cols1 = zeros(offaxN, 1);
n = 1;

for itrA = 1:size(iciNorm,1)-1  
    for itrB = itrA+1:size(iciNorm,1)
        rows1(n) = itrA;
        cols1(n) = itrB;
        n = n+1;
    end
end
%distClick = pdist(iciNorm,'euclidean');
distClick = pdist(iciNorm,'correlation');

distClickE = (exp(-distClick));

