function [bas]=NED_normalize(spc, iexp1, iexp2)

[sz1,sz2]=size(spc);
u=spc./(ones(sz1,1)*sum(spc.^2).^(1/2));
y=spc./(sum(spc'.^2).^(1/2)'*ones(1,sz2));
bas=abs(u).^(iexp1).*abs(y).^(iexp2); 