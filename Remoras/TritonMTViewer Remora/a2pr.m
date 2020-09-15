function     [p,r] = a2pr(A,fs,fc)

%     [p,r] = a2pr(A)			% A is a sensor structure or matrix
%		or
%     [p,r] = a2pr(A,fc)		% A is a sensor structure
%		or
%     [p,r] = a2pr(A,fs,fc)	% A is a matrix
%     Pitch and roll estimation from triaxial accelerometer data. This is 
%		a non-iterative estimator with |pitch| constrained to <= 90 degrees.
%     The pitch and roll estimates give the least-square-norm error between 
%		A and the A-vector that would be measured at the estimated pitch and roll.
%	   If A is in the animal frame, the resulting pitch and roll define
%	   the orientation of the animal with respect to its navigation frame.
%	   If A is in the tag frame, the pitch and roll will define the tag
%	   orientation with respect to its navigation frame.
%
%     Inputs:
%     A is an acceleration sensor structure (e.g., from readtag.m) or an nx3 
%		 acceleration matrix with columns [ax ay az]. Acceleration can 
%		 be in any consistent unit, e.g., g or m/s^2. 
%     fs is the sampling rate of the sensor data in Hz (samples per second).
%		 This is only needed if A is not a sensor structure and filtering is required.
%	   fc (optional) specifies the cut-off frequency of a low-pass filter to
%		 apply to A before computing pitch and roll. The filter cut-off
%		 frequency is in Hertz. The filter length is 4*fs/fc. Filtering adds 
%		 no group delay. If fc is not specified, no filtering is performed.
%
%     Returns:
%     p is the pitch estimate in radians
%     r is the roll estimate in radians
%
%     Output sampling rate is the same as the input sampling rate.
%		Frame: This function assumes a [north,east,up] navigation frame and a
%		[forward,right,up] local frame. In these frames, a positive pitch angle 
%		is an anti-clockwise rotation around the y-axis. A positive roll angle 
%		is a clockwise rotation around the x-axis. A descending animal will have
%		a negative pitch angle while an animal rolled with its right side up will
%		have a positive roll angle.
%
%		Example:
%		 [p,r] = a2pr([0.77 -0.6 -0.22])
% 	    returns: p=0.87806 radians, r=-1.9222 radians.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 10 May 2017

p = []; r = [];
if nargin==0,
   help a2pr
   return
end

if isstruct(A),
	if nargin>1,
		fc = fs ;
	else
		fc = [] ;
	end
	fs = A.sampling_rate ;
	A = A.data ;
else
	if nargin==1,
		fc = [] ;
	elseif nargin==2,
	   fprintf('Error: Need to specify fs and fc if calling a2pr with a matrix input\n') ;
	   return
	end
end	
	
% catch the case of a single acceleration sample
if min([size(A,1) size(A,2)])==1,
   A = A(:)' ;
end

if ~isempty(fc),
	nf = round((4*fs)/fc) ; %Adjustment: changed the equation to 4*fs/fc instead of 4/fc.
	if size(A,1)>nf,
		A = fir_nodelay(A,nf,fc/(fs/2)) ;
	end
end
	
v = sqrt(sum(A.^2,2)) ;

% compute pitch and roll
p = asin(A(:,1)./v) ;
r = real(atan2(A(:,2),A(:,3))) ;
