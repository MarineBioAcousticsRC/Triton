function    cuefname = makecuefile(recdir,prefix,suffix)
%
%    cuefname = makecuefile(recdir,prefix,suffix)
%

cuefname = [] ;
if nargin<3 | isempty(suffix),
   suffix = 'wav' ;
end

[cuetab,fs,fn,recdir,id] = d3getwavcues(recdir,prefix,suffix) ;
if isempty(cuetab)
   return ;
end

cuefname = [recdir '_' prefix suffix 'cues.mat'] ;

% nominate a reference time and refer the cues to this time
ref_time = cuetab(1,2)+cuetab(1,3)*1e-6 ;  % ref time is time of 1st sample in the deployment
ctimes = (cuetab(:,2)-ref_time)+cuetab(:,3)*1e-6 ;
cuetab = [cuetab(:,1) ctimes cuetab(:,4)] ;

vv = version ;
if vv(1)>'6',
   save(cuefname,'-v6','ref_time','fn','fs','id','cuetab','recdir') ;
else
   save(cuefname,'ref_time','fn','fs','id','cuetab','recdir') ;
end

return
