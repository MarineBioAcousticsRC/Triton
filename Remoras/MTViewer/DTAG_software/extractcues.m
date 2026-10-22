function  [X,c] = extractcues(x,c,t)
%
%    [X,c] = extractcues(x,c,t)
%    Extract sub-vectors from vector or matrix x around cues, c. Sub-vector 
%    length is given by t.
%    x is the base vector or matrix.
%    c is the vector of cues. Each component of c is an integer >=1 and
%      <=length(x)
%    t defines a window of x, centered at each cue point, to extract.
%      t=[tstart,tend], with tstart and tend in samples. t can also be a
%      2-column vector with number of rows equal to the length of c. The 
%      first column is tstart for each cue. The second column is tend. X
%      will have a number of rows equal to max(diff(t'))+1
%
%    returns:
%    X is a matrix of size mxn where m=diff(t) and n=length(c). Each column
%    of X is a sub-vector extracted from x corresponding to an element in
%    c. Only c for which c-t(1)>0 and c+t(2)<=length(x) are considered.
%    c is the actual cues used i.e., excluding the cues that are too close
%    to the beginning or end of x. If x is a matrix, X will be a
%    3-dimensional matrix with size mxpxn where p is the number of columns
%    in x.
%
%    mark johnson, WHOI
%    majohnson@whoi.edu
%    January 2004


if nargin<3,
   help extractcues
   return
end

t = round(t) ;
c = round(c) ;
X = [] ;

% detect if there is a single time interval
one_t = size(t,1)==1 | size(t,2)==1 ;

% constrain cl to lie within extractable interval
if one_t,
   min_c = -t(1) ;
   max_c = length(x)-t(2) ;
else
   min_c = -min(t(:,1)) ;
   max_c = length(x)-max(t(:,2)) ;
end

kc = find(c>min_c & c<max_c) ;
c = c(kc) ;

if isempty(c),
   return
end

T = diff(t') ;
X = zeros(max(T)+1,size(x,2),length(c)) ;

% now extract segments
if one_t,
   tt = t(1):t(2) ;
   for k=1:length(c),
      X(:,:,k) = x(c(k)+tt,:) ;
   end
else
   t = t(kc,:) ;
   for k=1:length(c),
      X(1:T(k)+1,:,k) = x(c(k)+(t(k,1):t(k,2)),:) ;
   end
end

X = squeeze(X) ;
