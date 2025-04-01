function cc_vis_create_settings_file
% made by SGB 20240717
% Shelby G. Bloom (sbloom@ucsd.edu)
% modified/based on Soundscape-Metrics Remora gui folder code by Simone Baumann-Pickering

global REMORA

fileName = REMORA.cc.vis.paramFileOut;
filePath = REMORA.cc.vis.paramPathOut;

fileTxT = strrep(fileName,'.m','.txt');
fileID = fopen(fullfile(filePath,fileTxT),'w');

% Write settings file
fprintf(fileID,'%% Settings for visEffort\n\n');

%% Input / Output Settings
fprintf(fileID,'%% Input / Output Settings \n\n');
fprintf(fileID,'REMORA.cc.vis.GPSFilePath = ''%s'';\n',REMORA.cc.verify.GPSFilePath.String);
fprintf(fileID,'REMORA.cc.vis.effFilePath = ''%s'';\n\n',REMORA.cc.verify.effFilePath.String);
fprintf(fileID,'REMORA.cc.vis.oDir = ''%s'';\n\n',REMORA.cc.verify.oDir.String);

%% Close and rename file
fclose(fileID);

% Rename File to Create M File
movefile(fullfile(filePath,fileTxT),fullfile(filePath,fileName), 'f')

