function    [M,CAL,mb] = autocalmag(s,CAL,test)

%    [M,CAL,mb] = autocalmag(s,CAL,[test])
%    Automatically performs a calibration sequence on the raw
%    magnetometer data in raw sensor matrix s. Calls calmag.m
%    for the actual calibration steps.
%    
%    mark johnson
%    majohnson@whoi.edu
%    last modified: 20 May 2006

if nargin<2,
   help autocalmag
   return
end

[s,k] = lowbattmcomp(s,CAL) ;
if ~isfield(CAL,'AK'),
   CAL.MK = 0.9*k ;                 % only calibrate over high battery data
end

if nargin==3 & ~isempty(test)
   [M,CAL,mb] = calmag(s,CAL,test);

else
   fprintf(' Hard iron calibration...\n') ;
   [M,CAL,mb]=calmag(s,CAL,'hard');
   fprintf(' Temperature calibration...\n') ;
   [M,CAL,mb]=calmag(s,CAL,'mb');
   fprintf(' Sensitivity calibration...\n') ;
   [M,CAL,mb]=calmag(s,CAL,'sens');
   fprintf(' Soft iron calibration...\n') ;
   [M,CAL,mb]=calmag(s,CAL,'soft');
   fprintf(' Pressure calibration...\n') ;
   [M,CAL,mb]=calmag(s,CAL,'p');
end
