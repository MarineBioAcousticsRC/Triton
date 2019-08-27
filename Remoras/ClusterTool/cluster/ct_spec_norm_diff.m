function [specClickTf_norm,specClickTf_diff] = ...
    ct_spec_norm_diff(specClickTf,stIdx,edIdx,linearTF)

if linearTF
    specClickTf = 10.^((specClickTf+1)./20);
end
minSSsection = min(specClickTf(:,stIdx:edIdx),[],2);
specClickTf_minNorm = (specClickTf - ...
  minSSsection(:,ones(1,size(specClickTf,2))));
maxSSsection = max(specClickTf_minNorm(:,stIdx:edIdx),[],2);
specClickTf_norm = specClickTf_minNorm./maxSSsection(:,ones(1,size(specClickTf_minNorm,2)));
specClickTf_diff = diff(specClickTf_norm,1,2);
