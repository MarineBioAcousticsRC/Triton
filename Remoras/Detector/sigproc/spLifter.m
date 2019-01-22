function [LifteredFeature] = spLifter(Feature);
% [LifteredFeature] = spLifter(Feature)
% 
%	Applies liftering to a feature set.  Feature is
%	either a column vector of L points (i.e. cepstrum
%	at time t) or a matrix containing column vectors.
%	
%	The liftering window is generated as follows:
%			1 + h sin(1 pi/L)
%			1 + h sin(2 pi/L)
%			     ...
%			1 + h sin(L pi/L)
%
%	h is L/2
%
% This code is copyrighted 1997, 1998 by Marie Roch.
% e-mail:  marie-roch@uiowa.edu
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 


[L FeatureCount] = size(Feature);

% Generate liftering vector
h = L/2;
Weights = 1 + h * sin(1:L' * pi / L);

% Lifter
for i = 1:L
  Feature(:,i) = Feature(:,i) .* Weights;
end

LifteredFeature = Feature;



  

	
