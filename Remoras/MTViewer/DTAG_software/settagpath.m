function    settagpath(varargin)
%
%    settagpath(datatype,pathname,...)
%    Sets the paths for tag data
%    datatype can be:
%    'prh' - directory containing prh .mat files
%    'audit' - directory containing audit results
%    'raw' - directory containing raw sensor .mat files
%    'cal' - directory containing deployment/calibration files
%    'audio' - directory containing subdirectories with names
%        of tag deployments each of which contains audio (wav),
%        swv and txt files.
%    Each datatype is followed by a path name where that data
%    may be found. Only one path is allowed for each data type.
%    Multiple datatype,pathname pairs may be given in a single
%    call to settagpath, e.g.,
%
%    settagpath('prh','d:/tag/tag2/data/prh','audio','f:')
%    It is suggested that a settagpath line be placed in the
%    a script that you always run when starting matlab
%
%    mark johnson
%    majohnson@whoi.edu
%    last modified: 13 May 2006

if length(varargin)<2,
   help settagpath
   return
end

if ~exist('TAG_PATHS','var'),
   global TAG_PATHS
else
   if ~isglobal(TAG_PATHS),
      ss = TAG_PATHS ;
      clear TAG_PATHS ;
      global TAG_PATHS
      TAG_PATHS = ss ;
   end
end

for k=1:2:length(varargin),
   d = varargin{k} ;
   p = varargin{k+1} ;
   if ~isstr(d) | ~isstr(p),
      fprintf(' Input arguments must be strings\n') ;
      return
   end

   if length(p)>0 & (p(end) == '\' | p(end) == '/'),
       p = p(1:end-1) ;
   end

   if ~exist(p,'dir'),
      fprintf(' Warning: directory %s does not exist\n', p) ;
   end

   switch lower(d),
      case 'prh', TAG_PATHS.PRH = p ;
      case 'audit', TAG_PATHS.AUDIT = p ;
      case 'raw', TAG_PATHS.RAW = p ;
      case 'audio', TAG_PATHS.AUDIO = p ;
      case 'cal', TAG_PATHS.CAL = p ;
      otherwise   fprintf(' Unknown data type %s\n',d) ;
   end
end
