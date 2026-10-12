function    [C,Y,v] = spherical_cal(X,n,fc,method)
%
%    [C,Y,v] = spherical_cal(X,n,fc,method)
%     X is a segment of triaxial sensor data to calibrate.
%     n is the target mean norm e.g., 1.0 for accelerometer 
%        data.
%     fc is the frequency of a low-pass filter used to reduce
%        the effect of specific acceleration. fc is specified
%        as a ratio of the sensor Nyquist frequency e.g.,
%        fc = 5/(fs/2) for a 5 Hz filter.
%     method selects the calibration procedure from the following
%        0  offset and scaling only
%        1  offset, gain and scaling
%        2  offset, scaling and cross-axis
%        3  offset, gain, scaling and cross-axis
%
%     C is calibration matrix [scale,offset,cross-axis]
%     Y is the converted sensor values
%     v is the 2-norm of Y
%
%     mark johnson   july 2012
%     markjohnson@st-andrews.ac.uk

if nargin<3,
   fc = [] ;    
end

if nargin<4 | isempty(method),
   method = 1 ;
end

C = repmat([1 0 0],3,1) ;
Y = X ;
for k=1:8,
   if isempty(fc),
      kk = 1:size(Y,1) ;
   else
      m = mean(norm2(Y)) ;
      ww = abs(fir_nodelay(norm2(diff(Y))/m,ceil(3/fc),fc));
      kk = find(ww<prctile(ww,75)) ;
   end
   if rem(method,2),
      g = minvar(Y(kk,:),[randn(length(kk),1) Y(kk,2:3)],'q') ;
      C(:,1:2) = [C(:,1).*[1;1+g(5:6)] C(:,2)+g(1:3)] ;
   else
      g = minvar(Y(kk,:),[],'q') ;
      C(:,2) = C(:,2)+g(1:3) ;
   end
   Y = appcal(X,C) ;
   if method>=2,
      g = minvar(Y(kk,:),Y(kk,[2 3 1]),'q') ;
      C(:,2:3) = C(:,2:3)+[g(1:3) g(4:6)];
   end
   Y = appcal(X,C) ;
end

nn = norm2(Y(kk,:)) ;
fprintf('Residual: %2.4f/%2.4f (%2.2f%%)\n',std(nn),mean(nn),100*std(nn)/mean(nn)) ;
R = outerprod(Y(kk,:)) ;
fprintf('Axial balance of cal data: %1.2f\n',1/cond(R)) ;

if nargin>=2 & ~isempty(n),
   sf = n/mean(norm2(Y(kk,:))) ;
   C(:,1:2) = C(:,1:2).*sf ;
   Y = appcal(X,C) ;
end

v = norm2(Y) ;
return


function    Y = appcal(X,C)
onz = ones(size(X,1),1) ;
Y = X.*(onz*C(:,1)')+(onz*C(:,2)') ;
xcm = 0.5*[2 C(1,3) C(3,3);C(1,3) 2 C(2,3);C(3,3) C(2,3) 2] ; 
Y = Y*xcm ;
return
