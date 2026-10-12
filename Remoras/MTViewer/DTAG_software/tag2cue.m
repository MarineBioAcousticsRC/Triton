function      [c,t,s,len,fs,TAGID,ndigits]=tag2cue(cue,tag,SILENT)
%
%      GENERAL ACCESS TO TAG CUES IS BY tagcue.m
%      tag2cue is called by tagcue
%
%      [c,t,s,len,fs,id,ndigits]=tag2cue(cue,tag,SILENT)
%      Return cue information for a tag dataset:
%         tag  is the deployment name e.g., 'sw01_200'
%         cue is a 1 to 3 element vector interpreted as:
%             0-element: first data point in recording
%             1-element: seconds since tag-on
%             2-element: data index in [chip,second]
%             3-element: time of day in [hour,min,sec]
%
%      Output arguments are:
%         c = [chip,audio-sample-in-chip,raw-sensor-sample]
%         t = [year,month,day,hour,min,sec]
%         s = seconds since tag on
%		    len = [d,l,r]   -  CURRENTLY NOT SUPPORTED
%		    where d = data length in hours
%			     l = length of attachment in hours
%				  r = reason for release 0=unknown, 1=release,
%					   2=knock-off, 3=mechanical failure
%         fs = [audio_sampling_rate,sensor_sampling_rate]
%         id = tag number that made the recording e.g., 210
%
%      To request a list of supported experiments, use:
%         tag2cue('') ;
%
%      To install a new experiment do the following:
%         1. N = makecuetab(fnamebase,chips) ;
%            where:
%            fnamebase is the start of the log filenames produced by
%            ffsrd, e.g., sw165a
%            chips is a vector of the chips numbers to be logged, e.g.,
%            chips = 1:12 ;
%         2. savecuetab(tag,id,tagon,N) ;
%            where tag is the full experiment identifier of form -
%            'ssyy_ddda', ss=2-letter species name, yy=2-digit year,
%            ddd is the 3-digit julian day, a is the 1-letter focal code
%            e.g., sw03_165a
%            id is the number of the tag e.g., 210
%            tagon is the 6-element vector of on-time [year,month,day,hour,
%            minute,second]
%
%  mark johnson, WHOI
%  majohnson@whoi.edu
%  last modified: June 2006
%                 added CAL file support

t = [] ; c = [] ; len = [] ; s = [] ; fs = [] ; TAGID = [] ; ndigits = 2 ;

if nargin==1 & isstr(cue),
   tag = cue ;
   cue = [] ;
end

if nargin<1,
   help('tag2cue') ;
   return
end

if nargin<3,
   SILENT = 0 ;
end

offset = 0 ;
fname = makefname(tag,'CAL','s') ;
if ~isempty(fname) & exist(fname,'file'),
   loadcal(tag,'CUETAB','TAGON','TAGID') ;
   if ~exist('CUETAB','var') | ~exist('TAGON','var') | ~exist('TAGID','var'),
      fprintf(' Parameters are missing in the CAL file for this deployment\n') ;
      return ;
   end

elseif exist('tag2cues.mat'),
   load tag2cues
   if length(tag)==0,
      fprintf(' Experiments listed in tag2cues are:\n') ;
      exps = fieldnames(CUES) ;
      for k=1:length(exps),
         fprintf(' %s\n',exps{k}) ;
      end
      return
   end

   if ~isfield(CUES,tag)
      if ~SILENT,
         fprintf('Experiment %s has not been installed - use savecal\n', tag) ;
      end
      return ;
   end

   ss = getfield(CUES,tag) ;
   CUETAB = ss.N ;
   TAGID = ss.id ;
   TAGON = ss.on ;
   if isfield(ss,'offset'),
      offset = ss.offset ;
   end

else
   if ~SILENT,
      fprintf('Unable to find cue information for tag %s - check path\n', tag) ;
   end
   return ;
end

if isempty(CUETAB),
   fprintf('Empty CUETAB in CAL file\n') ;
   return ;
end

if isstruct(CUETAB),
   ndigits = CUETAB.ndigits ;
   CUETAB = CUETAB.N ;
end

fs(1) = round(mean(CUETAB(:,5))) ;       % audio sampling rate in Hz
fs(2) = round(mean(CUETAB(:,10))) ;      % raw sensor sampling rate in Hz
crt = [0;cumsum(CUETAB(:,3))/fs(1)] ;    % cumulative record time in secs
TAGON = TAGON(:)' ;

switch length(cue)
   case 0
      tcue = CUETAB(1,2) ;
   case 1
      tcue = cue ;
   case 2
	   if cue(1) >= 1,
         tcue = CUETAB(1,2) + cue(2) + crt(cue(1)) ;
	   else
		   tcue = -1 ;
	   end
   case 3
      tcue = etime([TAGON(1:3) cue(:)'],TAGON) ;
   otherwise
      fprintf('Cue must be 1- to 3- elements. See help tagcue\n') ;
      t = [] ; c = [] ;
      return ;
end

rcue = tcue - CUETAB(1,2) ;           % time into recording in seconds
if rcue>-0.01 & rcue<=0,            
   rcue = 0 ;
   tcue = CUETAB(1,2) ;
end

t = datevec(datenum(TAGON(1),TAGON(2),TAGON(3),TAGON(4),TAGON(5),TAGON(6)+tcue)) ;
len = [TAGID,0,0,0] ;

if rcue<0,
   if ~SILENT,
      fprintf('Cue is before start of data set. Set starts at second %6.3f\n', CUETAB(1,2)) ;
   end

elseif rcue>=crt(end),
   if ~SILENT,
      fprintf('Cue is after end of data set. Set ends at second %6.3f\n',CUETAB(1,2)+crt(end)) ;
   end

else
   s = tcue ;
   kl = max(find(crt<=rcue)) ; 	% find which chip the tcue is in
   c(1) = CUETAB(kl,1) ;
   c(2) = fs(1)*(rcue - crt(kl))+1 ;
   c(3) = rcue*fs(2) ;
   c = round(c) ;
end

