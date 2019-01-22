function data = subsref(v, index)

switch index.type
 case '()'
  data = double(v.memmap.data(index.subs{:}));
 case '.'
  data = v.(index.subs);
 otherwise
  error('unsupported substructure reference')
end
