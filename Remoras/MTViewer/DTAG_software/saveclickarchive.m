function    saveclickarchive(tag,P)
%
%    saveclickarchive(tag,P)
%

fname = [tag 'click.txt'] ;
f = fopen(fname,'wt') ;
if f<=0,
   fprintf('Error: unable to open file %s\n',fname) ;
   return
end
fprintf(f,'%4.4f\n',P) ;
fclose(f) ;

