function out = dom2struct(dom) 
% DOM2STRUCT Read an document object model file into a MATLAB structure.

children = dom.getChildNodes; 
for i = 1:children.getLength
out(i) = node2struct(children.item(i-1)); 
end

function s = node2struct(node)

s.name = char(node.getNodeName); 

if node.hasAttributes

attributes = node.getAttributes;
nattr = attributes.getLength;
s.attributes = struct('name',cell(1,nattr),'value',cell(1,nattr));

for i = 1:nattr
attr = attributes.item(i-1);
s.attributes(i).name = char(attr.getName);
s.attributes(i).value = char(attr.getValue);
end

else

s.attributes = [];

end

try

s.data = char(node.getData);

catch

s.data = '';

end

if node.hasChildNodes

children = node.getChildNodes;
nchildren = children.getLength;
c = cell(1,nchildren);
s.children = struct('name',c,'attributes',c,'data',c,'children',c);

for i = 1:nchildren
child = children.item(i-1);
s.children(i) = node2struct(child);
end

else

s.children = [];

end 
