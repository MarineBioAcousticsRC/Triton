function    DTAB = delaytab(CL,varargin)
%
%    DTAB = delaytab(CL,D1,D2,...)
%     each Di contains 2 columns [CL,V]
%     DTAB comprises [CL,V1,V2,...]
%     where the Vi entries from each Di are selected
%     that match the input CL.

DTAB = [CL,NaN*ones(length(CL),length(varargin))];
for k=1:length(varargin),
   D = varargin{k} ;
   kk = nearest(CL,D(:,1),0.001);
   kkk = find(~isnan(kk)) ;
   DTAB(kk(kkk),k+1)=D(kkk,2);
end
