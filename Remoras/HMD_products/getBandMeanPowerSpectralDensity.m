
function bandsOut = getBandMeanPowerSpectralDensity(linLevel, fftBinSize, bin1CenterFrequency, ...
    firstBand, lastBand, freqTable )
% getBandMeanPowerSpectralDensity - this function sums squared sound
%	pressures to determine the in-band totals then divides by the
%     bandwidths to get PSD. The band edges are normally obtained from a call
%	to 'getBandTable.m'
% getBandSquaredSoundPressure is called to get the band SPLs
%
% Note that the output of getBandSquaredSoundPressurere should satisfy
% Parseval's theorem, but the output of getBandMeanPowerSpectralDensity
% will not unless the bands are re-multiplied by the bandwidths.
% results are returned as linear units not levels.
%
% inputs: linLevel - array of squared pressures from an FFT with a frequency
%		step size; index 1 (rows) are time, index 2 (columns) are freq.
%       fftBinSize - the size of the FFT bins in Hz.
%       bin1CenterFrequency: the freq in Hz of the first element of the FFT
%		array  normally this is frquency zero.
%       firstBand: the index in 'freqtable' of the first band to compute and
%		output
%       lastBand: the index in 'freqTable' of the last band to ocmpute and
%           output
%       freqTable - the list of band edges - Nx3 array where column 1 is the
%           lowest band frquency, column 2 is the center frequency and 3 is
%		the maximum.
%
% Outputs:  band mean PSD array with the same number of rows as linLevel and
%       one column per band.

bandsOut = getBandSquaredSoundPressure(linLevel, fftBinSize, ...
    bin1CenterFrequency, firstBand, lastBand, freqTable );
nRows = size(linLevel, 1);
bandWidths = freqTable(:, 3) - freqTable(:, 1);
for row = 1:nRows
    bandsOut(row, :) = bandsOut(row, :) ./ bandWidths';
end
end

