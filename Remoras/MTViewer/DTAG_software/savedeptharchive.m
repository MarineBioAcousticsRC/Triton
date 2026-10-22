function    savedeptharchive(tag,P,fs)
%
%    savedeptharchive(tag,P,fs)
%

fname = [tag 'depth.txt'] ;
f = fopen(fname,'wt') ;
if f<=0,
   fprintf('Error: unable to open file %s\n',fname) ;
   return
end

P = decdc(P,fs) ;
fprintf(f,'%4.1f\n',P) ;
fclose(f) ;

