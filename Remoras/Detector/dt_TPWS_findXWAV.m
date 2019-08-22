function fullFileNames = dt_TPWS_findXWAV(p,detFiles)

fullFileNames = cell(size(detFiles)); 

for f = 1: size(detFiles,1)
   thisFile = detFiles{f,1};
   [~,name,~] = fileparts(thisFile);
   recFile = fn_subdir(fullfile(p.recDir,[name,p.recFileExt]));
   if isempty(recFile)
       error('File (%s) not found',fullfile(p.recDir,[name,p.recFileExt]))
   end
   fullFileNames{f} = recFile.name;
end
