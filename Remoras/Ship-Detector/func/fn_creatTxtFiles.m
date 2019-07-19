function fn_creatTxtFiles(fnames,settings)
% Create files in output direcotry

for i = 1:length(fnames)
    wavName = fnames{i};
    outFileName = regexprep(wavName, settings.REWavExt, settings.RELtsaExt);
    fidOut = fopen(fullfile(settings.outpath,outFileName),'w');
    fclose(fidOut);
end