function    [Mi,Md,fs] = interpmag(M,mfs,K)
%
%    [M,Md,fs] = interpmag(M,mfs,K)
%     Process D3 magnetometer data to produce a 2xmfs
%     matrix and a dc offset vector.
%     M is a 6-column raw magnetometer matrix sampled at mfs Hz.
%     K is an optional set of cues to bad data at mfs. If K
%     is not specified, all data is used.
%
%     Result:
%     M is a 3-column interpolated magnetometer matrix.
%     Md is a vector of dc offsets for all channels.
%     fs contains [mfs,mdfs] the sampling rates in Hz of M and Md.
%
%     Note: this function is called automatically by d3calmag and
%     so should not normally be used.
%
%     mark johnson
%     30 Jan 2013

Mi = [] ; Md = [] ; fs = [] ;
if nargin<2,
   help interpmag
   return
end

fc = 0.1 ;
df = min(round(mfs/(8*fc)),16) ;

MM = sum(M,2) ;
if nargin==3 & ~isempty(K),
   if K(1)==1,
      kg = find(diff(K)>1,1) ;
      MM(1,:) = MM(kg+1,:) ;
      K = K(2:end) ;
   end
   for k=1:length(K),
      MM(K(k),:) = MM(K(k)-1,:) ;
   end
end

Moffs = decdc(MM,df)/6 ;
fr = fc/(mfs/2/df) ;
Mf = fir_nodelay(Moffs,round(6/fr),fr) ;
Md = reshape(repmat(Mf',df,1),[],1) ;
if size(Md,1)<size(M,1),
   Md(end+(1:size(M,1)-size(Md,1))) = Md(end) ;
end
Z = repmat(Md,1,6) ;
M = M-Z ;
Mi = zeros(size(M,1)*2,3) ;
Mi(:,1) = reshape([M(:,1) -M(:,4)]',[],1) ;
Mi(:,2) = reshape([M(:,2) -M(:,5)]',[],1) ;
Mi(:,3) = reshape([M(:,3) -M(:,6)]',[],1) ;
fs = [2*mfs mfs] ;
return
