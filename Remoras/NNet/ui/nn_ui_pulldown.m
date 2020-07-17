function nn_ui_pulldown(action)
%
% nn_ui_pulldown.m
% initializes pulldowns for nnet tool


global REMORA


if strcmp(action,'train_test_from_clusters')

    nn_ui_train_test_set_window  
    
elseif strcmp(action,'train_test_from_TPWS')
   
    nn_ui_train_test_from_TPWS
    
elseif strcmp(action,'train_net')
    
    nn_ui_train_net_window
    
elseif strcmp(action,'classify_data')
    
    nn_ui_classify_window
    
elseif strcmp(action,'post_classify')
    
    nn_ui_post_classification_window
end
