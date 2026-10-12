function    [ta,ts] = recordlength(tag)

%    [ta,ts] = recordlength(tag)
%     Returns the number of seconds in a tag audio recording in ta
%     and in a tag sensor recording in ts. tag is the full name of
%     a tag deployment for which a CAL file exists.
%     Can also be called as:
%     [ta,ts] = recordlength(CUETAB) ;
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     27 July, 2007

if nargin<1,
   help recordlength
   return
end

if isstr(tag),
   loadcal(tag,'CUETAB') ;
else
   CUETAB = tag ;
end

if ~exist('CUETAB','var')
   fprintf('No CAL file or CUETAB for this deployment\n') ;
   return
end

T = sum(CUETAB(:,[3 8])./CUETAB(:,[5 10])) ;
ta = T(1) ;
ts = T(2) ;

