function    [cl,a,m,q]=rainbowmono(x,fs,INOPTS)
%
%    [cl,a,m,q,xf]=rainbow(x,fs,OPTS)
%    Find all clicks in the audio signal x and display click magnitude
%    in a rainbow-click-like display. fs is the sampling rate in Hz.
%    OPTS (optional) can be a 2-vector in which case it is taken as bandpass 
%        filter cut-off frequencies or maybe a structure of options containing
%        one or more of:
%        OPTS.fh, OPTS.blanking, OPTS.fl, OPTS.minthr,
%        OPTS.maxthr, OPTS.nodisp - type rainbow for more options.
%
%    Returns:
%    cl  cues to the clicks in seconds
%    a   click magnitude in dB
%    m   peak envelope magnitude of each click
%    q   quality measure of the arrival angle for each click
%
%    mark johnson, WHOI
%    last modified: 27 October, 2006
%        simplified and added Hilbert envelope computation

cl=[]; a=[]; m=[]; q=[] ;

if nargin<2 | nargin>3,
   help rainbow
   return
end

OPTS.def.fh = [25e3 70e3] ;
OPTS.def.blanking = 0.5e-3 ;
OPTS.def.protocol = 'max-10';
OPTS.def.stdthr = 0.7 ;
OPTS.def.thrfactor = 0.8 ;
OPTS.def.maxthr = 0.1 ;
OPTS.def.minthr = 1e-5 ;
OPTS.def.maxclicks = 1000 ;
OPTS.def.nodisp = 0 ;

if nargin<3,
   INOPTS = struct([]) ;
elseif ~isstruct(INOPTS) & ~isempty(INOPTS),
	INOPTS = setfield([],'fh',INOPTS(1:2)) ;
end

OPTS = resolveopts([],OPTS,INOPTS) ;

% if required, bandpass filter the input signal
if ~isempty(OPTS.fh),
   % reduce filter settings if sampling rate is low
   if OPTS.fh(2)>fs/2,
      OPTS.fh(2) = fs*0.45 ;
   end
   [bf af] = butter(4,OPTS.fh/(fs/2));
   x = filter(bf,af,x);
   if ~isfield(OPTS,'fl'),
      OPTS.fl = OPTS.fh(1)/6 ;   % envelope smoothing LPF cut-off frequency in Hz (was 4000)
   end
end

% reset options for getclickx
OPTS.fh = [] ;
OPTS.env = 1 ;

% compute the envelope of the signal
xx = hilbenv(x) ;

% choose a threshold and find clicks above the threshold
thr = raylinv(0.9999,raylfit(xx)) ;
thr = min(max(thr*OPTS.thrfactor,OPTS.minthr),OPTS.maxthr) 
[cl,levl] = getclickx(xx,thr,fs,OPTS);

if length(cl)>OPTS.maxclicks,
   [nn,kk] = sort(levl) ;     % sort click magnitudes in ascending order
   kk = kk(end:-1:end-OPTS.maxclicks+1) ; % pick the MAXCLICKS loudest
   cl = sort(cl(kk)) ;    % re-sort in order of increasing detect time
   levl = levl(kk) ;
end

a = 20*log10(levl) ;
m = levl ;
q = ones(length(m),1) ;

fprintf('Found %d clicks\n',length(cl)) ;

if size(x,2)==1 | isempty(cl) | OPTS.noaoa==1,
   return
end

% now compute the angle of arrival of each click

if ~OPTS.nodisp,
   figure(3)
   scatter(cl,a,16,log10(m),'filled'),grid
   box on
end

