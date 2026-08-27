% mk_timestamp_plot.m
%
% script to make header timestamp check plot for BWA
%
% 221222 smw
%

mnum2secs = 24*60*60;
nch = 1;

fs = 200e3;

cflag = 1;  % csection =1, csector =0

pflag = 1;  % print pdf of figure

[fname, pname] = uigetfile('.mat', 'Select Section Timestamp file');
load(fullfile(pname,fname))       % load csectInfo matrix

dt_hdrs = csectInfo(:,1);  % header timestamp check from decompressRawHRP


%% header timestamp check

difft_hdrs = round(diff(dt_hdrs)*1e6*mnum2secs)/1e6; % round to microsecond
% threshold for bad times is sample rate/compression dependedent
fifoLen = 4000;
if cflag
    % compression threshold needs to integrate the bug that adds 1s every
    % FIFO and needs to be rounded up to millisecond precision
    dunit = 'section';
    dtTh = fifoLen/fs;
else
    datablk = 250;
    dunit = 'sector';
    dtTh =  (datablk/nch)/fs;
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
    
    titleStr = sprintf('%s\n%s',fname, ...
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
        [~,ofname,~]  = fileparts(fname);
        fofile2 = sprintf('%s_TimeStamps.pdf',ofname);
        print(h2,fullfile(pname,fofile2),'-dpdf','-r100','-painters');
    end
end

