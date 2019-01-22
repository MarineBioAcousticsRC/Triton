function [Components, EigValues, ZWeights, Info] = ...
    stPrincipalComponents(varargin)
% [Components, Scaling, ZWeights, Info] = stPrincipalComponents(Data, ArgList)
%
% Extracts principal components using the 'R' correlation method
% (normalized variance as opposed to total variance) for the column
% oriented data in Data. 
%
% The new basis set is returned in matrix Components where each column
% represents an axis.  The axes are sorted from most to least important,
% and the relative importance may be determined from the associated
% Eigen values (EigValues).  ZWeights are the weights to scale the
% principal components to 1 standard deviation in the original coordinate
% system.
%
% If the optional output argument Info is present, a structure containing
% the following fields will be returned:
%
%	VariancePct - The percentage of variance accounted for by each
%		axis in the new basis.
%	Loading - The per component loading factors.
%
%
% As the principal components are on a normalized space, the data must be
% rescaled by ZWeights before any type of analysis using the principal
% components.  Alternatively, the principal components can be transformed
% into the observations space with 1/ZWeights.  Principal components are
% sorted from the component vector contributing the most to the normalized
% variance to the least.
%
% Complexity is bounded by the matrix multiplaction necessary to compute the
% variance, and is O(N^2*C) where N is the number of observations and C is
% the number of components or random variables.
%
% Should alternative processing by the caller be desired, ArgList 
% acceptst the following arguments:
%
%	'VarCovar', Sigma - Rather than computing the variance/covariance
%		method by the data, the variance/covariance matrix Sigma
%		is used.  This permits non-standard variances (i.e. 
%		a moving average variance) to be used.
%	'Method', correlation|varcovar
%		By default, the correlation method of principal
%		components is used.  The Method flag allows the
%		user to specifically choose how the principal
%		components should be computed.
%
% This code is copyrighted 1999-2000 by Marie Roch.
% e-mail:  marie.roch@ieee.org
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

error(nargchk(1,inf,nargin))

VarCovar = [];	% defaults
Method = 'correlation';
Data = [];

m=1;
while m < length(varargin)
  switch(varargin{m})
   case 'Data'
    if ~ isempty(VarCovar)
      error('Specify variance-covariance matrix or data, but not both');
    end
    Data = varargin{m+1}; m=m+2;
    VarCovar = cov(Data);
    
   case 'Method'
    Method = varargin{m+1}; m=m+2; 

   case 'VarCovar'
    if ~ isempty(Data)
      error('Specify variance-covariance matrix or data, but not both');
    end
    VarCovar = varargin{m+1}; m=m+2;
    
   otherwise
    error(sprintf('Bad option "%s"', varargin{m}));
  end
end

if isempty(VarCovar) & isemptyt(Data)
  error('Must specify either variance-covariance matrix or data.');
end

ZWeights = sqrt(diag(VarCovar));	% extract out std dev

switch Method

 case 'correlation'
  % Transform variance-covariance matrix to autocorrelation
  AnalMatrix = VarCovar ./ (ZWeights * ZWeights');
  
 case 'varcovar'
  AnalMatrix = VarCovar;
  
 otherwise
  error(sprintf('Invalid principal component analysis method:  %s', Method));
end
      
% extract the eigen vectors/values and sort them from highest to
% smallest contribution to the overall variance
[EigVectors, EigValues] = eig(AnalMatrix);
EigValues = diag(EigValues);

% Arrange the principal components and their Eigen values
% from most to least important so that the user may easily
% select the N most important principal components.
[Components Indices] = sort(EigValues);		% min->max
Indices = flipud(Indices);			% max->min
Components = EigVectors(:,Indices);
EigValues = EigValues(Indices);

ZWeightsT = ZWeights';
Info.Loading = Components ./ ZWeightsT(ones(length(EigValues), 1), :);

Info.VariancePct = EigValues ./ sum(EigValues);
