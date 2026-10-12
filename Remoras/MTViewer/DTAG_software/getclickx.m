function   [cl,level,x,X] = getclickx(x,thresh,fs,opts)
%
%     [cl,level,env,X] = getclickx(x,thresh,fs,[opts])
%     Returns the time cue to each click in x, in seconds. Click extraction
%     is done in two steps. First the approximate click locations are found
%     from a conventional low-pass filtered rms envelope. Second, precise
%     envelopes around each candidate click are computed using the hilbert
%     transform. These envelopes are inspected to determine the starting
%     point of each click according to one of several protocols.
%
%     x   is the signal vector
%     thresh is the click detection threshold - try a value of 0.01 to
%         begin with. If thresh=0, only the envelope will be computed (clicks=[]). 
%     fs  is the sampling rate of x.
%     opts is a structure of options containing one or more of the following fields:
%         opts.fh is a scalar of 2-vector specifying a high-pass filter or
%            bandpass filter for the envelope follower [default = 10000Hz].
%            If opts.fh=[], no filter is applied.
%         opts.fl is the low-pass filter frequency for the envelope follower.
%            If opts.fl=[], the Hilbert envelope is computed.
%         opts.blanking is the minimum time between clicks [default = 10ms]
%         opts.protocol is the is the method used to determine where the cue is 
%            declared. Options are: {'first','steepest','max','max-'}. The default 
%            protocol, 'first', returns the first sample in which the pulse magnitude 
%            exceeds the threshold. The 'steepest' protocol returns the cue at which 
%            the envelope exceeds the threshold and has the steepest slope. The 'max' 
%            protocol returns the cue at which the envelope exceeds the threshold and 
%            reaches its maximum value. The 'max-10' protocol returns the cue at which
%            the envelope first exceeds 0.3 of its maximum value. The 'max-6' protocol
%            returns the cue at which the envelope first exceeds 0.5 of its maximum value. 
%         opts.env if this field exists and is set to 1, x is treated as an
%            envelope (i.e., a pre-computed envelope).
%         It is also possible to use a species identifier string in opts e.g.,
%         'sw', 'pw', 'md', 'zc'. The settings most appropriate to that species will 
%         then be used.
%
%     Return variables:
%     cl is the time cue of each click in seconds
%     level is the detection level of each click 
%     env is the rms envelope of x - this is compared against thresh to find clicks.
%     X  is the matrix of hilbert transforms of extracted clicks. The time cue of a click 
%        is the time when the absolute value of the corresponding column of X meets the 
%        selected protocol.
%
%     mark johnson, WHOI
%     last modified October 2006
%        simplified structure and added hibert envelope computation

cl=[]; level=[]; X=[] ;

if nargin<3,
   help getclickx ;
   return
end
    
% setup default options structure
defopts = struct('fh',10e3,'fl',2000,'blanking',0.01,'fr',[0,0],...
          'protocol','first','ffull',0,'win',0.01) ;

if nargin<4,
   opts = [] ;
end

% set options for the selected species
if isstr(opts),
   switch lower(opts)
      case 'pw', defopts = setfield(defopts,'fh',5000) ;
                 defopts = setfield(defopts,'blanking',5e-3) ;
      case 'md', defopts = setfield(defopts,'fh',25000) ;
                 defopts = setfield(defopts,'fl',[]) ;
                 defopts = setfield(defopts,'blanking',5e-3) ;
      case 'zc', defopts = setfield(defopts,'fh',[10e3 25e3]) ;
                 defopts = setfield(defopts,'fl',5e3) ;
                 defopts = setfield(defopts,'blanking',5e-3) ;
   end

% or merge passed and default options
elseif isstruct(opts),
   fn = fieldnames(opts) ;
   for k=1:length(fn),
      optname = fn{k} ;
      defopts = setfield(defopts,optname,getfield(opts,optname)) ;
   end
end

% extract settings
fh = defopts.fh ;
fl = defopts.fl ;
blanking = defopts.blanking ;
win = min(blanking,defopts.win) ;
protocol = defopts.protocol ;

if size(x,2)>1,
   x = x(:,1) ;
end

% if the input vector is a signal, bandpass filter it and compute the
% envelope
if ~isfield(opts,'env') | opts.env ~= 1 ;
   if ~isempty(fh),
      if length(fh)==1 | fh(2)==0,
         [b a] = butter(4,fh(1)/(fs/2),'high') ;
      else
         [b a] = butter(4,fh/(fs/2)) ;
      end
      % high-pass filter signal
      x = filter(b,a,x);
   end
      
   if isempty(fl),
      x = hilbenv(x) ;
   else
      % design envelope follower low pass filter
      [b_env,a_env] = butter(2,fl/(fs/2)) ;
      % compute rms envelope
      x = sqrt(abs(filtfilt(b_env,a_env,abs(x).^2))) ;
   end
end

% x is now an envelope
% raw click detection: find points at which threshold is first exceeded

cc = [] ;
if thresh>0,
   dxx = diff(x>thresh) ;
   cc = find(dxx>0)+1 ;
end

if isempty(cc), return ; end

% eliminate detections which do not meet blanking criterion.
% blanking time is calculated after pulse returns below threshold

% first compute raw pulse endings
coff = find(dxx<0)+1 ;    % find where envelope returns below threshold
cend = size(x,1)*ones(length(cc),1) ;
for k=1:length(cc)-1,
   kends = find(coff>cc(k),1) ;
   if ~isempty(kends),
      cend(k) = coff(kends) ;
   end
end

% merge pulses that are within blanking distance
done = 0 ;
while ~done,
   kg = find(cc(2:end)-cend(1:end-1)>(blanking*fs)) ;
   done = length(kg) == (length(cc)-1) ;
   cc = cc([1;kg+1]) ;
   cend = cend([kg;end]) ;
end

% for raw click detection, we are done
if isequal(protocol,'raw'),
   cl = (cc-1)/fs ;
   level = xx(cc) ;
   return ;
end

% for secondary click detection protocols, extract intervals of data 
% around each cue and re-process to get exact detection cues.

% extract sections of the filtered signal around each detection
if isempty(fl),
   T = round(fs*[-win win]) ;
else  
   T = round(fs*[-min([10/fl win]) win]) ;        % 10/fl was 0.002
end

[X,cc] = extractcues(x,cc,T) ;

% now check that there are still some clicks
if isempty(cc),
   return
end

level = 0*cc ;
switch protocol,
   case 'first',
         cplus = 0*cc ;
         for k=1:length(cc),
            cplus(k) = min(find(X(:,k)>thresh)) ;
            level(k) = X(cplus(k),k) ;
         end
   case 'max',
         [level cplus] = max(X) ;
   case 'max-10',
         level = max(X) ;
         for k=1:length(cc),
            cplus(k) = min(find(X(:,k)>0.3*level(k))) ;
         end
   case 'max-6',
         level = max(X) ;
         for k=1:length(cc),
            cplus(k) = min(find(X(:,k)>0.5*level(k))) ;
         end
   case 'steepest',
         [level cplus] = max(diff(X)) ;

   otherwise,
        cplus = 0 ;
end

cl = (cc+cplus(:)+T(1)-2)/fs ;
level = level(:) ;

if length(cplus)>1 & nargout>2,
   mincplus = min(cplus) ;
   len = size(X,1)-(max(cplus)-mincplus) ;
   Y = zeros(len,length(cc)) ;
   for k=1:length(cc),
      Y(:,k) = X(cplus(k)-mincplus+(1:len),k) ;
   end
   X = Y ;
end

