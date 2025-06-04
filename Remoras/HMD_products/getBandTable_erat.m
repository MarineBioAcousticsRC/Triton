
function [ freqTable ] = getBandTable_erat(fftBinSize, bin1CenterFrequency, fs, base, ...
    bandsPerDivision, firstOutputBandCenterFrequency, useFFTResAtBottom)
% getBandTable(): This is generic software that returns a three column array:
%     with the start, center, stop frequecies for logarthimically spaced
%     frequency bands such as millidecades or decidecades(third octaves base 
%     10) or third octaves base 2. These tables are passed to
%     'getBandSquaredSoundPressure' to convert square spectra to band
%     levels. The squared pressure can be converted to power spectral
%     density by dividing by the bandwidths.
% Inputs:
%       fftBinSize - the size of the FFT bins in Hz that subsequent
%       	processing of data will use.
%       bin1CenterFrequency - this is the center frequency in Hz of the FFT
%           spectra that will be passed to subsequent processing, normally
% 		this should be zero.
%       fs - data sampling frequency in Hz
%       base - base for the band levels, generally 10 or 2.
%       bandsPerDivision - the number of bands to divide the spectrum into
%           per increase by a factor of 'base'. A base of 2 and
%           bandsPerDivision of 3 results in third octaves base 2. Base 10
%           and bandsPerDivision of 1000 results in milliDecades.
%       firstOutputBandCenterFrequency: this is the frquency where the output
%           bands will start.
%       useFFTResAtBottom: In some cases, like milliDecades, we do not want
%           to have logarithmically spaced frequency bands across the full
%           spectrum, instead we have the option to have bands that are equal
%           FFTBinSize. The switch to log spacing is made at the band that
%           has a bandwidth greater than FFTBinSize and such that the
%           frequency space between band center frequencies is at least
%            FFTBinSize.
% Outputs:
%       Three column array where column 1 is the lowest frequency of the
%       band, column 2 is the center frequency, and 3 is the highest
%       frequency
% Author: Bruce Martin, JASCO Applied Sciences, Feb 2020; updated April 2021
%          bruce.martin@jasco.com.

bandCount = 0;

maxFreq = fs/2;

lowSideMultiplier = power(base, -1/(2*bandsPerDivision));
highSideMultiplier = power(base, 1/(2*bandsPerDivision));

% count the number of bands:
logBinCount = 0;
centerFreq = 0;
if (useFFTResAtBottom)
    binWidth = 0;
    while (binWidth < fftBinSize)
        bandCount = bandCount + 1;
        centerFreq =  getCenterFreq(base, bandsPerDivision, bandCount, ...
            firstOutputBandCenterFrequency);
        binWidth = highSideMultiplier*centerFreq - ...
            lowSideMultiplier*centerFreq;
    end
    % now keep counting until the difference between the log spaced
    % center frequency and new frequency is greater than .025
    centerFreq =  getCenterFreq(base, bandsPerDivision, bandCount, ...
        firstOutputBandCenterFrequency);
    linearBinCount = round(centerFreq / fftBinSize);
    dC = abs(linearBinCount * fftBinSize - centerFreq) + .1;
    while (abs(linearBinCount * fftBinSize - centerFreq) < dC)
        dC = abs(linearBinCount * fftBinSize - centerFreq);
        bandCount = bandCount + 1;
        linearBinCount = linearBinCount + 1;
        centerFreq =  getCenterFreq(base, bandsPerDivision, bandCount, ...
            firstOutputBandCenterFrequency);
    end
    linearBinCount = linearBinCount - 1;
    bandCount = bandCount - 1;

    if (fftBinSize * linearBinCount > maxFreq)
        linearBinCount = maxFreq / fftBinSize + 1;
    end
else
    linearBinCount = 0;
end

logBand_1 = bandCount;

% count the log space frequencies
lsFreq = centerFreq * lowSideMultiplier;
while (maxFreq > lsFreq)
    bandCount = bandCount + 1;
    logBinCount = logBinCount + 1;
    centerFreq =  getCenterFreq(base, bandsPerDivision, bandCount, ...
        firstOutputBandCenterFrequency);
    lsFreq  =  centerFreq * lowSideMultiplier;
end

freqTable = zeros((linearBinCount + logBinCount), 3);

% generate the linear frequencies
for i = 1:linearBinCount
    freqTable(i, 2)  =  bin1CenterFrequency + (i-1)*fftBinSize;
    freqTable(i, 1)  =  freqTable(i, 2) - fftBinSize/2;
    freqTable(i, 3)  =  freqTable(i, 2) + fftBinSize/2;
end

% generate the log spaced bands
for i = 1:logBinCount
    outBandNumber = linearBinCount + i;
    logBandNumber = logBand_1 + i - 1;
    freqTable(outBandNumber, 2) = getCenterFreq(base, bandsPerDivision,...
        logBandNumber, firstOutputBandCenterFrequency);
    freqTable(outBandNumber, 1)  =  freqTable(outBandNumber, 2) * ...
        lowSideMultiplier;
    freqTable(outBandNumber, 3)  =  freqTable(outBandNumber, 2) * ...
        highSideMultiplier;
end

if (logBinCount > 0)
    % align the end of the linear with the start of the log:
    if (linearBinCount > 0)
        freqTable(linearBinCount, 3) = freqTable(linearBinCount+1, 1);
    end
    % handle end of data values:
    freqTable(outBandNumber, 3) = maxFreq;
    if (freqTable(outBandNumber, 2) > maxFreq)
        freqTable(outBandNumber, 2) = maxFreq;
    end
end

end
