function    [kx,mind] = nearest(X,Y,maxdist,direction)
%
%    [kx,mind] = nearest(X,Y,[maxdist,direction])
%    Find the index of the nearest element in set X to each element in set
%    Y. X and Y must be column vectors and may have real or complex elements.
%    If maxdist is specified, only elements within +/-maxdist are considered 
%    and kx is set to NaN for elements that do not match. Use maxdist=NaN
%    to always return nearest element.
%    mind is the distance from each element of Y to the closest element in
%    X, irrespective of maxdist. kx and mind are both the same size as Y.
%    Optional argument direction is 0 (the default) for nearest in either
%    direction, 1 for nearest greater and -1 for nearest smaller.
%
%    mark johnson, WHOI
%    majohnson@whoi.edu
%    Last modified: 23 Nov. 2005

kx = [] ; mind = [] ;

if nargin<2,
   help nearest
   return
elseif nargin<3,
   maxdist = NaN ;
end

if nargin<4,
   direction = 0 ;
end

if size(X,2)+size(Y,2)>2,
   fprintf('X and Y must be column vectors\n') ;
   return
end

if isempty(X),
   kx = NaN*ones(length(Y),1) ;
   mind = kx ;

elseif ~isempty(Y),
   if length(X)==1,
      X = X*[1;1] ;
   end

   D = ones(size(X,1),1)*Y'-X*ones(1,size(Y,1)) ;

   if direction>0,
      D(D>0) = NaN ;
      [mind n] = min(abs(D)) ;
   elseif direction<0,
      D(D<0) = NaN ;
      [mind n] = min(abs(D)) ;
   else
      [mind n] = min(abs(D)) ;
   end

   mind = mind';
   n(isnan(mind)) = NaN ;
   kx = n' ;
   if ~isnan(maxdist),
      kx(mind>maxdist) = NaN ;
   end
end
