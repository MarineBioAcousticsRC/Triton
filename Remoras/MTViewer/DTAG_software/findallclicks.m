function    CL = findallclicks(tag,cue,INOPTS)
%
%     CL = findallclicks(tag,cue,OPTS)
%		General purpose automatic click finder. Always follow with
%     findmissedclicks to ensure that most clicks are identified.
%
%     tag is the tag deployment string e.g., 'sw03_207a'
%     cue is the time in seconds-since-tag-on to start and end working.
%        cue = [start_cue end_cue].
%		OPTS is an optional 2-vector of high-pass and low-pass frequencies
%        defining a filter to apply to the audio before click detection. 
%        If no filt is given or filt=[] the species prefix in tag is used
%        to select sensible values. If OPTS is a structure, it is passed
%        directly to the click finder routine (rainbow.m). Valid fields
%        are OPTS.fh, OPTS.blanking and OPTS.thrfactor.
%     CL is the click list.
%
%  mark johnson, WHOI
%  majohnson@whoi.edu
%  last modified: 15 January 2007

if nargin<2,
   help findallclicks
   return
end

LEN = 20 ;
CH = 3:4 ;

OPTS.sw.fh = [5e3 40e3] ;
OPTS.sw.blanking = 10e-3 ;
OPTS.sw.maxthr = 0.03 ;
%OPTS.sw.minthr = 0.03 ;
OPTS.sw.noaoa = 1 ;
OPTS.md.fh = [5e3 20e3] ;
OPTS.pw.fh = [5e3 20e3] ;
OPTS.pw.maxthr = 0.1 ;
OPTS.def.fh = [20e3 70e3] ;
OPTS.def.blanking = 15e-3 ;
OPTS.def.thrfactor = 5 ;
OPTS.def.minthr = 0.005 ;
OPTS.def.nodisp = 1 ;
 
if nargin<3,
   INOPTS = struct([]) ;
elseif ~isstruct(INOPTS) & ~isempty(INOPTS),
	INOPTS = setfield([],'fh',INOPTS(1:2)) ;
end

OPTS = resolveopts(tag,OPTS,INOPTS) ;

if nargin<4,
   CL = [] ;
end

if length(cue)~=2,
   fprintf(' Must give a start and end cue\n') ;
   return
end

scue = cue(1) ;
done = 0 ;

while ~done,
   len = min([LEN cue(2)+0.5-scue]) ;
   fprintf(' Reading %3.1fs at %5.1f... ',len,scue) ;

   % read in current block of audio
   [x fs] = tagwavread(tag,scue,len) ;
   if size(x,2)>2,
      x = x(:,CH) ;
   end

   % find all clicks in current block
   cl = rainbow(x,fs,OPTS) ;

   % identify saved clicks and append any clicks that don't appear in CL
   cl = scue+cl ;
   if ~isempty(CL),
      kk = find(cl>=CL(end)+OPTS.blanking & cl<cue(2)) ;
   else
      kk = find(cl<cue(2)) ;
   end
   
   if ~isempty(kk),
      CL = [CL;cl(kk)] ;     % and add them to CL
   end
   
   scue = scue+len-0.1 ; 
   done = scue > cue(2) ;
end
