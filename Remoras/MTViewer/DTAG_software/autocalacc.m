function    [A,CAL] = autocalacc(s,p,t,CAL,test)

%    [A,CAL] = autocalacc(s,p,tempr,CAL,[test])
%    Automatically performs a calibration sequence on the raw
%    accelerometer data in raw sensor matrix s. Calls calacc.m
%    for the actual calibration steps.
%    
%    mark johnson
%    majohnson@whoi.edu
%    last modified: 24 May 2006

if nargin<4,
   help autocalacc
   return
end

[s,k] = lowbattacomp(s,p,CAL) ;
if ~isfield(CAL,'AK'),
   CAL.AK = 0.9*k ;                 % only calibrate over high battery data
end

if nargin==5 & ~isempty(test)
   [A,CAL]=calacc(s,p,t,CAL,test);

else  
   fprintf(' Bias calibration...\n') ;
   [A,CAL]=calacc(s,p,t,CAL,'bias');
   fprintf(' Pressure calibration...\n') ;
   [A,CAL]=calacc(s,p,t,CAL,'p');
   fprintf(' Temperature calibration...\n') ;
   [A,CAL]=calacc(s,p,t,CAL,'t');
   fprintf(' Sensitivity calibration...\n') ;
   [A,CAL]=calacc(s,p,t,CAL,'sens');
   fprintf(' Cross-axis calibration...\n') ;
   [A,CAL]=calacc(s,p,t,CAL,'cross');
end
