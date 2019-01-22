function retval = subsassgn(s, sref, value)

switch sref.type
 case '()'
   indices = range.subs{:};
   s.Signal(indices) = value;
 otherwise
  error('Unsupported assignment to spSignal')
end
   
