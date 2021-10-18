function plot_triton
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% plot_triton.m
%
% This function checks to see which plots are to be plotted and plots them
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS HANDLES DATA
% decide what mode we're in
multich_on = get(HANDLES.mc.on,'Value');
% multich_off = get(HANDLES.mc.off,'Value');
multich_off = ~multich_on;

if multich_on == multich_off
    disp_msg(sprintf('Handle for multi channel toggle is wrong!  Both are %d', ...
        multich_on));
end

% make plot window active:
figure(HANDLES.fig.main);

if multich_off
    % figure out how many subplots needed :
    savalue = get(HANDLES.display.ltsa,'Value');
    tsvalue = get(HANDLES.display.timeseries,'Value');
    spvalue = get(HANDLES.display.spectra,'Value');
    sgvalue = get(HANDLES.display.specgram,'Value');
    
    m = savalue + tsvalue + spvalue + sgvalue ;  % total number of subplots
    
    % make subplots with handles
    if m == 0       % ie no buttons pushed
        plot_logo()
        disp_msg('No plot type selected')
    else
        for k = 1:m
            str = ['HANDLES.plot',num2str(k),'=subplot(',num2str(m),',1,',num2str(k),');'];
            eval(str);
        end
        p = 1;
        % long-term spectral average
        if savalue
            str = ['HANDLES.plot.now=HANDLES.plot',num2str(p),';'];
            eval(str);
            plot_ltsa
            p = p+1;
        end
        % spectrogram
        if sgvalue
            str = ['HANDLES.plot.now=HANDLES.plot',num2str(p),';'];
            eval(str);
            plot_specgram
            p = p+1;
        end
        % timeseries
        if tsvalue
            if PARAMS.nch > 1
                set(HANDLES.mc.on, 'Visible', 'on');
%                 set(HANDLES.mc.off, 'Visible', 'on');
            end
            str = ['HANDLES.plot.now=HANDLES.plot',num2str(p),';'];
            eval(str);
            plot_timeseries
            p = p+1;
        end
        % spectra
        if spvalue
            str = ['HANDLES.plot.now=HANDLES.plot',num2str(p),';'];
            eval(str);
            plot_spectra
            p = p+1;
        end
        if p ~= m+1
            disp_msg('error : wrong number of subplots made')
        end
        % update control window with time info
        %         if get(HANDLES.time.formatcheck, 'Value')
        %             set(HANDLES.time.edtxt1,'String',timestr(PARAMS.plot.dnum,7));
        %         else
        set(HANDLES.time.edtxt1,'String',timestr(PARAMS.plot.dnum,6));
        %         end
        set(HANDLES.time.edtxt3,'String',timestr(PARAMS.plot.dnum,5));
%         set(HANDLES.time.edtxt4,'String',num2str(PARAMS.tseg.sec));
        %timestr doesn't do micro seconds with datenums so micro seconds are stored
        %in PARAMS.plot.uuu
        %   mmm = timestr(PARAMS.plot.dnum,5);
        %   mmm = mmm(1:4);
        %   x = sprintf('%03d',PARAMS.plot.uuu);
        
        %   set(HANDLES.time.edtxt3,'String',[mmm x]);
        % set(HANDLES.time.edtxt4,'String',num2str(PARAMS.tseg.sec));
    end
elseif multich_on
    % figure out what we're plotting
    savalue = get(HANDLES.display.ltsa,'Value');
    tsvalue = get(HANDLES.display.timeseries,'Value');
    spvalue = get(HANDLES.display.spectra,'Value');
    sgvalue = get(HANDLES.display.specgram,'Value');
    
    m = savalue + tsvalue + spvalue + sgvalue ;  % total number of subplots
    
    num_ch = PARAMS.nch;
    
    if m == 0
        disp_msg('No plot type selected')
        plot_logo()
    else
        if savalue %if there's an LTSA, keep it at the top
            num_ch = num_ch + 1;
            sph_str = sprintf('HANDLES.plot1=subplot(%d, 1, 1);', num_ch);
            eval(sph_str); %need to eval to set up subplots
            h_str = sprintf('HANDLES.plot.now = HANDLES.plot1;');
            eval(h_str);
            plot_ltsa;
        end
        for ch=1+savalue:num_ch
            PARAMS.ch = ch;
            % subpplot handles cmd to evaluate
            sph_str = sprintf('HANDLES.plot%d=subplot(%d,1,%d);',...
                ch, num_ch,ch);
            eval(sph_str);
            a_str = sprintf('HANDLES.axes%d.handle = gca;',ch);
            eval(a_str);
            ach_str = sprintf('HANDLES.axes%d.ch = ch;',ch);
            eval(ach_str);
            % plot.now handle cmd to evaluate
            h_str = sprintf('HANDLES.plot.now=HANDLES.plot%d;',ch);
            eval(h_str);
            if savalue
                % commented out with original use of mDATA, swapped majority of
                % use of DATA variable to DATA(:,ch)
                %           DATA = mDATA(:,ch-1);
                %write out channel number for every separate title
                % maybe consider changing this later to reflect PARAMS or other
                % global variable
                title_ch = ch - 1;
            else
                %           DATA = mDATA(:,ch);
                title_ch = ch;
            end
            
            if tsvalue
                plot_timeseries;
                %title_ch is a variable made just to add channel number to title
                %                 title_str = sprintf(' CH = %d', title_ch);
                %                 title([PARAMS.inpath, PARAMS.infile,title_str]);
                if ch == 1
                    % only need file name for first/top plot
                    title([PARAMS.inpath, PARAMS.infile]);
                end
                
                if ch ~= num_ch %take off x-axis tick labels and x-axis labels
                    xlabel('');
                    set(gca, 'XTickLabel', []);
                end
                
                if ch == num_ch
                    text('Position',[0 -0.25],'Units','normalized',...
                        'String',timestr(PARAMS.plot.dnum,1));
                end
                
            elseif sgvalue
                if savalue
                    handle = sprintf('HANDLES.plot%d', ch);
                    axis_pos = get(eval(handle), 'position');
                    set(eval(handle), 'position', axis_pos);
                end
                plot_specgram;
%                 title_str = sprintf(' CH = %d', title_ch);
%                 title([PARAMS.inpath, PARAMS.infile,title_str]);
                if ch == 1
                    % only need file name for first/top plot
                    title([PARAMS.inpath, PARAMS.infile]);
                end
                if ch ~= num_ch %take off x-axis tick labels and x-axis labels
                    xlabel('');
                    set(gca, 'XTickLabel', []);
                end
                if ch == num_ch
                    %only when reach last graph, add text to bottom of figure
                    text('Position',[0 -0.25],'Units','normalized',...
                        'String',timestr(PARAMS.plot.dnum,1));
                    text('Position',[0.75 -0.25],'Units','normalized',...
                        'String',['Fs = ',num2str(PARAMS.fs),', NFFT = ',num2str(PARAMS.nfft),...
                        ', %OL = ',num2str(PARAMS.overlap)]);
                    HANDLES.BC = text('Position',[0.75 -0.15],'Units','normalized',...
                        'String',['B = ',num2str(PARAMS.bright),', C = ',num2str(PARAMS.contrast)]);
                end
                
            elseif spvalue
                plot_spectra;
%                 title_str = sprintf(' CH = %d', title_ch);
%                 title([PARAMS.inpath, PARAMS.infile,title_str]);
                if ch == 1
                    % only need file name for first/top plot
                    title([PARAMS.inpath, PARAMS.infile]);
                end
                if ch ~= num_ch %take off x-axis tick labels and x-axis labels
                    xlabel('');
                    set(gca, 'XTickLabel', []);
                end
                if ch == num_ch
                    % add text to bottom when reaching last subplot
                    text('Position',[0 -0.25],'Units','normalized',...
                        'String',timestr(PARAMS.plot.dnum,1));
                    len = length(DATA(:,PARAMS.ch));
                    dT1 = len/PARAMS.fs;
                    text('Position',[0.75 -0.15],'Units','normalized',...
                        'String',['Fs = ',num2str(PARAMS.fs),', NFFT = ',num2str(PARAMS.nfft),...
                        ', %OL = ',num2str(PARAMS.overlap)]);
                    text('Position',[0.75 -0.25],'Units','normalized',...
                        'String',['Time Window = ',num2str(dT1),' secs']);
                end
            elseif savalue && ~spvalue && ~tsvalue && ~sgvalue
                HANDLES.plot.now = subplot(1,1,1);
                plot_ltsa;
            else
                plot_logo()
            end
        end
    end
            % update control window with time info
        set(HANDLES.time.edtxt1,'String',timestr(PARAMS.plot.dnum,6));
        set(HANDLES.time.edtxt3,'String',timestr(PARAMS.plot.dnum,5));
        set(HANDLES.time.edtxt4,'String',num2str(PARAMS.tseg.sec));
else
    plot_logo()
    disp_msg('Triton doesn''t know if it''s in single or multichannel mode')
    disp_msg('This should never happen')
end

end %end fxn

function plot_logo()
global PARAMS
clf
logofn = fullfile(PARAMS.path.Extras,'Triton_logo.jpg');
if exist(logofn)
    image(imread(logofn))
    text('Position',[.7 .15],'Units','normalized',...
        'String',PARAMS.ver,...
        'FontSize', 14,'FontName','Times','FontWeight','Bold');
    axis off
end
end

