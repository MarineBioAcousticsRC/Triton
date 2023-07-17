function read_effort(filename)
global TREE 

import java.lang.String

current = TREE.rootNode;
[I,map] = uncheckedIcon;
javaImage_unchecked = im2java(I,map);

while ~isempty(current)
    nodeValue = current.getValue;
        v{1} = 'unselected';
        v{2} = char(nodeValue(2));
        v{3} = char(nodeValue(3));
        current.setValue(v);
        current.setIcon(javaImage_unchecked);
    current = current.getNextNode;
end
[I,map] = checkedIcon;
javaImage_checked = im2java(I,map);

[I,map] = partCheckedIcon;
javaImage_partChecked = im2java(I,map);

currNode = TREE.rootNode;
[xlnum, xltext, xlcell]=xlsread(filename,'effort');

% Find columns of interest
CommonNameI = strcmp(xltext(1,:), 'Common Name');
CallI = strcmp(xltext(1,:), 'Call');

% Calls that are numbers will not be read properly.  Fix them
NumericInd = find(cellfun(@isnumeric, xlcell(:, CallI)));
isNumber = ~cellfun(@isnan, xlcell(NumericInd,CallI)) & ~cellfun(@isinf, xlcell(NumericInd, CallI));
NumericRows = NumericInd(isNumber)';
for r=NumericRows
    xltext{r, CallI} = num2str(xlcell{r, CallI});
end
lastrow=size(xltext,1);

lastspecies = [];

% Look for the first species (grandchild)
% root --> group --> species
category = TREE.rootNode.getFirstChild();
while ~ isempty(category) && isempty(category.getFirstChild())
    category = category.getNextSibling();
end
firstspecies = category.getFirstChild();

firstcall = false;
count = 2;  % start after header
while count <= lastrow
    % Look for the current species
    if strcmp(xltext{count, CommonNameI}, lastspecies) == 1
        % We have seen this species before, just handle next call
        
        % Look for current call type in children
        callNode = speciesNode.getFirstChild();
        callFound = false;
        while ~ isempty(callNode) && ~ callFound
            value = callNode.getValue();
            callName = callNode.getName();
            callFound = strcmp(callName, xltext{count, CallI});
            if ~ callFound
                callNode = callNode.getNextSibling();
            end
        end
        
        % todo: if ~ found, generate error
        
        value(1) = String('selected');
        callNode.setValue(value);  % store change

        % iterate back up the tree
        checkParent(callNode, javaImage_checked);
        
        count = count + 1;  % Move to next line of input
    
    else
        % Find species
        % to do, what if we don't find the species...
        
        % Skip over empty species entries
        while count <= lastrow && isempty(xltext{count, CommonNameI})
            count = count + 1;
        end
        
        % Search for the current species
        speciesNode = search_species(xltext{count, CommonNameI}, firstspecies);
        lastspecies = xltext{count, CommonNameI};
        if isempty(speciesNode)
            errordlg('Species %s not in allowed effort.', lastspecies);
            return
        end
    end
end

    function node = search_species(species, currNode)
        % node = search_species(item, currNode)
        % Assuming that currNode points to the first species level node,
        % find the entry that matches species
        
        found = strcmp(currNode.getName(), species);
        done = found;
        while ~ done && ~ found
            if ~ found
                sibling = currNode.getNextSibling();
                if isempty(sibling)
                    % No more species in the current category, move to next parent
                    parent = currNode.getParent().getNextSibling();
                    % Look for a child (species).  If there is not one, move
                    % to the next.
                    while ~isempty(parent) && isempty(parent.getFirstChild())
                        parent = parent.getNextSibling();
                    end
                    done = isempty(parent) || isempty(parent.getFirstChild());
                    if ~ done
                        currNode = parent.getFirstChild();
                        found = strcmp(currNode.getName(), species);
                    end
                else
                    currNode = sibling;
                    found = strcmp(currNode.getName(), species);
                end
            end
        end
        
        if found
            node = currNode;
        else
            node = [];
        end
    end
 function node = search_fn(item,currNode)
     check = 1;
     if isempty(item)
         node = [];
         return
     end
     while ~isempty(currNode) && check == 1
         
         currValue = currNode.getName();
         
         if strcmp(currValue,item)
             %     v{1} = 'selected';
             %     v{2} = char(currValue(2));
             %     currNode.setValue(v);
             check = 0;
             node = currNode;
             return
         end
         currNode = currNode.getNextNode;
         
     end
     
     if check == 1
         node = [];
     end
 end

 function checkParent(node,icon)
     nodeValue = node.getValue;
        v{1} = 'selected';
        v{2} = char(nodeValue(2));
        v{3} = char(nodeValue(3));
        node.setValue(v);
        node.setIcon(icon);
        drawnow;
     found = 0;
     if ~isempty(node.getParent)
         %checkParent(node.getParent);
         nxt = node.getParent.getNextNode;
         while ~isempty(nxt) && ~found
             
             vn = nxt.getValue;
             if strcmp(vn(1),'unselected') || nxt.getIcon == javaImage_partChecked
                 found = 1;
                 break;
             end
             
             nxt = nxt.getNextSibling;
         end
         
         if ~found
             checkParent(node.getParent,javaImage_checked);
         else
             checkParent(node.getParent,javaImage_partChecked);
         end
     end
        
 end

function [I,map] = checkedIcon()
I = uint8(...
    [1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0;
    2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,1;
    2,2,2,2,2,2,2,2,2,2,2,2,0,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,0,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,0,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,0,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,0,0,1,1,2,2,3,1;
    2,2,1,0,0,1,1,0,0,1,1,1,2,2,3,1;
    2,2,1,1,0,0,0,0,1,1,1,1,2,2,3,1;
    2,2,1,1,0,0,0,0,1,1,1,1,2,2,3,1;
    2,2,1,1,1,0,0,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,0,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
    1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1]);
map = [0.023529,0.4902,0;
    1,1,1;
    0,0,0;
    0.50196,0.50196,0.50196;
    0.50196,0.50196,0.50196;
    0,0,0;
    0,0,0;
    0,0,0];
end
function [I,map] = partCheckedIcon()
I = uint8(...
    [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1;
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1;
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
    2,2,3,0,3,0,3,0,3,0,3,0,2,2,3,1;
    2,2,0,3,0,3,0,3,0,3,0,3,2,2,3,1;
    2,2,3,0,3,0,3,0,3,0,3,0,2,2,3,1;
    2,2,0,3,0,3,0,3,0,3,0,3,2,2,3,1;
    2,2,3,0,3,0,3,0,3,0,3,0,2,2,3,1;
    2,2,0,3,0,3,0,3,0,3,0,3,2,2,3,1;
    2,2,3,0,3,0,3,0,3,0,3,0,2,2,3,1;
    2,2,0,3,0,3,0,3,0,3,0,3,2,2,3,1;
    2,2,3,0,3,0,3,0,3,0,3,0,2,2,3,1;
    2,2,0,3,0,3,0,3,0,3,0,3,2,2,3,1;
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
    1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1]);
map = ...
    [0.023529,0.4902,0;
    1,1,1;
    0,0,0;
    0.50196,0.50196,0.50196;
    0.50196,0.50196,0.50196;
    0,0,0;
    0,0,0;
    0,0,0];
end

function [I,map] = uncheckedIcon()
I = uint8(...
    [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1;
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1;
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
    1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1]);
map = ...
    [0.023529,0.4902,0;
    1,1,1;
    0,0,0;
    0.50196,0.50196,0.50196;
    0.50196,0.50196,0.50196;
    0,0,0;
    0,0,0;
    0,0,0];
end

end