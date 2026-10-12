function    dnum = d3datenum(dvec)
%
%    dnum = d3datenum(dvec)
%
%     Convert a 6-element datevector [year month day hour minute second]
%     into a DMON (UNIX) datenumber.
%     The UNIX and D3 datenumber is the number of seconds 
%     since midnight Jan 1 1970.


dd = datenum([1970 1 1 0 0 0]) ;
dnum = (datenum(dvec)-dd)*3600*24 ;
