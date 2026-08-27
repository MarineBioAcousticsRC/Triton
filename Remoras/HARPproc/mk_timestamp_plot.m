% mk_timestamp_plot.m
%
% script to make header timestamp check plot for BWA
%
% 221216 smw
%
global PARAMS

mnum2secs = 24*60*60;
nch = 1;
cflag = 1;  % csection =1, csector =0

pflag = 0;  % print pdf of figure

inpath = 'G:\My Drive\HARPrawfiles\SDHARP_syncLoss_BWA';
% infile = 'GOM_CE_02_disk01_RF26589.hrp';
% infile = 'GOM_CE_02_disk01_RF32598.hrp';
infile = 'GOM_CE_02_disk01_RF33257.hrp';

filesize = getfield(dir(fullfile(inpath,infile)),'bytes');

ofname = infile;

fid = fopen(fullfile(inpath,infile),'r','b');
rf = 1;
dtype = 3;   % compression for V2.02R and beyond
ftype = 2;  % SD

PARAMS.fs = 200e3;

if ftype == 1
    dvec(2) = fread(fid,1,'uint8');
    dvec(1) = fread(fid,1,'uint8');
    dvec(4) = fread(fid,1,'uint8');
    dvec(3) = fread(fid,1,'uint8');
    dvec(6) = fread(fid,1,'uint8');
    dvec(5) = fread(fid,1,'uint8');
    ticks = fread(fid,1,'uint16');
    %   msec = msec/4;      % quick fix for wrong header time
    fseek(fid,-8,0);            % rewind to start of header
elseif ftype == 2
    dvec(1) = fread(fid,1,'uint8');
    dvec(2) = fread(fid,1,'uint8');
    dvec(3) = fread(fid,1,'uint8');
    dvec(4) = fread(fid,1,'uint8');
    dvec(5) = fread(fid,1,'uint8');
    dvec(6) = fread(fid,1,'uint8');
    ticks = fread(fid,1,'uint16');
    % msec = msec/4;      % quick fix for wrong header time
    fseek(fid,-8,0);
end


%%

data = decompressRawHRP(fid,rf,dtype,'ftype',ftype,...
    'usb_ftp_flag',1,'filesize',filesize,'dvec',dvec,...
    'ticks',ticks,'samplerate', PARAMS.fs);
dt_hdrs = PARAMS.csectInfo(:,1);  % header timestamp check from decompressRawHRP


%% header timestamp check


difft_hdrs = round(diff(dt_hdrs)*1e6*mnum2secs)/1e6; % round to microsecond
% threshold for bad times is sample rate/compression dependedent
fifoLen = 4000;
if cflag
    % compression threshold needs to integrate the bug that adds 1s every
    % FIFO and needs to be rounded up to millisecond precision
    dunit = 'section';
    dtTh = fifoLen/PARAMS.fs;
else
    datablk = 250;
    dunit = 'sector';
    dtTh =  (datablk/nch)/PARAMS.fs;
end

% round threshold up to milliseconds
dtTh = ceil(dtTh*1e3)/1e3;

tgaps = find(abs(difft_hdrs) > dtTh);
if ~isempty(tgaps)
    % check some timing info  - not sure how useful this is...left over
    % from something...
    
    disp(' ')
    fprintf('\t%d timing header gaps found ( delta t %.6f s ):\n',length(tgaps),dtTh);
    fprintf('\t%s number of first occurence: %d\n',dunit, tgaps(1));
    fprintf('\tUnique timing gap durations ( delta t > %.6f s ):\n',dtTh);
    uDurs = unique(difft_hdrs(tgaps));
    uDursN = histc(difft_hdrs(tgaps),uDurs);
    arrayfun(@(x,y) fprintf('\t\t%.6f (%d)\n',x,y),uDurs,uDursN);
    
    %plot
    h2 = figure(700);
    clf
    scatter(1:length(dt_hdrs),dt_hdrs,5,'filled');
    % scatter(PARAMS.csectInfo(:,4),dt_hdrs,5,'filled');
    
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
        datestr(dt_hdrs(1),'mm/dd/yy HH:MM:SS.FFF'));
    title(titleStr,'interpreter','none');
    box on
    
    % set ouput plot params
    FS = 14;
    LW = 1;
    h2.PaperOrientation = 'landscape';
    h2.PaperPosition = [0 0 11 8.5];
    set(h2,'Position',[ 100 100 1440 900 ] );
    set(findall(h2,'type','text'),'fontSize',FS);
    set(findall(h2,'type','axes'),'fontSize',FS);
    set(findall(h2,'type','axes'),'lineWidth',LW);
    set(findobj(h2,'Type','Line'),'LineWidth',LW);
    
    if pflag
        fofile2 = sprintf('%s_TimeStamps.pdf',ofname);
        print(h2,fullfile(inpath,fofile2),'-dpdf','-r100','-painters');
    end
end

fclose(fid);


