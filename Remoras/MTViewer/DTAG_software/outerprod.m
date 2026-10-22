function    R = outerprod(A)
%
%    R = outerprod(A)
%

R = zeros(size(A,2)) ;
for k=1:size(A,1),
   R = R+A(k,:)'*A(k,:) ;
end
