function    A = meanabsorption(f1,f2,d,depth,Ttab)
%
%    A = meanabsorption(f1,f2,d,depth,tempr)
%     Calculate the mean absorption in salt water over a frequency range
%     from f1 to f2 Hz. The path length is d meters. The depths covered
%     by the path d=[dmax,dmin] and the temperature profile 
%     Ttab=[depth, tempr] can be specified. Default depth and temperature
%     are a horizontal path at 500 m depth with a temperature of 13
%     degrees.
%     For a single frequency, use f2=[].

if nargin<4,
   depth = 500 ;
end

if nargin<5,
   tempr = 13 ;
elseif length(Ttab)==1,
   tempr = Ttab ;
end

if length(depth)>1,
   depth = linspace(min(depth),max(depth),50) ;
   if nargin == 5,
      if length(Ttab)>1,
         tempr = interp1(Ttab(:,1),Ttab(:,2),depth) ;
      end
   end
end

if isempty(f2),
   f = f1 ;
   A = d*mean(absorption(f,tempr,depth)) ;
   return
end

f = linspace(f1,f2,50) ;
a = zeros(length(depth),length(f)) ;
for k=1:length(depth),
   a(k,:) = absorption(f,tempr(k),depth(k)) ;
end
a = mean(a,1) ;
A = zeros(length(d),1) ;
for kk=1:length(d),
   A(kk) = -10*log10(mean(10.^(-a*d(kk)/10))) ;
end
return
