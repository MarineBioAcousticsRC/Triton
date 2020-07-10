function nn_fn_save_training_figs(filenameStem)

global REMORA

disp('Saving figures\n')
saveas(REMORA.fig.nn.training_plots{1},fullfile(REMORA.nn.train_net.outDir,[filenameStem,'Training_Data.png']))
saveas(REMORA.fig.nn.training_plots{2},fullfile(REMORA.nn.train_net.outDir,[filenameStem,'Test_Data.png']))
saveas(REMORA.fig.nn.training_plots{3},fullfile(REMORA.nn.train_net.outDir,[filenameStem,'Classifications_Test.png']))
saveas(REMORA.fig.nn.training_plots{4},fullfile(REMORA.nn.train_net.outDir,[filenameStem,'Misclassified_Test.png']))
saveas(REMORA.fig.nn.training_plots{5},fullfile(REMORA.nn.train_net.outDir,[filenameStem,'Classification_accuracy.png']))
saveas(REMORA.fig.nn.training_plots{6},fullfile(REMORA.nn.train_net.outDir,[filenameStem,'Confusion_train.png']))
saveas(REMORA.fig.nn.training_plots{7},fullfile(REMORA.nn.train_net.outDir,[filenameStem,'Confusion_test.png']))
h = findall(groot,'Type','Figure');
trainFig = find(~cellfun(@isempty,strfind({h(:).Name},'Training Progress')),1,'first');
REMORA.fig.nn.training_plots{8} = h(trainFig);
saveas(h(trainFig),fullfile(REMORA.nn.train_net.outDir,[filenameStem,'Training_progress.png']))

disp('Done saving figs\n')