function    [CAL,DEPLOY,ufname] = d3loadcal(uname)
%
%    [CAL,DEPLOY,ufname] = d3loadcal(uname)
%     Retrieve calibration information for a deployment.
%     Example:
%     [CAL,DEPLOY] = d3loadcal('mn10_146a') ;

CAL = [] ;
DEPLOY = [] ;

% make a filename for the deployment 'cal' file
global TAG_PATHS
if isempty(TAG_PATHS) | ~isfield(TAG_PATHS,'CAL'),
   fprintf(' No %s file path - use settagpath\n','CAL') ;
   return
end
ufname = sprintf('%s/%s',getfield(TAG_PATHS,'CAL'),[uname 'cal.xml']) ;

% check if a deployment file already exists - if so, read it
if ~exist(ufname,'file'),
   return
end

readmatxml(ufname) ;
if isfield(DEPLOY,'CAL'),
   CAL = DEPLOY.CAL ;
end
