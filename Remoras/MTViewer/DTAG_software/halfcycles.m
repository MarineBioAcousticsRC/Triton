function    [H,K] = halfcycles(x,T,Tmax)
%
%    H = halfcycles(x,K,Tmax)
%     H = [start,end,dir,pkpk]

K = findzc(x,T,Tmax) ;
H = K ;
X = extractcues(x,K(:,2),[0 Tmax]) ;
[fs fpk] = find1stpk(X.*repmat(K(:,3)',size(X,1),1),0.9,T) ;
X = extractcues(x,K(:,1),[-Tmax 0]) ;
[ps ppk] = find1stpk(-flipud(X).*repmat(K(:,3)',size(X,1),1),0.9,T) ;
H(:,2) = H(:,2)+fs-1 ;
H(:,1) = H(:,1)-ps+1 ;
H(:,4) = ppk ;
H(:,5) = fpk ;

% redo the zero-crossings with corrected zeros
H(:,6) = H(:,3).*(fpk-ppk)/2 ;
%X = extractcues(x,H(:,1),[0 Tmax]) ;
%XX = (X-repmat(H(:,6),size(X,1),1)).*repmat(H(:,3)',size(X,1),1) ;
%kk = find(XX>0,1)-1 ;
%X(kk,:)/(y(1)-y(2))
