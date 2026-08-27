function plot_AGM_YPR_260220(iffns)

%%% plot processed imu data ( plots ripped off from KLLs scripts )
%%% made from splitting up IMU_eval_YYMMDD.m
%%%
%%% expects mat files made by IMU_2_euler_251104.m
%%%
%%% BJT 
%%% 251105
%%%
%%% added plot saving bits back in 
%%% 
%%% BJT 
%%% 251214
%%%
%%% made script into function for remora integration
%%%
%%% BJT
%%% 260220


if isempty(iffns)
    FilterSpec = '*procIMU*.mat';
    BoxTitle = 'Choose processed IMU .mat File(s)';
    [ifns,inpath] = uigetfile(fullfile(pwd,FilterSpec),BoxTitle,'MultiSelect','on');
    iffns = fullfile(inpath, ifns);
end

if iscell(iffns)
   % for multiple imu files 
    [~,ind]=sort(iffns);
    iffns = iffns(ind);
else
    iffns = { iffns }; % if only one imu file is selected
end

% IMU file(s) for plotting should all be in the same directory
[ p, f, e ] = fileparts(iffns{1});

odir = fullfile(p,'IMUplots');
if ~isdir(odir) %#ok<ISDIR> 
    disp('\tIMU plots folder does not exist');
    mkdir(odir);
    fprintf('\tMade IMU plots folder %s',odir);
end

tAGM_all = [];
tYPR_all = [];

fprintf('\tLoading AGM & YPR data for:\n');
for k = 1:length(iffns)

    [ ~, ifn_pfx, ~ ] = fileparts(iffns{k});
    fprintf('\t%s\n', ifn_pfx);
    
    % load mat files
    % probably don't need to load D for this...whatevs
    load(iffns{k});
    
    tAGM_all = [ tAGM_all; tAGM ];
    tYPR_all = [ tYPR_all; tYPR ];

    clear tAGM;
    clear tYPR;
end

% one timeseries to rule them all
tdnum_all = tAGM_all(:,1);

%%%% plotting time

% check amount of time we're plotting
tspan_days = tdnum_all(end)-tdnum_all(1);
if tspan_days > 2
    date_fmt = 'mmm-dd';
else
    date_fmt = 'mmm-dd HH:MM:SS';
end

h3 = figure(40);
% h3.Position = [100 50 800 950]; % narrow stack
h3.Position = [100 50 1600 900]; % wide stack

subplot(6,1,1)
plot(tdnum_all, tAGM_all(:,2:4),'.'); 
datetick('x',date_fmt);
legend(['x';'y';'z']);
ylabel('Acc (G)'); 
grid minor;
ylim([-1.1*max(abs(tAGM_all(:,2:4)),[],'all'),  1.1*max(abs(tAGM_all(:,2:4)),[],'all')]);%xlim([xlimstart xlimstop]);
xlim( [ min(tdnum_all) max(tdnum_all) ] );


subplot(6,1,2);
plot(tdnum_all,tAGM_all(:,5:7),'.');
datetick('x',date_fmt);
legend(['x';'y';'z']);
ylabel('Gyro (deg/s)');
grid minor;
ylim([-1.1*max(abs(tAGM_all(:,5:7)),[],'all'),  1.1*max(abs(tAGM_all(:,5:7)),[],'all')]);
% ylim([-50 50]); %xlim([xlimstart xlimstop]);
xlim( [ min(tdnum_all) max(tdnum_all) ] );

subplot(6,1,3);
plot(tdnum_all,tAGM_all(:,8:10),'.');
datetick('x',date_fmt);
legend(['x';'y';'z']);
ylabel('Mag (uT)');
grid minor;
ylim([-1.1*max(abs(tAGM_all(:,8:10)),[],'all'),  1.1*max(abs(tAGM_all(:,8:10)),[],'all')]);
%ylim([-40 40]); %xlim([xlimstart xlimstop]);
xlim( [ min(tdnum_all) max(tdnum_all) ] );

subplot(6,1,4); 
plot(tdnum_all,tYPR_all(:,4),'.k');
datetick('x',date_fmt);
ylabel('Roll (deg)'); 
grid minor;
ylim([-1.1*max(abs(tYPR_all(:,4))),  1.1*max(abs(tYPR_all(:,4)))]);
% xline(boatTurnTime,'r'), xline(beginDeploymentTime,'r'), xline(releaseTime,'r'), xline(seafloorTime,'r')
xlim( [ min(tdnum_all) max(tdnum_all) ] );

subplot(6,1,5);
plot(tdnum_all,tYPR_all(:,3),'.k');
datetick('x',date_fmt);
ylabel('Pitch (deg)');
grid minor;
ylim([-1.1*max(abs(tYPR_all(:,3))),  1.1*max(abs(tYPR_all(:,3)))]);
xlim( [ min(tdnum_all) max(tdnum_all) ] );

subplot(6,1,6);
plot(tdnum_all,tYPR_all(:,2),'.k'); 
datetick('x',date_fmt);
ylabel('Yaw (deg)'); 
grid minor;
xlabel(sprintf('Time ( %s )', date_fmt));
ylim([-1.1*max(abs(tYPR_all(:,2))),  1.1*max(abs(tYPR_all(:,2)))]);
xlim( [ min(tdnum_all) max(tdnum_all) ] );

% set export params
FS = 12;
LW = 1;
% set(h3,'Position',[ 50 50 1440 900 ] );
set(findall(h3,'type','text'),'fontSize',FS);
set(findall(h3,'type','axes'),'fontSize',FS);
set(findall(h3,'type','axes'),'lineWidth',LW);
set(findobj(h3,'Type','Line'),'LineWidth',LW);


% save plot
if length(iffns)==1 % if only one mat file, save plot with input files
    ofn = sprintf('%s.png',f);
else 
    % more than one input file, prompt for output file name
    [ofn, odir, ~] = uiputfile(fullfile(p,'*.png'), 'Save plot  as');
end

offn = fullfile(odir,ofn);
print(h3, offn, '-dpng','-r100');

%  save .fig
[ ofn_pfx, ~ ] = strsplit(ofn, '.');
offn2 = fullfile(odir, sprintf('%s.fig',ofn_pfx{1}));
savefig(h3,offn2);

1;

end

