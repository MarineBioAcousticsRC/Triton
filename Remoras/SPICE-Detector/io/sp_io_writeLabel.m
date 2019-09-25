function sp_io_writeLabel(labelFileName, detTimes)

fid = fopen(labelFileName,'w+');
for n = 1:size(detTimes,1)
   fprintf(fid, '%f %f \n', detTimes(n,1), detTimes(n,2));
end
fclose(fid);

fprintf('done with file %s\n',labelFileName);
