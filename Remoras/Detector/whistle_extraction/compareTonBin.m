function [success, fail, problem] = compareTonBin()

import tonals.*

success = {};
fail = [];
problem = {};

corpus = 'd:\home\bioacoustics\Paris-ASA';
gtton = utFindFiles({'*.ton'}, {corpus}, true);
gtbin = strrep(gtton, '.ton', '.bin');
diary('test.txt');
for idx=1:length(gtton)
    fprintf('Comparing %d %s\n', idx, gtton{idx});
    try
        truth = dtTonalsLoad(gtton{idx});
    catch e
        fprintf('Could not read file %s\n', gtton{idx})
        disp(e.message)
        problem{end+1} = gtton{idx};
        continue
    end
    success{end+1} = gtton{idx};
    n = truth.size();
    truth2 = dtTonalsLoad(gtbin{idx});
    
    if ~isempty(comparetonals(truth, truth2))
        fprintf('failure:  %s\n', result);
        fail(end+1).obj = truth;
        fail(end).bin = truth2;
        fail(end).fname = gtton{idx};
    end
end

function result = comparetonals(a, b)

result = [];  % assume same until we learn otherwise
if a.size() - b.size() ~= 0
    result = sprintf('differing #s of tonals:  %d %d\n', ...
        a.size(), b.size());
else
    for k=0:a.size()-1
        atonal = a.get(k);
        btonal = b.get(k);
        if atonal.compareTo(btonal) ~= 0
            if isempty(result)
                result = sprintf('differing tonals: %d', k);
            else
                result = sprintf('%s %d', result, k);
            end
        end
    end
end