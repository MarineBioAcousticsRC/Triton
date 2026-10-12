function    dvec = d3datevec(dnum)
%
%    dvec = d3datevec(dnum)
%
%     Convert a DMON (UNIX) datenumber into a 6-element
%     datevector [year month day hour minute second].
%     The UNIX and D3 datenumber is the number of seconds 
%     since midnight Jan 1 1970.


dd = datenum([1970 1 1 0 0 0]) ;
dvec = datevec(dnum(:)/3600/24+dd) ;

