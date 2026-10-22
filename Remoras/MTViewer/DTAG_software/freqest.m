function    f = freqest(x,fs)
%
%    f = freqest(x,fs)
%

f = NaN*ones(size(x,2),1) ;
for k=1:length(f),
   kk = findzc(x(:,k),std(x(:,k))/4) 
   kk = kk(find(kk(:,3)>0),:) ;
   f(k) = fs*(size(kk,1)-1)/(kk(end,1)-kk(1,1)) ;
end
