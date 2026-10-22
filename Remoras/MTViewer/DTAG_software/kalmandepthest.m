function      [v,k] = kalmandepthest(p,fs)
%
%     [v,k] = kalmandepthest(p,fs)
%     Estimate a smooth depth and depth rate to fit the observed depth, p, in m.
%     sampled at rate fs, Hz. Process is a 2-state Kalman
%     filter estimating vertical rate and depth, followed by a Rauch smoother.
%     Output:
%     v = [depth_rate, depth] in m/s and m.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     November 2010

v = [] ;
if nargin<2,
   help kalmandepthest
   return
end

r = 0.001 ;          % measurement noise cov. - this should be set equal to the noise power
                     % in the depth estimate, p, e.g., 0.05 m^2. was 0.005
q1 = (0.5/fs)^2 ;   % speed state noise cov. - accounts for variations in speed, was 0.05
q2 = (0.2/fs)^2 ;   % depth state noise cov. - accounts for errors in pitch angle, was 0.05
T = 1/fs ;           % sampling period

% vector Kalman filter with 2 states: s and p

A = [1 0;1/fs 1] ;      % state transition matrix
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
   if k>1,
      Pm = A*P*A' + Q ;      % update a priori state cov
      shatm = A*shat ;          % a priori state estimate
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
   K = Ps(:,:,k-1)*A'*inv(Pms(:,:,k));   % smoother gain
   srau(:,k-1) = skal(:,k-1)+K*(srau(:,k)-A*skal(:,k-1)) ; % smooth state
end

v = srau' ;
k = skal' ;
