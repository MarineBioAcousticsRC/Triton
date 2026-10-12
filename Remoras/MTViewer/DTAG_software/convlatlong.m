function    [x,s] = convlatlong(x,latlong,fmt,silent)
%
%    [x,s] = convlatlong(s,latlong,fmt,silent)
%     Convert string or cell array of strings into decimal degrees. 
%     latlong must be 'lat' or 'lon'. Valid strings are: -ddd.dddddd,
%     -ddd mm.mmmm or -ddd mm ss.ss. 4th argument is optional.
%
%    [x,s] = convlatlong(x,latlong,fmt,silent)
%     Convert decimal degrees x into a string or array of strings 
%     according to fmt.
%     latlong must be 'lat' or 'lon'.
%     Options are:
%     fmt = 'decdeg'    -ddd.dddddd
%     fmt = 'degmin'    -ddd mm.mmmm
%     fmt = 'dms'       -ddd mm ss.ss
%     If no fmt is specified, the logtool preferences are followed.
%
%     Optional 4th argument turns off error messages if 1.
%     Returns x=NaN and s='' for invalid inputs.

if nargin<4, silent = 0 ; end
if isempty(x), x=NaN; s=''; return, end

if isstr(x),
   x = {x} ;
end

if iscell(x),
   xx = NaN*ones(length(x),1) ;
   for k=1:length(x),
      xx(k) = str2decdeg(x{k},strncmp(latlong,'lon',3)) ;
   end
   x = xx ;
end

if nargout<2, return, end

if nargin<3 | isempty(fmt),
   if ~ispref('logtoolv4','latlongfmt')
      fmt = 'decdeg' ;
   else
      fmt = getpref('logtoolv4','latlongfmt') ;
   end
end

bad = 0 ;
s = cell(length(x),1) ;
[s{1:length(x)}]=deal('') ;
k = find(~isnan(x)) ;

switch fmt
   case 'decdeg'
      for kk=k',
         s{kk} = num2str(x(kk),'%3.6f') ;
      end
   case 'degmin'
      degs = round(x) ;
      mins = rem(abs(x),1)*60 ;
      for kk=k',
         s{kk} = sprintf('%3d %2.4f',degs(kk),mins(kk)) ;
      end
   case 'dms'
      degs = round(x) ;
      mins = rem(abs(x),1)*60 ;
      secs = rem(mins,1)*60 ;
      for kk=k',
         s{kk} = sprintf('%3d %2d %2.2f',degs(kk),floor(mins(kk)),secs(kk)) ;
      end
   otherwise
      if silent~=1,
         logtoolerror('Unknown latitude/longitude display format - check settings') ;
      end
end

if length(s)==1,
   s = s{1} ;
end

return


function    x = str2decdeg(s,islong)
%
%    x = parselatlong(s,islong)
%     Convert string s into decimal degrees.
%     s can have decimal degree (-ddd.dddddd), degree-minute (-ddd mm.mmmm)
%     or degree-minute-second (-ddd mm ss.ss) format.
%
%     TODO: add optional N/S/E/W character at end of string

[x,cnt] = sscanf(s,'%f %f %f',3) ;
if cnt==1 & abs(cnt(1))<=180,
   x = x(1) ;                                % decimal degrees format
elseif cnt==2 & all(abs(x(1:2))<=[180;60]) & x(2)>=0 & rem(x(1),1)==0,
   x = sign(x(1))*(abs(x(1))+x(2)/60) ;      % degrees and minutes format
elseif cnt==3 & all(abs(x)<=[180;60;60]) & all(x(2:3)>=0) & all(rem(x(1:2),1)==0),
   x = sign(x(1))*(abs(x(1))+(x(2)+x(3)/60)/60) ; % degrees minutes seconds format
else
   x = NaN ;
end

if abs(x)>90*(islong+1),
   x = NaN ;
end
return


