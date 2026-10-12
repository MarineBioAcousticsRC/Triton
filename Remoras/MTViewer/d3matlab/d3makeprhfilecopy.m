function    d3makeprhfilecopy(recdir,prefix,tag,df)
%   COPY CREATED BY JOHN HILDEBRAND and AINSLEIGH LLOYD 7/2024
%   ADDED TEMPR VARIABLE FOR MTVIEWER ANNOTATION
%
%   d3makeprhfile(recdir,prefix,tag,df)
%   Generate a complete PRH file from raw sensor data using calibrations
%   and tag orientations in the tag deployment calibration file
%   recdir and prefix specify where to find the .swv files as in d3readswv.
%   tag is the deployment name used when registering the deployment.
%   df is an optional decimation factor to apply to the PRH data. If df is
%   not given, a df=1 will be used (i.e., full rate data).
%
%   This function generates a file in the PRH directory specified in the
%   tagpath (see settagpath.m). The file name will be <uname>prhfff.mat where
%   ff is the sampling rate in Hz (up to three digits).
%
%   Example:
%     d3makeprhfile('e:/data/bb10/bb10_214a','bb214a','bb10_214a',10);
%
%   MJ with help from LMML
%   markjohnson@st-andrews.ac.uk
%   28 Feb 2013
%

[CAL,DEPLOY] = d3loadcal(tag) ;

if ~exist('CAL','var')
   fprintf(' No CAL structure - perform calibration before running makeprhfile') ;
   return
end

X = d3readswv(recdir,prefix) ;

% apply calibrations
[ch_names,descr,ch_nums,cal] = d3channames(X.cn) ; %added from d3calacc to id and read in tempr
[p,CAL,fsp] = d3calpressure(X,CAL,'none') ;
[M,CAL,fsm] = d3calmag(X,CAL,'none') ;
[A,CAL,fs] = d3calacc(X,CAL,'none') ;
kt = find(strcmp(cal,'tempr')) ;       % find the temperature channel in X
tempr = apply_cal(X.x{kt},CAL.TEMPR) ; %temperature saved as tempr


% check sampling rates are compatible
if fsp~=fs || fsm(1)~=fs,
   fprintf('Different sampling rates on p, A and M not yet supported\n') ;
   return
end

% decimate all channels
if nargin==4 && df~=1,
   p = decdc(p,df) ;
   M = decdc(M,df) ;
   A = decdc(A,df) ;
   % tempr = decdc(tempr,df); %do not need here b/c length(tempr) matches
   fs = fs/df ;
end

% check the lengths of the A, M and p matrices
S = [size(A,1),size(M,1),length(p),length(tempr)] ;
if length(unique(S))>1,
   n = min(S) ;
   fprintf(' Length mismatch in A, M and p. Trimming by %d samples\n',max(S)-n) ;
   A = A(1:n,:) ;
   M = M(1:n,:) ;
   p = p(1:n) ;
   tempr = tempr(1:n) ;
end

% make a filename for the PRH file
global TAG_PATHS
if isempty(TAG_PATHS) || ~isfield(TAG_PATHS,'PRH'),
   fprintf(' No PRH file path - use settagpath\n') ;
   return
end
fname = sprintf('%s/%sprh%d.mat',getfield(TAG_PATHS,'PRH'),tag,round(fs)) ;
vv = version ;

if ~isfield(DEPLOY,'OTAB'),
   fprintf(' No OTAB (tag orientation) - only computing tag frame variables\n') ;
   % save results
   if vv(1)>'6',
      save(fname,'-v6','p','fs','A','M','tempr') ;
   else
      save(fname,'p','fs','A','M','tempr') ;
   end
   return
end

% report on trustworthiness of heading estimate
dp = (A.*M*[1;1;1])./norm2(M) ;
incl = asin(mean(dp)) ;     % do the mean before the asin to avoid problems
                            % when the specific acceleration is large
sincl = asin(std(dp)) ;
fprintf(' Mean Magnetic Field Inclination: %4.2f\260 (%4.2f\260 RMS)\n',...
       180/pi*incl, 180/pi*sincl) ;

% Compute the whale frame A and M matrices:
[Aw,Mw] = tag2whale(A,M,DEPLOY.OTAB,fs) ;

% Compute whale frame pitch, roll, heading
[P R] = a2pr(Aw) ; % changed to P, R to avoid rad->deg conversion issues in MTViewer
[H,mm,incl] = m2h(Mw,P,R) ; % changed to H for same reason

if ~isfield(DEPLOY,'DECLINATION'),
   fprintf(' No DECL (magnetic field declination specified in CAL file - using 0\n') ;
   DECL = 0 ;
else
   DECL = DEPLOY.DECLINATION ;
end
H = H + DECL*pi/180 ;      % adjust heading for declination angle in radians

% save results
if vv(1)>'6',
   save(fname,'-v6','p','P','R','H','fs','Aw','Mw','A','M','tempr') ;
else
   save(fname,'p','P','R','H','fs','Aw','Mw','A','M','tempr') ;
end
