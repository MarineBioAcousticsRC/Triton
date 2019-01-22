function Draws = stDiscreteDraw(DiscreteDistributions)
% Values = stDiscreteDraw(DiscreteDistributions)
% Given a series of independent discrete distributions whose pdfs
% form column vectors in matrix DiscreteDistributions, return
% a stochastic draw from each distribution.
%
% This code is copyrighted 2001 by Marie Roch.
% e-mail:  marie.roch@ieee.org
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

pdfs = size(DiscreteDistributions, 2);
UDraws = rand(pdfs, 1);
Draws = stDiscreteDrawAux(DiscreteDistributions, UDraws);
