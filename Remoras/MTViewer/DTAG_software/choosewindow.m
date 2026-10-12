function    k = choosewindow(x,lev,Np) ;

%    k = choosewindow(x,lev,[Np])
%    find the most compact closed interval of x that contains
%    at least lev fraction of the energy.
%    Optionally removes Np noise power from the instantaneous input power
%    before computing the signal energy
%    Returns k, the indices of the interval.
%
%    mark johnson, WHOI
%    majohnson@whoi.edu
%    last modified: 15 May 2006

k = [] ;
if nargin<2,
   help choosewindow
   return
end

if nargin<3,
   Np = 0 ;
end

if lev>1 | lev<=0,
   fprintf(' Energy fraction must be (0,1]\n')
   return
end

% cumulative energy of transient based on prior measurement of 
% the noise power
cs = cumsum(abs(x).^2)-Np*(1:length(x))' ;

% find latest start point in cs that still gives lev energy
kmax = max(find(cs<(cs(end)*(1-lev)))) ;
if isempty(kmax),
   kkk = min(find(cs>=cs(end)*lev)) ;
   k = (1:kkk)' ;
   return
end
   
n = NaN*ones(kmax,1) ;

% test each starting point from 1 to kmax for window length
for kk=1:kmax,
   kkk = min(find((cs-cs(kk))>=cs(end)*lev)) ;
   if ~isempty(kkk),
      n(kk) = kkk ;
   end   
end

% choose smallest window that covers the energy
[p,m] = min(n-(1:kmax)') ;
k = (m:n(m))' ;
