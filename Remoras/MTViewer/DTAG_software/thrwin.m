function    W=thrwin(x,th,maxgap,c)
%
%    W=thrwin(x,th,maxgap,c)
%    Find the start and end of pulses in envelope vector or 
%    matrix x. Each column of x is treated as a different 
%    signal. Each column is searched in turn for a pulse 
%    exceeding threshold th. The search is focused around
%    the center of the envelope or around sample c(k), for
%    the kth column, if given. The pulse must cover c(k) or
%    the center sample of x. A gap in the envelope will
%    be tolerated within the pulse if it is less than maxgap
%    samples long.
%    Returns the sample numbers corresponding to the start 
%    and end of the pulses as W=[start end]. If no pulse is 
%    found in column k, the corresponding row of W will be 
%    [NaN NaN].
%
%    mark johnson, WHOI
%    majohnson@whoi.edu
%    last modified: 8 January, 2007
    
if nargin<3,
   help thrwin
   return
end

if nargin<4,
   c = round(size(x,1)/2) ;
end

if length(c)<size(x,2),
   c = c*ones(size(x,2),1) ;
end

XX = x>th ;
W = zeros(size(x,2),2) ;
for k=1:size(x,2),
   kk = find(XX(:,k)) ;
   kn = nearest(kk,c(k),2*maxgap) ;     % find a point in the pulse
   if isnan(kn),
      W(k,:) = NaN*[1 1] ;
      continue
   end

   % find leading edge
   cc = kk(kn) ;
   T = XX(cc:-1:1,k) ;
   kk = [find(T);length(T)] ;
   if length(kk)==1,
      st = cc ;
   else
      st = cc-kk(min(find(diff(kk)>maxgap))) ;
      if isempty(st),
         st = 1 ;
      end
   end

   T = XX(cc:end,k) ;
   kk = [find(T);length(T)] ;
   if length(kk)==1,
      ed = cc ;
   else
      ed = kk(min(find(diff(kk)>maxgap)))+cc ;
      if isempty(ed),
         ed = size(x,1) ;
      end
   end
   W(k,:) = [st ed] ;
end
