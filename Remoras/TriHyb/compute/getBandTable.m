function [ bands ] = getBandTable(fftBinSize, bin1CenterFrequency, fs, base, ...
    bandsPerDivision, firstOutputBandCenterFrequency, useFFTResAtBottom)
% getBandTable(): This is generic software that returns a three column array:
%     with the start, center, stop frequecies for logarthimically spaced
%     frequency bands such as millidecades, decidecades (thirdoctaves base10)
%     or third octaves base 2. These tables are passed to
%     'getBandSquaredSoundPressure' to convert square spectra to band
%     levels. The squared pressure can be converted to power spectral
%     density by dividing by the bandwidths.
% Inputs:
%       fftBinSize - the size of the FFT bins in Hz that subsequent
%		processing of data will use.
%       bin1CenterFrequency - this is the center frequency in Hz of the FFT
%           spectra that will be passed to subsequent processing, normally
%		this should be zero.
%       fs - data sampling frequency in Hz
%       base - base for the band levels, generally 10 or 2.
%       bandsPerDivision - the number of bands to divide the spectrum into
%           per increase by a factor of 'base'. A base of 2 and
%           bandsPerDivision of 3 results in third octaves base 2. Base 10
%           and bandsPerDivision of 1000 results in millidecades.
%       firstOutputBandCenterFrequency: this is the frquency where the output
%		bands will start.
%       useFFTResAtBottom: In some cases, like millidecades, we do not want
%           to have logarithmically spaced frequency bands across the full
%           spectrum, instead we have the option to have bands that are equal
%           FFTBinSize. The switch to log spacing is made at the band that
%		has a bandwidth greater than FFTBinSize and such that the
%           frequency space between band center frequencies is at least
%		FFTBinSize.
%
% Outputs:
%       Three column array where column 1 is the lowest frequency of the
%       band, column 2 is the center frequency, and 3 is the highest
%       frequency
% Example Usage:
%    fftBinSize = fs/fftSize; % fs is sample rate,
%	     fftSize is number of points in your FFT
%    milliDecadeBands = getBandTable(fftBinSize, 0, fs, 10, 1000, 1, 1);
%    deciDecadeBands = getBandTable(fftBinSize, 0, fs, 10, 10, 1, 0);
%    thirdOctaveBands = getBandTable(fftBinSize, 0, fs, 2, 3, 1, 0);

%Author: Bruce Martin, JASCO Applied Sciences, Feb 2020.
%          bruce.martin@jasco.com.

bandCount = 0;
maxFreq = fs/2;
lowSideMultiplier = power(base, -1/(2*bandsPerDivision));
highSideMultiplier = power(base, 1/(2*bandsPerDivision));
% count the number of bands:
linearBinCount = 0;
logBinCount = 0;
centerFreq = 0;
if (useFFTResAtBottom)
    binWidth = 0;
    while (binWidth < fftBinSize)
        bandCount = bandCount + 1;
        centerFreq =  firstOutputBandCenterFrequency * ...
            power(base, bandCount / bandsPerDivision);
        binWidth = highSideMultiplier*centerFreq - ...
            lowSideMultiplier*centerFreq;
    end
    % now keep counting until the difference between the log spaced
    % center frequency and new frequency is greater than .025
    centerFreq =  firstOutputBandCenterFrequency * ...
        power(base, bandCount / bandsPerDivision);
    linearBinCount = ceil(centerFreq / fftBinSize);
    while ((linearBinCount * fftBinSize - centerFreq > 0.0))
        bandCount = bandCount + 1;
        linearBinCount = linearBinCount + 1;
        centerFreq =  firstOutputBandCenterFrequency * ...
            power(base, bandCount / bandsPerDivision);
    end

    if (fftBinSize * linearBinCount > maxFreq)
        linearBinCount = maxFreq / fftBinSize + 1;
    end
else
    linearBinCount = 0;
end

logBand1 = bandCount;

% count the log space frequencies
while (maxFreq > centerFreq)
    bandCount = bandCount + 1;
    logBinCount = logBinCount + 1;
    centerFreq =  firstOutputBandCenterFrequency * ...
        power(base, bandCount / bandsPerDivision);
end

bands = zeros((linearBinCount + logBinCount), 3);

% generate the linear frequencies
for i = 1:linearBinCount
    bands(i, 2)  =  bin1CenterFrequency + (i-1)*fftBinSize;
    bands(i, 1)  =  bands(i, 2) - fftBinSize/2;
    bands(i, 3)  =  bands(i, 2) + fftBinSize/2;
end


% generate the log spaced bands
for i = 1:logBinCount
    outBandNumber = linearBinCount + i;
    mDecNumber = logBand1 + i;
    bands(outBandNumber, 2)  =  firstOutputBandCenterFrequency * ...
        power(base, (mDecNumber-1) / bandsPerDivision);
    bands(outBandNumber, 1)  =  bands(outBandNumber, 2) * ...
        lowSideMultiplier;
    bands(outBandNumber, 3)  =  bands(outBandNumber, 2) * ...
        highSideMultiplier;
end

if (logBinCount > 0)
    bands(outBandNumber, 3) = maxFreq;
end

end

