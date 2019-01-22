function Var = var(varargin)
% stVar	Variance.
%	For vectors, stVar(x) returns the unbiased variance.
%	For matrices, stVar(X) is a row vector containing
%	the variance of each column.
%
%	Additional parameters for biased/unbiased or row summation 
%	are posssible.  See STD for details.
%
%	See also:  STD

Var = std(varargin{:}) .^ 2;	% Pass all args to std & square result.
