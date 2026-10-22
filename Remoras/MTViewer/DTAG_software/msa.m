function    m = msa(A)
%
%     m = msa(A)
%       Compute the Minimum Specific Acceleration
%       sensu Simon et al. 2012.
%       MSA is the absolute value of the norm of the
%       acceleration - 1 g, i.e., the amount that the
%       acceleration differs from the gravity value. This
%       is an underestimate on the specific acceleration.
%       A is the 3-column acceleration recording in g's.
%        Can be in the tag or whale frame - it doesn't matter.
%       m is the MSA in m/s2
%
%    markjohnson@st-andrews.ac.uk
%    15 aug 2012

m = 9.81*abs(sqrt(A.^2*ones(3,1))-1) ;
