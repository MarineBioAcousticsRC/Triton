function [out, strt] = MT2MAT_PC()
%function [output1=data, output2=start time] = = MT2MAT_PC
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

% 1. Read acousonde data, adopted from Acousonderead.m
%     if flag==1; 

currentFolder = pwd ; %Save current directory before running PlotMTdata.m
global PARAMS HANDLES all
clc
fprintf('[\bRunning[|         ] ]\b\n');
        auxALL = [];
        %startdir = '/Users/HARP/Desktop/AcousticTags/deployments_downloads/';
        startdir = PARAMS.ltsa.inpath ;
        path = uigetdir(startdir,'Choose acousonde .MT file directory');
        cd(path); d=dir('*.MT'); mn=char(d.name);

        p=1; tmp=0; t=1; a=1; b=1; c=1; d=1; e=1; j=1; k=1;
        
% 2. loop through files and combine multiple files together
        while p <= size(mn,1) 
            if mn(p,3) == 'T'
                tmp = 1;
                tn(t,:) = mn(p,:);
                t = t+1;
            elseif mn(p,3) == 'X'
                anX(a,:) = mn(p,:);
                a = a+1;
            elseif mn(p,3) == 'Y'
                anY(b,:) = mn(p,:);
                b = b+1;
            elseif mn(p,3) == 'Z'
                anZ(c,:) = mn(p,:);
                c = c+1;
            elseif mn(p,3) == 'P'
                pn(d,:) = mn(p,:);
                d = d+1;
            elseif mn(p,3) == 'I'
                anI(e,:) = mn(p,:);
                e = e+1;
            elseif mn(p,3) == 'J'
                anJ(j,:) = mn(p,:);
                j = j+1;
            elseif mn(p,3) == 'K'
                anK(k,:) = mn(p,:);
                k = k+1;
            end %end if
            p = p+1;
        end %end while


% 3. READ auxillary files
        if exist('pn','var')
            [x,y] = size(pn);
        end
        press=[];temp=[];
        xaccel=[];yaccel=[];zaccel=[];
        iaccel=[];jaccel=[];kaccel=[];
        i = 1;

% 4. Loop each parameter using MTRead_mfm to extract individual parameters
        while i <= x
            if exist('pn')                                  %VL: Pressure data
                [pdata,header,infor]=MTRead_mfm(pn(i,:));
                strt = infor.datenumber ;
                psamp = 1 / infor.srate;
                pp = 0 : psamp  : (infor.nsamp-1)*psamp ;
                pp = (pp ./ (24*60*60)) + strt;
                ptp = [pdata,pp'];
                all.press=[press;ptp];
            end
            if exist('tn')                                  %VL: Temp data
                [tdata,header,infor]=MTRead_mfm(tn(i,:));
                strt = infor.datenumber ;
                tsamp = 1 / infor.srate;
                tp = 0 : tsamp  : (infor.nsamp-1)*tsamp ;
                tp = (tp ./ (24*60*60)) + strt;
                ttp = [tdata,tp'];
                all.temp=[temp;ttp];
            end
            if exist('anX') && exist('anY') && exist('anZ') %VL: Magnetic/Compass data
                [xdata,header,infor]=MTRead_mfm(anX(i,:));   
                [ydata,header,infor]=MTRead_mfm(anY(i,:)); 
                [zdata,header,infor]=MTRead_mfm(anZ(i,:));
                strt = infor.datenumber ;
                xsamp = 1 / infor.srate;
                xp = 0 : xsamp  : (infor.nsamp-1)*xsamp ;
                xp = (xp ./ (24*60*60)) + strt;
                xtp = [xdata,xp']; ytp = [ydata,xp']; ztp = [zdata,xp'];
                all.xaccel=[xaccel;xtp]; all.yaccel=[yaccel;ytp]; all.zaccel=[zaccel;ztp];
            end
            if exist('anI') && exist('anJ') && exist('anK') %VL: Accelerometer Data
                [idata,header,infor]=MTRead_mfm(anI(i,:));   
                [jdata,header,infor]=MTRead_mfm(anJ(i,:)); 
                [kdata,header,infor]=MTRead_mfm(anK(i,:));
                strt = infor.datenumber ;
                isamp = 1 / infor.srate;
                ip = 0 : isamp  : (infor.nsamp-1)*isamp ;
                ip = (ip ./ (24*60*60)) + strt;
                itp = [idata,ip']; jtp = [jdata,ip']; ktp = [kdata,ip'];
                all.iaccel=[iaccel;itp]; all.jaccel=[jaccel;jtp]; all.kaccel=[kaccel;ktp];
            end
            i = i+1;
        end
all.srate = infor.srate;
% 5. Save data
%         len = [length(press) length(temp) length(xaccel) length(yaccel) length(zaccel)...
%             length(iaccel) length(jaccel) length(kaccel)];
        out={(press) (temp) (xaccel) (yaccel) (zaccel)...
            (iaccel) (jaccel) (kaccel)};
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