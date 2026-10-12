function    savetextarchive(tag,P,A,M)
%
%    savetextarchive(tag,P,A,M)
%

fname = [tag 'pam.txt'] ;
f = fopen(fname,'wt') ;
if f<=0,
   fprintf('Error: unable to open file %s\n',fname) ;
   return
end

P = [P,A,M] ;
fprintf(f,'%4.3f, %1.5f, %1.5f, %1.5f, %2.4f, %2.4f, %2.4f\n',P') ;
fclose(f) ;

