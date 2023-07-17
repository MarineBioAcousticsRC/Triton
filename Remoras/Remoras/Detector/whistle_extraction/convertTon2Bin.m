function [success, fail] = convertTon2Bin()

import tonals.*

success = {};
fail = {};

corpus = 'd:\home\bioacoustics\Paris-ASA';
gtton = utFindFiles({'*.ton'}, {corpus}, true);
gtbin = strrep(gtton, '.ton', '.bin');
diary('test.txt');
for idx=10:length(gtton)
    fprintf('Processing %d %s\n', idx, gtton{idx});
    try
        truth = dtTonalsLoad(gtton{idx});
    catch e
        fprintf('Exception for file %s\n', gtton{idx})
        disp(e.message)
        fail{end+1} = gtton{idx};
        continue
    end
    success{end+1} = gtton{idx};
    n = truth.size();
    out = TonalBinaryOutputStream(gtbin{idx});
    for n=0:n-1
        out.write(truth.get(n));
    end
    out.close();
end

