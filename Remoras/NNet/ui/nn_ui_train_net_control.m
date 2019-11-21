function nn_ui_train_net_control(hObject,eventdata,myEvent)

global REMORA

if strcmp(myEvent, 'setTrainFile')
    REMORA.nn.train_net.trainFile = ...
        get(REMORA.fig.nn.train_net.trainFileEdTxt,'String');
    
elseif strcmp(myEvent, 'setTestFile')
    REMORA.nn.train_net.testFile = ...
        get(REMORA.fig.nn.train_net.testFileEdTxt,'String');
    
elseif strcmp(myEvent, 'setOutDir')
    REMORA.nn.train_net.outDir = ...
        get(REMORA.fig.nn.train_net.outDirEdTxt,'String');

elseif strcmp(myEvent, 'setNHidden')
    REMORA.nn.train_net.nHiddenLayers = ...
        round(str2num(get(REMORA.fig.nn.train_net.nHiddenEdTxt,'String')));

elseif strcmp(myEvent, 'setHiddenLayerSize')
    REMORA.nn.train_net.hLayerSize = ...
        round(str2num(get(REMORA.fig.nn.train_net.hLayerSizeEdTxt,'String')));

elseif strcmp(myEvent, 'setBatchSize')
    REMORA.nn.train_net.batchSize = ...
        round(str2num(get(REMORA.fig.nn.train_net.batchSizeEdTxt,'String')));

elseif strcmp(myEvent, 'setNEpochs')
    REMORA.nn.train_net.nEpochs = ...
        round(str2num(get(REMORA.fig.nn.train_net.nEpochsEdTxt,'String')));

elseif strcmp(myEvent, 'setDropout')
    REMORA.nn.train_net.dropout = ...
        round(str2num(get(REMORA.fig.nn.train_net.dropoutEdTxt,'String')));

elseif strcmp(myEvent, 'Run')
    nn_train_nnet
else
    error('Unrecognized callback')
end
