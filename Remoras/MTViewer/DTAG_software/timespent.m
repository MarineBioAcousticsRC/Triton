function    [TS,t,P]=timespent(tag,lims,R,T)
%
%     [TS,t,P] = timespent(tag,lims,R,T)
%     Time spent in each sphere of radius R along a pseudo-track.
%     tag is the tag identifier string, e.g., 'md06_296a'
%     lims is a vector or matrix of start and end times for the
%     analysis in second since tag-on. lims = [start end]. If
%     lims is a matrix, each row will be treated as an independent
%     track segment to analyse. 
%     R is the radius of the sphere in m (default is 20 m). R can
%     also be a vector of radii in which case, TS will have a column
%     for each R(k).
%     T is the analysis time step (default is 1 s). T should be 
%     chosen so that T*fs is an integer where fs is the sensor 
%     sampling rate.
%     Returns:
%     TS is the vector of time spent indices in seconds
%     t is the vector of time cues corresponding to TS.
%     P is a structure containing the track, the speed, and
%     time vectors.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     Last modified: 8 February, 2007

if nargin<2,
   help timespent ;
   return
end

if nargin<3,
   R = 20 ;        % time steps along track
end

if nargin<4,
   T = 1 ;         % time steps along track
end

if size(lims,2)==1,
   lims = lims(:)' ;
end

R = R(:)' ;
TS = [] ;
S = [] ;
TRK = [] ;
t = [] ;

loadprh(tag,'p','fs','pitch','head') ;
LPF = 0.4/T ;

for k=1:size(lims,1),      % for each segment of track

   % compute the track
   kk = round(fs*lims(k,1)):round(fs*lims(k,2)) ;
   [trk,pe,s] = ptrack(pitch(kk),head(kk),p(kk),fs,LPF) ;

   % sampling times in this segment
   tt = (lims(k,1)+T:T:lims(k,2)-T)' ;
   kt = round(fs*(tt-lims(k,1)))+1 ;

   % decimate track
   trkd = trk(kt,:) ;

   % if the P output is requested, store the track and speed
   if nargout==3,
      S = [S;NaN;s(kt)] ;
      TRK = [TRK;NaN*ones(1,3);trkd] ;
   end

   % compute time spent for each T second segment of the track
   nt = length(kt) ;
   ts = NaN*zeros(length(kt),length(R)) ;

   if length(R)==1,
      for kk=1:nt,
         r = norm2(trkd-ones(nt,1)*trkd(kk,:)) ;
         ts(kk) = sum(r<R) ;
      end
   else
      for kk=1:nt,
         r = norm2(trkd-ones(nt,1)*trkd(kk,:)) ;
         ts(kk,:) = sum(r*ones(1,length(R))<ones(length(r),1)*R) ;
      end
   end   

   TS = [TS;NaN;ts] ;
   t = [t;NaN;tt] ;
end

TS = TS*T ;

if nargout==3,
   P.s = S ;
   P.trk = TRK ;
end
