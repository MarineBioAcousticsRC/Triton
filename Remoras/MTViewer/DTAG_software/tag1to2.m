function    s = tag1to2(s)
%
%    s = tag1to2(s)
%    Change column order of tag1 sensor matrix s to match
%    tag2 channel order. See swvread.m for tag2 channel order.
%
%    mark johnson, WHOI
%    majohnson@whoi.edu
%    24 June, 2007

s = s(:,[3 4 5 8 7 9 11 10 16 12 14 15]) ;


