function v = subsasgn(v, index, val)
% permit index assignment

switch index.type
 case '()'
  v.memmap.data(index.subs{:}) = val;
 otherwise
  error('substructure assignment not supported')
end

