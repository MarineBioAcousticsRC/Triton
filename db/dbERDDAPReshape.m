function data = dbERDDAPReshape(data, Dim)

fields = {data.hdr.name};
last = cell(Dim, 1);
counts = ones(1, Dim);



% Determine shape of data
for idx = Dim:-1:1
    step = prod(counts);
    [counts(idx), data.labels.(fields{idx})] = SearchRepeat(data, fields{idx}, step);
    
end

for idx = 1:length(fields)
    data.(fields{idx}) = reshape(data.(fields{idx}), counts);
end



function [N, Values] = SearchRepeat(data, field, step)
% function N = SearchRepeat(field, step)
% Find how many indices until we see something repeat,
% stepping by a given step size

first = data.(field)(1);
next = 1 + step;
done = false;
N = 1;

while ~ done && next < length(data.(field))
    if data.(field)(next) == first
        done = true;
    else
        next = next + step;
        N = N + 1;
    end
end

Values = data.(field)(1:step:1+(N-1)*step);

