function cc_gmt_create_settings_file
% made by SGB 20240717
% Shelby G. Bloom (sbloom@ucsd.edu)
% modified/based on Soundscape-Metrics Remora gui folder code by Simone Baumann-Pickering

global REMORA

fileName = REMORA.cc.gmt.paramFileOut;
filePath = REMORA.cc.gmt.paramPathOut;

fileTxT = strrep(fileName,'.m','.txt');
fileID = fopen(fullfile(filePath,fileTxT),'w');

% Write settings file
fprintf(fileID,'%% Settings for GMT Maps\n\n');

%% Input / Output Settings
fprintf(fileID,'%% Input / Output Settings \n\n');
fprintf(fileID,'REMORA.cc.gmt.GPSFilePath = ''%s'';\n',REMORA.cc.verify.GPSFilePath.String);
fprintf(fileID,'REMORA.cc.gmt.SightingDir = ''%s'';\n\n',REMORA.cc.verify.SightingDir.String);
fprintf(fileID,'REMORA.cc.gmt.OutputDir = ''%s'';\n\n',REMORA.cc.verify.OutputDir.String);

%% Close and rename file
fclose(fileID);

% Rename File to Create M File
movefile(fullfile(filePath,fileTxT),fullfile(filePath,fileName), 'f')

