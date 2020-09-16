function PlotMTdata(handles)
% function PlotMTdata(out = nx8 matrix of auxillery data ,strt = datevector of start time)
% Plot the depth, time, compass and acceleration for MT data.
%
%  INPUTS:
%           out        An nx8 matrix of auxillery data
%           strt	   A datevector of start time
%
% OUTPUTS:
%           four plots
%
%
%   MODIFICATION HISTORY:
%   MM/DD/YYYY	INITIALS    Modification details
%   04/10/2016	VEL         Function created. 
%
%
%% USEFUL NOTES:
%     1. initializing the figure settings for Plot - Triton example:
%     HANDLES.fig.main = figure( ...
%     'NumberTitle','off', ...
%     'Name',['Plot - Triton '], ...
%     'Units','normalized',...
%     'Position',defaultPos{1});
%
%  Note: Calling datetick sets the TickMode of the specified axis to
%  'manual'. This means that after zooming, panning or otherwise changing
%  axis limits, you should call datetick again to update the ticks and
%  labels (doc datetick).  This is the purpose of the function
%  UpdateAxis(ax), to ensure that the axis which has just been zoomed or
%  scrolled has also been updated.  This function should execute as a
%  ButtonUp
%
%% open and setup figure window
% global REMORA
%
% 1. Get data info from user
    % Hard-coding for debugging purposes.  Usually this is a user input!
%     prompt1={'Enter tag id'};
%     inl = inputdlg(prompt1);
%     tt = (inl{1});

currentFolder = pwd ; %Save current directory before running PlotMTdata.m
tt = 'B013' ;
sp = 'Bryde''s Whale' ;
global all 
if (get(handles.pushbutton2,'Value')||get(handles.checkbox1,'Value'))
    
    updated_start_p = handles.index_newstart_p ;
    updated_end_p = handles.index_newend_p ;
    
    updated_start_t = handles.index_newstart_t ;
    updated_end_t = handles.index_newend_t ;
    
    updated_start_x = handles.index_newstart_x ;
    updated_end_x = handles.index_newend_x ;
    
    updated_start_i = handles.index_newstart_i ;
    updated_end_i = handles.index_newend_i ;
    
    updated_start_s = handles.index_newstart_s;
    updated_end_s = handles.index_newend_s;
    
    axes(handles.axes6)
        cla
        %get(handles.axes6)
        plot(all.press(updated_start_p:updated_end_p,end),all.press(updated_start_p:updated_end_p,1),'b') ;
        axis tight
        axis ij
        UpdateAxis('x')
        axis ij; 
        ylabel('Depth [m]');
        set(gca, 'XColor','k','YColor','k') ;
        titl = sprintf('%s %s %s %s',sp, tt, datestr(handles.strt)) ;
        title(titl) ;
        set(gca,'XTick',[],'FontSize',9,'Tag','Depth','NextPlot','add')
        xlabel('')
    axes(handles.axes7)
        cla
        plot(all.temp(updated_start_t:updated_end_t,end),all.temp(updated_start_t:updated_end_t,1),'b');  
        axis tight
        UpdateAxis('x')
        ylabel('Temperature [C]');
        set(gca, 'XColor','k','YColor','k') ;
        set(gca,'XTick',[],'Tag','Temp','NextPlot','add')
        xlabel('')
    axes(handles.axes8)
        cla
        plot(all.xaccel(updated_start_x:updated_end_x,end),all.xaccel(updated_start_x:updated_end_x,1),':r'); axis tight; hold on;
        plot(all.yaccel(updated_start_x:updated_end_x,end),all.yaccel(updated_start_x:updated_end_x,1),':m'); axis tight; 
        plot(all.zaccel(updated_start_x:updated_end_x,end),all.zaccel(updated_start_x:updated_end_x,1),':c'); axis tight; 
        UpdateAxis('x')
        set(gca, 'XColor','k','YColor','k');
        ylabel('Compass [nT]');
        set(gca,'XTick',[],'Tag','Compass XYZ','NextPlot','add')
        xlabel('')
%         if get(handles.checkbox3,'Value') && ~get(handles.checkbox1,'Value')
%             legend('X','Y','Z','Location','northwest')
%         else
%             legend('hide')
%         end
    axes(handles.axes9)
        cla
        plot(all.iaccel(updated_start_i:updated_end_i,end),all.iaccel(updated_start_i:updated_end_i,1),':r'); axis tight; hold on;
        plot(all.jaccel(updated_start_i:updated_end_i,end),all.jaccel(updated_start_i:updated_end_i,1),':m'); axis tight;
        plot(all.kaccel(updated_start_i:updated_end_i,end),all.kaccel(updated_start_i:updated_end_i,1),':c'); axis tight;
        UpdateAxis('x')
        set(gca, 'XColor','k','YColor','k','FontSize',9,'Tag','Acceleration IJK','NextPlot','add');
        ylabel('Acceleration [mGal]');
%         if get(handles.checkbox3,'Value') && ~get(handles.checkbox1,'Value')
%             legend('I','J','K','Location','northwest')
%         else
%             legend('hide')
%         end
       axes(handles.axes10)
        cla
        plot(all.speed.JJ(updated_start_s:updated_end_s,end),all.speed.JJ(updated_start_s:updated_end_s,1),':b'); axis tight;
        UpdateAxis('x')
        set(gca, 'XTick',[],'Tag','Speed','NextPlot','add');
        ylabel('Speed [m/s]');
%         if get(handles.checkbox3,'Value') && ~get(handles.checkbox1,'Value')
%             legend('I','J','K','Location','northwest')
%         else
%             legend('hide')
%         end
else
    axes(handles.axes6)
        %get(handles.axes6) ;
        cla
        plot(all.press(:,end),-1*all.press(:,1),'b') ;
        axis ij
        axis tight
        UpdateAxis('x')
        axis ij; 
        ylabel('Depth [m]');
        set(gca, 'XColor','k','YColor','k') ;
        titl = sprintf('%s %s %s %s',sp, tt, datestr(handles.strt)) ;
        title(titl) ;
        set(gca,'XTick',[],'FontSize',9,'Tag','Depth','NextPlot','add')
        xlabel('')
    axes(handles.axes7)
        cla
        plot(all.temp(:,end),all.temp(:,1),'b'); 
        axis tight
        UpdateAxis('x')
        ylabel('Temperature [C]');
        set(gca,'XColor','k','YColor','k') ;
        set(gca,'XTick',[],'Tag','Temp','NextPlot','add')
        xlabel('')
    axes(handles.axes8)
        cla
        plot(all.xaccel(:,end),all.xaccel(:,1),':r'); axis tight; hold on;
        plot(all.yaccel(:,end),all.yaccel(:,1),':m'); axis tight
        plot(all.zaccel(:,end),all.zaccel(:,1),':c'); axis tight
        UpdateAxis('x')
        set(gca, 'XColor','k','YColor','k');
        ylabel('Compass [nT]');
        set(gca,'XTick',[],'Tag','Compass XYZ','NextPlot','add')
        xlabel('')
    axes(handles.axes9)
        cla
        plot(all.iaccel(:,end),all.iaccel(:,1),':r'); axis tight; hold on;
        plot(all.jaccel(:,end),all.jaccel(:,1),':m'); axis tight
        plot(all.kaccel(:,end),all.kaccel(:,1),':c'); axis tight
        UpdateAxis('x')
        set(gca, 'XColor','k','YColor','k','FontSize',9,'Tag','Acceleration IJK','NextPlot','add');
        ylabel('Acceleration [mGal]');
    axes(handles.axes10)
        cla
        plot(all.speed.JJ(updated_start_s:updated_end_s,end),all.speed.JJ(updated_start_s:updated_end_s,1),':b'); axis tight;
        UpdateAxis('x')
        set(gca, 'XTick',[],'Tag','Speed','NextPlot','add');
        ylabel('Speed [m/s]');
end





% %     prompt1={'Species'};
% %     inl = inputdlg(prompt1);
% %     sp = (inl{1});
%     
% % 2. Plot Depth (Pressure) Data 
%     close(findobj('type','figure','name','Aux Depth'))
%     
%     fig1 = figure('NumberTitle','off', ...
%      'Name',['Aux Depth'],...
%      'Position',[538 48 1050 270]);
%     figure(fig1)
%     
%     plot(out(:,9), out(:,1)) ;
%     axis tight
%     UpdateAxis('x')
% %     set(fig1,'menubar','none')
%     axis ij; 
%     ylabel('Depth (m)');
%     set(gca, 'XColor','k','YColor','b') ;
%     titl = sprintf('%s %s %s %s',sp, tt, datestr(strt)) ;
%     title(titl) ;
% %     text('Position',[0 -0.125],'Units','normalized',...
% %     'String',timestr(strt,1));
%     REMORA.TritonMTViewer.fig.depth = fig1 ;
%     
% % 3. Plot Temperature data
%     close(findobj('type','figure','name',['Aux Temperature']))
%     
%     fig2 = figure('NumberTitle','off', ...
%      'Name',['Aux Temperature'],...
%      'Position',[538 48 1050 270]);  
%     figure(fig2)
%  
%     plot(out(:,9), out(:,2));  
%     axis tight
%     UpdateAxis('x')
% %     set(fig2,'menubar','none')
%     ylabel('Temperature (?)');
%     set(gca, 'XColor','k','YColor','b') ;
%     titl = sprintf('%s %s %s %s',sp, tt, datestr(strt));
%     title(titl) ;
%     REMORA.TritonMTViewer.fig.temp = fig2 ;
% 
% % 4. Plot Compass Data (XYZ)
%     close(findobj('type','figure','name',['Aux Compass']))
%     
%     subplot = 0 ;
%     
%     fig3 = figure('NumberTitle','off', ...
%      'Name',['Aux Compass'],...
%      'Position',[538 48 1050 270],...
%      'NextPlot','replacechildren'); 
%     figure(fig3)
%     
%     % if subplots are wanted for compass 
%     if subplot == 1
%         subplot(4,1,1); 
%         plot(out(:,9), out(:,3),':r');
%         axis tight
%         UpdateAxis('x')
% %         set(fig3,'menubar','none')
%         set(gca, 'XColor','k','YColor','r','XTick',[]);
%         titl = sprintf('%s %s %s %s',sp, tt, datestr(strt));
%         title(titl) ;
%         ylabel('X');
% 
%         subplot(4,1,2); 
%         plot(out(:,9),out(:,4),':m');
%         axis tight
%         UpdateAxis('x')
%         set(gca, 'XColor','k','YColor','m','XTick',[]);
%         ylabel('Y');
% 
%         subplot(4,1,3); plot(out(:,9),out(:,5),':c');
%         axis tight
%         UpdateAxis('x')
%         set(gca, 'XColor','k','YColor','c','XTick',[]);
%         ylabel('Z');
% 
%         subplot(4,1,4); 
%         plot(out(:,9),out(:,3),':r'); axis tight; hold on;
%         plot(out(:,9),out(:,4),':m'); axis tight
%         plot(out(:,9),out(:,5),':c'); axis tight
%         UpdateAxis('x')
%         set(gca, 'XColor','k','YColor','b');
%         % xlabel(datestr(strt))
%     else
%         plot(out(:,9),out(:,3),':r'); axis tight; hold on;
%         plot(out(:,9),out(:,4),':m'); axis tight
%         plot(out(:,9),out(:,5),':c'); axis tight
%         UpdateAxis('x')
% %         set(fig3,'menubar','none')
%         set(gca, 'XColor','k','YColor','b');
%         ylabel('X Y Z')
%         %xlabel(datestr(strt))
%         title(titl) ;
%     end
%     REMORA.TritonMTViewer.fig.compass = fig3 ;
%     
% % 5. Plot Acceleration Data (IJK)
%     close(findobj('type','figure','name',['Aux Acceleration']))
%      
%     fig4 = figure('NumberTitle','off', ...
%      'Name',['Aux Acceleration'],...
%      'Position',[538 48 1050 270],...
%      'NextPlot','replacechildren');
%     figure(fig4)
%  
%     % if subplots are wanted for acceleration
%     if subplot == 1
%         subplot(4,1,1); plot(out(:,9),out(:,6),':r');
%         axis tight
%         UpdateAxis('x')
% %         set(fig4,'menubar','none')
%         set(gca, 'XColor','k','YColor','r','XTick',[]);
%         titl = sprintf('%s %s %s %s',sp, tt, datestr(strt));
%         title(titl) ;
%         ylabel('I');
% 
%         subplot(4,1,2); plot(out(:,9),out(:,7),':m');
%         axis tight
%         UpdateAxis('x')
%         set(gca, 'XColor','k','YColor','m','XTick',[]);
%         ylabel('J');
% 
%         subplot(4,1,3); plot(out(:,9),out(:,8),':c');
%         axis tight
%         UpdateAxis('x')
%         set(gca, 'XColor','k','YColor','c','XTick',[]);
%         ylabel('K');
% 
%         subplot(4,1,4); 
%         plot(out(:,9),out(:,6),':r'); axis tight; hold on;
%         plot(out(:,9),out(:,7),':m'); axis tight
%         plot(out(:,9),out(:,8),':c'); axis tight
%         UpdateAxis('x')
%         set(gca, 'XColor','k','YColor','b');
%         %xlabel(datestr(strt))
%     else
%         plot(out(:,9),out(:,6),':r'); axis tight; hold on;
%         plot(out(:,9),out(:,7),':m'); axis tight;
%         plot(out(:,9),out(:,8),':c'); axis tight;
%         UpdateAxis('x')
% %         set(fig4,'menubar','none')
%         set(gca, 'XColor','k','YColor','b');
%         ylabel('I J K') ;
%         %xlabel(datestr(strt)) ;
%         title(titl) ;
%     end  
%     REMORA.TritonMTViewer.fig.accel = fig4 ;
%     
% %     fprintf('SYNC THE TICK LABELS!\n\tFigure(1); size(get(gca,'XTickLabel'))\n')


cd(currentFolder) %Change directory back to original folder.
end
