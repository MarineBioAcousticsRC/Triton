function       X = simulateabsorption(X,d,fs,m)
%
%      X = simulateabsorption(X,d,fs)
%

n = size(X,1) ;
N = 1024 ;
[H,f]=absorptiontaper(N,fs,d,[],-70);
F = fft(X.*repmat(hamming(n),1,size(X,2)),N) ;
X = real(ifft(F.*(H*ones(1,size(X,2))))) ;
if nargin==4,
   X = [X(end+(-m+1:0),:);X(1:n+m,:)] ;
else
   X = X(1:n,:) ;
end
