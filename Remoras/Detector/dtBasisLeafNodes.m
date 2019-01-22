function ret = dtBasisLeafNodes(basis, d, b, ret)
% ret = dtBasisLeafNodes(basis);
%    Given a basis tree as in BestBasis, return a basis that includes only
%    the leaf nodes.

if (nargin == 1)
    % Init.
    d = 0; 
    b = 0; 
    ret = zeros(1,length(basis)); 
end

n = node(d,b);
if (basis(n) == 1)
    ret = dtBasisLeafNodes(basis, d+1, b*2, ret);
    ret = dtBasisLeafNodes(basis, d+1, b*2+1, ret);
else
    ret(n) = 1;
end
