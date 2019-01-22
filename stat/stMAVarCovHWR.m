function VarCovar = stMAVarCovHWR(Data, W)
% VarCovar = stMAVarCovarHWR(Data, W)  stMAVarCovar w/Half Wave Rectification
% Given a matrix of column oriented data where each column represents and
% independent random variable, compute the moving average variance
% covariance mstrix  using a local W point mean.  The variance is
% weighted by the number of samples N - 1. 
%
% This code is copyrighted 1999 by Marie Roch.
% e-mail:  marie-roch@uiowa.edu
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

WorkData = stMA(abs(Data), W);	
WorkData = Data - sign(Data).*WorkData;		% difference w/MA

VarCovar = (WorkData' * WorkData) / (size(WorkData, 1) - 1);




