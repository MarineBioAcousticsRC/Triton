function [dttTemp,cRateTemp] = ct_compute_rate_distributions(ttSet,p)

% deals with weird behavior of histc when there are few/no data points in
% ttSet

dttTemp =  histc(diff(sort(ttSet))*24*60*60,p.barInt);
cRateTemp = histc(1./(diff(sort(ttSet))*24*60*60),p.barRate);
if isempty(dttTemp)
    dttTemp = zeros(size(p.barInt));
    cRateTemp = zeros(size(p.barRate));
elseif size(dttTemp,1)>size(dttTemp,2)
    dttTemp = dttTemp';
    cRateTemp = cRateTemp';
end