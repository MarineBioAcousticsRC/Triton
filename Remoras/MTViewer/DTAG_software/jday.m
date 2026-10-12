function      n = jday(ymd)
%
%      n = jday([ymd])
%      Calculate the 'Julian' day number for a given
%      date: ymd = [year,month,day]. If no argument
%      is given, the Julian day number for today is
%      returned.
%
%      mark johnson
%      majohnson@whoi.edu
%      13 May 2006

if nargin==0 | isempty(ymd),
   d = clock ;
   t = now ;
else
   d = ymd(1) ;
   t = datenum(ymd) ;
end

n = floor(t-datenum([d(1) 1 1 0 0 0]))+1 ;
