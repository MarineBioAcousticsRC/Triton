function    savecal(tag,varargin)
%
%    savecal(tag,type,val,...)
%    Add calibration data to a correctly-named file in the
%     cal directory on the tag path. The data type is a
%     string selected from the following:
%     'AUTHOR' - string containing the initials or name of creator
%     'CAL' - structure of calibration settings
%     'CUETAB' - cue table from makecuetab
%     'DECL' - local declination angle in degrees
%     'GMT2LOC' - hours from GMT to local time
%     'OTAB' - matrix of tag orientations
%     'TAGATTACH' - time of tag attachment in seconds since tagon
%              (if not specified, it is assumed that the tag attached at
%              the tag on time).
%     'TAGDETACH' - time of tag detachment in seconds since tagon
%              (if not specified, it is assumed the tag is still attached
%              at the end of the record).
%     'TAGID' - identification number of the tag device
%     'TAGLOC' - tagon position [latitude,longitude] in decimal degrees
%     'TAGON' - tag start time as 6-element vector [yr mon day hr min sec]
%    If multiple calibration data are available, pass them
%    as additional type,val pairs, e.g.,
%      savecal(tag,'CUETAB',N,'CHIPS',chips)
%
%    mark johnson
%    majohnson@whoi.edu
%    edited by charles white
%    cwhite@whoi.edu
%    last modified: 29 June 2006

SILENT = 0 ;

if nargin<=1,
   help savecal
   return
end

% try to make filename
fname = makefname(tag,'CAL') ;
if isempty(fname),
   return
end

if ~exist(fname,'file'),
   ss = sprintf(' Calibration file %s does not exist.\n Do you want to create one? y/n... ', fname) ;
   s = input(ss,'s') ;
   if lower(s(1))=='n',
      return
   end

   if ~SILENT,
      AUTHOR = input(' Enter your initials... ','s') ;
      fprintf(' Creating file %s\n', fname);
      eval(sprintf('save \''%s\'' AUTHOR',fname)) ; % CHANGE_CEW

      TAGID = [] ;
      while length(TAGID)~=1,
         s = input(' Enter the tag id number e.g., 210... ','s') ;
         TAGID = sscanf(s,'%d') ;
      end
      eval(sprintf('save \''%s\'' -APPEND TAGID',fname)) ; % CHANGE_CEW

      TAGON = [] ;
      while length(TAGON)~=6,
         s = input(' Enter the tag on time (6 numbers)... ','s') ;
         TAGON = sscanf(s,'%f') ;
      end
      eval(sprintf('save \''%s\'' -APPEND TAGON',fname)) ; % CHANGE_CEW
   else
      AUTHOR = [] ;
      eval(sprintf('save \''%s\'' AUTHOR',fname)) ;
   end
end

types = {'AUTHOR','DECL','CAL','TAGID','TAGON','TAGLOC','OTAB','CUETAB','GMT2LOC','TAGATTACH','TAGDETACH'} ;

% save the variable to the file

k = 1 ;
while k<length(varargin),
   treq = upper(varargin{k}) ;
   if any(strcmp(types,treq)),
      eval(sprintf('%s=varargin{k+1};',treq)) ;
      s = sprintf('save \''%s\'' -APPEND %s',fname,treq) ;
      eval(s) ;
   else
      fprintf(' Unknown data type ''%s'' for calibration file. Skipping\n', treq) ;
   end
   k = k+2 ;
end

LASTENTRY = clock ;
eval(sprintf('save \''%s\'' -APPEND LASTENTRY',fname)) ;
