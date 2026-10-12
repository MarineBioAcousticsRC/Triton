function    r = loadcal(tag,varargin)
%
%    loadcal(tag,...)
%    Load the calibration data file associated with a tag deployment.
%    Optionally pass the names of variables from the file that are
%    required. Otherwise all variables are loaded.
%
%    mark johnson
%    majohnson@whoi.edu
%    last modified: 24 June 2006

if nargin<1,
   help loadcal
   return
end

% try to make filename
fname = makefname(tag,'CAL') ;
if isempty(fname),
   return
end

% check if the file exists
if ~exist(fname,'file'),
   if nargout==0,
      fprintf(' Unable to find cal file %s - check directory and settagpath\n',fname) ;
   else
      r = 0 ;
   end
   return
end

% load the variables from the file
try
   s = load(fname,varargin{:}) ;
catch
end

if nargout==0,
   names = fieldnames(s) ;
   % push the variables into the calling workspace
   for k=1:length(names),
      assignin('caller',names{k},getfield(s,names{k})) ;
   end
else
   r = s ;
end


