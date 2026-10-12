function    PRH = prhpredictor(p,A,fs,TH,METHOD,DIR,MARGIN)
%
%    PRH = prhpredictor(p,A,fs,[TH,METHOD,DIR])
%     Predict the tag position on the whale parameterized by p0, r0, and
%     h0, the cannonical angles between the whale and the tag principal axes.
%     p is the measured depth vector (from the prh file).
%     A is the measured (i.e., tag-frame) accelerometer matrix.
%     fs is the sensor sampling rate.
%     TH is an optional dive depth threshold (default is 500m).
%     METHOD is the analysis method (1 or 2, default is 1, see below)
%     DIR is an optional dive direction constraint. DIR='ascent' rejects
%     descents for analysis. DIR='descent' rejects ascents. The default
%     behaviour ([] or 'both') accepts both dive directions.
%
%     Returns PRH = [cue,p0,r0,h0,dir,quality] with a row for each dive edge
%     analyzed. cue is the second-since-tagon of the dive edge. [p0,r0,h0]
%     are the deduced tag orientation angles in radians. 'dir' is the dive
%     direction: 1 is an ascent, -1 is a descent. 'quality' is one or more
%     columns of quality metrices depending on the method employed.
%
%     Two methods are supported:
%      Method 1 is suitable for logging-diving animals, e.g. sperm whales
%               This is the default method.
%      Method 2 is suitable for whales that make short dives while
%      respiring, e.g., beaked whales.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     Lat modified: 31 May 2006
%
%     UPDATE 9/2025 AINSLEIGH LLOYD: ADJUSTABLE MARGIN SIZE IN GUI

% MARGIN = 50 ;           % display margin around segments in seconds

if ~exist('MARGIN','var') % ADJUST WINDOIW SIZE (AINSLEIGH LLOYD)
    MARGIN = 50 ;   % default if not already defined
end
PRH = [] ; 

if nargin<3,
   help prhpredictor
   return
end

if nargin<5 | isempty(METHOD),
   METHOD = 1 ;            % analysis method
end

if nargin<4 | isempty(TH),
   TH = 500 ;           % default dive depth threshold
end

if nargin<6 | isempty(DIR),
   DIR = 'both' ;       % default is to analyse ascents and descents
end

if METHOD==1,           % default segments centered on a descending dive edge
   SEGS = [-100 -10 0 40] ;     % segment offsets are all in seconds
else
   SEGS = [-150 -10 NaN NaN] ;    % only one segment required
end

T=finddives(p,fs,TH);
if isempty(T),
   fprintf(' No dives deeper than %4.0f in the record\n', TH) ;
   return
end

TT = reshape(T(:,1:2)',2*size(T,1),1) ;      % remove edges too close to start or end of record
k = find(TT>nanmin(nanmin(SEGS)) & TT<length(p)/fs-nanmax(nanmax(SEGS))) ;
TT = TT(k) ;

figure(1),clf
subplot(311), plot((1:length(p))/fs,p), set(gca,'YDir','reverse'), grid
ylabel('Depth, m')
axis tight

for kd=1:length(TT),                % for each dive edge
   if rem(kd,2)==1                  % edge is a descent
      if isequal(DIR,'ascent'),     % skip if we are only analyzing ascents
         continue
      end
      segs = TT(kd)+SEGS ;
      ktest = round(fs*(TT(kd)+20)) ;  % test that pitch is +ve 20s before edge
      tdir = 'descent' ; dir = -1 ;
   else                             % edge is an ascent
      if isequal(DIR,'descent'),    % skip if we are only analyzing descents
         continue
      end
      segs = TT(kd)-SEGS([2 1 4 3]) ;
      ktest = round(fs*(TT(kd)-20)) ;  % test that pitch is -ve 20s after edge
      tdir = 'ascent' ; dir = 1 ;
   end
   segs = max(segs,1+0*segs) ;
   if segs(1)==segs(2),
      continue
   end
   done = 0 ;
   while ~done,                     % continue with this edge until we are happy
      % select segments of data for analysis
      k1 = round(segs(1)*fs:segs(2)*fs) ;    % analysis segment 1
      k2 = round(segs(3)*fs:segs(4)*fs) ;    % analysis segment 2
      % display segment
      kk = nanmax([1 nanmin([k1(1) k2(1)])-round(MARGIN*fs)]):nanmin([length(p) nanmax([k1(end) k2(end)])+round(MARGIN*fs)]) ;
      AA = A(kk,:) ;
      pp = p(kk) ;
      % apply prh inference method on segments
      if isnan(k2),
         [prh,Q,pow] = applymethod(A(k1,:),[],A(ktest,:),dir,METHOD) ;
      else
         [prh,Q,pow] = applymethod(A(k1,:),A(k2,:),A(ktest,:),dir,METHOD) ;
      end
      nPRH = [PRH ; TT(kd),prh,dir,pow(1)] ;

      % plot uncorrected data and analysis segments
      plotresults(AA,AA*Q',kk/fs,segs,nPRH,pp) ;

      % report results
      ss = sprintf('%s  p0=%3.1f  r0=%3.1f  h0=%3.1f  cond=%4.3f  rms=%4.3f', ...
            tdir,prh*180/pi,pow) ;
      title(ss,'FontSize',12) ;

      [x,y,butt] = ginput(1) ;
      if isempty(butt), butt = 'f' ; end

      if butt==1,
         [m n] = min(abs(segs-x)) ;     % find nearest segment edge to x
         segs(n) = min([length(p) max([1 round(fs*x)])])/fs ;   % constrain to within record

      else switch butt
         case 'q'
                  done = 2 ;
         case 'x'
                  done = 1 ;
         otherwise   % store and report results
                  PRH = nPRH ;
                  % report results
                  fprintf('cue=%6.0f %s\tp0=%3.1f, r0=%3.1f, h0=%3.1f, cond=%4.3f, rms=%4.3f\n',...
                        TT(kd),tdir,prh*180/pi,pow) ;
                  done = 1 ;
         end
      end
   end

   if done==2,
      break
   end
end



function    [prh,Q,pow] = applymethod(Ak1,Ak2,Atest,dir,METHOD)
%
%
%
if METHOD==1,
   [prh,pow] = method1(Ak1,Ak2) ;    % apply prh estimation method
else
   [prh,pow] = method2(Ak1,Ak2) ;    % apply prh estimation method
end

Q = makeT(prh) ;                          % make transformation matrix

% check that h0 is not 180 degrees out by checking that the sign of the
% pitch is correct for the dive edge - descent is pitch down, ascent is
% pitch up.
if sign(Atest*Q(1,:)') ~= dir,
   prh(3) = rem(prh(3)-pi,2*pi) ;   % if incorrect, add/subtract 180 degrees
   Q = makeT(prh) ;
end

% by convention, constrain r0 and h0 to the interval -pi:pi
for k=2:3,
   if abs(prh(k))>pi,
      prh(k) = prh(k)-sign(prh(k))*2*pi ;
   end
end
return



function    [prh,pow] = method1(Ak1,Ak2)
%
%     For logging-diving dive edges (descending or ascending)
%     Chooses p0 and r0 for a horizontal whale during the logging
%     segment (Ak1) and chooses h0 to minimize the mean-squared
%     y-axis acceleration in the diving segment (Ak2).
%

Am1=mean(Ak1)' ;           % mean acceleration in logging segment
[p0,r0]=a2pr(Am1) ;        % corresponding p0 and r0
prh = [p0,r0,0] ;

Q = makeT(prh) ;           % transformation to remove p0 and r0
At2 = Ak2*Q' ;             % transformed acceleration in diving segment

AA = sum([At2(:,1:2).^2 At2(:,1).*At2(:,2)]) ;  % sum-of-squares needed for ls algorithm

% 2 quadrant atan - determine the correct quadrant later from context
h2 = atan(2*AA(3)/(AA(1:2)*[-1;1])) ;

% check that this is a minima - if not add 180 degrees
if AA(1:2)*[1;-1]*cos(h2)-2*AA(:,3)*sin(h2)<0,
   h2 = h2+pi ;
end

prh(3) = h2/2 ;            % actual h0 is half of h2

% Quality metrices:
% 1. Residual squared error for the chosen h0
se = AA(1:2)*[1;1]/2+AA(1:2)*[-1;1]*cos(h2)/2+AA(3)*sin(h2) ;

% 2. energy ratio between plane-of-motion and axis of rotation 
QQ = Ak2'*Ak2 ;            % form outer product of acceleration in diving segment

% break into eigen-axes: assuming that the motion is mostly planar,
% the eigenvalues of QQ will indicate how planar: the largest two eigenvalues
% describe the energy in the plane of motion; the smallest eigenvalue
% describes the energy in the invariant direction i.e., the axis of
% rotation.

[V,D] = svd(QQ) ;    
cc = D(3,3)/D(2,2) ;       % if the inverse condition cc>~0.05, the motion in Ak2
                           % is better described as one or three-dimensional than
                           % two-dimensional

% collect the quality metrices
pow = [cc,sqrt(se/size(Ak2,1))] ;
return


function    [prh,pow] = method2(Ak1,Ak2)
%
%     For rolling-surfacing (descending or ascending)
%     Chooses r0 and h0 to minimize the mean-squared
%     y-axis acceleration in segment Ak1 and then chooses
%     p0 for a mean pitch angle of 0. Segment Ak2 is not used.
%

% break into eigen-axes: assuming that the motion is mostly planar,
% the eigenvalues of QQ will indicate how planar: the largest two eigenvalues
% describe the energy in the plane of motion; the smallest eigenvalue
% describes the energy in the invariant direction i.e., the axis of
% rotation

% energy ratio between plane-of-motion and axis of rotation 
QQ = Ak1'*Ak1 ;            % form outer product of acceleration
[V,D] = svd(QQ) ;          
pow = D(3,3)/D(2,2) ;      % if the inverse condition cc>~0.05, the motion in Ak2
                           % is better described as three-dimensional than
                           % two-dimensional

% axis of rotation to restore V to tag Y axis
aa = acos([0 1 0]*V(:,3)) ;
Phi = cross([0;1;0],V(:,3))/sin(aa) ;
S = skew(Phi) ;
Q = eye(3)+(1-cos(aa))*S*S-sin(aa)*S ;    % generate rotation matrix for rotation 
                                          % of aa degrees around axis Phi
am = mean(Ak1)*Q' ;
p0 = atan2(am(1),am(3)) ;
Q = makeT([p0 0 0])*Q ;
prh = [asin(Q(3,1)) atan2(Q(3,2),Q(3,3)) atan2(Q(2,1),Q(1,1))] ;

aa = Ak1*Q(2,:)' ;
pow(2) = std(aa) ;
return



function    plotresults(Au,Al,tt,segs,PRH,p) ;
%
%

figure(1)
subplot(311), XL = get(gca,'XLim') ;
subplot(312), plot(PRH(:,1),PRH(:,2:4)*180/pi,'*-'); grid, set(gca,'XLim',XL)
hold on, plot(PRH(end,1),PRH(end,2:4)*180/pi,'o'), hold off, ylabel('PRH0, degrees')

subplot(313), plot(PRH(:,1),PRH(:,6),'*-'); grid, set(gca,'XLim',XL,'YLim',[0 0.1])
hold on, plot(PRH(end,1),PRH(end,6),'o'), hold off, xlabel('time cue'), ylabel('Quality')
figure(2)

YEXT = 1.25 ;           % vertical extent of accelerometry plots +/-g
rctx = [0 1 1 0;1 1 0 0] ;
rcty = [0 0 1 1;0 1 1 0] ;

figure(2),clf
subplot(311),plot(tt,p),grid,hold on
set(gca,'LineWidth',1,'XLim',round(tt([1 end])),'YDir','reverse') ;
ylabel('depth, m'), title('Dive depth')

subplot(312),plot(tt,Au),grid,hold on
set(gca,'YLim',YEXT*[-1 1],'LineWidth',1,'XLim',round(tt([1 end]))) ;
ylabel('tag frame A, g'), title('Tag-frame accelerometer signals')

plot(diff(segs(1:2))*rctx+segs(1),0.9*YEXT*(2*rcty-1),'k') ;
if all(~isnan(segs(3:4))),
   plot(diff(segs(3:4))*rctx+segs(3),0.9*YEXT*(2*rcty-1),'k') ;
end

% plot corrected accelerometer vector for the interval
subplot(313),hz = plot(tt,Al); grid,hold on
set(gca,'YLim',YEXT*[-1 1],'LineWidth',1,'XLim',round(tt([1 end]))) ;
xlabel('time cue'), ylabel('whale frame A, g')
return
