function ks = base2(baseline)
% ks = base2(baseline)
% Sort vector baseline, and return the values of the 50%
% interval where the values are most concentrated (highest
% and lowest value in this interval are minimized).
  
bs = sort(baseline)';
bs1 = length(bs);

if mod(bs1,2)==1
  % if odd make even
  bs(end) = [];
  bs1=bs1-1;
end

% Make column 1 0-50%, column 2 is 50+-100%
bs = reshape(bs,bs1/2,2);  

% Find smallest interval covering 50% of the distribution
[delta, bestidx]= min(diff(bs, 1, 2));

low=bs(bestidx,1);
high=bs(bestidx,2);

k1=find(baseline>=low);
k2=find(baseline<=high);
ks=intersect(k1,k2);

