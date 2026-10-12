function PlotANNOdata(handles)
% function PlotANNOdata
% Plot the annotations on depth plot.
%
%   MODIFICATION HISTORY:
%   MM/DD/YYYY	INITIALS    Modification details
%   04/10/2016	VEL         Function created.
%   10/14/2021   JAH     MODIFIED FROM PlotMTdata.m
%
currentFolder = pwd ; %Save current directory before running PlotMTdata.m
tt = ' ' ;
sp = ' Tag Data' ;
global Gtable all
if exist('Gtable', 'var') && istable(Gtable)
    updated_start_p = handles.index_newstart_p ;
    updated_end_p = handles.index_newend_p ;

    get(handles.checkbox4,'Value');
    ib = find(Gtable.date >= datetime(all.press(updated_start_p,2),'ConvertFrom','datenum') & ...
        Gtable.date <= datetime(all.press(updated_end_p,2),'ConvertFrom','datenum'));
    % [C,ia,ib] = intersect(all.press(updated_start_p:updated_end_p,2),datenum(Gtable.date));
    axes(handles.axes6)
    %get(handles.axes6)
    hold on
    i1 = find(strcmp(Gtable.dtype(ib), 'exhale'));
    i2 = find(strcmp(Gtable.dtype(ib), 'inhale'));
    i3 = find(strcmp(Gtable.dtype(ib), 'ascent start'));
    i4 = find(strcmp(Gtable.dtype(ib), 'descent end'));
    i5 = find(strcmp(Gtable.dtype(ib), 'fluke'));
    i6 = find(strcmp(Gtable.dtype(ib), 'buzz'));
    i7 = find(strcmp(Gtable.dtype(ib), 'LF click'));
    i8 = find(strcmp(Gtable.dtype(ib), 'HF click'));
    i9 = find(strcmp(Gtable.dtype(ib), 'feeding'));
    i10 = find(strcmp(Gtable.dtype(ib), 'neutral buoyancy up'));
    i11 = find(strcmp(Gtable.dtype(ib), 'neutral buoyancy down'));
    i12 = find(strcmp(Gtable.dtype(ib), 'splash start'));
    i13 = find(strcmp(Gtable.dtype(ib), 'splash end'));
    i14 = find(strcmp(Gtable.dtype(ib), 'tag fell off'));
    i15 = find(strcmp(Gtable.dtype(ib), 'call start'));
    i16 = find(strcmp(Gtable.dtype(ib), 'call end'));

    plot(datenum(Gtable.date(ib(i1))),Gtable.depth(ib(i1)),'.r','MarkerSize',30) ;
    plot(datenum(Gtable.date(ib(i2))),Gtable.depth(ib(i2)),'.g','MarkerSize',30) ;
    plot(datenum(Gtable.date(ib(i3))),Gtable.depth(ib(i3)),'xr','MarkerSize',20,...
        'LineWidth',2) ;
    plot(datenum(Gtable.date(ib(i4))),Gtable.depth(ib(i4)),'xg','MarkerSize',20,...
        'LineWidth',2) ;
    plot(datenum(Gtable.date(ib(i5))),Gtable.depth(ib(i5)),'+b','MarkerSize',10,...
        'LineWidth',2) ;
    plot(datenum(Gtable.date(ib(i6))),Gtable.depth(ib(i6)),'og','MarkerSize',10,...
        'LineWidth',2) ;
    plot(datenum(Gtable.date(ib(i7))),Gtable.depth(ib(i7)),'or','MarkerSize',10,...
        'LineWidth',2) ;
    plot(datenum(Gtable.date(ib(i8))),Gtable.depth(ib(i8)),'ok','MarkerSize',10,...
        'LineWidth',2) ;
    plot(datenum(Gtable.date(ib(i9))),Gtable.depth(ib(i9)),'ok','MarkerSize',10,...
        'LineWidth',2) ;
    plot(datenum(Gtable.date(ib(i10))),Gtable.depth(ib(i10)),'ob','MarkerSize',10,...
        'LineWidth',2) ;
    plot(datenum(Gtable.date(ib(i11))),Gtable.depth(ib(i11)),'ob','MarkerSize',10,...
        'LineWidth',2) ;
    plot(datenum(Gtable.date(ib(i12))),Gtable.depth(ib(i12)),'+g','MarkerSize',10,...
        'LineWidth',2) ;
    plot(datenum(Gtable.date(ib(i13))),Gtable.depth(ib(i13)),'+r','MarkerSize',10,...
        'LineWidth',2) ;
    plot(datenum(Gtable.date(ib(i14))),Gtable.depth(ib(i14)),'*r','MarkerSize',10,...
        'LineWidth',2) ;
    plot(datenum(Gtable.date(ib(i15))),Gtable.depth(ib(i15)),'^g','MarkerSize',10,...
        'LineWidth',2) ;
    plot(datenum(Gtable.date(ib(i16))),Gtable.depth(ib(i16)),'^r','MarkerSize',10,...
        'LineWidth',2) ;
    cd(currentFolder) %Change directory back to original folder.
else
    disp('No annotations loaded')
end
end
