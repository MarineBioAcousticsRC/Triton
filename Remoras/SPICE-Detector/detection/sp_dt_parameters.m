function [clickDets,f] = sp_dt_parameters(noiseIn,...
    filteredData,p,clicks,hdr)

%Take timeseries out of existing file, convert from normalized data to
%counts
%1) calculate spectral received levels RL for click and preceding noise:
%calculate spectra, account for bin width to reach dB re counts^2/Hz,
%add transfer function, compute peak frequency and bandwidth
%2) calculate RLpp at peak frequency: find min & max value of timeseries,
%convert to dB, add transfer function value of peak frequency (should come
%out to be about 9dB lower than value of spectra at peak frequency)
%3) Prune out clicks that don't fall in expected peak frequency, 3dB
%bandwidth/duration range, or which are not high enough amplitude
%(ppSignal)
% ** There's code in here to compute a noise spectrum alongside the click
% spectrum. It should at least get you started if you want that sort of
% thing.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize variables
N = length(p.fftWindow);
f = 0:((hdr.fs/2)/1000)/((N/2)):((hdr.fs/2)/1000);
f = f(p.specRange);
sub = 10*log10(hdr.fs/N);

ppSignal = zeros(size(clicks,1),1);
durClick =  zeros(size(clicks,1),1);
bw3db = zeros(size(clicks,1),3);
yFilt = cell(size(clicks,1),1);
specClickTf = zeros(size(clicks,1),length(f));
yFiltBuff = cell(size(clicks,1),1);
peakFr = zeros(size(clicks,1),1);
% cDLims = ceil([p.minClick_us, p.maxClick_us]./(hdr.fs/1e6));
envDurLim = ceil(p.delphClickDurLims.*(hdr.fs/1e6));
nDur = zeros(size(clicks,1),1);
deltaEnv = zeros(size(clicks,1),1);
snr = zeros(size(clicks,1),1);

filteredDataNoDets = filteredData(1:clicks(1,1));
for iNoise = 1:size(clicks,1)-1
    filteredDataNoDets = [filteredDataNoDets,...
        filteredData(clicks(iNoise,2):(clicks(iNoise+1,1)-1))];
end
filteredDataNoDets = [filteredDataNoDets,filteredData(clicks(end,2):end)];
estNoise = sqrt(median(filteredDataNoDets.^2));

if p.saveNoise
    
    if ~isempty(noiseIn)
        yNFilt = filteredData(noiseIn(1):noiseIn(2));
        
        noiseWLen = length(yNFilt);
        noiseWin = hann(noiseWLen);
        wNoise = zeros(1,N);
        wNoise(1:noiseWLen) = noiseWin.*yNFilt';
        spNoise = 20*log10(abs(fft(wNoise,N)));
        spNoiseSub = spNoise-sub;
        spNoiseSub = spNoiseSub(:,1:N/2);
        if ~p.whiten
            specNoiseTf = spNoiseSub(p.specRange)+p.xfrOffset;
        else
            specNoiseTf = spNoiseSub(p.specRange)+p.meanxfrOffset;
        end
            
    else
        yNFilt = [];
        specNoiseTf = [];
    end
end

% Add small buffer to edges of clicks
buffVal = hdr.fs * p.HRbuffer; 

for c = 1:size(clicks,1)
    % Pull out band passed click timeseries
    yFiltBuff{c} = filteredData(max(clicks(c,1)-buffVal,1):min(clicks(c,2)+buffVal,size(filteredData,2)));
    yFilt{c} = filteredData(clicks(c,1):clicks(c,2));
    
    click = yFilt{c};
    clickBuff = yFiltBuff{c};
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculate duration in samples
    durClick(c) = (clicks(c,2)-clicks(c,1));
    
    % Compute click spectrum
    winLength = length(clickBuff);
    wind = hann(winLength);
    wClick = zeros(1,N);
    wClick(1:winLength) = clickBuff.*wind.';
    spClick = 20*log10(abs(fft(wClick,N)));
    
    % account for bin width
    spClickSub = spClick-sub;
    
    %reduce data to first half of spectra
    spClickSub = spClickSub(:,1:N/2);
    if ~p.whiten
        specClickTf(c,:) = spClickSub(p.specRange)+p.xfrOffset;
    else
       specClickTf(c,:) = spClickSub(p.specRange)+p.meanxfrOffset;
    end
    %%%%%
    % calculate peak click frequency
    % max value in the first half samples of the spectrogram
    
    [valMx, posMx] = max(specClickTf(c,:));
    peakFr(c) = f(posMx); %peak frequency in kHz
    
    %%%%%%%%%%%%%%%%%
    % calculate click envelope (code & concept from SBP 2014):
    % env = sqrt((real(pre_env)).^2+(imag(pre_env)).^2); %Au 1993, S.178, equation 9-4
    env = abs(hilbert(click));
    
    %calculate energy duration over x% energy
    env = env - min(env);
    env = env/max(env);
    %determine if the slope of the envelope is positive or negative
    %above x% energy
    aboveThr = find(env>=p.energyThr);
    direction = nan(1,length(aboveThr));
    for a = 1:length(aboveThr)
        if aboveThr(a)>1 && aboveThr(a)<length(env)
            % if it's not the first or last element fo the envelope, then
            % -1 is for negative slope, +1 is for + slope
            delta = env(aboveThr(a)+1)-env(aboveThr(a));
            if delta>=0
                direction(a) = 1;
            else
                direction(a) = -1;
            end
        elseif aboveThr(a) == 1
            % if you're looking at the first element of the envelope
            % above the energy threshold, consider slope to be negative
            direction(a) = -1;
        else  % if you're looking at the last element of the envelope
            % above the energy threshold, consider slope to be positive
            direction(a) = 1;
        end
    end
    
    % find the first value above threshold with positive slope and find
    % the last above with negative slope
    lowIdx = aboveThr(find(direction,1,'first'));
    negative = find(direction==-1);
    if isempty(negative)
        highIdx = aboveThr(end);
    else
        highIdx = aboveThr(negative(end));
    end
    nDur(c,1) = highIdx - lowIdx + 1;
    
    %compare maximum first half of points with second half.
    halves = ceil(nDur(c,1)/2);
    env1max = max(env(lowIdx:min([lowIdx+halves,length(env)])));
    env2max = max(env(min([lowIdx+(halves)+1,length(env)]):end));
    deltaEnv(c,1) = env1max-env2max;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % calculate bandwidth
    % -3dB bandwidth
    % calculation of -3dB bandwidth - amplitude associated with the halfpower points of a pressure pulse (see Au 1993, p.118);
    low = valMx-3; % p1/2power = 10log(p^2max/2) = 20log(pmax)-3dB = 0.707*pmax; 1/10^(3/20)=0.707
    %walk along spectrogram until low is reached on either side
    slopeup = fliplr(specClickTf(c,1:posMx));
    slopedown = specClickTf(c,posMx:round(length(specClickTf(c,:))));
    
    for e3dB = 1:length(slopeup)
        if slopeup(e3dB)<low %stop at value < -3dB: point of lowest frequency
            break
        end
    end
    for o3dB=1:length(slopedown)
        if slopedown(o3dB)<low %stop at value < -3dB: point of highest frequency
            break
        end
    end
    
    %calculation from spectrogram -> from 0 to 100kHz in 256 steps (FFT=512)
    high3dB = (hdr.fs/(2*1000))*((posMx+o3dB)/length(specClickTf(c,:))); %-3dB highest frequency in kHz
    low3dB = (hdr.fs/(2*1000))*((posMx-e3dB)/length(specClickTf(c,:))); %-3dB lowest frequency in kHz
    bw3 = high3dB-low3dB;
    
    bw3db(c,:)= [low3dB, high3dB, bw3];
    
    %%%%%
    %calculate RLpp at peak frequency: find min/max value of timeseries,
    %convert to dB, add transfer function value of peak frequency (should come
    %out to be about 9dB lower than value of spectra at peak frequency)
    
    % find lowest and highest number in timeseries (counts) and add those
    high = max(click.');
    low = min(click.');
    ppCount = high+abs(low);
    
    % calculate dB value of counts and add transfer function value at peak
    % frequency to get ppSignal (dB re 1uPa)
    P = 20*log10(ppCount);
    
    if ~p.whiten
        peakLow=floor(peakFr(c));
        fLow=find(f>=peakLow);
        
        % add PtfN transfer function at peak frequency to P
        tfPeak = p.xfrOffset(fLow(1));
        ppSignal(c) = P+tfPeak;
    else
        ppSignal(c) = P+p.meanxfrOffset;
        
    end
    % Calculate an snr value
    estSignal = sqrt(mean(yFilt{c}.^2));
    snr(c) = 10*log10(estSignal/estNoise);
end

validClicks = ones(size(ppSignal));

% Check parameter values for each click
for idx = 1:length(ppSignal)
    tfVec = [deltaEnv(idx) < p.dEvLims(1);...
        peakFr(idx) < p.cutPeakBelowKHz;...
        peakFr(idx) > p.cutPeakAboveKHz;...
        nDur(idx)>  (envDurLim(2));...
        nDur(idx)<  (envDurLim(1));
        durClick(idx) < p.delphClickDurLims(1);
        durClick(idx) > p.delphClickDurLims(2)];%...
    %          bw3db(idx,3) < p.bw3dbMin];
    %          plot(yFiltBuff{idx})
    %          title(sum(tfVec))
    if ~p.snrDet && ppSignal(idx)< p.dBppThreshold
        validClicks(idx) = 0;
    elseif p.snrDet && snr(idx)< p.snrThresh
        validClicks(idx) = 0;
    elseif sum(tfVec)>0
        validClicks(idx) = 0;
        %else
        %    1;
    end
    
end
clickInd = find(validClicks == 1);

clickDets.clickInd = clickInd;
% throw out clicks that don't fall in desired ranges
clickDets.ppSignal = ppSignal(clickInd,:);
clickDets.durClick =  durClick(clickInd,:);
clickDets.bw3db = bw3db(clickInd,:);
% frames = frames{clickInd};
clickDets.yFilt = yFilt(clickInd);
clickDets.yFiltBuff = yFiltBuff(clickInd);
clickDets.specClickTf = specClickTf(clickInd,:);
clickDets.peakFr = peakFr(clickInd,:);
clickDets.deltaEnv = deltaEnv(clickInd,:);
clickDets.nDur = nDur(clickInd,:);
clickDets.snr = snr(clickInd,:);

if p.saveNoise && ~isempty(clickInd)
    % save noise, as long as valid clicks were also found. 
    % This is a redundant safety check to make sure that noise is not saved if
    % clicks are not saved. 
    clickDets.specNoiseTf = specNoiseTf;
    clickDets.yNFilt = {yNFilt};
elseif p.saveNoise
    clickDets.specNoiseTf = [];
    clickDets.yNFilt = [];
end
