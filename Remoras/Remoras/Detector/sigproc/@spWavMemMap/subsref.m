function data = subsref(w, index)

switch index.type
 case '()'
  data = double(w.memmap.data(index.subs{:}))/w.Normalize;
 case '.'
  data = w.(index.subs);
 otherwise
  error('unsupported substructure reference')
end
