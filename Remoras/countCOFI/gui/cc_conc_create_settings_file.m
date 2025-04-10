function cc_conc_create_settings_file
% made by SGB 20240717
% Shelby G. Bloom (sbloom@ucsd.edu)
% modified/based on Soundscape-Metrics Remora gui folder code by Simone Baumann-Pickering

global REMORA

fileName = REMORA.cc.conc.paramFileOut;
filePath = REMORA.cc.conc.paramPathOut;

fileTxT = strrep(fileName,'.m','.txt');
fileID = fopen(fullfile(filePath,fileTxT),'w');

% Write settings file
fprintf(fileID,'%% Settings for Concatenation of Daily Expanded Files\n\n');

%% Input / Output Settings
fprintf(fileID,'%% Input / Output Settings \n\n');
fprintf(fileID,'REMORA.cc.conc.indir = ''%s'';\n',REMORA.cc.verify.indir.String);
fprintf(fileID,'REMORA.cc.conc.outdir = ''%s'';\n\n',REMORA.cc.verify.outdir.String);

%% Close and rename file
fclose(fileID);

% Rename File to Create M File
movefile(fullfile(filePath,fileTxT),fullfile(filePath,fileName), 'f')

