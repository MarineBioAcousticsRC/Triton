function    fname = makefname(tag,type,chip,SILENT,ndigits)
%
%    fname = makefname(tag,type,[chip,SILENT,ndigits])
%     Generate a standard filename for a given tag deployment
%     and file type. Optional chip number is used for SWV, AUDIO,
%     GTX and LOG files.
%     Valid file types are:
%     RAW,CAL,PRH,AUDIT,SWV,GTX,AUDIO,LOG
%
%     mark johnson
%     majohnson@whoi.edu
%     last modified: 24 June 2006

fname = [] ; 

if nargin<2,
   help makefname
   return
end

if nargin<3,
   chip = 1 ;
   SILENT = [] ;
end

if nargin<4,
   SILENT = [] ;
end

if nargin>=3,
   if isstr(chip),         % swap arguments if silent comes first
      chip = SILENT ;
      SILENT = 's' ;
   end
end

if nargin<5 | isempty(ndigits),
   ndigits = 2 ;
end

if length(tag)~=9,
   if isempty(SILENT),
      fprintf(' Tag deployment name must have 9 characters e.g., sw05_199a') ;
   end
   return
end

shortname = tag([1:2 6:9]) ;
subdir = tag(1:4) ;
if ndigits==2,
   pref = sprintf('%s/%s/%s%02d',subdir,tag,shortname,chip) ;
else
   pref = sprintf('%s/%s/%s%03d',subdir,tag,shortname,chip) ;
end

% make appropriate suffix for the given file type
switch upper(type),
   case 'RAW'
         suffix = strcat(tag,'raw.mat') ;
   case 'CAL'
         suffix = strcat(tag,'cal.mat') ;
   case 'PRH'
         suffix = strcat(tag,'prh.mat') ;
   case 'AUDIT'
       suffix = strcat(tag,'aud.txt') ;
    case 'SWV'
         suffix = [pref '.swv'] ;
%        suffix = strcat(tag,'.swv') ;
        type = 'AUDIO' ;
    case 'GTX'
         suffix = [pref '.gtx'] ;
         type = 'AUDIO' ;
   case 'AUDIO'
         suffix = [pref '.wav'] ;
   case 'LOG'
         suffix = [pref '.txt'] ;
         type = 'AUDIO' ;
   otherwise
         fprintf(' Unknown file type: %s', type) ;
         return
end
        
% try to make filename
global TAG_PATHS
if isempty(TAG_PATHS) | ~isfield(TAG_PATHS,type),
   if isempty(SILENT),
      fprintf(' No %s file path - use settagpath\n', type) ;
   end
   fname = -1 ;   % indicate an error
   return
end
fname = fullfile(getfield(TAG_PATHS,type),suffix) ;
% fname = sprintf('%s\%s',getfield(TAG_PATHS,type),suffix) ;
