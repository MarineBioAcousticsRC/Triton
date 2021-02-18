function p = sp_fn_interp_tf_whiten(p,fs)

% If a transfer function is provided, interpolate to desired frequency bins

% Determine the frequencies for which we need the transfer function
p.xfr_f_whiten = 0:(p.binWidth_Hz*2):(fs/2);
if ~isempty(p.tfFullFile)
    [p.xfr_f_whiten, p.xfrOffset_whiten] = sp_fn_tfMap(p.tfFullFile, p.xfr_f_whiten);    
else
    % if you didn't provide a tf function, then just create a
    % vector of zeros of the right size.
    p.xfrOffset_whiten = zeros(size(p.xfr_f));
end