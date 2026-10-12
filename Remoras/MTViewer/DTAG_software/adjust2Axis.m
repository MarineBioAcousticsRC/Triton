function [y,tx,ty]=adjust2Axis(x)

%   [y,tx,ty]=adjust2Axis(x)
%   Reshape matrix to fit to axis
%   WMXZ August 2004
%   THIS FUNCTION IS CALLED BY OTHER FUNCTIONS IN THE TAG TOOLBOX

adim=get(gcf,'position').*get(gca,'position');
aw=floor(adim(3));
ah=floor(adim(3));
sz1=size(x);
if aw<sz1(2)
    d1=ceil(sz1(2)/aw);
    z1=mod(sz1(2),d1);
    if z1>0,z1=d1-z1;end
    xx=[x,zeros(sz1(1),z1)];
    xx=squeeze(max(reshape(xx',d1,[],sz1(1))))';
else
    xx=x;
end
sz2=size(xx);
if ah<sz2(1)
    d2=ceil(sz2(1)/ah);
    z2=mod(sz2(1),d2);
    if z2>0,z2=d2-z2;end
    xx=[xx;zeros(z2,sz2(2))];
    xx=squeeze(max(reshape(xx,d2,[],sz2(2))));
end
y=xx;
tx=(1:aw)/aw*sz1(2);
ty=(1:ah)/ah*sz1(1);

