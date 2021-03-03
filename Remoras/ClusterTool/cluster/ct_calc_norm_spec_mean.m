function spectraMean = ct_calc_norm_spec_mean(specSet,p)

if p.normalizeTF
    minSSsection = min(specSet,[],2);
    specClickTf_minNorm = (specSet - minSSsection(:,ones(1,size(specSet,2))));
    maxSSsection = max(specClickTf_minNorm,[],2);
    specClickTf_norm = specClickTf_minNorm./maxSSsection(:,ones(1,size(specClickTf_minNorm,2)));
    
    linearSpec = 10.^(specClickTf_norm./20);
    spectraMean = 20*log10(mean(linearSpec,1));
    
else

    linearSpec = 10.^(specSet./20);
    spectraMean = 20*log10(mean(linearSpec,1)); 
end