function      [s,fit] = kalmanspeedest(p,pitch,fs)
%
%     [s,fit] = kalmanspeedest(p,pitch,fs)
%     EXPERIMENTAL !!
%     Estimate the swim speed of a whale with given depth profile, p, in m, and
%     pitch in radians, sampled at rate fs, Hz. Process is a 2-state Kalman
%     filter estimating speed and depth, followed by a Rauch smoother.
%     Output:
%     s  is the swim speed estimate in m/s
%     fit is a structure of results including:
%      fit.ks = kalman filtered speed
%      fit.kd = kalman depth estimate
%      fit.rd = rauch depth estimate
%      fit.kp = kalman a posteriori state covariance (2x2xn)
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     November 2004

if nargin<3
   help kalmanspeedest
   return
end

r = 0.001 ;          % measurement noise cov. - this should be set equal to the noise power
                     % in the depth estimate, p, e.g., 0.05 m^2. was 0.005
q1 = (0.02/fs)^2 ;   % speed state noise cov. - accounts for variations in speed, was 0.05
q2 = (0.08/fs)^2 ;   % depth state noise cov. - accounts for errors in pitch angle, was 0.05
T = 1/fs ;           % sampling period

% vector Kalman filter with 2 states: s and p

a = -sin(pitch)/fs ;    % transition matrix entry (2,1)
shatm = [1;p(1)] ;      % starting state estimate
Q = [q1 0;0 q2] ;       % state noise matrix
H = [0 1] ;             % observation vector
Pm = [0.01 0;0 r] ;     % initial state covariance matrix:
                        % says how much we trust initial values of s and p?

skal = zeros(2,length(p)) ;    % place to store states
srau = skal ;
Ps = zeros(2,2,length(p)) ;
Pms = Ps ;

for k=1:length(p),             % Kalman filter
   Ak = [1 0;a(k) 1] ;        % make state transition matrix

   if k>1,
      Pm = Ak*P*Ak' + Q ;      % update a priori state cov
      shatm = Ak*shat ;          % a priori state estimate
   end

   K = Pm*H'/(H*Pm*H'+r) ;    % compute kalman gain
   shat = shatm + K*(p(k)-H*shatm) ;  % a posteriori state estimate
   %shat = max([shat';[0 0]])' ;       % speed and depth must always be positive
   P = (eye(2)-K*H)*Pm ;      % a posteriori state cov

   skal(:,k) = shat ;         % store results of iteration
   Pms(:,:,k) = Pm ;
   Ps(:,:,k) = P ;
end

%Vh is P(T)
srau(:,length(p)) = shat ;

for k=length(p):-1:2,                % Kalman/Rauch smoother
   Ak = [1 0;a(k-1) 1] ;                  % make state transition matrix
   K = Ps(:,:,k-1)*Ak'*inv(Pms(:,:,k));   % smoother gain
   srau(:,k-1) = skal(:,k-1)+K*(srau(:,k)-Ak*skal(:,k-1)) ; % smooth state
end

s = srau(1,:)' ;
fit.ks = skal(1,:)' ;
fit.kd = skal(2,:)' ;
fit.rd = srau(2,:)' ;
fit.kp = Ps ;
