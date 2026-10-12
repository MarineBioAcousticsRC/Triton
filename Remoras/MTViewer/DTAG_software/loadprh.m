function    r = loadprh(tag,varargin)
%
%    loadprh(tag,...)
%    Load variables from the prh file associated with a tag deployment.
%    Examples:
%    load all the variables in the prh file of md04_287a
%       loadprh('md04_287a')
%    load just some variables from the prh file of md04_287a
%       loadprh('md04_287a','p','fs')
%    equivalently:
%       loadprh md04_287a
%       loadprh md04_287a p fs
%    If multiple PRH files are available for the deployment (i.e., with
%     different sampling rates, a dialog window will open to allow selection.
%     If the 2nd argument to loadprh is 0, the dialog will be skipped and
%     the first file opened.
%    load just some variables from the prh file of md04_287a
%       loadprh('md04_287a','p','fs')
%
%    mark johnson
%    majohnson@whoi.edu
%    last modified: July 2012

if nargout==1,
   r = 0 ;
end

if nargin<1,
   help loadprh
   return
end

% look for prh files for this deployment
pth = gettagpath('PRH') ;
ff = dir([pth '/' tag 'prh*.mat']) ;
if isempty(ff),
   if nargout==0,
      fprintf(' Unable to find prh file for %s - check directory and settagpath\n',tag) ;
   end
   return
end

select = 1 ;
fname = [pth '/' ff(1).name] ;
if nargin>1 & ~isstr(varargin{1}),
   select = varargin{1}~=0 ;
   varargin = {varargin{2:end}} ;
end

if select==1 & length(ff)>1,
   [fn,npth]=uigetfile([gettagpath('PRH') '/' tag 'prh*.mat'],'Select PRH file',fname) ;
   if fn~=0,
      fname = [npth fn] ;
   end
end

% load the variables from the file
s = load(fname,varargin{:}) ;
names = fieldnames(s) ;

% push the variables into the calling workspace
for k=1:length(names),
   assignin('caller',names{k},getfield(s,names{k})) ;
end

if nargout~=0,
   r = length(names) ;
end
