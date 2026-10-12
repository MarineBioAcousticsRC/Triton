function    subplot_zoom(xlim)
%
%    subplot_zoom(xlim)
%     Adjust the time axis on all plots in a multi-panel figure (i.e.,
%     a figure created using subplot() or axes().
%     Example:
%     subplot_zoom   adjust the time axes to match that of the last
%                    plot created or zoomed.
%     subplot([1,2]) adjust the time axes of all plots to [1,2].
%
%     markjohnson@st-andrews.ac.uk
%     feb 2014

if nargin==0,
   xlim = get(gca,'XLim') ;
end

ylim = get(gca,'YLim') ;
ax = get(gcf,'Children') ;
k = strcmp(get(ax,'Type'),'axes') ;
set(ax(k),'XLim',xlim)
set(ax(k),'YLimMode','auto')
set(gca,'YLim',ylim) ;
