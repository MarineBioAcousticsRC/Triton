function Estimate = spSNR(FrameData)
% Estimate = spSNR(FrameData)
% Compute a blind estimate of the Signal + Noise to Noise ratio as detailed
% in:
%
% @TechReport{hirsch93,
%   author = 	 {Hirsch, H. G\"{u}nter},
%   title = 	 {Estimation of Noise Spectrum and its Application to
%                   SNR-Estimation and Speech Enhancement},
%   institution =  {International Computer Science Institute},
%   year = 	 1993,
%   address =	 {Berkeley, California, USA}
% }
%
% FrameData should be a matrix where each column is a frame.
%
% This code is copyrighted 1998 by Marie Roch.
% e-mail:  marie-roch@uiowa.edu
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

Energy = sum(FrameData .* conj(FrameData));

figure
Bins = 400;

% 11 point equiripple 
% Low pass filter with cutoff at .3 normalized frequency
lp.num = [0.01829920826960  -0.05357618542679   0.08058108467662  ...
-0.06665202288328  -0.05737412202926   0.57566350391637   ...
0.57566350391637  -0.05737412202926 -0.06665202288328   ...
0.08058108467662  -0.05357618542679   0.01829920826960];
lp.den = 1;

TmpEnergy = Energy;

% Energy = filtfilt(lp.num, lp.den, Energy); TitleStr='LP >.3 norm cutoff';
% Energy(find(Energy < 0)) = 0;	% eliminate negative ripple
% Energy = spNLFilter(Energy, 'median', 11); TitleStr='Median 11';
Energy(find(Energy == 0)) = eps;
Energy = log(Energy); TitleStr=('Log Energy');

[Freq, BinLabels] = hist(Energy, Bins);
[MaxVal, MaxInd] = max(Freq);

NumPlot=3;
subplot(NumPlot,1,1)
plot(Energy);
title(sprintf('%s - MaxBin %d, BinValue %f', TitleStr, MaxInd, BinLabels(MaxInd)));

subplot(NumPlot,1,2)
% bar(BinLabels(Bins/2), Freq(1:Bins/2));
bar(BinLabels, Freq);
ylabel('E hist')

subplot(NumPlot,1,3)
x=1:length(TmpEnergy);
plot(x,TmpEnergy,'g-',x,Energy,'r:')
ylabel('En/Trans');



