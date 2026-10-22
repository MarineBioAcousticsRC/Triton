function   [G,p] = minvar(v,t,W,q)
%
%   [G,p] = minvar(v,t,W,q)
%   Minimize the variance of the squared 2-norm of the 3-vector sequence v=[x,y,z],
%   i.e., cov(x.^2+y.^2+z.^2), by adding/subtracting small adjustments of the
%   auxilliary (t) vector or matrix to each axis.
%   v should be a nx3 matrix and should be initially calibrated so that 
%   cov(x.^2+y.^2+z.^2) is fairly small.
%   t is an optional auxilliary vector with values as follows:
%   - If no t is given, the d.c. offset in each axis is optimized.
%   - If t is a nx1 vector, the free variables are the d.c. offset and the
%     amount of t added to each axis (6 variables).
%   - If t is a nx3 matrix, the 1st column is associated with x, the 2nd with y,
%     etc. The free variables are the d.c. offset and the amount of t(:,1) to add
%     to x, etc. for y and z.
%   W is an optional nx1 weighting vector that can be used to focus
%   optimization effort on subsets of the n observations. W can also be a
%   string 'q' to force quiet operation.
%
%   A locally-linearized least-squares method is used in which the adjustments
%   are assumed small so that
%           e = (x+gt).^2+y.^2+z.^2
%   where g is the free variable, is approximated by:
%           e ~ x.^2+y.^2+z.^2+2gx.*t
%   which is linear in g. The value of g minimizing cov(e) can be determined
%   by a straightforward least-squares solution. With multiple free variables,
%   g becomes a vector G and the optimal solution has the form:
%           G = -0.5*inv(R)*P
%   where R is an autocorrelation matrix and P is a covariance vector.
%   If the condition of R is high (as reported by this function), numerical
%   inaccuracies in the solution are likely.
%   Note that, to make the solution tractable, the covariance of the 2-norm-
%   squared is minimized rather than the 2-norm per se. This serves to emphasise 
%   outliers which is not desirable. Filter and decimate the input vectors as much 
%   as possible to ameliorate this.
%
%   Usage: the 't' variable can be temp, pressure, or even one or more of the 
%   main axes. e.g.,
%   minvar(A,p/1000)    fits any pressure effect in the accelerometer
%                            (use p/1000 to preserve condition - keep an eye on
%                            the condition value reported by minvar and do your
%                            own scaling to keep it reasonable).
%   minvar(A,t-20)      fits any effect due to variations in temperature.
%                            remove 20 degrees from t so that the calibrated
%                            offsets for ax, ay, and az are good at 20 degs.
%   minvar(A,[az,az,r]) where r=randn(n,1), n=length(ax). This finds the
%                            amount of cross-axis leakage (usually due to physical
%                            misalignment of the axes) between ax and az and 
%                            between ay and az. r is an uncorrelated dummy 
%                            variable to ensure a unique solution.
%
%   mark johnson
%   majohnson@whoi.edu
%   28 November 2000

G = [] ; p = [] ;

if nargin<1,
   help minvar
   return
end

% choose free variables
if nargin>1 & ~isempty(t),
   if size(t,2)==3,
      v(:,4:6) = v.*t ;
   else
      v(:,4:6) = v.*(t*[1 1 1]) ;
   end
end

% subtract means
wm = v(:,1:3).^2*[1;1;1] ;
w = detrend(wm,'constant') ;
v = detrend(v,'constant') ;

quiet = 0 ;
if nargin>=3,
   if isstr(W),
      quiet = isequal(W,'q') ;
   else
      if ~isempty(W),
         v = v.*repmat(W,1,size(v,2)) ;
         w = w.*W ;
      end
      if nargin==4,
         quiet = isequal(q,'q') ;
      end
   end
end

% form least-squares solution
P = w'*v ;
R = v'*v ;
rr = rcond(R) ;
if isnan(rr) || (rr<1e-5),
   fprintf(' Poor condition in minvar - skipping\n') ;
   return
end

G = -0.5*inv(R)*P' ;

% report results
s0 = std(sqrt(wm)) ;
wmi = wm+2*v*G ;
s1 = std(sqrt(wmi)) ;
p = [s0 s1 sqrt(mean(wmi))] ;

if ~quiet,
   fprintf('  cond(R): %4.1e\n', cond(R)) ;
   fprintf('  starting std: %4.4f\t improved to: %4.4f\t mean: %4.2f\n',p) ;
end

