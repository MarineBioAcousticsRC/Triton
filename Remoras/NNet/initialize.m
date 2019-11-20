global REMORA HANDLES

% initialization script for nnet remora

REMORA.nn.menu = uimenu(HANDLES.remmenu,'Label','&NeuralNet',...
    'Enable','on','Visible','on');

uimenu(REMORA.nn.menu, 'Label', 'Make Train & Test Sets', ...
    'Callback', 'nn_ui_pulldown(''make_train_test_sets'')');

uimenu(REMORA.nn.menu, 'Label', 'Train Network', ...
    'Callback', 'nn_ui_pulldown(''train_net'')');

uimenu(REMORA.nn.menu, 'Label', 'Classify Data', ...
    'Callback', 'nn_ui_pulldown(''classify_data'')');

if ~isfield(REMORA,'fig')
    REMORA.fig = [];
end
