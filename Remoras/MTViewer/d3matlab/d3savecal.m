function    d3savecal(uname,name,value)
%
%    d3savecal(uname,fieldname,value)
%     Save calibration information specific to a tag deployment.
%     An XML format file is generated and stored in the same
%     directory as the source data or in a prefered calibration
%     directory according to recdir. The file is named <uname>cal.xml
%     where <uname> is the deployment name e.g., 'mn10_185a'.
%     fieldname is any valid field name for a DEPLOY structure.
%     To remove a field, use:
%     d3savecal(uname,fieldname)
%
%      Any fieldname can be used except the reserved names:
%        ID, RECN, RECDIR, FN, SCUES, NAME
%
%    mark johnson
%    markjohnson@st-andrews.ac.uk
%    last modified: July 2012

if nargin<2,
   help d3savecal
   return
end

DEPLOY = [] ;
[CAL,DEPLOY,fn] = d3loadcal(uname) ;
if isempty(DEPLOY),
   fprintf('No deployment file for %s - run d3deployment to make one\n',uname) ;
   return
end

if nargin>2,
   % update the DEPLOY information
   if nargin>2,
      DEPLOY = setfields(DEPLOY,upper(name),value) ;
   elseif isfield(DEPLOY,name),
      DEPLOY = rmfields(DEPLOY,upper(name)) ;
   end
end

writematxml(DEPLOY,'DEPLOY',fn) ;
return


function S = setfields(S,name,value)
%
%
eval(sprintf('S.%s=value;',name))
return


function S = rmfields(S,name)
%
%
eval(sprintf('S.%s=[];',name))
return
