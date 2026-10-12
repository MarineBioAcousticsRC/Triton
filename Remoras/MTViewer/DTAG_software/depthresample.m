function        [P,fo]=depthresample(tag,startcue,endcue,fo)
%
%  [P,fo]=depthresample(tag,startcue,endcue,fo)
%     resample the dive profile for the given tag to an output
%     rate of fo Hz (default is 1Hz). The dive profile can be
%     clipped to startcue:endcue in seconds since tag on.
%
%  example:
%     P=depthresample('sw00_250a');     % resample the whole dive profile
%     P=depthresample('sw00_250a',400,2500);  % resample an extract
%     
%  mark johnson, WHOI
%  July 2008

NWIN = 10 ;

P = [] ;
if nargin<1,
   help depthresample
   return
end

if nargin<4,
   fo = 1 ;             % default 1 Hz archive
end

loadprh(tag,'p','fs') ;
df = fs/fo ;
ns = NWIN*round(df) ;
p = [p(ns+1:-1:2);p;p(end-(1:ns))] ;

if df==round(df),
   P = decimate(p,df) ;
else
   sc = df*17/100 ;              % 100/17 is the magic 5.8824 used in tag1
   if abs(sc-round(sc))<0.001,
      P = resample(p,17,100) ;
      if round(sc)>1,
         P = decimate(P,round(sc)) ;
      end
   else
      fprintf('Unfamiliar sampling-rate - you will need to resample by hand\n') ;  
      return
   end 
end
   
% P now contains p resampled at fo samples/sec
% Extract the part required

if nargin>=3,
   if startcue<0 | max(startcue,endcue)*fo>length(P),
      fprintf('Startcue and endcue must be within the length of the deployment\n') ;
      P = [] ;
      return
   end
   P = P(round(startcue*fo)+NWIN+1:round(endcue*fo)+NWIN) ;
else
   P = P(NWIN+1:end-NWIN) ;
end
