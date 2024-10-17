function cc_count_create_settings_file
% made by SGB 20240717
% Shelby G. Bloom (sbloom@ucsd.edu)
% modified/based on Soundscape-Metrics Remora gui folder code by Simone Baumann-Pickering

global REMORA

fileName = REMORA.cc.count.paramFileOut;
filePath = REMORA.cc.count.paramPathOut;

fileTxT = strrep(fileName,'.m','.txt');
fileID = fopen(fullfile(filePath,fileTxT),'w');

% Write settings file
fprintf(fileID,'%% Settings for countCOFI Table\n\n');

%% Input / Output Settings
fprintf(fileID,'%% Input / Output Settings \n\n');
fprintf(fileID,'REMORA.cc.count.indir = ''%s'';\n',REMORA.cc.verify.indir.String);
fprintf(fileID,'REMORA.cc.count.outdir = ''%s'';\n\n',REMORA.cc.verify.outdir.String);
fprintf(fileID,'REMORA.cc.count.GMTdiff = %s;\n\n',REMORA.cc.verify.GMTdiff.String);

%% Close and rename file
fclose(fileID);

% Rename File to Create M File
movefile(fullfile(filePath,fileTxT),fullfile(filePath,fileName), 'f')

