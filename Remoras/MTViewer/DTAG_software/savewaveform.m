function    savewaveform(fname,V,fs)
%
%    savewaveform(fname,V,fs)
%

f = fopen(fname,'wt') ;
if f<=0,
   fprintf('Error: unable to open file %s\n',fname) ;
   return
end
fprintf(f,'Start:,1,\n') ;
fprintf(f,'Length:,%d,\n',length(V)) ;
fprintf(f,'Sample Rate:,+%1.6E,\n',fs) ;
fprintf(f,'%d,\n',round(32767*V)) ;
fclose(f) ;

