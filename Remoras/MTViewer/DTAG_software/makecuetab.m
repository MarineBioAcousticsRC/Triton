function       [N,chips,chnk] = makecuetab(tag,chips)
%
%      [N,chips,chnk] = makecuetab(tag,[chips])
%      Find all chips for a tag deployment and read the log (.txt) file
%      for each chip. Timing information is summarized in the output
%      matrix N. The chips read are returned in vector 'chips'. Optional
%      input argument chips specifies which chips to read.
%      Columns of N are [chip,audio_log,sensor_log]
%      where each log contains [pps_at_start,nsamples,err,fs,compression].
%      Optional output argument, chnk, returns the values from the
%      concatenated input files as a mx6 matrix. Columns of chnk are:
%      [id,config,bytes,samples,kpps,error].
%
%      mark johnson, WHOI
%      majohnson@whoi.edu
%      last modified: 19 Dec. 2006
%           improved memory management for chunks

N = [] ; chnk = [] ;
NCHUNKTYPES = 2 ;

if nargin<2,
   chips = [] ;
end

if nargin<1,
   help makecuetab
   return
end

[fnames,chips,ndigits] = makefnames(tag,'LOG',chips) ;
if isempty(fnames),
   fprintf(' Unable to find any files with names like:\n %s\n',...
         makefname(tag,'LOG',1)) ;
   fprintf(' Check that the tag AUDIO path is correct using gettagpath') ;
   return
end

N = zeros(length(chips),11) ;
c = zeros(length(chips)) ;
last = -1*ones(NCHUNKTYPES,6) ;
terrors = zeros(NCHUNKTYPES,1) ;
lastk = 0 ;

for k=1:length(chips),
   fprintf('\nReading %s\n', fnames{k}) ;
   [log,ch,tterrors,last] = tag2log(fnames{k},last) ;
   terrors = terrors+tterrors ;
   N(k,:) = [chips(k) reshape(log,1,10)] ;
      
   if nargout>2,
      if isempty(chnk),       % allocate some space for chnk
         chnk = NaN*zeros(length(chips)*size(ch,1),size(ch,2)) ;
      end
      chnk(lastk+(1:size(ch,1)),:) = ch ;
      lastk = lastk+size(ch,1) ;
   end
end

if nargout>2,
   k = min(find(isnan(chnk(:,1)))) ;
   if k>1,
      chnk = chnk(1:k-1,:) ;
   end
end

if length(chips)>1,
   fprintf('\nSUMMARY\n') ;
   fprintf('  AUDIO module reports:\n') ;
   fprintf('  overall average sampling rate\t\t\t%6.3f\n', mean(N(:,5))) ;
   fprintf('  overall average compression factor\t%4.3f\n', mean(N(:,6))) ;
   fprintf('  total chunk errors\t\t\t\t\t%d\n', sum(N(:,4))) ;
   fprintf('  total timing errors\t\t\t\t\t%d\n', terrors(1)) ;
   
   fprintf('\nSENSOR module reports:\n') ;
   fprintf('  overall average sampling rate\t\t\t%6.3f\n', mean(N(:,10))) ;
   fprintf('  total chunk errors\t\t\t\t\t%d\n', sum(N(:,9))) ;
   fprintf('  total timing errors\t\t\t\t\t%d\n', terrors(2)) ;
end

N = struct('N',N,'ndigits',ndigits) ;
return


function   [log,chnk,terrors,last] = tag2log(fname,last)
%
%     [log,chnk] = tag2log(fname)
%     where columns of log are [AUDIO,SENSOR]
%           rows of log are [pps_at_start,nsamples,err,fs,compression]
%

chnk = [] ; n = [0 0] ; err = n ; fs = n ; compr = n ; t = n ;
terrors = [0;0] ;

f = fopen(fname,'r') ;
if f<=0,
   fprintf('Unable to find file %s\n', fname) ;
   return ;
end

done = 0 ;
while done==0,
   l = fgetl(f) ;
   done = isempty(l) ;
   if ~done,
      fprintf('%s\n',l) ;
  end
end

fclose(f) ;
chnk = load(fname,'-ascii') ;

% get audio chunks
fprintf('AUDIO module reports:\n') ;
k = find((chnk(:,1)==16 | chnk(:,1)==48) & chnk(:,2)~=1 & chnk(:,6)==0) ;
terrors(1) = findtimingerrors(chnk(k,:),last(1,:)) ;
last(1,:) = chnk(k(end),:) ;
t(1) = chnk(k(1),5)/1000 ;
n(1) = sum(chnk(k,4)) ;
err(1) = length(find((chnk(:,1)==16 | chnk(:,1)==48) & chnk(:,6)~=0)) ;
fchunks = length(find((chnk(:,1)==16 | chnk(:,1)==48) & chnk(:,2)==4)) ;
fs(1) = 1000*mean(chnk(k(1:end-1),4))/mean(diff(chnk(k,5))) ;
compr(1) = 2*mean(chnk(k,4))/mean(chnk(k,3)) ;
fprintf('  average sampling rate\t\t\t%6.3f\n', fs(1)) ;
fprintf('  average compression factor\t%4.3f\n', compr(1)) ;
fprintf('  chunk errors\t\t\t\t\t%d\n', err(1)) ;
fprintf('  number of fill chunks\t\t\t%d\n', fchunks) ;

% get sensor chunks
fprintf('SENSOR module reports:\n') ;
k = find(chnk(:,1)==32 & chnk(:,2)~=1 & chnk(:,6)==0) ;
terrors(2) = findtimingerrors(chnk(k,:),last(2,:)) ;
last(2,:) = chnk(k(end),:) ;
t(2) = chnk(k(1),5)/1000 ;
n(2) = sum(chnk(k,4)) ;
err(2) = length(find(chnk(:,1)==32 & chnk(:,6)~=0)) ;
fchunks = length(find(chnk(:,1)==32 & chnk(:,2)==4)) ;
fs(2) = 1000*mean(chnk(k(1:end-1),4))/mean(diff(chnk(k,5))) ;
compr(2) = 1 ;
fprintf('  average sampling rate\t\t\t%5.3f\n', fs(2)) ;
fprintf('  chunk errors\t\t\t\t\t%d\n', err(2)) ;
fprintf('  number of fill chunks\t\t\t%d\n', fchunks) ;

log = [t;n;err;fs;compr] ;



function    nbad = findtimingerrors(ca,last)
%
%
%

if last(1) ~= -1,
   ca = [last;ca] ;
end

% compute mean sampling period per sample
mp = mean(diff(ca(:,5)))/mean(ca(:,4)) ;

% look for holes in the data greater than 2ms (i.e., 2x resolution of kpps)
h = diff(ca(:,5)) - mp*ca(1:end-1,4) ;

nneg = length(find(h < -2)) ;
if nneg>0,
   fprintf('  Out of sequence chunks or chunks with header error: %i\n', nneg) ;
end

k = find([0;h]>=-2) ;
h = diff(ca(k,5)) - mp*ca(k(1:end-1),4) ;
kbad = find(h > 2) ;
nbad = length(kbad) ;

if nbad>0,
   for k=kbad,
      fprintf('  TIMING ERROR: approx. %i samples missing\n',round(h(kbad)/mp)) ;
   end
end

nbad = nbad+nneg ;
return


