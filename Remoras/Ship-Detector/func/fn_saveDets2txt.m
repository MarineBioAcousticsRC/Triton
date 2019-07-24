function fn_saveDets2txt(detection,label,ifiles,fnames,settings)
% Write annotations to .s file

wavName = fnames{ifiles};
outFileName = regexprep(wavName, settings.REWavExt, settings.RELtsaExt);
fidOut = fopen(fullfile(settings.outpath,outFileName),'w+');
fprintf(fidOut, '%f %f %s\n', detection(1),detection(2),label);
fclose(fidOut);
