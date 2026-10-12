function    [ppmci,TD,Q] = clockanal(P,fs,NOBUFFFIX)

%    [ppm TD Q] = clockanal(P,fs,NOBUFFFIX)
%     Calculate the drift of a tag clock from GPS PPS messages
%     Use readgtx to get P. fs is the nominal audio sampling rate
%     of the tag.
%    Returns: ppm = [mean lower_ci upper_ci] where lower_ci and
%     upper_ci are the +/-2-sigma confidence intervals on the mean.
%     Results are in parts-per-million.
%
%    mark johnson, WHOI
%     21 Sept. 2008

if nargin<2,
   help clockanal
   return
end

BUFFLEN = 900 ;               % dtag audio buffer length in samples
if nargin<3,
   ds = diff(P.diffsamples) ;
   k = find(ds>1000 & ds<2000) ;
   if ~isempty(k),
      P.diffsamples(k) = P.diffsamples(k)+BUFFLEN ;
      P.diffsamples(k+1) = P.diffsamples(k+1)-BUFFLEN ;
      P.cuetime(k) = P.cuetime(k)+BUFFLEN/fs ;
   end
end

T = P.gpstime(2:end) ;
fsest = P.diffsamples(2:end)./diff(P.gpstime) ;
k = find(abs(fsest-fs)<0.1*fs);
se = std(fsest(k))/sqrt(length(k)) ;
me = mean(fsest(k)) ;
ppmci = (me-fs+2*se*[0 -1 1])/fs*1e6 ;
fprintf('Mean clock error is %5.1f (confidence interval: %5.1f-%5.1f) PPM\n',ppmci) ;
fprintf('Based on %d samples\n',length(k)) ;

if nargout>=2,
   D = (fsest-fs)/fs*1e6 ;
   TD = [T D] ;
end

if nargout==3,
   Q.gpstime = P.gpstime(k) ;
   Q.cuetime = P.cuetime(k) ;
   Q.latitude = P.latitude(k) ;
   Q.longitude = P.longitude(k) ;
end
