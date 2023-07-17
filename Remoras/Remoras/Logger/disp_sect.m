function [textR,textW, order, freq] = disp_sect(class, action)

global TREE PARAMS
if nargin < 1 
    lc = length(TREE.chart);
    textR = {};
    textW = {};
    
    for i = 1:TREE.chart{1}.getDepth
        sCol{i} = '';
    end
    for y = 2:lc  
        Cnode = TREE.chart{y};
        value = Cnode.getValue;
        select = char(value(1));
        if strcmp(select,'selected') || strcmp(PARAMS.log.mode, 'OffEffort')
            name = char(Cnode.getName);
            tag = char(value(2));
            freqV = char(value(3));
            col = sCol;
            col{Cnode.getLevel} = name;
            ls = size(textR);
            textR(ls(1)+1,:) = col(1,:);
            col{Cnode.getLevel} = tag;
            textW(ls(1)+1,:) = col(1,:);
            freq(ls(1)+1,:) = TREE.frequency(str2num(freqV),:);
        end
    end
    [ly,lx] = size(textR);
    
    treeR = zeros(1,lx);
    order = zeros(ly,lx);
    
    for x = 1:lx
        for y = 1:ly
            if ~strcmp(textR(y,x),'')
                treeR(x) = treeR(x) + 1;
            end
            order(y,x) = treeR(x);
        end
    end

elseif strcmp(action, 'read')
lc = length(TREE.chart);
end