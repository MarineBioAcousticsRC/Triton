function [spc,qs]=dtWhiten(sp,fac)
% [spc,qs]=dtWhiten(sp,fac)
% Spectrum whitener
% Spectral subtraction where subtracted value is based on a statistic
% of the quietist part of the spectrum.  In this case, the statistic
% is the mean of the smallest spread of spectral power that covers 50%
% of the distribution of spectral power. 
%
% sp - spectrogram matrix, time x freq
% fac - scale factor
%
% example with toy sp (single row):
%   [8 9 2 4 5 1] 
%   sorted:  [1 2 4 5 8 9]
%   Spread of maximum - minimum values that are 3 bins (50%) away
%   from each other:
%      5 - 1 = 4  <-- smallest
%      8 - 2 = 6
%      9 - 4 = 5
%   The mean of [1 2 4 5] would  be used as the noise estimate.
% 
% Return values:
%   spc - whitened spectrum  sp - fac*statistic
%   qs - values used to compute mean - fac*statstic
%          [1 2 4 5] - fac*mean([1 2 4 5]) in example case.

if nargin < 2
    fac = 1;
end

[timeN,freqN]=size(sp);
qs=zeros(timeN,ceil(freqN/2))+nan;

for i=1:timeN
    % Find the values for this frequency bin that account
    % for the contiguous interval over 50% of the row such
    % the high and low values are minimized.
    [ks]=base2(sp(i,:));
    % store those spectral values in qs
    qs(i,1:length(ks))=sp(i,ks);
end

% Discard any frames that have infinite values in them.
sqs = sum(qs);
k = find(isfinite(sqs));
if ~ isempty(k)
    qs = qs(:,k);
end

mu = mean(qs, 2);

% whiten 
spc = sp -(fac*mu)*ones(1,freqN);
qs = qs-(fac*mu)*ones(1,size(qs, 2));


