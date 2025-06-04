function sm_ltsa_create_settings_file

global PARAMS REMORA

fileName = REMORA.sm.ltsa.paramFileOut;
filePath = REMORA.sm.ltsa.paramPathOut;

fileTxT = strrep(fileName,'.m','.txt');
fileID = fopen(fullfile(filePath,fileTxT),'w');

% Write settings file
fprintf(fileID,'%% Settings Script for Soundscape LTSA\n\n');

fprintf(fileID,'%% DIRECTORY INFORMATION \n\n');
fprintf(fileID,'PARAMS.ltsa.indir = ''%s'';\n',REMORA.sm.verify.indir.String);
fprintf(fileID,'PARAMS.ltsa.outdir = ''%s'';\n',REMORA.sm.verify.outdir.String);
fprintf(fileID,'PARAMS.ltsa.outfname = ''%s'';\n\n',REMORA.sm.verify.outfname.String);

fprintf(fileID,'REMORA.sm.ltsa.indir = ''%s'';\n',REMORA.sm.verify.indir.String);
fprintf(fileID,'REMORA.sm.ltsa.outdir = ''%s'';\n',REMORA.sm.verify.outdir.String);
fprintf(fileID,'REMORA.sm.ltsa.outfname = ''%s'';\n\n\n',REMORA.sm.verify.outfname.String);


fprintf(fileID,'%% LTSA PARAMETERS \n\n');
fprintf(fileID,'PARAMS.ltsa.tave = %s;\n',REMORA.sm.verify.tave.String);
fprintf(fileID,'PARAMS.ltsa.dfreq = %s;\n',REMORA.sm.verify.dfreq.String);
fprintf(fileID,'PARAMS.ltsa.ndays = %s;\n',REMORA.sm.verify.ndays.String);
fprintf(fileID,'PARAMS.ltsa.nstart = %s;\n',REMORA.sm.verify.nstart.String);
fprintf(fileID,'PARAMS.ltsa.ftype = %s;\n',REMORA.sm.verify.ftype.String);
fprintf(fileID,'PARAMS.ltsa.dtype = %s;\n',REMORA.sm.verify.dtype.String);
fprintf(fileID,'PARAMS.ltsa.ch = %s;\n\n',REMORA.sm.verify.ch.String);

fprintf(fileID,'REMORA.sm.ltsa.tave = %s;\n',REMORA.sm.verify.tave.String);
fprintf(fileID,'REMORA.sm.ltsa.dfreq = %s;\n',REMORA.sm.verify.dfreq.String);
fprintf(fileID,'REMORA.sm.ltsa.ndays = %s;\n',REMORA.sm.verify.ndays.String);
fprintf(fileID,'REMORA.sm.ltsa.nstart = %s;\n',REMORA.sm.verify.nstart.String);
fprintf(fileID,'REMORA.sm.ltsa.ftype = %s;\n',REMORA.sm.verify.ftype.String);
fprintf(fileID,'REMORA.sm.ltsa.dtype = %s;\n',REMORA.sm.verify.dtype.String);
fprintf(fileID,'REMORA.sm.ltsa.ch = %s;\n',REMORA.sm.verify.ch.String);


fclose(fileID);

% Rename File to Create M File
movefile(fullfile(filePath,fileTxT),fullfile(filePath,fileName), 'f')
