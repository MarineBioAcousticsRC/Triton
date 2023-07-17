function [specClickTfNorm,specClickTfNormDiff] = ct_normalize_click_spectra(specClickTf, p)

if p.linearTF
    % convert out of log space for linear comparison
    specClickTf = 10.^((specClickTf+1)./20);
end

% Normalize clicks on 0-1 scale

% find minimum over freq range of interest
minSSsection = min(specClickTf(:,p.startFreqIdx:p.endFreqIdx),[],2);
% subtract minimum
specClickTf_minNorm = (specClickTf - minSSsection(:,ones(1,size(specClickTf,2))));
% find maximum over freq range of interest
maxSSsection = max(specClickTf_minNorm(:,p.startFreqIdx:p.endFreqIdx),[],2);
% divide by maximum
specClickTfNorm = specClickTf_minNorm./maxSSsection(:,ones(1,size(specClickTf_minNorm,2)));

specClickTfNormDiff = [];
if p.diff
    % do diff of linear spectra
    specClickTfNormDiff = diff(specClickTfNorm,1,2);
end
