function retval = subsref(s, sref)

switch sref.type
  case '()'
   indices = range.subs{:};
   retval = s.Signal(indices);
 otherwise
  error('Unsupported reference to spSignal')
end
   
