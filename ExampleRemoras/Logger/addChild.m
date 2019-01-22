function addChild(node,value)
% addChild(node, value)
% add children to a tree

global TREE
[specR, specW] = species_ordering(value);

position = TREE.position;
if strcmp(value,'root')
    value = '';
end
[I,map] = uncheckedIcon;
javaImage_unchecked = im2java(I,map);

for i = 1:length(specR)
    % create a new value but adding the next subsection to it

    newValue = [value, specR{i}, filesep];
    
    %find out if the current node has any children
    parent = isParent(newValue);
    
    v{1} = 'unselected';
    v{2} = specW{i};
    v{3} = num2str(position-1 + i);
    %create a new node
    newNode = mk_node(v, specR{i}, [], ~parent);   %newNode = uitreenode( v, specR{i}, [], ~parent);
    
    %add the unchecked icon
    newNode.setIcon(javaImage_unchecked);
    
    % add the new node to the parent node
    node.add(newNode);
    
    %if there are more nodes connected to it then repeat process for new node and values
    if parent 
        addChild(newNode,newValue);
    end
end

end

function found = isParent(value)

subsect = species_ordering(value);

if isempty(subsect)
    found = false;
else
    found = true;
end
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