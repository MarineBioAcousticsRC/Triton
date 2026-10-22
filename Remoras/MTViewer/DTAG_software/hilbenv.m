function    E=hilbenv(X)
%
%    E=hilbenv(X)
%    Compute envelope of the signal matrix X using overlap and add
%    method.
%
%    mark johnson, WHOI
%    majohnson@whoi.edu
%    21 Oct. 2006

N = 1024 ;                    % must be even
taper = triang(N)*ones(1,size(X,2)) ;
nbuffs = floor(size(X,1)/(N/2)-1) ;
iind = 1:N ;
oind = 1:N/2 ;
lind = N/2+1:N ;
E = zeros(size(X)) ;

if nbuffs==0,
   E = abs(hilbert(X)) ;
   return
end

% first buffer
H = hilbert(X(1:N,:)) ;
E(oind,:) = abs(H(oind,:)) ;
lastH = H(lind,:).*taper(lind,:) ;

for k=2:nbuffs-1,
   kk = (k-1)*N/2 ;
   H = hilbert(X(kk+iind,:)).*taper ;
   E(kk+oind,:) = abs(H(oind,:)+lastH) ;
   lastH = H(lind,:) ;
end

% last buffer
kk = (nbuffs-1)*N/2 ;
H = hilbert(X(kk+1:end,:)) ;
E(kk+oind,:) = abs(H(oind,:).*taper(oind,:)+lastH) ;
E(kk+N/2+1:end,:) = abs(H(N/2+1:end,:)) ;
