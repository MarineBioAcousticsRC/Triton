
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Utility function to compute the center frequencies with and without offset
% by half a band.
function centerFreq = getCenterFreq(base, bandsPerDivision, bandNum, ...
firstOutBandCenterFreq)
        
    if (bandsPerDivision == 10 || mod(bandsPerDivision, 2) == 1)
        centerFreq = firstOutBandCenterFreq * power(base, (bandNum-1) / ...
bandsPerDivision);
    else
        % from IEC 2014:
        G = power(10, .3);
        b = bandsPerDivision * 0.3;
        centerFreq = base*power(G, (2*(bandNum-1)+1)/(2*b));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

