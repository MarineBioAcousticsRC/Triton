function    [CAL,DEPLOY] = d3deployment(recdir,prefix,uname)
%
%      [CAL,DEPLOY] = d3deployment(recdir,prefix,uname)
%        Collect information about a deployment and create a deployment
%        'cal' file. The 'cal' file will be called <uname>cal.xml and
%        will be written to the CAL directory on the tag path (see
%        settagpath.m).
%        Examples:
%            CAL=d3deployment('e:/data/bb10','bb215a','bb10_215a') ;
%        or  d3deployment('e:/data/bb10','bb10_215a') ;
%
%        markjohnson@st-andrews.ac.uk
%        26 feb 2013
%        bug fix: FHJ 8 april 2014

DEPLOY = [] ; CAL = [] ;

if nargin<2,
   help d3deployment
   return
end

if nargin<3,
   uname = prefix ;
end

% make a filename for the deployment 'cal' file
global TAG_PATHS
if isempty(TAG_PATHS) | ~isfield(TAG_PATHS,'CAL'),
   fprintf(' No CAL file path - use settagpath\n') ;
   return
end
ufname = sprintf('%s/%scal.xml',getfield(TAG_PATHS,'CAL'),uname) ;

% check if a deployment file already exists - if so, check if overwriting is ok
if exist(ufname,'file'),
   ss = sprintf(' A deployment with the same name already exists.\n Do you want to overwrite it? y/n... ') ;
   s = input(ss,'s') ;
   if lower(s(1))=='n',
      return
   end
end

senssuffix = 'swv' ;
fprintf(' Looking for recordings...\n') ;
[fn,did,recn,recdir] = getrecfnames(recdir,prefix) ;
DEPLOY.ID = dec2hex(did(1)) ;
if length(DEPLOY.ID)<8,      % check if zero-padding is required
   DEPLOY.ID = [repmat('0',1,8-length(DEPLOY.ID)) DEPLOY.ID];
end
DEPLOY.NAME = [] ;
DEPLOY.RECN = recn ;
DEPLOY.RECDIR = recdir ;
DEPLOY.FN = fn ;
DEPLOY.SCUES = struct ;
for k=1:length(fn),
   fprintf(' Checking recording %s\n',fn{k}) ;
   d3=readd3xml([recdir fn{k} '.xml']) ;
   cues = d3.CUE ;
   for kk=1:length(cues),
      if strcmp(cues{kk}.SUFFIX,senssuffix)
         break ;
      end
   end
   cc = cues{kk} ;
   DEPLOY.SCUES.SAMPLE(k) = str2num(cc.SAMPLE) ;
   t = str2num(cc.TIME) ;
   t(end) = t(end) + str2num(cc.CUE) ;
   DEPLOY.SCUES.TIME(k,:) = t ;

   n = wavread16([recdir fn{k} '.swv'],'size') ;
   DEPLOY.SCUES.N(k) = n(1) ;
   cfg = cc.ID ;
end

% find the configuration entry in d3 for the sensor file
d3=readd3xml([recdir fn{1} '.xml']) ;
for k=1:length(d3.CFG),
   cc = d3.CFG{k} ;
   if strcmp(cc.ID,cfg),
      break
   end
end

% get the base sensor sampling rate
sfs = [] ;
if isfield(cc,'SRC'),
   srcid = cc.SRC.ID ;
   % try to get precise sampling rate from CLK and DIVIDE numbers
   for k=1:length(d3.CFG),
      cc = d3.CFG{k} ;
      if strcmp(cc.ID,srcid),
         break
      end
   end
   if isfield(cc,'MCLK') && isfield(cc,'CLKDIV') && isfield(cc,'NSEQ'),
      sfs = str2double(cc.MCLK.MCLK)*1e6/str2double(cc.CLKDIV)/str2double(cc.NSEQ) ;
   end
end

if isempty(sfs),
   if isfield(cc,'EXP'),
      cc.EXP(cc.EXP=='_') = '-' ;     % reverse the fix in readd3xml to overcome Matlab
                                   % field name restrictions
      sfs = str2num(cc.FS)*10^str2num(cc.EXP) ;
   else
      sfs = str2num(cc.FS)*10^(-3) ;
   end
end

if isempty(sfs),
   fprintf('Error: unable to determine actual sensor sampling rate\n') ;
   return ;
end

% check for timing errors in the sensor files
DEPLOY.SCUES.TERR(1) = 0 ;
for k=1:length(fn)-1,
   fdur = etime(DEPLOY.SCUES.TIME(k+1,:),DEPLOY.SCUES.TIME(k,:)) ;
   sdur = DEPLOY.SCUES.N(k)/sfs ;
   terr = fdur-sdur ;
   DEPLOY.SCUES.TERR(k+1) = terr ;
   if abs(terr)>0.001,
      fprintf('Sensor timing error of %3.3f ms between files %d and %d\n',...
         terr*1000,k,k+1);
   end
end

DEPLOY.SCUES.SSTART = DEPLOY.SCUES.TIME(1,:) ;

% look for a suitable CAL
[CAL,id,cname] = d3findcal(DEPLOY.ID) ;
if ~isempty(CAL),
   DEPLOY.NAME = cname ;
   DEPLOY.CAL = CAL ;
end

% create the deployment record file
writematxml(DEPLOY,'DEPLOY',ufname) ;

