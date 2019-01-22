function species_tree(template)
import javax.swing.*
import javax.swing.tree.*;

global handles TREE
TREE.position = 0;

% Read the template to build the effort tree
[TREE.textR, TREE.textW, TREE.orderR,TREE.project, ...
    TREE.headers, TREE.frequency] = spec_data(template);

% Read in icons for marking the effort tree
[I,map] = checkedIcon;  % selected
javaImage_checked = im2java(I,map);

[I,map] = uncheckedIcon; % unselected
javaImage_unchecked = im2java(I,map);

[I,map] = partCheckedIcon; % some children selected
javaImage_partChecked = im2java(I,map);

% javaImage_checked/unchecked are assumed to have the same width
iconWidth = javaImage_unchecked.getWidth;

% Create the root node for the tree
v{1} = 'unselected';
v{2} = 'root';
v{3} = '2';
TREE.rootNode = mk_node(v,'ALL', [], false);
%add the unchecked icon
addChild(TREE.rootNode,v{2})

TREE.rootNode.setIcon(javaImage_unchecked);




treeModel = DefaultTreeModel( TREE.rootNode );
% create the tree
TREE.tree = mk_tree(handles.logcallgui);    %TREE.tree = uitree(handles.logcallgui);

% we often rely on the underlying java tree
jtree = handle(TREE.tree.getTree,'CallbackProperties');

% some layout
drawnow;
TREE.tree.setModel( treeModel );
set(TREE.tree, 'Units', 'normalized', 'position', [0 0 1 0.87]);
set(TREE.tree, 'NodeSelectedCallback', @selected_cb );

% make root the initially selected node
TREE.tree.setSelectedNode(TREE.rootNode);

% make a chart to map all the nodes
TREE.chart = species_chart(TREE.rootNode);

% MousePressedCallback is not supported by the uitree, but by jtree
set(jtree, 'MousePressedCallback', @mousePressedCallback);

% Set the mouse-press callback
    function mousePressedCallback(hTree, eventData) %,additionalVar)
        % if eventData.isMetaDown % right-click is like a Meta-button
        % if eventData.getClickCount==2 % how to detect double clicks

        % Get the clicked node
        clickX = eventData.getX;
        clickY = eventData.getY;
        treePath = jtree.getPathForLocation(clickX, clickY);
        % check if a node was clicked
        if ~isempty(treePath)
            % check if the checkbox was clicked
            if clickX <= (jtree.getPathBounds(treePath).x+iconWidth)
                node = treePath.getLastPathComponent;
                nodeValue = node.getValue;
                select = char(nodeValue(1));
                % as the value field is the selected/unselected flag,
                % we can also use it to only act on nodes with these values
                switch select
                    case 'selected'
                        unCheck(node);
                        %              v{1} = 'unselected';
                        %              v{2} = char(nodeValue(2));
                        %             node.setValue(v);
                        %             node.setIcon(javaImage_unchecked);
                        jtree.treeDidChange();
                    case 'unselected'
                        %              v{1} = 'selected';
                        %              v{2} = char(nodeValue(2));
                        %              childCount = node.getChildCount;
                        putCheck(node);
                        %             node.setValue(v);
                        %             node.setIcon(javaImage_checked);
                        jtree.treeDidChange();
                end
            end
        end
    end % function mousePressedCallback
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%   Make check marks for the all the nodes in the section
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function putCheck(node,kidCount)

        if nargin < 2
            checkParent(node,javaImage_checked); 
            kidCount = 0;
        end
        
        if kidCount < 0
           return

        elseif node.getAllowsChildren
            child = node.getChildCount;
            kidCount = kidCount-1 + child;
            putCheck(node.getNextNode,kidCount)
        else
            putCheck(node.getNextNode,kidCount-1)
        end
        nodeValue = node.getValue;
        v{1} = 'selected';
        v{2} = char(nodeValue(2));
        v{3} = char(nodeValue(3));
        node.setValue(v);
        node.setIcon(javaImage_checked);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%   uncheck any marks for the all the nodes in the section
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function unCheck(node,kidCount)

        if nargin < 2
            uncheckParent(node,javaImage_unchecked); 
            kidCount = 0;
        end
        if kidCount < 0
            return

        elseif node.getAllowsChildren
            child = node.getChildCount;
            kidCount = kidCount-1 + child;
            unCheck(node.getNextNode,kidCount)
        else
            unCheck(node.getNextNode,kidCount-1)
        end
        nodeValue = node.getValue;
        v{1} = 'unselected';
        v{2} = char(nodeValue(2));
        v{3} = char(nodeValue(3));
        node.setValue(v);
        node.setIcon(javaImage_unchecked);
    end
%% make a check mark for the parent
 function checkParent(node,icon)
     
     nodeValue = node.getValue;
        v{1} = 'selected';
        v{2} = char(nodeValue(2));
        v{3} = char(nodeValue(3));
        node.setValue(v);
        %node.setIcon(javaImage_checked);
        node.setIcon(icon);
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

%% uncheck the parents
 function uncheckParent(node,icon)
     
     nodeValue = node.getValue;
        v{1} = 'unselected';
        v{2} = char(nodeValue(2));
        v{3} = char(nodeValue(3));
        node.setValue(v);
%         node.setIcon(javaImage_unchecked);
     found = 0;
     if ~isempty(node.getParent)
         nxt = node.getParent.getNextNode;
         while ~isempty(nxt) && ~found
             
             vn = nxt.getValue;
             if strcmp(vn(1),'selected') %&& node ~= nxt
                 found = 1;
                 break;
             end
             
             nxt = nxt.getNextSibling;
         end
         
         checkKid = 1;
         if node.getAllowsChildren
             child = node.getFirstChild;
             while ~isempty(child) && ~checkKid
                 vn = child.getValue;
               if strcmp(vn(1),'selected') 
                 checkKid = 0;
                 break;
               end
               child = child.getNextSibling;
             end
         end
         
         if ~found && checkKid
             uncheckParent(node.getParent,javaImage_unchecked);
         else
             checkParent(node.getParent,javaImage_partChecked);
         end
         
         
     end
        node.setIcon(icon);
 end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function selected_cb( tree, value )
        nodes = tree.getSelectedNodes;
        if ~ isempty(nodes)
            node = nodes(1);
            path = node2path(node);
        end
    end
TREE.tree.setSelectedNode([]);
TREE.tree.repaint;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function path = node2path(node)
        path = node.getPath;
        for i=1:length(path);
            p{i} = char(path(i).getName);
        end
        if length(p) > 1
            path = fullfile(p{:});
        else
            path = p{1};
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Function for making the checked image
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Function for making the unchecked image
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

function chart = species_chart(node)

kidCount = 1;

Cnode = node;
chart = {};
while kidCount > 0
    lc = length(chart);
    chart{lc +1} = Cnode;
    if Cnode.getAllowsChildren
        child = Cnode.getChildCount;
        kidCount = kidCount - 1 + child;
    else
        kidCount = kidCount - 1;
    end
    Cnode = Cnode.getNextNode;
end

end
