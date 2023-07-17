function sh_create_settings_file(s,fileName,filePath) 
    
fileTxT = strrep(fileName,'.m','.txt');
fileID = fopen(fullfile(filePath,fileTxT),'w');

% Edit text files
fprintf(fileID,'%% Settings script for ship_detector\n\n');

fprintf(fileID,'settings.outDir = '''';\n');
if ~isnumeric(s.tfFullFile)
    isNum = ~isnan(str2double(s.tfFullFile));
    if isNum
      s.tfFullFile = str2double(s.tfFullFile);
    end
end
if ischar(s.tfFullFile) && ~isempty(s.tfFullFile)
    fprintf(fileID,'settings.tfFullFile = ''%s'';\n\n',s.tfFullFile);
elseif isnumeric(s.tfFullFile)
    fprintf(fileID,'settings.tfFullFile = %s;\n\n',num2str(s.tfFullFile));
else
    fprintf(fileID,'settings.tfFullFile = '''';\n\n');
end


% fprintf(fileID,'settings.REWavExt = ''(\.x)?\.wav'';\n\n');
fprintf(fileID,'%% DETECTOR PARAMETERS \n\n');

fprintf(fileID,'settings.lowBand = [%s,%s];\n', num2str(s.lowBand(1)),num2str(s.lowBand(2)));
fprintf(fileID,'settings.mediumBand = [%s,%s];\n', num2str(s.mediumBand(1)),num2str(s.mediumBand(2)));
fprintf(fileID,'settings.highBand = [%s,%s];\n\n', num2str(s.highBand(1)),num2str(s.highBand(2)));

fprintf(fileID,'settings.thrClose = %s;\n', num2str(s.thrClose));
fprintf(fileID,'settings.thrDistant = %s;\n', num2str(s.thrDistant));
fprintf(fileID,'settings.thrRL = %s;\n', num2str(s.thrRL));
fprintf(fileID,'settings.minPassage = %s;\n', num2str(s.minPassage / (60*60)));
fprintf(fileID,'settings.buffer = %s;\n\n', num2str(s.buffer / 60));

fprintf(fileID,'settings.durWind = %s;\n', num2str(s.durWind / (60*60)));
fprintf(fileID,'settings.slide = %s;\n', num2str(s.slide / (60*60)));
fprintf(fileID,'settings.errorRange = %s;\n\n', num2str(s.errorRange));

fprintf(fileID,'settings.diskWrite = %s;\n', mat2str(s.diskWrite));
fprintf(fileID,'settings.dutyCycle = %s;\n', mat2str(s.dutyCycle));
fprintf(fileID,'settings.saveLabels = true;\n\n');

fclose(fileID);

% Rename File to Create M File
movefile(fullfile(filePath,fileTxT),fullfile(filePath,fileName), 'f')
