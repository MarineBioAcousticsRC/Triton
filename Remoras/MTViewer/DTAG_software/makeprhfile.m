function    makeprhfile(tag,s,fs,fname)
%
%   makeprhfile(tag)
%   Generate complete PRH file from a raw file using calibrations
%   and tag orientations in the tag deployment calibration file
%
%   makeprhfile(tag,s,fs,fname)
%   Apply calibrations for a tag to a sensor matrix and save the
%   result to a specific filename. Note that if fname is not
%   specified, the default PRH file will be overwritten. If fname
%   is specified and is not an absolute file name, the file will
%   be created in the current working directory.
%
%   To make a 25Hz PRH file using 5Hz calibrations do:
%
%     [s,fs]=swvread(tag,[],2) ;
%     makeprhfile(tag,s,fs,[tag 'prh25']) ;
%
%   mark johnson
%   majohnson@whoi.edu
%   last modified: 17 January 2008, added alternative call format
%

loadcal(tag) ;

if ~exist('CAL','var')
   fprintf(' No CAL structure in the tag file - perform calibration before running makeprhfile') ;
   return
end

if ~exist('DECL','var')
   fprintf(' No DECL (magnetic field declination) variable in tag file - using DECL=0\n') ;
   DECL = 0 ;
end

if nargin<3,
   [s,fs] = loadraw(tag) ;
end

if fs==5,
   [p,tempr] = calpressure(s,CAL,'lowbat') ;    % only apply lowbat correction to decimated data
   % this is a bag that needs to be fixed - ideally, lowbat onset variable should be stored as
   % a cue not a number of samples but this means that fs has to be passed to the cal tools
else
   [p,tempr] = calpressure(s,CAL,'none') ;
end

M = autocalmag(s,CAL,'none') ;
A = autocalacc(s,p,tempr,CAL,'none') ;

if ~exist('OTAB','var'),
   fprintf(' No OTAB (tag orientation) matrix in tag file - only computing tag frame variables\n') ;
   % save results
   if nargin<4,
      saveprh(tag,'p','fs','A','M','tempr') ;
   else
      save(fname,'p','fs','A','M','tempr') ;
   end
   return
end

% Compute the whale frame A and M matrices:
[Aw,Mw] = tag2whale(A,M,OTAB,fs) ;

% Compute whale frame pitch, roll, heading
[pitch roll] = a2pr(Aw) ;
[head vm incl] = m2h(Mw,pitch,roll) ;
head = head + DECL*pi/180 ;      % adjust heading for declination angle in radians

% report on trustworthiness of heading estimate
fprintf(' After gimballing :-\n') ;
fprintf(' Mean Magnetic Field Inclination: %4.2f\260 (%4.2f\260 RMS)\n',...
       180/pi*mean(incl), 180/pi*std(incl)) ;

% save results
if nargin<4,
   saveprh(tag,'p','pitch','roll','head','fs','Aw','Mw','A','M','tempr') ;
else
   save(fname,'p','pitch','roll','head','fs','Aw','Mw','A','M','tempr') ;
end
