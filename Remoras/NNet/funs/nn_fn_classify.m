function nn_fn_classify

global REMORA

if REMORA.nn.classify.binsTF 
    nn_fn_classify_bins

elseif REMORA.nn.classify.detsTF
    nn_fn_classify_dets
end