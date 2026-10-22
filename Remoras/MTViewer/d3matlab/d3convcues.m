function    [cue,fs] = d3convcues(cue,recdir,prefix,suffix)
%
%  [cue,fs] = d3convcues(cue,recdir,prefix,suffix)
%     if cue is a column vector it is taken as a time-since-ref_time cue
%        and is converted to a file-second cue.
%     if cue is a 2-column matrix it is taken as a file-second cue
%        and is converted to a time-since-ref_time cue.

% get the cue table
[ct,ref_time,fs,fn,recdir] = d3getcues(recdir,prefix,suffix) ;

if size(cue,2)==2,
   cues = repmat(NaN,size(cue,1),1) ;
   ns = round(cue(:,2)*fs)' ;
   fn = unique(cue(:,1)) ;
   for kf=1:length(fn),
      k = find(ct(:,1)==fn(kf)) ;
      kk = find(cue(:,1)==fn(kf)) ;
      nr = repmat(ns(kk),length(k)+1,1)-repmat([0;cumsum(ct(k,3))],1,length(kk)) ;
      kr = sum(nr>0) ;
      indx = kr+(0:length(kr)-1)*(length(k)+1) ;
      cues(kk) = ct(k(kr),2)+nr(indx)'/fs ;
   end
   cue = cues ;

else
   k = max(find(ct(:,2)<=cue(1))) ;
   if isempty(k),
      fprintf(' Cue is before the start of recording\n') ;
      return
   end

   % find which file the cue comes from and make a cuetable for the file
   fnum = ct(k,1) ;
   kf = find(ct(:,1)==fnum) ;
   csc = [0;cumsum(ct(kf,3))] ;

   % convert cue to samples wrt start of file
   st = round(fs*(cue(1)-ct(k,2)))+csc(k-kf(1)+1) ;
   cue = [fnum,st/fs] ;
end
