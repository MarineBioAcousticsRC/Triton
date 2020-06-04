function bm_DetPickCompare
%Comparison of manual picks (xlsx file) and automatic detections
%Convert all times to numbers before running

clear all;
cd('H:\Postdoc\SanctSound\CI04_02_output\Threshold');
%load picking data and effort
%get excel file to read file with manual picks
[infile,inpath]=uigetfile('*.xls','Select a xls file with manual picks');
if isequal(infile,0)
    disp('Cancelled button pushed');
    return
end
%  inpath = 'F:\Logging\Site N';
%  infile = 'SOCAL44N_June.xls';

[pnum, txt] = xlsread(strcat(inpath,'\',infile),'Detections');
%convert to Matlab times
pmatnum = ones(size(pnum)).*datenum('30-Dec-1899')+pnum;
msize=size(pmatnum); %size of the manual picks

%load directory of detections
location = uigetdir(inpath,'Select directory with xls files with detections at various threshold');
% location = 'F:\Logging\Site N\Detections';
dfile = dir(strcat(location,'\*.xlsx'));

%Initialize misses and falses vectors
P_prec = zeros(size(dfile,1),1);
P_rec = zeros(size(dfile,1),1);

%cycle through all the thresholds
for k=1:size(dfile,1)
    %location = 'G:\Data\Research\SOCAL habitat modeling\testAUG17';
    lengname = length(dfile(1,1).name); %-4
    %[dnum, txt, raw] = xlsread(strcat(location,'\',dfile(k,1).name(1:lengname)));
    [dnum,txt] = xlsread(strcat(location,'\',dfile(k,1).name(1:lengname)));
    %convert to Matlab times
    dnum2 = dnum(:,1);
    dmatnum = ones(size(dnum2)).*datenum('30-Dec-1899')+dnum2; %dat =
    %dmatnum = dat(:,1);
    %code for fixing timing issue in 36R
    %dmatnum = dmatnum+datenum([0 0 0 0 0 5]);     %add 6 s for timing error
    dsize=size(dmatnum(:,1)); %size of the detector picks

    if msize(1,1) >= dsize(1,1)
        [Trues False Miss] = moreHumanPicks(dsize, msize, pmatnum, dmatnum);
    else
        [Trues False Miss] = moreDetPicks(dsize, msize, pmatnum, dmatnum);
    end

%     TrueStr(k) = datestr(Trues(:,k));
%     FalseStr(k) = datestr(False(:,k));
%     MissStr(k) = datestr(Miss(:,k));

    P_prec(k) = length(Trues)/dsize(1);
    P_rec(k) = length(Trues)/msize(1);
    %clear dnum dmatnum dsize Miss False Trues;
end

PlotPrecision = P_prec(:,1).*100;
PlotRecall = P_rec(:,1).*100;
figure(1)
%loglog(P_rec,P_prec,'k');
plot(PlotRecall,PlotPrecision,'k*');
ylabel('Precision');
xlabel('Recall');

% avQual = (P_rec+P_prec)/2;
% plot(1:size(avQual(:,1)),avQual)
end
%save the figure automatically
%modify path to something that makes sense on your machine
%path = 'G:\Groundtruth Logging\Site H';
% figname = infile(1:size(infile,2)-4);
% figname = cat(2,path,figname,'.fig');
% saveas(gcf,figname,'fig');

% figure(2)
% plot(PlotRecall,PlotPrecision,'k');
% ylabel('Detector precision');
% xlabel('Detector recall');
% axis ij;

