function mk_SpotCheck(hpath,d)
%
% make Spot Check (Acoustic and TimeStamp [BWA eval]) Plot files from HRP raw disk image files
%
% stolen from BJT codes: Example_spotcheck.m and spotCheckHRP_180207.m
%
% 220810 smw
%

%% get the input parameters for spotCheck
%

% hrp and output directory
if ~exist(hpath,'dir')
    hpath=uigetdir('*.hrp','Select HRP directory for Spot Checking');
end
hrpdir = hpath;

% number of hrp files
hf = dir(fullfile(hrpdir,'*.hrp'));
nhf = size(hf,1);

% data ID string and disk number vector
diskVecstr = '';
for k = 1:nhf
    fn = char(hf(k).name);
    [sI,eI] = regexp(fn,'_disk');
    if k == 1
        dataID = fn(1:sI-1);
    end
    diskVecstr = [diskVecstr,' ',num2str(str2num(fn(eI+1:eI+2)))];
end

outdir = fullfile(hpath,[dataID,'_spotCheck']);

% number of raw file plots per disk
nrf_perdisk = 20;

% default settings
dinfo{1} = hrpdir;
dinfo{2} = dataID;
dinfo{3} = diskVecstr;
dinfo{4} = num2str(nrf_perdisk);
dinfo{5} = outdir;

prompt = {'HRP file Directory: ';...
    'Data file ID name: ';...
    'Disk Number Vector: ';...
    'Number of RF perdisk to SpotCheck: ';...
    'SpotCheck Output file Directory: '};

title = 'Spot Check Parameters';

info = inputdlg(prompt, title, [1 50], dinfo);

% if input dialog box closed
if isempty(info); return; end;

% it would be good to check info{} for validity

hrpdir = info{1};
dataID = info{2};
diskVecstr = info{3};
diskVec = str2num(diskVecstr);
nrf_perdisk = str2num(info{4});
outdir = info{5};

%%
% check for output directories

plotDir = fullfile(outdir,'AcousticPlots');
plotDir2 = fullfile(outdir,'TimeStampPlots');
dataDir = fullfile(outdir,'RawFiles');
sumDir = fullfile(outdir,'Summary');

if ~exist(outdir,'dir')
    fprintf('Making root output directory %s\n',outdir);
    mkdir(outdir);
end
if ~exist(plotDir,'dir')
    fprintf('Making plot directory %s\n',plotDir);
    mkdir(plotDir);
end
if ~exist(plotDir2,'dir')
    fprintf('Making plot directory %s\n',plotDir2);
    mkdir(plotDir2);
end
if ~exist(dataDir,'dir')
    fprintf('Making data directory %s\n',dataDir);
    mkdir(dataDir);
end
if ~exist(sumDir,'dir')
    fprintf('Making plot directory %s\n',sumDir);
    mkdir(sumDir);
end
disp(' ')

% diary
outlog = sprintf('%s_spotCheck_d%02d-%02d.txt',...
    dataID, diskVec(1), diskVec(end));

dfn = fullfile(sumDir,outlog);
diary(dfn);
fprintf('Diary file: %s\n',dfn);

fprintf('Current datetime: %s\n', datestr(now,'mm/dd/yyyy HH:MM:SS'));
fprintf('SpotCheck Code: %s\n\n',mfilename('fullpath'));


%%
% now loop over the disks for SpotCheck

for x = 1:length(diskVec)
    hrpfile = sprintf('%s_disk%02d.hrp',dataID, diskVec(x));
    disp(' ')
    spotCheckHRP(hrpdir,hrpfile,outdir,nrf_perdisk, diskVec(x));
end


% combine plots into one pdf
cfn = ['"',fullfile(sumDir,[dataID,'_AcousticSpotCheck.pdf']),'"'];
if exist(cfn,'file') == 2
    fprintf('Delete old file: %s\n',cfn);
    delete(cfn)
end
%
cfn2 = ['"',fullfile(sumDir,[dataID,'_TimeStampSpotCheck.pdf']),'"'];
if exist(cfn2,'file') == 2
    fprintf('Delete old file: %s\n',cfn2);
    delete(cfn2)
end

%
mf = mfilename('fullpath');  % file and path of this *.m m-file
[pn,~,~] = fileparts(mf);   % pdf combiner path too
pdfexe = fullfile(pn,'pdftk.exe');  % pdf toolkit executable
% pdf tool kit exe and dll need to be in HARPproc REMORA dir
if exist(pdfexe,'file') ~= 2
    disp('Error: missing \Remoras\HARPproc from MATLAB path')
    disp('Combine pdfs manually')
    return
else
    pdffn = ['"',fullfile(plotDir,'*.pdf'),'"'];
    status = system([pdfexe,' ',pdffn,' cat output ',cfn]);
    %
    dpdf = dir(fullfile(plotDir2,'*.pdf'));
    if ~isempty(dpdf)
        pdffn2 = ['"',fullfile(plotDir2,'*.pdf'),'"'];
        status2 = system([pdfexe,' ',pdffn2,' cat output ',cfn2]);
    end
end
disp('Done')
diary('off')

end
%%
function spotCheckHRP(hrppath,hrpfile,opath,numrfs,disk)

% 220811 smw included into HARPproc Remora via mk_SpotCheck.m function
%           Removed Section/Sector timing checks ** need to add back in
%           updated use of newer decompressRawHRP.m

global PARAMS DATA

plotDir = fullfile(opath,'AcousticPlots');
plotDir2 = fullfile(opath,'TimeStampPlots');
dataDir = fullfile(opath,'RawFiles');
dataDir = fullfile(dataDir, sprintf('disk%02d', disk));
mkdir(dataDir);

ffhrp = fullfile(hrppath, hrpfile);

lsf = ls(ffhrp);

if isempty(lsf)
    fprintf('No File %s\n', ffhrp);
    return
else
    fprintf('%s\n',ffhrp);
    if isfield(PARAMS, 'head')
        PARAMS = rmfield(PARAMS, 'head');  % need for different size hrp files
    end
    read_rawHARPdir(ffhrp, 0);
end

ckFirmware; % at least get sample rate, number of channels, and compression type

dmatch = regexpi(hrpfile,'disk\d*','match');
if isempty(dmatch)
    fprintf('\tUnknown Disk number for file hrp file %s\n', hrpfile);
    diskn = PARAMS.head.disknumberSector3;
    fprintf('\tUsing diskNumberSector0 %d\n',diskn);
    dmatch = {sprintf('%02d',diskn)};
end

nmatch = regexpi(hrpfile,'disk\d*','split');
if isempty(nmatch{1})
    fprintf('\tUnknown project/site name...using ''HARP''\n');
    nmatch = {'HARP'};
end
oroot = sprintf('%s%s',nmatch{1}, dmatch{1});

if strcmpi(dmatch,'disk01')
    skiprf = 5; % don't include first 5 rf, could include decktest/shortedAD/etc.
else
    skiprf = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% not sure if the partial stuff works or is needed ???
% before spotCheckHRP function above, reset/removed PARAMS.head

% adjust number of files for partial HRP support
n = PARAMS.head.nextFile; % number of raw files in image
% calculate the number of raw files from dirlist
% if the hrp file is truncated or otherwise missing data
hrp_size = dir(ffhrp);
hrp_size = hrp_size.bytes;

% some aliases to make stuff easier here
partial = hrp_size < 512 * PARAMS.head.dirlist(end, 1);

ndir = 0;
k = 1;

% rf adjustment (rfs to skip and partial hrp)
if partial
    disp('PARTIAL HRP FOUND');
    while k <= length(PARAMS.head.dirlist)
        
        % rf we can add (not in skip list or beyond end of hrp)
        if 512*PARAMS.head.dirlist(k, 1) < hrp_size
            ndir = ndir + 1;
            k = k + 1;
            
            % beyond the end of the hrp
        else
            k = k + 1;
        end
    end
else
    ndir = PARAMS.head.nextFile;
end

headblk = 12;   % data block header length in bytes
mnum2secs = 24*60*60;
bps = 2; % bytes per sample
fs = PARAMS.head.samplerate;
fwStr = PARAMS.head.firmwareVersion;

cflag = PARAMS.cflag;
nch = PARAMS.nch;

if nch == 1 && ~cflag
    datablk = 250; % number of samples per data block
    tailblk = 0;
    offset = 0;
    prcsn = sprintf('%d*int16', datablk);
elseif nch == 4 && ~cflag
    datablk = 248; % number of samples per data block
    tailblk = 4;
    offset = -32767;
    prcsn = sprintf('%d*uint16', datablk);
end

if PARAMS.SATA_bool == 2    % SD system
    ftype = 2;  % data byte order and header format
elseif PARAMS.SATA_bool == 1
    ftype = 1;
elseif PARAMS.SATA_bool == 0
    ftype = 1;
else
    disp('hmmm, must be really old or really new or ??')
end

fprintf('\tHARP Firmware: %s\n', fwStr);

n = ndir;
rfbin = ceil( (n-skiprf)/numrfs );
for rf = skiprf+1:rfbin:n
    fprintf('\n\tRaw File #%d\n', rf);
    rdata = [];
    data = [];
    ofname = sprintf('%s_rf%05d',oroot, rf);  % output file name base
    
    % open up the disk raw hrp file  -- this needs to be reworked to remove
    % making single RF hrp and then reading it again to make xwav ...
    if ftype == 1  % IDE and SATA
        fid = fopen(ffhrp,'r','l'); %for usb file
        fseek(fid,PARAMS.head.dirlist(rf,1)*512,'bof');  % jump to start of rawfile
        % get 1st time stamp for plot title
        dvec = nan(6,1)';
        dvec(2) = fread(fid,1,'uint8');
        dvec(1) = fread(fid,1,'uint8');
        dvec(4) = fread(fid,1,'uint8');
        dvec(3) = fread(fid,1,'uint8');
        dvec(6) = fread(fid,1,'uint8');
        dvec(5) = fread(fid,1,'uint8');
%         ticks = fread(fid,1,'uint16');
        ticks = 2^8 * fread(fid,1,'uint8') + fread(fid,1,'uint8');

        if ~cflag  % non-compression
            if PARAMS.nch == 1
                fseek(fid,PARAMS.head.dirlist(rf,1)*512,'bof');  % jump to start of rawfile
                fseek(fid,headblk,'cof');
                data = fread(fid,nsamp,prcsn,headblk+tailblk)+offset;
                
            elseif PARAMS.nch == 4
                nsect = PARAMS.head.dirlist(rf,10);
                nsamp = (nsect*(512-headblk-tailblk)/2); % 512 /sect 12 byte timestamp/sec 2 byte /sample
                
                %% header timestamp check
                fseek(fid,PARAMS.head.dirlist(rf,1)*512,'bof');  % jump to start of rawfile
                head8 = 8;
                dt_hdrs = (fread(fid,[head8 nsect], [ num2str(head8) '*uint8'],bps*datablk+tailblk+(headblk-head8)))';   
                dt_hdrs = dt_hdrs(:,[2,1,4,3,6,5,8,7]);
                dt_hdrs = datenum([ dt_hdrs(:,1:5) dt_hdrs(:,6) + 0.001*( 2^8*(dt_hdrs(:,7)) + dt_hdrs(:,8))]);
                % get data
                fseek(fid,PARAMS.head.dirlist(rf,1)*512,'bof');  % jump to start of rawfile
                fseek(fid,headblk,'cof');
                data = fread(fid,nsamp,prcsn,headblk+tailblk)+offset;
                
            else
                disp(['Number of channels is not 1 nor 4? nch = ',num2str(PARAMS.nch)])
            end
              
        else  %% compession
            try
                fseek(fid,PARAMS.head.dirlist(rf,1)*512,'bof');  % jump to start of rawfile
                data = decompressRawHRP(fid,rf,PARAMS.ctype,'ftype',ftype);
                dt_hdrs = PARAMS.csectInfo(:,1);  % header timestamp check
                
            catch ME
                fprintf('\tdecompress failed with ME: %s\n',ME.message);
                fprintf('\tskipping to next raw file!\n');
                continue;
            end
        end
        fclose(fid);
        
    elseif ftype == 2  % this needs to add in SD 4 chan non-compression
        fid = fopen(ffhrp,'r','b'); %for ftp file
        fseek(fid,PARAMS.head.dirlist(rf,1)*512,'bof');  % jump to start of rawfile
        % get 1st time stamp for plot title
        dvec = nan(6,1)';
        dvec(1) = fread(fid,1,'uint8');
        dvec(2) = fread(fid,1,'uint8');
        dvec(3) = fread(fid,1,'uint8');
        dvec(4) = fread(fid,1,'uint8');
        dvec(5) = fread(fid,1,'uint8');
        dvec(6) = fread(fid,1,'uint8');
        ticks = 2^8 * fread(fid,1,'uint8') + fread(fid,1,'uint8');  % for all SD BUT 3B02220110
        
        if PARAMS.nch == 1
            fseek(fid,PARAMS.head.dirlist(rf,1)*512,'bof');  % jump to start of rawfile
            data = decompressRawHRP(fid,rf,PARAMS.ctype,'ftype',ftype);
            dt_hdrs = PARAMS.csectInfo(:,1);  % header timestamp check from decompressRawHRP
            
        elseif PARAMS.nch == 4
            nsect = PARAMS.head.dirlist(rf,10);
            nsamp = (nsect*(512-headblk-tailblk)/2); % 512 /sect 12 byte timestamp/sec 2 byte /sample
            
            %% header timestamp check
            fseek(fid,PARAMS.head.dirlist(rf,1)*512,'bof');  % jump to start of rawfile
            head8 = 8;
            dt_hdrs = (fread(fid,[head8 nsect], [ num2str(head8) '*uint8'],bps*datablk+tailblk+(headblk-head8)))';
            dt_hdrs = datenum([ dt_hdrs(:,1:5) dt_hdrs(:,6) + 0.001*( 2^8*(dt_hdrs(:,7)) + dt_hdrs(:,8))]);
            % get data
            fseek(fid,PARAMS.head.dirlist(rf,1)*512,'bof');  % jump to start of rawfile
            fseek(fid,headblk,'cof');
            data = fread(fid,nsamp,prcsn,headblk+tailblk)+offset;
            
        else
            disp(['Number of channels is not 1 nor 4? nch = ',num2str(PARAMS.nch)])
        end
        fclose(fid);
    end
    
    % make xwav file of data
    
    %stuff needed for wrxwavhd
    PARAMS.tseg.samp = length(data);
    PARAMS.samp.byte = 2; % assuming 16 bit samples
    PARAMS.ch = 1; % this will need to be updated for 4ch
    PARAMS.xhd.gain = 0;
    PARAMS.xhd.sample_rate = fs;
    PARAMS.fs = PARAMS.xhd.sample_rate;
    PARAMS.plot.dnum = datenum([ dvec(1:5) dvec(6)+ticks/1000 ]);
    PARAMS.df = 1;
    PARAMS.nBits = 16;
    PARAMS.nch = nch;
    PARAMS.xhd.WavVersionNumber = '1';
    PARAMS.xhd.FirmwareVersionNumber = sprintf('%10s',fwStr);
    PARAMS.xhd.InstrumentID = 'DLXX';
    PARAMS.xhd.SiteName = 'sitX';
    PARAMS.xhd.ExperimentName = 'XXXXXXXX';
    PARAMS.xhd.DiskSequenceNumber = 0;
    PARAMS.xhd.DiskSerialNumber = '12345678';
    PARAMS.xhd.Longitude = -00000000;
    PARAMS.xhd.Latitude = 0000000;
    PARAMS.xhd.Depth = 000;
    PARAMS.outpath = dataDir;
    
    
    DATA = data;
    PARAMS.outfile = sprintf('%s.x.wav',ofname);
    PARAMS.infile = PARAMS.outfile;
    PARAMS.inpath = dataDir;
    wrxwavhd(1);
    fod = fopen(fullfile(dataDir,PARAMS.outfile),'a'); % append to xwav w/header
    fwrite(fid,DATA,'int16');
    fclose(fod);

    % make some plots/dump some info
    
    if nch == 1
        hddw_s = 15; % usually HDD writes are within 15s
        hddMax = max(data(1:hddw_s*fs));
        hddMin = min(data(1:hddw_s*fs));
        fprintf('\tHDD Write Min/Max Counts [ %d %d ]\n', hddMin, hddMax);
        
        maxTS = max(data);
        minTS = min(data);
        meanTS = mean(data);
        stdTS = std(data);
        fprintf('\tMin/Max/ in timeseries [ %d %d ]\n', minTS,maxTS);
        fprintf('\tMean/StD of timeseries [ %.2f %.2f ]\n', meanTS, stdTS);
        
        
        subdata_s = 10; % 10 seconds of data for subsample spectra
        skip_samp = hddw_s*2*fs+1;
        subdata_t = PARAMS.plot.dnum+datenum([ 0 0 0 0 0 hddw_s*2 ]);
        end_samp = skip_samp+subdata_s*fs-1;
        if skip_samp > length(data)
            fprintf('\tInsufficient data in raw file %d for plots, skipping\n', ...
                rf);
            fprintf('\tlength of data = %d samples, %f seconds\n', length(data), ...
                length(data)/fs);
            continue
        elseif end_samp > length(data)
            fprintf('\tInsufficient data in raw file %d for plots, skipping\n', ...
                rf);
            fprintf('\tlength of data = %d samples, %f seconds\n', length(data), ...
                length(data)/fs);
            continue
        end
        subdata = data(skip_samp:end_samp);
        maxSd = max(max(subdata));
        minSd = min(min(subdata));
        
        overlap = 0;
        nfft = fs;
        window = hanning(nfft);
        t = (1:length(subdata))'./fs;
        Pxx = pwelch(subdata,window, overlap, nfft, fs);
        P = 10*log10(Pxx');
        
        h = figure(600);
        subplot(3,1,1)
        dt = .1;
        data_dt = subdata(1:dt*fs);
        t_dt = (1:length(data_dt))'./fs;
        plot(t_dt, data_dt); % plot 100ms
        axis([ t_dt(1) t_dt(end) min(min(data_dt))-100 max(max(data_dt))+100 ])
        ylabel('counts');
        titleStr = sprintf('%s\n%s',ofname, ...
            datestr(subdata_t,'mm/dd/yy HH:MM:SS.FFF'));
        title(titleStr,'interpreter','none');
        subplot(3,1,2)
        plot(t,subdata);
        axis([ t(1) t(end) minSd-100 maxSd+100 ])
        xlabel('seconds');
        ylabel('counts');
        subplot(3,1,3);
        semilogx(0:fs/2,P);
        axis( [ 0 fs/2 -50 40 ] );
        xlabel('Frequency');
        ylabel('Spectrum Level dB re counts/Hz^2')
        grid on
        
    elseif nch == 4
        hddw_s = 3; % usually HDD writes are within 15s
        mc = hsv(nch);
        data = reshape(data,nch,length(data)/nch)';
        hddMax = max(data(1:hddw_s*fs,:));
        hddMin = min(data(1:hddw_s*fs,:));
        hddPkPk = hddMax-hddMin;
        lCh = find(hddPkPk == max(hddPkPk));
        fprintf('\tHDD Write Min/Max Counts [ %d %d ] in Ch %d\n', ...
            hddMin(lCh), hddMax(lCh), lCh);
        
        maxTS = max(max(data));
        minTS = min(min(data));
        meanTS = mean(mean(data));
        stdTS = mean(std(data));
        fprintf('\tMin/Max/ all channels in timeseries [ %d %d ]\n', minTS,maxTS);
        fprintf('\tMean/StD all channels of timeseries [ %.2f %.2f ]\n', meanTS, stdTS);
        
        
        subdata_s = 10; % 10 seconds of data for subsample spectra
%         sd0 = hddw_s + 5;
        sd0 = hddw_s + 1;
        skip_samp = (sd0)*fs+1;
        subdata_t = PARAMS.plot.dnum+datenum([ 0 0 0 0 0 sd0 ]);
        end_samp = skip_samp+subdata_s*fs-1;
        if skip_samp > length(data)
            fprintf('\tInsufficient data in raw file %d for plots, skipping\n', ...
                rf);
            fprintf('\tlength of data = %d samples, %f seconds\n', length(data), ...
                length(data)/fs);
            continue
        elseif end_samp > length(data)
            fprintf('\tInsufficient data in raw file %d for plots, skipping\n', ...
                rf);
            fprintf('\tlength of data = %d samples, %f seconds\n', length(data), ...
                length(data)/fs);
            continue
        end
        subdata = data(skip_samp:end_samp,:);
        maxSd = max(max(subdata));
        minSd = min(min(subdata));
        
        overlap = 0;
        nfft = fs;
        window = hanning(nfft);
        t = (1:length(subdata))'./fs;
        P = [];
        lstr = {};
        % pwelch is supposed to be matrix friendly, probably need to
        % reinstall matlab per https://www.mathworks.com/matlabcentral/answers/268020-problem-with-matrix-as-input-for-pwelch
        for ch=1:nch
            Pxx = pwelch(subdata(:,ch),window, overlap, nfft, fs);
            P =  [ P, 10*log10(Pxx) ];
            lstr{end+1} = sprintf('ch%d',ch);
        end
        h = figure(600);
        clf
        subplot(3,1,1)
        set(gca,'ColorOrder',mc);
        dt = .1;
        data_dt = subdata(1:dt*fs,:);
        t_dt = (1:length(data_dt))'./fs;
        plot(t_dt, data_dt); % plot 100ms
        legend(lstr);
        axis([ t_dt(1) t_dt(end) min(min(data_dt))-100 max(max(data_dt))+100 ])
        ylabel('counts');
        titleStr = sprintf('%s\n%s',ofname, ...
            datestr(subdata_t,'mm/dd/yy HH:MM:SS.FFF'));
        title(titleStr,'interpreter','none');
        subplot(3,1,2)
        set(gca,'ColorOrder',mc);
        plot(t,subdata);
        axis([ t(1) t(end) minSd-100 maxSd+100 ])
        xlabel('seconds');
        ylabel('counts');
        subplot(3,1,3);
        set(gca,'ColorOrder',mc);
        semilogx(0:fs/2,P);
        axis( [ 0 fs/2 -50 40 ] );
        xlabel('Frequency');
        ylabel('Spectrum Level dB re counts/Hz^2')
        grid on
        
    else
        disp(['Number of channels is not 1 nor 4? nch = ',num2str(PARAMS.nch)])
    end
    
    % set export params
    FS = 14;
    LW = 1;
    h.PaperOrientation = 'landscape';
    h.PaperPosition = [0 0 11 8.5];
    set(h,'Position',[ 50 50 1440 900 ] );
    set(findall(h,'type','text'),'fontSize',FS);
    set(findall(h,'type','axes'),'fontSize',FS);
    set(findall(h,'type','axes'),'lineWidth',LW);
    set(findobj(h,'Type','Line'),'LineWidth',LW);
    
    fofile = sprintf('%s.pdf',ofname);
    
    print(h,fullfile(plotDir,fofile),'-dpdf','-r100','-painters');
    
    %% header timestamp check
    
    difft_hdrs = round(diff(dt_hdrs)*1e6*mnum2secs)/1e6; % round to microsecond
    % threshold for bad times is sample rate/compression dependedent
    fifoLen = 4000;
    if cflag
        % compression threshold needs to integrate the bug that adds 1s every
        % FIFO and needs to be rounded up to millisecond precision
        dunit = 'section';
        dtTh = fifoLen/PARAMS.fs+1;
    else
        dunit = 'sector';
        dtTh =  (datablk/nch)/PARAMS.fs;
    end
    % round threshold up to milliseconds
    dtTh = ceil(dtTh*1e3)/1e3;
    
    tgaps = find(abs(difft_hdrs) > dtTh);
    if ~isempty(tgaps)
        % check some timing info
        fprintf('\t%d timing header gaps found ( delta t %.6f s ):\n',length(tgaps),dtTh);
        uDurs = unique(difft_hdrs(tgaps));
        uDursN = histc(difft_hdrs,uDurs);
        fprintf('\t%s number of first occurence: %d\n',dunit, tgaps(1));
        fprintf('\tUnique timing gap durations ( delta t > %.6f s ):\n',dtTh);
        arrayfun(@(x,y) fprintf('\t\t%.6f (%d)\n',x,y),uDurs,uDursN);
        
        %plot
        h2 = figure(700);
        clf
        scatter(1:length(dt_hdrs),dt_hdrs,5,'filled');
        
        mint =  min(dt_hdrs)-10/mnum2secs;
        maxt =  max(dt_hdrs)+10/mnum2secs;
        axis( [ 1 length(dt_hdrs) mint maxt] );
        grid on
        grid minor
        xlabel(dunit);
        num_ticks = 10;
        set(gca,'Ytick',linspace(mint,maxt,num_ticks));
        set(gca,'YTickLabel',...
            datestr(linspace(mint,maxt,num_ticks)+datenum([ 2000 0 0 0 0 0 ]), ...
            'HH:MM:SS.FFF' ));
        
        titleStr = sprintf('%s\n%s',ofname, ...
            datestr(PARAMS.plot.dnum,'mm/dd/yy HH:MM:SS.FFF'));
        title(titleStr,'interpreter','none');
        box on
        
        % set ouput plot params
        h2.PaperOrientation = 'landscape';
        h2.PaperPosition = [0 0 11 8.5];
        set(h2,'Position',[ 100 100 1440 900 ] );
        set(findall(h2,'type','text'),'fontSize',FS);
        set(findall(h2,'type','axes'),'fontSize',FS);
        set(findall(h2,'type','axes'),'lineWidth',LW);
        set(findobj(h2,'Type','Line'),'LineWidth',LW);
        
        fofile2 = sprintf('%s_TimeStamps.pdf',ofname);
        print(h2,fullfile(plotDir2,fofile2),'-dpdf','-r100','-painters');
    end
    
    
end
fprintf('\n');

end
