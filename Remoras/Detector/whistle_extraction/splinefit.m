function pp = splinefit(x,y,arg3)
%SPLINEFIT Fit a cubic spline to noisy data.
%   PP = SPLINEFIT(X,Y,XB) fits a piecewise cubic spline with breaks
%   (or knots) XB to the noisy data (X,Y). X is a vector and Y is a vector
%   or an ND array. If Y is an ND array, then X(j) and Y(:,...,:,j) are
%   matched. XB may or may not be a subset of X. Use PPVAL to evaluate PP.
%
%   PP = SPLINEFIT(X,Y,M) where M is a positive integer takes XB as a
%   subset of X according to: XS = SORT(X), XB = XS(1:M:end). A large M
%   means few breaks and a smooth spline. Default is M = 4.
%
%   Example:
%       x = cumsum(rand(1,50));
%       y = sin(x/2) + cos(x/4) + 0.05*randn(size(x));
%       pp = spline(x,y);
%       qq = splinefit(x,y,6);
%       xx = linspace(min(x),max(x),400);
%       yy = ppval(pp,xx);
%       zz = ppval(qq,xx);
%       plot(x,y,'bo',xx,yy,'r',xx,zz,'k')
%       legend('NOISY DATA','SPLINE','SPLINEFIT','Location','Best')
%
%   See also PPVAL, SPLINE, PPFIT

%   Author: jonas.lundgren@saabgroup.com, 2009.

%   2009-05-15  Bug fix for ND arrays.

if nargin < 2, help splinefit, return, end
if nargin < 3, arg3 = 4; end

% Check data
x = x(:);
mx = length(x);             % Number of data points

% Treat ND array
dim = size(y);
while length(dim) > 2 && dim(end) == 1
    dim(end) = [];
end

if length(dim) > 2
    % ND array
    my = dim(end);
    dim(end) = [];
    y = reshape(y,prod(dim),my);
    y = y.';
elseif dim(2) > 1
    % 2D array
    my = dim(2);
    dim(2) = [];
    y = y.';
else
    % Column vector
    my = dim(1);
    dim = 1;
end

% Check dimensions
if mx ~= my
    msgid = 'SPLINEFIT:DataDimensions';
    message = 'Last dimension of array Y must equal length of vector X!';
    error(msgid,message)
end

% Sort data
if any(diff(x) < 0)
    [x,isort] = sort(x);
    y = y(isort,:);
end

% Treat breaks
if numel(arg3) == 1
    if ~isreal(arg3) || mod(arg3,1) || arg3 < 1
        msgid = 'SPLINEFIT:BreakCount';
        message = 'Third argument must be a vector or a positive integer!';
        error(msgid,message)
    end
    xb = x(1:arg3:end);
else
    xb = arg3(:);
end

% Unique breaks
if any(diff(xb) <= 0)
    xb = unique(xb);
end

% Ensure at least two breaks
if length(xb) < 2
    xb = [x(1); x(mx)];
    if xb(1) == xb(2)
        xb(2) = xb(1) + 1;
    end
end

% Dimensions
nb = length(xb);            % Number of breaks
nu = 2*nb;                  % Number of unknowns
mb = nb - 2;                % Number of smoothness conditions
nr = nb + 2;                % Dimension of null space base

% Scale data
xb0 = xb;
scale = (nb-1)/(xb(nb)-xb(1));
if scale > 10 || scale < 0.1
    x = scale*x;
    xb = scale*xb;
end

% Interval lengths
hb = diff(xb);
% Negative powers of interval lengths
r1 = 1./hb;
r2 = r1./hb;
r3 = r2./hb;

% Is the mesh uniform?
hm = (xb(nb)-xb(1))/(nb-1);
uniform = max(abs(hb - hm)) < 10*eps(max(abs(xb([1 nb]))));

% Adjust limits
xlim = xb;
xlim(1) = -Inf;
xlim(end) = Inf;

% Bin data
[junk,ibin] = histc(x,xlim);

% Evaluate polynomial base
t = (x - xb(ibin))./hb(ibin);
t2 = t.*t;
t3 = t2.*t;
p1 = 2*t3 - 3*t2 + 1;
p2 = hb(ibin).*(t3 - 2*t2 + t);
p3 = -2*t3 + 3*t2;
p4 = hb(ibin).*(t3 - t2);

% Set up system matrix A
ii = repmat(1:mx,1,4);
jj = [2*ibin-1; 2*ibin; 2*ibin+1; 2*ibin+2];
A = sparse(ii, jj, [p1; p2; p3; p4], mx, nu);

% Set up smoothness matrix B (continuous curvature)
curv1 = [6*r2(1:mb); 2*r1(1:mb); -6*r2(1:mb); 4*r1(1:mb)];
curv2 = [6*r2(2:mb+1); 4*r1(2:mb+1); -6*r2(2:mb+1); 2*r1(2:mb+1)];
ii = repmat(1:mb,1,4);
jj = [1:2:nu-5, 2:2:nu-4, 3:2:nu-3, 4:2:nu-2];
B = sparse(ii, jj, curv1, mb, nu, 6*nb);
B = B + sparse(ii, jj+2, curv2, mb, nu);

% Set up coefficient transformation matrix C
ii = repmat(1:nb-1,1,4);
ii = [ii, ii+nb-1, 2*nb-1:4*nb-4];
jj = [1:2:nu-3, 2:2:nu-2, 3:2:nu-1, 4:2:nu];
jj = [jj, jj, 2:2:nu-2, 1:2:nu-3];
cc = [2*r3; r2; -2*r3; r2; -3*r2; -2*r1; 3*r2; -r1; ones(2*nb-2,1)];
C = sparse(ii, jj, cc, 4*nb-4, nu);

% Compute a base Z for the null space of B (B*Z = 0)
if nb < 60
    % QR-factorization is efficient for small problems
    [Q,R] = qr(full(B'));
    Z = Q(:,mb+1:nu);
else
    % For larger problems we need a sparse null space base.
    % The following is an adaption of the Turnback Algorithm.
    % See for example: Berry, et al, An algorithm to compute a sparse basis
    % of the null space, Numer Math, Vol 47, pp 483-504. 
    k = 0;
    % Indices for the submatrices of B
    imin = [1 1 1 1 1:mb];
    imax = [1:mb mb mb mb mb];
    kmin = [1:4, 5:2:nu-1];
    kmax = [2:2:nu-4, nu-3:nu];
    % Allocate space for Z
    Z = spalloc(nu, nr, 6*nr);
    % Loop over null vectors
    for j = 1:nr
        k0 = k;
        k = kmax(j) - kmin(j);
        % For a uniform mesh we can reuse null vectors
        if ~uniform || k ~= k0
            % Each submatrix Bj determines a null vector
            Bj = B(imin(j):imax(j),kmin(j):kmax(j));    % k by k+1
            z = [-Bj(:,1:k)\Bj(:,k+1); 1];
        end
        Z(kmin(j):kmax(j),j) = z;
    end
end

% Solve: Minimum norm(A*u - y) subject to B*u = 0
G = A*Z;
u = Z*(G\y);

% Compute polynomial coefficients
coefs = C*u;
coefs = reshape(coefs.',[],4);

% Scale coefficients
if scale > 10 || scale < 0.1
    scalepow = repmat(scale.^[3 2 1 0], (nb-1)*prod(dim), 1);
    coefs = scalepow.*coefs;
end

% Make piecewise polynomial
pp.form = 'pp';
pp.breaks = xb0';
pp.coefs = coefs;
pp.pieces = nb-1;
pp.order = 4;
pp.dim = dim;
