function sm_cmpt_create_settings_file

global REMORA

fileName = REMORA.sm.cmpt.paramFileOut;
filePath = REMORA.sm.cmpt.paramPathOut;

fileTxT = strrep(fileName,'.m','.txt');
fileID = fopen(fullfile(filePath,fileTxT),'w');

% Write settings file
fprintf(fileID,'%% Settings for Computation of Soundscape Metrics\n\n');

%% Input / Output Settings
fprintf(fileID,'%% Input / Output Settings \n\n');
fprintf(fileID,'REMORA.sm.cmpt.indir = ''%s'';\n',REMORA.sm.verify.indir.String);
fprintf(fileID,'REMORA.sm.cmpt.outdir = ''%s'';\n\n',REMORA.sm.verify.outdir.String);
fprintf(fileID,'REMORA.sm.cmpt.ltsaout = %i;\n',REMORA.sm.verify.ltsaout.Value);
fprintf(fileID,'REMORA.sm.cmpt.csvout = %i;\n',REMORA.sm.verify.csvout.Value);
fprintf(fileID,'REMORA.sm.cmpt.fstart = %s;\n\n',REMORA.sm.verify.fstart.String);

%% Analysis Options
fprintf(fileID,'%% Analysis Options \n\n');

% Bandpass Edges
fprintf(fileID,'REMORA.sm.cmpt.lfreq = %s;\n',REMORA.sm.verify.lfreq.String);
fprintf(fileID,'REMORA.sm.cmpt.hfreq = %s;\n\n',REMORA.sm.verify.hfreq.String);

% Analysis Type
fprintf(fileID,'REMORA.sm.cmpt.bb = %i;\n',REMORA.sm.verify.bb.Value);
fprintf(fileID,'REMORA.sm.cmpt.ol = %i;\n',REMORA.sm.verify.ol.Value);
fprintf(fileID,'REMORA.sm.cmpt.tol = %i;\n',REMORA.sm.verify.tol.Value);
fprintf(fileID,'REMORA.sm.cmpt.psd = %i;\n\n',REMORA.sm.verify.psd.Value);

% Averaging
fprintf(fileID,'REMORA.sm.cmpt.avgt = %s;\n',REMORA.sm.verify.avgt.String);
fprintf(fileID,'REMORA.sm.cmpt.avgf = %s;\n',REMORA.sm.verify.avgf.String);
fprintf(fileID,'REMORA.sm.cmpt.perc = %2.1f;\n\n',str2double(REMORA.sm.verify.perc.String)/100);

fprintf(fileID,'REMORA.sm.cmpt.mean = %i;\n',REMORA.sm.verify.mean.Value);
fprintf(fileID,'REMORA.sm.cmpt.median = %i;\n',REMORA.sm.verify.median.Value);
fprintf(fileID,'REMORA.sm.cmpt.prctile = %i;\n\n',REMORA.sm.verify.prctile.Value);


% Remove Erroneous Data
fprintf(fileID,'REMORA.sm.cmpt.fifo = %i;\n',REMORA.sm.verify.fifo.Value);
fprintf(fileID,'REMORA.sm.cmpt.dw = %i;\n',REMORA.sm.verify.dw.Value);
fprintf(fileID,'REMORA.sm.cmpt.strum = %i;\n',REMORA.sm.verify.strum.Value);
fprintf(fileID,'REMORA.sm.cmpt.perc = %i;\n\n',REMORA.sm.verify.perc.Value);


%% Calibration Options
fprintf(fileID,'%% Calibration Options \n\n');

% Single Value Calibration
fprintf(fileID,'REMORA.sm.cmpt.cal = %i;\n',REMORA.sm.verify.cal.Value);
fprintf(fileID,'REMORA.sm.cmpt.sval = %i;\n',REMORA.sm.verify.sval.Value);
if REMORA.sm.verify.sval.Value == 1
    fprintf(fileID,'REMORA.sm.cmpt.caldb = %s;\n\n',REMORA.sm.verify.caldb.String);
end

% Trasnfer Function Calibration
fprintf(fileID,'REMORA.sm.cmpt.tfval = %i;\n',REMORA.sm.verify.tfval.Value);
if REMORA.sm.verify.tfval.Value == 1
    fprintf(fileID,'REMORA.sm.cmpt.tfile = ''%s'';\n',REMORA.sm.verify.tfile.String);
    fprintf(fileID,'REMORA.sm.cmpt.tpath = ''%s'';\n\n',REMORA.sm.verify.tpath.String);
end

%% Close and rename file
fclose(fileID);

% Rename File to Create M File
movefile(fullfile(filePath,fileTxT),fullfile(filePath,fileName), 'f')

