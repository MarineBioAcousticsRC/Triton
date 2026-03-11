
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function bandsOut = getBandSquaredSoundPressure(linLevel, fftBinSize, ...
    bin1CenterFrequency, firstBand, lastBand, freqTable )
% getBandSquaredSoundPressure - this function sums squared sound pressures
% to determine the in-band totals. The band edges are normally obtained
% from a call to 'getBandTable.m'
%
% inputs: linLevel - array of squared pressures from an FFT with a frequency
%		step size; index 1 (rows) are time, index 2 (columns) are freq.
%       fftBinSize - the size of the FFT bins in Hz.
%       bin1CenterFrequency: the freq in Hz of the first element of the FFT
%		array - normally this is frquency zero.
%       firstBand: the index in 'freqtable' of the first band to compute and
%		output
%       lastBand: the index in 'freqTable' of the last band to ocmpute and
%           output
%       freqTable - the list of band edges - Nx3 array where column 1 is the
%           lowest band frquency, column 2 is the center frequency and 3 is
%		the maximum.
%
% Outputs:  band squared sound pressure array with the same number of rows as
%	 linLevel and one column per band.
%
% Bruce Martin, JASCO Applied Sciences, Feb 2020.

nRows = size(linLevel, 1);

bandsOut = zeros(nRows, lastBand-firstBand+1);
step = fftBinSize / 2;
nFFTBins = size(linLevel, 2);
startOffset = floor(bin1CenterFrequency / fftBinSize);

for row = 1:nRows
    for j = firstBand:lastBand
        minFFTBin = floor((freqTable(j,1) / fftBinSize) + step) + 1 - ...
            startOffset;
        maxFFTBin = floor((freqTable(j,3) / fftBinSize) + step) + 1 - ...
            startOffset;
        if (maxFFTBin > nFFTBins)
            maxFFTBin = nFFTBins;
        end
        if (minFFTBin < 1)
            minFFTBin = 1;
        end

        if (minFFTBin == maxFFTBin)
            bandsOut(row, j) = linLevel(row, minFFTBin) *((freqTable(j, 3)- ...
                freqTable(j, 1))/ fftBinSize);
        else
            % Add the first partial FFT bin - take the top of the bin and
            % subtract the lower freq to get the amount we will use:
            % the top freq of a bin is bin# * step size - binSize/2 since bin
            %
            lowerFactor =((minFFTBin - step) * fftBinSize - freqTable(j, 1));
            bandsOut(row, j) = linLevel(row, minFFTBin) * lowerFactor;

            % Add the last partial FFT bin.
            upperFactor = freqTable(j, 3) - (maxFFTBin - 1.5*fftBinSize)* ...
                fftBinSize;
            bandsOut(row, j) = bandsOut(row, j) + linLevel(row, maxFFTBin)* ...
                upperFactor;
            %
            % Add any FFT bins in between min and max.
            if (maxFFTBin - minFFTBin) > 1
                bandsOut(row, j) = bandsOut(row, j) + ...
                    sum( linLevel(row,minFFTBin+1:maxFFTBin-1) );
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

