function node = mk_node(value, string, icon, isleaf)

try
   node = uitreenode('v0', value, string, icon, isleaf);
catch 
   node = uitreenode(value, string, icon, isleaf);
end