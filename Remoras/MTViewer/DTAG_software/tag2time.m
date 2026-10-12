function      v = tag2time(s)
%
%     v = tag2time(s)
%     Convert hexadecimal time string shown by ffsrd into a date and time
%     This is useful for emergency recovery of the tag-on time.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     last modified: 10 May, 2007 

if nargin<1,
   help tag2time
   return
end

dd=datenum([2003 6 14 13 38 35]) ;
ddt=hex2dec('c295a3db')/3600/24 ;
offs=dd-ddt ;

if nargout == 0,
   fprintf('%s\n',datestr(hex2dec(s)/3600/24+offs));
else
   v = datevec(hex2dec(s)/3600/24+offs) ;
end
