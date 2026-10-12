function    X = nmeaparse(s)
%
%     x = nmeaparse(s)
%     Extract data from the NMEA sentence in string s. Supported sentences
%     are:
%     $GPRMC, $GPGGA, $GPGLL, $PGRMF
%     The following data are extracted into structure x, if available in the 
%     sentence (x has matching fieldnames):
%     time=[y m d h min sec], position=[lat long], nav=[sog cog], decl
%     head=[heading,headtype], mess
%     time is in UTC; pos, decl, heading and cog are in decimal degrees.
%     sog is in m/s. mess is the 6-character NMEA message. headtype is
%     0 for magnetic and 1 for true.
%
%     Returns:
%     structure x with fields as above.
%     If any field is not available in the sentence or if the sentence status
%     is invalid, NaN is returned.
%
%     Example:
%     s = '$GPRMC,203018,A,2442.433,N,07745.900,W,000.0,360.0,211006,006.7,W*72'
%     x = nmeaparse(s)
%     gives:   x.mess = '$GPRMC'
%              x.time = [2006 10 21 20 30 18]
%              x.position = [24.7072 -77.7650 1]
%              x.decl = -6.7
%              x.nav = [0 360]
%              x.head = [NaN NaN]
%
%     other test sentences:
%     s = '$GPGGA,203018,2442.433,N,07745.900,W,2,06,2.0,3.0,M,30.0,M,600,0000*72'
%     s = '$GPGLL,2442.433,N,07745.900,W,203018,A,A*72'
%     s = '$PGRMF,45,45678,211006,203018,47,2442.433,N,07745.900,W,A,1,2,330,2,3*72'
%     s = '$HCHDM,023.9,M*21
%     s = '$HCHDT,023.9,T*21
%
%     mark johnson, majohnson@whoi.edu
%     logtoolv4 toolbox
%     April, 2008

X = [] ;
if nargin<1,
   help nmeaparse
   return
end

if ischar(s),
   s = {s} ;
end

% message elements are:
%  1    2    3   4       5    6        7   8   9    10       11     12    13   14
% [date time lat lathemi long longhemi sog cog decl declhemi status valid head htype]

for k=1:length(s),
   x = struct('mess',s{k}(1:6)) ;
   sogscf = 1000/3600 ;          % conversion between km/hr and m/s
   switch x.mess
      case '$GPRMC'
         indx = [10,2,4,5,6,7,8,9,11,12,0,3,0,0] ;
         sogscf = 1852/3600 ;          % conversion between knots and m/s
      case '$GPGGA'
         indx = [0,2,3,4,5,6,0,0,0,0,7,0,0,0] ;
      case '$GPGLL'
         indx = [0,6,2,3,4,5,0,0,0,0,0,7,0,0] ;
      case '$PGRMF'
         indx = [4,5,7,8,9,10,13,14,0,0,12,0,0,0] ;
      case {'$HCHDM','$HCHDT'}
         indx = [0,0,0,0,0,0,0,0,0,0,0,0,2,3] ;
      otherwise
      %   logtoolerror('Unknown nmea sentence %s',x.mess) ;
         return
   end

   ss = gettoks(s{k},max(indx)) ;
   if isempty(ss),
      logtoolerror('Bad NMEA message: %s', s{k}) ;
      return
   end

   % interpret components in message...
   % date in yymmdd
   if indx(1)>0,
      xx = str2double(ss{indx(1)}) ;
      yr = 2000+mod(xx,100) ;
      xx = floor(xx/100) ;
      mon = mod(xx,100) ;
      day = floor(xx/100) ;
      x.time = [yr mon day NaN NaN NaN] ;
   else
      x.time = NaN*ones(1,6) ;
   end

   % time of day in hhmmss
   if indx(2)>0,
      xx = str2double(ss{indx(2)}) ;
      sec = mod(xx,100) ;
      xx = floor(xx/100) ;
      min = mod(xx,100) ;
      hr = floor(xx/100) ;
      x.time(4:6) = [hr min sec] ;
   end

   % latitude is in ddmm.mmm
   if indx(3)>0,
      xx = str2double(ss{indx(3)}) ;
      mm = mod(xx,100) ;
      dd = floor(xx/100) ;
      x.position = [dd+mm/60 NaN] ;
      if isequal(ss{indx(4)},'S'),
         x.position(1) = -x.position(1) ;
      end
      % longitude is in dddmm.mmm
      xx = str2double(ss{indx(5)}) ;
      mm = mod(xx,100) ;
      dd = floor(xx/100) ;
      x.position(2) = dd+mm/60 ;
      if isequal(ss{indx(6)},'W'),
         x.position(2) = -x.position(2) ;
      end
   else
      x.position = NaN*[1 1] ;
   end

   % navigation data
   % speed over ground in dd.d
   % course over ground in dd.d
   if all(indx(7:8)>0),
      x.nav = str2double({ss{indx(7:8)}}) ;
      if length(x.nav)==1,
         x.nav = NaN*[1 1] ;
      else
         x.nav(1) = x.nav(1)*sogscf ;
      end
   else
      x.nav = NaN*[1 1] ;
   end

   % declination angle in dd.d
   if indx(9)>0,
      x.decl = str2double(ss{indx(9)}) ;
      if ss{indx(10)}(1)=='W',
         x.decl = -x.decl ;
      end
   else
      x.decl = NaN ;
   end

   % check status and valid fields
   bad = 0 ;
   if indx(11)>0,
      qi = str2double(ss{indx(11)}) ;
      bad = qi<1 | qi>2 ;
   end
   if indx(12)>0,
      bad = ss{indx(12)}(1)~='A' ;
   end
   if bad,
      x.position = NaN*[1 1] ;
   end

   % heading in dd.d with a magnetic or true character
   if indx(13)>0,
      x.head = [str2double(ss{indx(13)}) ss{indx(14)}(1)=='T'] ;
   else
      x.head = NaN*[1 1] ;
   end
   if isempty(X),
      X = x ;
   else
      X(k) = x ;
   end
end
return


function    ss = gettoks(s,n)
%
%
%
ss = cell(1,n) ;
for k=1:n,
   if all(s(1:2) == ','),
      ss{k} = NaN ;
      s = s(2:end) ;
   else
      [ss{k},s] = strtok(s,',') ;
   end
   if isempty(s), break, end
end
return
