function tree = mk_tree(node)

try
   tree = uitree('v0',node);
catch 
   tree = uitree(node);
end