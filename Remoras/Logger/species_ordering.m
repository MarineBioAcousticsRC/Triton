function [subsectR,subsectW] = species_ordering(name, cx, py)

global TREE

if nargin < 3
    cx = 1;
    py = 1;
end
n = 1;
[ly,lx] = size(TREE.textR);
col = strfind(name,filesep);

% checking how many sections to look through
if col ~= 0
    start = 1;
    for i = 1:length(col)
        subject{i} = name(start:col(i)-1);
        start = col(i) + 1;
    end
else
    subject{1} = name;
end

x = 0;
y = 1;
subnum = 0;
%cx = 1;

% looks for the section the word is in
for k = 1:length(subject)
    x = 0;
    while cx <= lx && x == 0
        for cy = py:ly
            if strcmp(TREE.textR(cy,cx), subject{k})
                if k == length(subject)
                    subnum = TREE.orderR(cy,cx);
                end
                x = cx;
                y = cy;
                break
            end
        end
        cx = cx +1;
    end
end
save = y;

% if the name cannot be found in the list then check to see if it is a root
if subnum == 0
    if strcmp(name,'root') 
        TREE.position = y;
        c = 1;
        for i = 1:length(TREE.textR)
            if ~strcmp(TREE.textR(i,1),'')
                subsectR(c) = TREE.textR(i,n);
                if nargout == 2
                subsectW(c) = TREE.textW(i,n);
                end
                c = c+1;
            end
        end
        return
    else
        disp('species not found make sure you spelled it correctly')
        subsectR = [];
        if nargout == 2
        subsectW = [];
        end
        return
    end
end

if x == lx || x + n > lx
    subsectR = [];
    if nargout == 2
        subsectW = [];
    end
else
    i = 0;
    prev = [];
    while y <= ly && TREE.orderR(y,x) < subnum + 1  
        if ~strcmp(TREE.textR(y,x+1),'') && ~strcmp(TREE.textR(y,x+1),prev)
            i = i+1;
            subsectR(i) = TREE.textR(y,x+n);
            if nargout == 2
                subsectW(i) = TREE.textW(y,x+n);
            end
            prev = TREE.textR(y,x+n);
        end
        y = y+1;
    end
    if i == 0
        subsectR = [];
        if nargout == 2
        subsectW = [];
        end
    end
end

if ~isempty(subsectR)
    TREE.position = save;
end