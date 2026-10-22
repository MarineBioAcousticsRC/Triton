function    [cl,a,m,q]=rainbow(x,fs,INOPTS)
%
%    [cl,a,m,q,xf]=rainbow(x,fs,OPTS,NODISP)
%    Find all clicks in the stereo audio signal x and display the angle
%    of arrival in a rainbow-click-like display. fs is the sampling rate in Hz.
%    OPTS (optional) can be a 2-vector in which case it is taken as bandpass 
%        filter cut-off frequencies or maybe a structure of options containing
%        one or more of:
%        OPTS.fh, OPTS.blanking, OPTS.fl, OPTS.aoa_win, OPTS.minthr,
%        OPTS.maxthr, OPTS.nodisp - type rainbow for more options.
%    If x is a mono signal, only the click cues are returned and no
%    display is made.
%
%    Returns:
%    cl  cues to the clicks in seconds
%    a   angle of arrival of each click in degrees
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
OPTS.def.thrfactor = 5 ;
OPTS.def.minthr = 0.005 ;
OPTS.def.maxthr = 0.1 ;
OPTS.def.protocol = 'max-10';
OPTS.def.stdthr = 0.7 ;
OPTS.def.aoa_win = [-0.15e-3 0.25e-3] ;
OPTS.def.thrfactor = 0.8 ;
OPTS.def.separation = 0.025 ;
OPTS.def.minthr = 1e-5 ;
OPTS.def.maxclicks = 1000 ;
OPTS.def.qthr = 0.6 ;        % minimum quality index for angle to accept click (was 0.5)
OPTS.def.soundspeed = 1500 ;
OPTS.def.nodisp = 0 ;
OPTS.def.aoa_fh = [] ;
OPTS.def.noaoa = 0 ;

if nargin<3,
   INOPTS = struct([]) ;
elseif ~isstruct(INOPTS) & ~isempty(INOPTS),
	INOPTS = setfield([],'fh',INOPTS(1:2)) ;
end

OPTS = resolveopts([],OPTS,INOPTS) ;

% if required, bandpass filter the input signal
if ~isempty(OPTS.fh),
   % reduce filter settings if sampling rate is low
   if length(OPTS.fh)>1,
      if OPTS.fh(2)>fs/2,
         OPTS.fh(2) = fs*0.45 ;
      end
      [bf af] = butter(6,OPTS.fh/(fs/2));
   else
      [bf af] = butter(6,OPTS.fh/(fs/2),'high');
   end
   x = filter(bf,af,x);
   if ~isfield(OPTS,'fl'),
      OPTS.fl = OPTS.fh(1)/6 ;   % envelope smoothing LPF cut-off frequency in Hz (was 4000)
   end
end

% reset options for getclickx
OPTS.fh = [] ;
OPTS.env = 1 ;

% compute the envelope of one channel of the signal
xx = hilbenv(x(:,1)) ;

% choose a threshold and find clicks above the threshold
thr = raylinv(0.9999,raylfit(xx)) ;
thr = min(max(thr*OPTS.thrfactor,OPTS.minthr),OPTS.maxthr) 
[cl,levl] = getclickx(xx,thr,fs,OPTS);

if length(cl)>OPTS.maxclicks,
   [nn,kk] = sort(levl) ;     % sort click magnitudes in ascending order
   kk = kk(end:-1:end-OPTS.maxclicks+1) ; % pick the MAXCLICKS loudest
   cl = sort(cl(kk)) ;    % re-sort in order of increasing detect time
end

fprintf('Found %d clicks\n',length(cl)) ;

if size(x,2)==1 | isempty(cl) | OPTS.noaoa==1,
   return
end

% now compute the angle of arrival of each click

kwin = round(fs*OPTS.aoa_win) ;
X = extractcues(x,cl*fs,kwin) ;
if ~isempty(OPTS.aoa_fh),
   [b a] = butter(4,OPTS.aoa_fh/(fs/2)) ;
   H1 = hilbert(filter(b,a,squeeze(X(:,1,:)))) ;
   H2 = hilbert(filter(b,a,squeeze(X(:,2,:)))) ;
else
   H1 = hilbert(squeeze(X(:,1,:))) ;
   H2 = hilbert(squeeze(X(:,2,:))) ;
end

maxdel = 1.2*fs*OPTS.separation/1500 ;
%w = gausswin(size(H1,1),1.5)*ones(1,size(H1,2)) ;     % weak window
%[cm,q] = xc_tdoa(H1.*w,H2.*w,maxdel) ;
[cm,q] = xc_tdoa(H1,H2,maxdel) ;
a = 180/pi*asin(cm*OPTS.soundspeed/OPTS.separation/fs) ;
m = max(abs(H1))';
k = find(q>OPTS.qthr);

if length(k)==0,
   fprintf('All clicks rejected\n') ;
   return
else
   fprintf('Accepted %d clicks\n',length(k)) ;
end

if ~OPTS.nodisp,
   figure(3)
   scatter(cl(k),a(k),16,log10(m(k)),'filled'),grid
   box on
end

cl = cl(k) ;
a = a(k) ;
m = m(k) ;
q = q(k) ;
