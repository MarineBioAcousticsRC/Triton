function visWeeklyPlotv2(data,granularity,varargin)

%   Weekly Plotting
%   This function depends on
%   plots - the structure containing  plot info
%   data - the plot data
%   project - name of Project as string

vidx=1;
years = [];
first_day=0;
last_day=0;
sub_plot=false;

switch granularity
    case 'call'
        title_lt = 'Total Detections per Week';
    otherwise
        title_lt = 'Cumulative Hours per Week';
end

title_rt = 'Percentage of Effort per Week';
        

while vidx <= length(varargin)
    switch varargin{vidx}
        case 'Axis'
            ax = varargin{vidx+1};
            vidx=vidx+2;
        case 'Years'
            years = varargin{vidx+1};
            vidx=vidx+2;
        case 'First'
            first_day = varargin{vidx+1};
            vidx = vidx+2;
        case 'Last'
            last_day = varargin{vidx+1};
            sub_plot=false;
            vidx=vidx+2;
        otherwise
            error('Bad arugment:  %s', varargin{vidx});
            return;
    end
end


xstep_length = 1;
xstep_unit = 'month';

useOffEffortBars = 1;
useNormalizedData = 1;
offeffortcolor = [205 201 201]/255;



currentdata = data.plot_days;
if ~first_day && ~last_day
    first_day = currentdata(1,1);
    last_day = currentdata(end,1);
end



current_day = first_day;

% Adjust so the month tick is at the beginning of the calender month,
% not with respect to when the data collection began.
[Y, M, D, H, MN, S] = datevec(current_day);
current_day = addtodate(current_day, -D + 1,'day');
xtick = [current_day];
while (last_day > current_day)
    xtick = [xtick addtodate(current_day, xstep_length, xstep_unit)];
    current_day = addtodate(current_day, xstep_length, xstep_unit);
end

set(gca,'XTickLabelMode','manual')
set(gca,'XTickLabel', datestr(xtick,'mmmyy'))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if useNormalizedData
label = '';
fun1 = @(x,y)bar(x,y,1,'FaceColor',[0 0 0]);
fun2 = @(x,y)plot(x,y,'k.','MarkerSize',20,'Color',[0.5 0.5 0.5]);
t = [];

t = data.week(:,1);
y = data.cum_hrs(:,1);
e = data.pcnt_eff(:,1);
t2 = t; e2 = e;
for i = size(e,1):-1:1
    % don't plot cases in which there is 0 or 100% effort
    if e(i) <= 0 || e(i) >= 100
        e2(i) = [];
        t2(i) = [];
    end
end

[AX,H1,H2] = plotyy(t+3.5,y,t2+3.5,e2,fun1,fun2);
if ~useNormalizedData
    delete(AX(2))
end

%Modify Cum. hrs/wk scale
%MaxY is upper 10th decimal place of maximum detected hours
%HalfY is half of that value
if data.maxY==0
    data.maxY=1;
end
maxY = data.maxY;
minY = 0; 
if maxY<1
    maxY= ceil(maxY*10)/10;
else
    %just pad another 20%
    maxY = ceil(maxY * 1.20);
end
halfY = maxY/2;

if useOffEffortBars
    for i = 1:size(t,1)
        if e(i) == 0
            %tmp1 = get(gca,'YTick');
            %tmp2 = get(gca,'YLabel');
            %tmp3 = get(gca,'YLim');
            
            xmin = t(i);
            %tmp = min(i+1,size(t,1));
            %xmax = t(tmp);
            ymin = 0;
            %ymax = tmp3(2);
            if i == size(t,1)
                %h = fill([xmin last_day last_day xmin],[ymin ymin maxY maxY],offeffortcolor);
                h = patch([xmin last_day last_day xmin],[ymin ymin maxY maxY],...
                    offeffortcolor, 'LineStyle', 'None');
            else
                %h = fill([xmin xmax xmax xmin],[ymin ymin maxY maxY],offeffortcolor);
                h = patch([xmin xmin+7 xmin+7 xmin],[ymin ymin maxY maxY],...
                    offeffortcolor, 'LineStyle', 'None');
            end
            set(h,'EdgeColor','None');
        end
    end
end
%  uistack(h,'bottom')
set(AX(1),'Layer','top')

% Set parameters
if useNormalizedData    
    set(AX(2),'YColor',[0 0 0])
    set(AX(2),'Xlim',[first_day last_day]);
    set(AX(2),'XTick',xtick);
    set(AX(2),'XTickLabel','');
    %tmp = get(AX(2),'Ylim');
    set(AX(2),'Ylim',[0 100],'YTick',[0 50 100],'FontSize',12);
    if ~sub_plot || length(years) ==1
        ylabel(AX(2),title_rt,'FontSize',12);
    end
end

%    set(AX(1), 'Title', text('String',speciesname{n}))
set(AX(1),'XTick', xtick);

set(AX(1),'Xlim',[first_day last_day],'YLim',[minY maxY],'YTick',...
    [minY halfY maxY],'FontSize',11,'XTickLabel', datestr(xtick,'mmmyy'));
if ~sub_plot || length(years) == 1 
    ylabel(AX(1),title_lt,'FontSize',12);
end

