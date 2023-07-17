function Result = utIsVector(Vector, varargin)
% Result = utIsVector(Vector, Optional arguments)
% Returns 1 if Vector is a vector, 0 otherwise
%
% Optional arguments:
%	'Type' 'row'|'column'
%		Determine if row/column vector
%
% This code is copyrighted 2003 by Marie Roch.
% e-mail:  marie.roch@ieee.org
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

[row, col] = size(Vector);

if min(row, col) ~= 1
  Result = 0;
else
  
  n = 1;
  while n <= length(varargin)
    switch(varargin{n})
     case 'Type'
      switch varargin{n+1}
	
       case 'row'
	if row ~= 1, Result = 0; return; end
       case 'column'
	if col ~= 1, Result = 0; return; end
      end
      n=n+2;
      
     otherwise
      error('Bad optional argument: "%s"', varargin{n});
    end
  end
  
  Result = 1;
end

