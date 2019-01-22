function averagedPower = noiseStatistic(M, per)
% M = spectrum of frames x frequencies
% per = percentile

    [~, numFreq] = size(M);
    averagedPower = zeros(numFreq,1);

    % Take mean of per% of the frames per frequency
    % Percentage based on index not values.
    for i=1:numFreq
        % Return the indicies for which the requested percentage of values
        % are spread such that the lowest and highest values are cloests to
        % each other.
        indc = base3(M(:,i), per);
        averagedPower(i) = mean(M(indc,i));
    end
    
end