global REMORA HANDLES

% initialization script for nnet remora

REMORA.nn.menu = uimenu(HANDLES.remmenu,'Label','&NeuralNet',...
    'Enable','on','Visible','on');

REMORA.nn.trainTestmenu = uimenu(REMORA.nn.menu, 'Label', 'Make Train & Test Sets');

uimenu(REMORA.nn.trainTestmenu, 'Label', 'From Clusters', ...
     'Enable', 'on', 'Callback', 'nn_ui_pulldown(''train_test_from_clusters'')');

uimenu(REMORA.nn.trainTestmenu, 'Label', 'From Labeled TPWS',...
     'Visible','off',...
     'Enable', 'on', 'Callback', 'nn_ui_pulldown(''train_test_from_TPWS'')');

uimenu(REMORA.nn.menu, 'Label', 'Train Network', ...
    'Callback', 'nn_ui_pulldown(''train_net'')');

uimenu(REMORA.nn.menu, 'Label', 'Classify Data', ...
    'Callback', 'nn_ui_pulldown(''classify_data'')');

uimenu(REMORA.nn.menu, 'Label', 'Post-Classification Options', ...
    'Callback', 'nn_ui_pulldown(''post_classify'')');

if ~isfield(REMORA,'fig')
    REMORA.fig = [];
end
