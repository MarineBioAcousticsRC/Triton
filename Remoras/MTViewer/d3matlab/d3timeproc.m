function    Y = d3timeproc(recdir,prefix)
%
%    Y = d3timeproc(recdir,prefix)
%     Read .tim files from a D3 deployment
%     Returns a matrix with columns:
%        local time in second of day
%        corresponding UTC time in second of day
%        latitude in decimal degrees
%        longitude in decimal degrees
%     e.g.,
%        Y=d3timeproc('e:/by09/27oct/','byDMON5_27oct09');
%
%     mark johnson, WHOI
%     29 Oct 2009

S = readnmefiles(recdir,prefix,'tim');

% find which NMEA string is in the files
switch S{2,3},
   case '$PGRMF'
      cols = [1 2 7 9 11] ;
      vchar = vertcat(S{:,14}) ;
      ind = find(vchar(:,1) == '2') ;
      dirs = [10 12] ;
   case '$GPGLL'
      cols = [1 2 8 4 6] ;
      vchar = vertcat(S{:,9}) ;
      ind = find(vchar(:,1) == 'A') ;
      dirs = [5 7] ;
   case '$GPGGA'
      cols = [1 2 4 5 7] ;
      vchar = vertcat(S{:,9}) ;
      ind = find(vchar(:,1) == '1' | vchar(:,1) == '2') ;
      dirs = [6 8] ;
   case '$GPRMC'
      cols = [1 2 4 6 8] ;
      vchar = vertcat(S{:,5}) ;
      ind = find(vchar(:,1) == 'A') ;
      dirs = [7 9] ;
end

X = str2double({S{ind,cols}}) ;
X = reshape(X,length(ind),length(cols)) ;
Dn = strvcat(S{ind,dirs(1)}) ;   % direction latitude
De = strvcat(S{ind,dirs(2)}) ;   % direction longitude

% columns of X are   local second,
%                    local microseconds,
%                    UTC compound time-of-day (hhmmss),
%                    compound latitude (ddmm.mmmm),
%                    compound longitude (dddmm.mmmm)

% convert UTC compound time-of-day to second-of-day
z = X(:,3) ;
sofday = floor(z/10000+0.1)*3600 + floor(100*rem(z/10000,1)+0.1)*60 + 100*rem(z/100,1) ;

% convert compound latitude to decimal degrees
z = X(:,4) ;
lati = floor(z/100) ;
lati = lati + (z-lati*100)/60 ;

% convert compound longitude to decimal degrees
z = X(:,5) ;
longi = floor(z/100) ;
longi = longi + (z-longi*100)/60 ;

% correct for direction of latitude
k = find(Dn(:,1)=='S') ;
lati(k) = -lati(k) ;

% correct for direction of longitude
k = find(De(:,1)=='W') ;
longi(k) = -longi(k) ;

% get local date to use as a referenc
dv = datevec(X(1,1)/24/3600+datenum([1970 1 1 0 0 0])) ;
dd = [dv(1:3) 0 0 0] ;
fprintf(' Reference date is %s\n', datestr(dd,1)) ;
dref = round((datenum(dd)-datenum([1970 1 1 0 0 0]))*24*3600) ;
lsofday = (X(:,1)-dref)+X(:,2)/1e6 ;

kk = 5:length(sofday) ;      % ignore the first few points - they might be bad
[pp ppint] = regress(lsofday(kk)-sofday(kk),[ones(length(kk),1),sofday(kk)]) ;
cint = max(abs(ppint(2,:)-pp(2))) ;
fprintf(' Local clock drift is %3.2f +/- %1.2f ppm\n',pp(2)*1e6,cint*1e6) ;
 
Y = [lsofday sofday lati longi] ;
return
