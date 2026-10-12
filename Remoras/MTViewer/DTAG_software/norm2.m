function    v=norm2(X)
%
%     v=norm2(X)
%     Returns the row-wise 2-norm of matrix X. If X is a
%     vector, norm2() is equivalent to norm().
%
%     mark johnson
%     majohnson@whoi.edu
%     last modified: 27 June 2006

[m n] = size(X) ;
if m==1 | n==1,
   v = norm(X) ;
else
   v = sqrt(abs(X).^2*ones(n,1)) ;
end

