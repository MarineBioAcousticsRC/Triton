function jaxb_test(q)


kinds(1).SpeciesID = q.QueryTethys('lib:completename2tsn("Physeter macrocephalus")');
kinds(1).Granularity = 'encounter';
kinds(1).Call = 'clicks';

% Make up some pretend times
start = now;
times = [start + sort(cumsum(randn(20,1)*9))];
times = [times, times + abs(randn(20,1)* (10/(24*60)))];

for k=1:size(times,1)
    fprintf('%s - %s\n', datestr(times(k,1)), datestr(times(k,2)));
end
dbDetections2XML(now, now+1, kinds, times);