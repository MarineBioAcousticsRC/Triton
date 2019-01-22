function display(v)
% display an spVecMemMap object

if v.valid
  disp([sprintf('\n%s =\nspVecMemMap object:  ', ...
                inputname(1)), ...
        sprintf('%d\t', size(v))]);
else
  disp(sprintf('\n%s =\nspVecMemMap object: invalid memory map', inputname(1)));
end


