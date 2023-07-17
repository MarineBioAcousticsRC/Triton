function saveker(kerker, fileSuffix, subp, xlim)

kerker = kerker - min(min(kerker));
if (~isstr(fileSuffix)), fileSuffix = num2str(fileSuffix); end
eval(['save kerker' fileSuffix ' kerker']);

subplot(subp);
image(flipud(kerker(1:30,:) * 70)); 
set(gca,'xlim',[1 xlim]);
set(gca,'xcolor',[0 0 0]); set(gca,'xtick',[]);
set(gca,'ycolor',[0 0 0]); set(gca,'ytick',[]);

%colormap([sub(gray(40),  20:-1:1, 1:3); sub(gray(88),88:-1:45,1:3)]);
colormap([sub(gray(117),117:-1:74,1:3); sub(gray(32),20:-1:1, 1:3)]);
