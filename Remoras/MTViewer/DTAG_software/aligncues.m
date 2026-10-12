function   cc = aligncues(x,cc,win)

%   cl = aligncues(x,cl,win)
%   Align a set of cues to coincide with the maximum value of x within +/- win
%   samples (default 100) of the input cues in cl. cl must be in
%   samples.
%
%   mark johnson, WHOI
%   majohnson@whoi.edu
%   January 2005

if nargin<2,
   help aligncues
   return
end

if size(x,2)>1,
   fprintf(' Input signal must be mono\n') ;
   return
end

if nargin<3,
   win = 100 ;
end

cc = round(cc) ;
cc = cc(find(cc>win & cc<length(x)-win)) ;
r = zeros(2*win+1,length(cc)) ;

for k=1:length(cc),
    r(:,k) = abs(hilbert(x(cc(k)+(-win:win)))) ;
end

[nn ccoffs] = max(r) ;
cc = cc+ccoffs'-win ;
return
