function UpdateAxis(ax,newstart,newend)
% function UpdateAxis('xy') UpdateAxis('x') UpdateAxis('y')
% Updates the specified axis of current plot, should be 
%   executed after zooming or scrolling any Aux plot. 
% This function should execute as a ButtonUpFunction when plot window 
%   has been manipulated.
% Warning: this function changes the plot window axes as it coorilates to 
%   the plotted data.  If the time stamps don't seem to match the data, 
%   there is probably a problem with this function!
% Calling datetick sets the TickMode of the specified axis to
%	'manual'. This means that after zooming, panning or otherwise changing
%	axis limits, you should call datetick again to update the ticks and
%	labels (doc datetick). 
%

%
%
% TickLabelInterpreter:     http://www.mathworks.com/help/matlab/ref/axes-properties.html#prop_TickLabelInterpreter
% Axes Properties :         http://www.mathworks.com/help/matlab/ref/axes-properties.html
%  helpful functions
%   datestr()
%   
    % fprintf('function: UpdateAxis(%c)\n',ax);
    
%1. If user is updating the x-axis only and syncing to LTSA
if ~isa(ax,'char')
    ax = 'x' ;
end

    if ax == 'x' && exist('newstart','var') && exist('newend','var')
            global REMORA PARAMS
            %out = REMORA.MT2MAT.out ;
            Ylim = get(gca,'YLim') ;
            
            try
                set(gca,'XLim',[out(newstart,9) out(newend,9)],'YLim',Ylim)
            catch
                set(gca,'XLim',[newstart newend],'YLim',Ylim)
            end
            
            temp = get(gca,'XTick') ; 
            set(gca,'XTickMode','auto')
            set(gca,'XTickLabel',datestr(temp,'HH:MM:SS'))
            %xlabel(datestr(temp(1),'mm/dd/yyyy  HH:MM:SS'))
            xlabel('Time')
        if exist('str','var')
            clear('str')
            str = text('Position',[0 -0.125],'Units','normalized','String',timestr(newstart(1),1));
        else
            str = text('Position',[0 -0.125],'Units','normalized','String',timestr(newstart(1),1));
        end
            
%2. If user is updating the x-axis only
    elseif ax == 'x'
        %update the x axis after being zoomed in function ZoomCurrentPlot
        temp = get(gca,'XTick') ; 
        set(gca,'XTickMode','auto')
        set(gca,'XTickLabel',datestr(temp,'HH:MM:SS'))
            %xlabel(datestr(temp(1),'mm/dd/yyyy  HH:MM:SS'))
        xlabel('Time')
%         ch = get(gca,'Children'); 
%         try
%             xdata = get(ch(end),'XData'); 
%         catch
%             xdata = get(ch,'XData');
%         end
        
%         if exist('str','var')
%             clear('str')
%             str = text('Position',[0 -0.125],'Units','normalized','String',timestr(newstart(1),1));
%             fprintf('%s\n',timestr(newstart(1),1))
%             %text('Position',[0 -0.125],'Units','normalized','String',timestr(newstart(1),1));
%         else
%             str = text('Position',[0 -0.125],'Units','normalized','String',timestr(xdata(1),1));
%             fprintf('%s\n',timestr(xdata(1),1))
%             %text('Position',[0 -0.125],'Units','normalized','String',timestr(xdata(1),1));
%         end


%3. If updating the y-axis only
    elseif ax == 'y'
            %I don't think I actually need this bc y axis doesn't have problems usually
        %update the y axis after being zoomed in function ZoomCurrentPlot
        temp = get(gca,'YTick') ; 
        set(gca,'YTickMode','auto')
        set(gca,'YTickLabel',temp)

%4. If updating both the x-axis and y-axis
    elseif ax == 'xy'
        temp = get(gca,'XTick') ; 
        set(gca,'XTickMode','auto')
        set(gca,'XTickLabel',datestr(temp,'HH:MM:SS'))
        xlabel(datestr(temp(1),'mm/dd/yyyy  HH:MM:SS'))
        temp = get(gca,'YTick') ; 
        set(gca,'YTickMode','auto')
        set(gca,'YTickLabel',temp)

    else
        fprintf('UpdateAxis function did not recognize input')
    end
end