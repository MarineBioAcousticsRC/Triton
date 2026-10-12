function    [y,f0] = rtcclean(x,afs,f0)
%
%    [y,f0] = rtcclean(x,afs,f0)
%

if nargin<3 | isempty(f0),
   f0 = 32768 ;
end

[b,a] = butter(4,[30e3 35e3]/(afs/2)) ;
% conversion between frequency and phase of filter
[h,f] = freqz(b,a,1024,afs);
kk = nearest(f,32768) ;
pp = polyfit(f(kk+(-10:10)),angle(h(kk+(-10:10))),1) ;

[xx,z] = filter(b,a,x(1000:-1:1)) ;
[xf,z] = filter(b,a,x,z) ;
nbl = floor(length(x)/afs) ;
kst = (0:nbl-1)*afs+1 ;
ked = kst+afs-1 ;
ked(end) = length(x) ;
y = zeros(length(x),1) ;

for k=1:nbl,
   kk = kst(k):ked(k) ;
   f1 = f0 ;
   for kkk=1:4,
      d = exp(-j*2*pi*f0/afs*(1:length(kk))') ;
      xx = xf(kk).*d ;
      r = mean(buffer(xx,256,0,'nodelay')) ;
      fr = abs(fft(r,1024)) ;
      ff = [-512:511]*afs/256/1024 ;
      fr = fr([513:end,1:512]) ;
      [nn,kp] = max(fr) ;
      pv = fr(kp+(-1:1))' ;
      xm = 0.5*(pv(1)-pv(3))./(pv(3)-2*pv(2)+pv(1)) ;
      finc = ff(kp)+xm*afs/256/1024 ;
      f0 = f0+finc ;
      if abs(finc)<0.3, break, end
   end

   if abs(finc)>0.3,
      f0 = f1 ;
      d = exp(-j*2*pi*f0/afs*(1:length(kk))') ;
      xx = xf(kk).*d ;
   end
   G = 2*conj(mean(xx)) ;
   y(kk) = x(kk)-real(d.*(G*exp(j*polyval(pp,f0)))) ;
end
