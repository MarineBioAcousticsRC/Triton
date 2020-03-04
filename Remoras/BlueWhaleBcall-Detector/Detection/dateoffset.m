function offset = dateoffset()
% offset = dateoffset()
% Triton stores dates relative to the Matlab serial date offset.
% If Matlab encodes a date as x, store it as x - dateoffset() 
% in Triton.  Actual dates are x + dateoffset()

offset = datenum([2000 0 0 0 0 0]);
