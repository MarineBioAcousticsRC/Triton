function [out, strt] = MTPRH2MAT_PC()
%function [output1=data, output2=start time] = = MTPRH2MAT_PC
% code opens .MT auxillary files, plots dive profile and saves information
% in variables out and strt
%
%  INPUTS:
%           input1	   MT files chosen by user
%
% OUTPUTS:
%           out        An nx8 matrix of auxillery data
%           strt	   A datevector of start time
%
% FUNCTIONS REQ'D:
%           MTREAD_mfm.m    Extract individual parameters from MT files
%                           while running MT2MAT_PC.m
%           mtViewer.m      Use before this function to convert raw data
%                           files into MT files
%
%  MODIFICATION HISTORY:
%
%  MM/DD/YYYY INITIALS  Modification details:
%
%   04/15/16 VEL    Plotted x-axis was static when scrolling/zooming in plot.
%                   Fixed with datetick() function added after plot, but
%                   axes must be updated after every scroll or zoom action!
%                       plot(out(:,9),out(:,2));
%                       datetick('x','HH:MM:SS.FFF')
%                   http://www.mathworks.com/matlabcentral/answers/?term=tag%3A%22xticklabel%22
%
%
%   06/21/2011 MFM  run this after the data is downloaded and split using mtViewer
%
%
% todoList


%     prompt1={'Enter tag type (1=Acousonde, 2=Bprobe)'};
%     inl = inputdlg(prompt1); flag = str2num(inl{1});


% 1. check if user has made PRH file from raw acousonde data
checkPRH = questdlg('Have the .MT files been converted into a PRH file?', 'Check for PRH file');
switch checkPRH
    case 'Yes'
    case 'No'
        error('.MT must be converted to PRH using MT2PRH.m')
    case 'Cancel'
        error('.MT must be converted to PRH using MT2PRH.m')
end

% 2. Choose MT --> PRH file
currentFolder = pwd ; %Save current directory before running PlotMTdata.m
global PARAMS HANDLES all
clc
fprintf('[\bRunning[|         ] ]\b\n');
auxALL = [];
%startdir = '/Users/HARP/Desktop/AcousticTags/deployments_downloads/';
startdir = PARAMS.ltsa.inpath ;

if ~startdir()
end
path = uigetdir(startdir,'Choose acousonde PRH file directory');
cd(path); d=dir('*prh.mat'); mn=char(d.name);
load(fullfile(path,mn));%loads p temp M A Mw Aw pitch roll and head

inforpath = uigetdir(startdir, 'Choose infor metadata');
cd(inforpath); dinfor = dir('infor*.mat'); mninfor = char(dinfor.name);
load(fullfile(inforpath,mninfor));

% 3. Make time vector
disp('Start Time:');
disp(PARAMS.ltsa.dvecStart(1,:));
strt = infor.datenumber;
lenp = length(press);
psamp = 1 / fs;
pp = 0 : psamp  : (lenp-1)*psamp ;
pp = (pp ./ (24*60*60)) + strt;

% 4. Create all vectors
all.press = [press,pp'];
all.temp= [tempr(1:lenp,1),pp'];
all.xaccel= [M(1:lenp,1),pp'];
all.yaccel= [M(1:lenp,2),pp'];
all.zaccel= [M(1:lenp,3),pp'];
all.iaccel= [A(1:lenp,1),pp'];
all.jaccel= [A(1:lenp,2),pp'];
all.kaccel= [A(1:lenp,3),pp'];
all.roll = [R(1:lenp,1),pp'];
all.azi = [H(1:lenp,1),pp'];
all.pitch = [P(1:lenp,1),pp'];

% 5. Save data
%         len = [length(press) length(temp) length(xaccel) length(yaccel) length(zaccel)...
%             length(iaccel) length(jaccel) length(kaccel)];
out={(all.press) (all.temp) (all.xaccel) (all.yaccel) (all.zaccel)...
    (all.iaccel) (all.jaccel) (all.kaccel) (all.pitch) (all.roll) (all.azi)};
%         ml=max(len);

% % 6. zeropad so one matrix can be created
%         out=[];
%         for ii = 1:length(all)
%             dt = [all{ii} ; zeros(ml-len(ii),1)];
%     %                 dt = [all{ii};(nan(ml-len(ii)))];
%             out = [out dt];
%         end

% 7. create time stamp for each data point using MTREAD_mfm
%         n=infor.srate ;
%         msamp=(length(press)/n) ;
%         secs=1/n:1/n:msamp ;
%         [pdata,header,infor]=MTRead_mfm(pn(1,:)) ;



%         dtime = nan(length(out),1);
%         for ii=1:length(secs)
%             if ii == ceil(length(secs)/4)
%                 clc
%                 fprintf('[\bRunning[|||       ] ]\b\n');
%             elseif ii == ceil(length(secs)/2)
%                 clc
%                 fprintf('[\bRunning[|||||     ] ]\b\n');
%             elseif ii == ceil(length(secs)*0.75)
%                 clc
%                 fprintf('[\bRunning[|||||||   ] ]\b\n');
%             elseif ii == ceil(length(secs)*0.99)
%                 clc
%                 fprintf('[\bRunning[||||||||||] ]\b\n');
%             else
%             end
%
%             d1 = datenum(datevec(strt) + [0 0 0 0 0 secs(ii)]);
%             dtime(ii) = d1;
%         end
%         ck=length(press)/length(dtime);
%         out(:,9) = dtime; %convert zeros to nans
%         out(:,10:15) = datevec(dtime);

% 8. Plot data into four figures
global REMORA
REMORA.MT2MAT.out = out ;
%         PlotMTdata(out,strt) ;
% vargout{1} = out;
% vargout{2} = strt;


%     %save data to a text file
%     strtv=datestr(strt);

%     %save figure to current directory as a pdf
%     filename = sprintf('%s_%s_%s%s%s_%s%s%s.pdf',tt,header.stationcode,...
%         (strtv(1:2)), (strtv(4:6)), (strtv(8:12)),...
%         (strtv(13:14)), (strtv(16:17)), (strtv(19:20)));
%     filename = num2str(filename);
%     %print(h,'-painters', '-dpdf', '-r600', filename)


%     filename = sprintf('%s_%s_%s%s%s_%s%s%s.txt',tt,header.stationcode,...
%         (strtv(1:2)), (strtv(4:6)), (strtv(8:12)),...
%         (strtv(13:14)), (strtv(16:17)), (strtv(19:20)));
%     filename = num2str(filename);
%     %save out auxillary data- to import the time in later processing
%     dlmwrite(filename, out);



%
% VL: I can deal w saving the data w headers for output later
%     headers = {'Depth', 'Temp', 'I', 'J', 'K', 'X', 'Y', 'Z', 'Time', 'YYYY', 'MM', 'DD', 'hh', 'mn', 'ss'} ;
%     output = vertcat(headers, num2cell(out)) ;
%     save output.mat
%     end

%--------------------------------------------------------------------------
%     if flag ==2; %run for Bprobe data
%         display('Process on PC- this code doesn not work for Bprobes (sorry)')
%         return
%
%     end


cd(currentFolder) %Change directory back to original folder.
end