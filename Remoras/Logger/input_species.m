function [chartR,chartW] = input_species(node,kidCount)


if nargin < 2
    kidCount = 0;
end
child = 0;
if kidCount < 0
    chartR = {};
    chartW = {};
    return

elseif node.getAllowsChildren
    child = node.getChildCount;
    kidCount = kidCount-1 + child;
    [r , w] = input_species(node.getNextNode,kidCount);
else
    [r , w] =  input_species(node.getNextNode,kidCount-1);
end

nodeValue = node.getValue;
mark = char(nodeValue(1));

if strcmp(mark,'selected') && node.getLevel > 0

    tag = char(nodeValue(2));
    name = char(node.getName);
    if isempty(r) || node.getLevel > length(r)
        r{node.getLevel} = {name};
        w{node.getLevel} = {tag};
    else
        spotR = r{node.getLevel};
        spotW = w{node.getLevel};
        ls = length(spotR);
        spotR{ls+1} = name;
        spotW{ls+1} = tag;            
        r{node.getLevel} = spotR;
        w{node.getLevel} = spotW;
    end

    chartR = r;
    chartW = w;

else
    chartR = r;
    chartW = w;
end