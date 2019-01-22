function control(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% control.m
%
% toggle on/off control window pull-down menus and buttons
% set and implement newtime, newtseg, newstep,coordinate display
%
% Parameters:
%       action - the action that the user initiated.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES PARAMS
if strcmp(action,'buttoff')
    %
    % turn off buttons and menues (during picks)
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.motioncontrols,'Enable','off');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'button')
    %
    % turn on buttons and menues (after picks)
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.motioncontrols,'Enable','on');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'menuon')
    %
    % turn on and menues (after picks)
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set([HANDLES.filemenu HANDLES.exportdata HANDLES.savefig HANDLES.exportparams...
        HANDLES.toolmenu],...
        'Enable','on');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'menuoff')
    %
    % turn off buttons and menues (during picks)
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set([HANDLES.filemenu HANDLES.toolmenu],...
        'Enable','off');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % time stuff in control window
elseif strcmp(action,'timeon')
    %
    % turn on time controls
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.timecontrols,'Visible','on');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'timeoff')
    % turn off time controls
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.timecontrols,'Visible','off');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % amp stuff in control window
elseif strcmp(action,'ampon')
    % turn on amplitude controls
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.ampcontrols,'Visible','on');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'ampoff')
    % turn off amplitude controls
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.ampcontrols,'Visible','off');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % frequency stuff in control window
elseif strcmp(action,'freqon')
    % turn on frequency controls
    set(HANDLES.freqcontrols,'Visible','on');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'freqoff')
    % turn off frequency controls
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.freqcontrols,'Visible','off');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % log stuff control window
elseif strcmp(action,'logon')
    % turn on logfile radiobuttons
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.logcontrols,'Visible','on');
    set(HANDLES.logcontrols,'Value',0);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'logoff')
    % turn off logfile radiobuttons
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.logcontrols,'Visible','off');
    set(HANDLES.logcontrols,'Value',0);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'newtime1')
    %
    % plot with new time
    % mm/dd/yyyyy HH:MM:SS
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    %tstr = get(HANDLES.time.edtxt1,'String');
    PARAMS.save.dnum = PARAMS.plot.dnum;
    PARAMS.save.dvec = PARAMS.plot.dvec;
    time = get(HANDLES.time.edtxt1, 'String');
    % Regexs for removing whitespace and rebuilding string properly
    [~, white_index] = regexp(time, '\s');
    time(white_index) = '';
    %     if get(HANDLES.time.formatcheck, 'Value')
    %       % Using standard format, need to parse string differently
    %       [month_day, time_index] = regexp(time, '/\d{0,2}', 'match', 'end');
    %       year = regexp(time, '/\d{0,2}', 'split');
    %       year = ['/' year{1}];
    %       if length(time_index) == 2
    %         time_index = time_index(2);
    %       else
    %         disp_msg('incorrect time format')
    %       end
    %       if length(month_day) == 2 || length(year) == 1
    %         % passes if format is right, otherwise say error but let timenum exit
    %         % properly to set the editbox to a proper value
    %         month_day{2} = strtok(month_day{2}, '/');
    %         month_day{1} = [month_day{1}]
    %         time = [month_day{2} month_day{1} year ' ' time(time_index+1:length(time))];
    %       else
    %         disp_msg('Different format, maybe to few or many /''s?');
    %       end
    %       % index 1 is dd, 2 is yyyy and 3 is mm plus hh:mm:ss so only need
    %     else
    month_day = regexp(time, '\d{0,2}/', 'match');
    [year, time_index] = regexp(time, '/\d{4}', 'match', 'end');
    year = year{1};
    year = strtok(year, '/');
    if length(month_day) == 2 || length(year) == 1
        % passes if format is right, otherwise say error but let timenum exit
        % properly to set the editbox to a proper value
        time = [month_day{1} month_day{2} year ' ' time(time_index+1:length(time))];
    else
        disp_msg('Different format, maybe to few or many /''s?');
    end
    %     end
    PARAMS.plot.dnum = timenum([time,'.',...
        get(HANDLES.time.edtxt3,'String')],1);
    PARAMS.plot.dvec = datevec(PARAMS.plot.dnum);
    readseg
    if ~isempty(PARAMS.xhd.byte_length)
        rtime =(PARAMS.raw.dnumEnd(PARAMS.raw.currentIndex) - PARAMS.plot.dnum)...
            * 60 *60 * 24;
        stime =(PARAMS.start.dnum - PARAMS.plot.dnum)* 60 *60 * 24;
        if rtime >= stime
            PARAMS.plot.bytelength = PARAMS.plot.bytelength + (rtime - stime)*PARAMS.xhd.ByteRate(1);
        elseif stime < rtime
            PARAMS.plot.bytelength = PARAMS.plot.bytelength + (stime - rtime)*PARAMS.xhd.ByteRate(1);
        end
    end
    plot_triton
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    seconds_from_start = (PARAMS.plot.dnum - PARAMS.start.dnum) * 60 * 60 * 24;
    set(HANDLES.time.slider, 'Value', seconds_from_start);
    % the following give focus to the uicontrol obj just used (ver>=7.0)
    %     uicontrol(HANDLES.time.edtxt1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'newtime3')
    %
    % plot with new time
    % mmm.sss
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    PARAMS.save.dnum = PARAMS.plot.dnum;
    PARAMS.save.dvec = PARAMS.plot.dvec;
    if strcmp(get(HANDLES.time.edtxt3,'String'),'0')    % allow 0 instead of having to type 000.000
        %         PARAMS.plot.dnum = timenum([get(HANDLES.time.edtxt1,'String'),' ',...
        %             get(HANDLES.time.edtxt2,'String')],6);
        PARAMS.plot.dnum = timenum([get(HANDLES.time.edtxt1,'String'),'.000.000'],1);
    else
        PARAMS.plot.dnum = timenum([get(HANDLES.time.edtxt1,'String'),'.',...
            get(HANDLES.time.edtxt3,'String')],1);
    end
    PARAMS.plot.dvec = datevec(PARAMS.plot.dnum);
    readseg
    plot_triton
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    % the following give focus to the uicontrol obj just used (ver>=7.0)
    uicontrol(HANDLES.time.edtxt3)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'newtseg')
    %
    % plot with new time segment (Plot Length)
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    tseg = str2num(get(HANDLES.time.edtxt4,'String'));
    if tseg < 2/PARAMS.fs;
        disp_msg('Error: Duration too small')
    elseif PARAMS.end.dnum < (PARAMS.plot.dnum + datenum([0 0 0 0 0 tseg]))
        disp_msg('Error: Plot Length too Long')
        if PARAMS.plot.dnum == PARAMS.start.dnum    % beginning of file
            disp_msg('Set Plot Length to Files Size')
            PARAMS.tseg.sec = floor((PARAMS.end.dnum - PARAMS.start.dnum)...
                * (24 * 60 * 60));
            if ~isempty(PARAMS.xhd.byte_length)
                etime = 0;
                for r=1:length(PARAMS.xhd.byte_length)
                    etime = etime + PARAMS.xhd.byte_length(r)/PARAMS.xhd.ByteRate;
                end
                
                if etime < PARAMS.tseg.sec
                    PARAMS.tseg.sec = etime;
                end
            end
        else
            disp_msg('Set Plot Length to End of File')
            PARAMS.tseg.sec = floor((PARAMS.end.dnum - PARAMS.plot.dnum)...
                * (24 * 60 * 60));
        end
    else
        PARAMS.tseg.sec = tseg;
        if ~isempty(PARAMS.xhd.byte_length)
            etime = 0;
            for r=1:length(PARAMS.xhd.byte_length)
                etime = etime + PARAMS.xhd.byte_length(r)/PARAMS.xhd.ByteRate;
            end
            
            if etime < PARAMS.tseg.sec
                PARAMS.tseg.sec = etime;
            end
        end
    end
    set(HANDLES.time.edtxt4,'String',num2str(PARAMS.tseg.sec));
    readseg
    plot_triton
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    % the following give focus to the uicontrol obj just used (ver>=7.0)
    uicontrol(HANDLES.time.edtxt4)
    file_length_sec = (PARAMS.end.dnum - PARAMS.start.dnum) * 60 * 60 * 24;
    step = PARAMS.tseg.sec/round(file_length_sec);
    set(HANDLES.time.slider, 'SliderStep', [step step*3]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'newtstep')
    %
    % plot with new time step
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PARAMS.tseg.step = str2num(get(HANDLES.time.edtxt5,'String'));
    if PARAMS.tseg.step < 0 & PARAMS.tseg.step ~= -1 & PARAMS.tseg.step ~= -2
        disp_msg('Error: Incorrect Step Size')
        PARAMS.tseg.step = -1;
        set(HANDLES.time.edtxt5,'String',num2str(PARAMS.tseg.step));
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'delay')
    %
    % delay between auto displays
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % time delay between Auto Display
    delay= str2num(get(HANDLES.time.edtxt6,'String'));
    maxdelay = 10;
    mindelay = 0;
    if maxdelay < delay
        disp_msg(['Error: Delay greater than ' num2str(maxdelay) ' seconds!'])
        PARAMS.cancel = 1;
        return
    elseif delay < mindelay
        disp_msg(['Error: Delay shorter than ' num2str(mindelay) ' seconds?'])
        PARAMS.cancel = 1;
        return
    elseif delay <= maxdelay & delay >= mindelay
        PARAMS.aptime = delay;
    else
        PARAMS.cancel = 1;
        disp_msg('Error: Unknown amount')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'coorddisp')
    %
    % show new cursor location
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    coorddisp(0);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action, 'setcmap')
    %
    % change the color of the spectrogram
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %get the cell array of options from the popup menu
    options = get(HANDLES.amp.cmap, 'String');
    %get the index indicating which option is selected
    index = get(HANDLES.amp.cmap, 'Value'); %automatically is 1, so always color
    PARAMS.cmap = options{index};
    %set the color in ltsa to represent the color that HANDLES.fig.main was
    %change to
    set(HANDLES.ltsa.amp.cmap, 'Value', index) % sets LTSA cmap value==specgram, it's wrong
    PARAMS.ltsa.cmap = PARAMS.cmap;
    
    MultiCh_On = get(HANDLES.mc.on, 'Value');
    if MultiCh_On
        figure(get(HANDLES.plot1, 'parent'));
    else
%         figure(get(HANDLES.plt.specgram, 'parent'));
        figure(HANDLES.fig.main);%focus on the main window
    end
    %, set up 2 if statements,
    % one with the focus on specgram, one on LTSA
    if strcmp(PARAMS.cmap,'gray')
        cmap = gray;
        colormap(flipud(cmap));
    else
        colormap(PARAMS.cmap);%change color
    end
        PARAMS.ltsa.cmap = PARAMS.cmap;
    figure(HANDLES.fig.ctrl)%change focus so the changes are immediatly shown
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'ampadj')
    %
    % Adjusts the amplitude of the spectrogram
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    brsld = get(HANDLES.amp.brsld,'Value');
    bredt = str2num(get(HANDLES.amp.bredt,'String'));
    consld = get(HANDLES.amp.consld,'Value');
    conedt = str2num(get(HANDLES.amp.conedt,'String'));
    if bredt ~= PARAMS.bright
        PARAMS.bright = bredt;
    elseif brsld ~= PARAMS.bright
        PARAMS.bright = round(brsld);
    end
    set(HANDLES.amp.bredt,'String',num2str(PARAMS.bright));
    set(HANDLES.amp.brsld,'Value',PARAMS.bright);
    if conedt ~= PARAMS.contrast
        PARAMS.contrast = conedt;
    elseif consld ~= PARAMS.contrast
        PARAMS.contrast = round(consld);
    end
    set(HANDLES.amp.consld,'Value',PARAMS.contrast)
    set(HANDLES.amp.conedt,'String',num2str(PARAMS.contrast))
    
    % check and apply/remove spectrogram equalization:
    state = get(HANDLES.sgeq.tog,'Value');
    if state == get(HANDLES.sgeq.tog,'Max')
        set(HANDLES.sgeq.tog,'String','ON')
        sg = PARAMS.pwr - mean(PARAMS.pwr,2) * ones(1,length(PARAMS.t));
    elseif state == get(HANDLES.sgeq.tog,'Min')
        set(HANDLES.sgeq.tog,'String','OFF')
        sg = PARAMS.pwr;
    end
    
    c = (PARAMS.contrast/100) .* sg + PARAMS.bright;
    %         c = (PARAMS.contrast/100) .* (PARAMS.pwr + PARAMS.bright);
    set(HANDLES.BC,'String',['B = ',num2str(PARAMS.bright),', C = ',num2str(PARAMS.contrast)]);
    
    %this bit of code used to adjust the color map for spectrogram during
    %multichannel mode, because it would not all adjust simultaneously before
    multichannel_mode = get(HANDLES.mc.on, 'Value');
    savalue = get(HANDLES.display.ltsa, 'Value');
    if multichannel_mode
        % have to add in savalue to shift subplot HANDLES down one
        for ch = 1+savalue:PARAMS.nch+savalue
            %       if PARAMS.fax == 1
            if PARAMS.sgfax == 1
                flen = length(PARAMS.f);
                [M,N] = logfmap(flen,4,flen);
                c = M*c;
            end
            h_str = sprintf('HANDLES.plot%d', ch);
            h_val = eval(h_str);
            image_str = imhandles(h_val);
            set(image_str,'CData',c);
        end
    else
        if PARAMS.sgfax == 0
            set(HANDLES.plt.specgram,'CData',c)
        elseif PARAMS.sgfax == 1
            flen = length(PARAMS.f);
            [M,N] = logfmap(flen,4,flen);
            c = M*c;
            f = M*PARAMS.f;
            set(get(HANDLES.plt.specgram,'Parent'),'YScale','log');
            set(HANDLES.plt.specgram,'CData',c)
        end
    end
        pause(0.02)     % this is a lame hack to get colorbar to update
                    % after changing brightness and contrast
                    % without pause it is as if the following isn't
                    % executed or that it is executed before
                    % set(HANDLES.plt.ltsa,'CData',c); is completed???
    % set color bar limit
    minp = min(min(PARAMS.pwr));
    maxp = max(max(PARAMS.pwr));
    set(PARAMS.cb,'YLim',[minp maxp])
    % image (child of colorbar)
    PARAMS.cbb = findobj(get(PARAMS.cb, 'Children'), 'Type', 'image');
    % adjust colorbar
    minc = min(min(c));
    maxc = max(max(c));
    if isinf(minc)
        minc = -100;
    end
    if isinf(maxc)
        maxc = 100;
    end
    difc = 2;
    set(PARAMS.cbb,'CData',[minc:difc:maxc]')
    set(PARAMS.cbb,'YData',[minp maxp])

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'newstfreq')
    %
    % Start Frequency
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    f0 = str2num(get(HANDLES.stfreq.edtxt,'String'));
    if f0 >= PARAMS.freq1
        disp_msg('Freq larger than End Freq :')
        disp_msg(num2str(PARAMS.freq1))
        set(HANDLES.stfreq.edtxt,'String',PARAMS.freq0);
        return
    elseif f0 < 0
        disp_msg('Freq smaller than Min Freq : 0')
        disp_msg('Using Min Freq')
        PARAMS.feq0 = 0;
        plot_triton;
        set(HANDLES.stfreq.edtxt,'String',PARAMS.freq0);
    elseif length(f0) == 0
        disp_msg('Wrong format')
        PARAMS.cancel = 1;
        set(HANDLES.stfreq.edtxt,'String',PARAMS.freq0);
        return
    else
        PARAMS.freq0 = f0;
        plot_triton;
    end
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    % the following gives focus to the uicontrol obj just used (ver>=7.0)
    uicontrol(HANDLES.stfreq.edtxt)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'newendfreq')
    %
    % End Frequency
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    f1 = str2num(get(HANDLES.endfreq.edtxt,'String'));
    if f1 <= PARAMS.freq0
        disp_msg('Freq smaller than Start Freq :')
        set(HANDLES.endfreq.edtxt,'String',PARAMS.freq1);
        set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
        return
    elseif f1 > PARAMS.fmax
        disp_msg(['Freq greater than Max Freq : ' num2str(PARAMS.fmax)])
        disp_msg('Using Max Freq')
        PARAMS.freq1 = PARAMS.fmax;
        plot_triton;
        set(HANDLES.endfreq.edtxt,'String',PARAMS.freq1);
        set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    elseif length(f1) == 0
        disp_msg('Wrong format')
        set(HANDLES.endfreq.edtxt,'String',PARAMS.freq1);
        set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
        return
    else
        PARAMS.freq1 = f1;
        plot_triton;
        PARAMS.cancel = 0;
    end
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    % the following give focus to the uicontrol obj just used (ver>=7.0)
    uicontrol(HANDLES.endfreq.edtxt)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'setspec')
    %
    % Set Spectral Parameters
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sgco=gco;
    % FFT length
    PARAMS.nfft=str2num(get(HANDLES.specnfft.edtxt,'String'));
    % FFT overlap
    PARAMS.overlap=str2num(get(HANDLES.specol.edtxt,'String'));
    if PARAMS.cancel ~= 1
        plot_triton
    else
        
        PARAMS.cancel = 0;
    end
    if sgco == HANDLES.specnfft.edtxt
        % the following give focus to the uicontrol obj just used (ver>=7.0)
        uicontrol(HANDLES.specnfft.edtxt)
    elseif sgco == HANDLES.specol.edtxt
        % the following give focus to the uicontrol obj just used (ver>=7.0)
        uicontrol(HANDLES.specol.edtxt)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'filton')
    %
    % toggle filter on with radio button
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PARAMS.filter = 1;
    set(HANDLES.filtradios,'Value',0)
    set(HANDLES.filt.rad1,'Value',1)
    control('filtdata')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'filtoff')
    %
    % toggle filter on with radio button
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PARAMS.filter = 0;
    set(HANDLES.filtradios,'Value',0)
    set(HANDLES.filt.rad2,'Value',1)
    readseg
    plot_triton
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'filtdata')
    %
    % Filter Data
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sgco=gco;
    pflag = 0;
    if PARAMS.filter == 1
        % start Frequency
        f0 = str2num(get(HANDLES.filt.edtxt1,'String'));
        if f0 >= PARAMS.freq1
            disp_msg('Freq larger than End Freq :')
            disp_msg(num2str(PARAMS.freq1))
            PARAMS.cancel = 1;
            return
        elseif f0 < 0
            disp_msg('Freq smaller than Min Freq :')
            disp_msg('0')
            PARAMS.cancel = 1;
            return
        elseif length(f0) == 0
            disp_msg('Wrong format')
            PARAMS.cancel = 1;
            return
        else
            PARAMS.ff1 = f0;
        end
        % End Freq
        f1 = str2num(get(HANDLES.filt.edtxt2,'String'));
        if f1 <= PARAMS.freq0
            disp_msg('Freq smaller than Start Freq :')
            disp_msg(num2str(PARAMS.freq0))
            PARAMS.cancel = 1;
            return
        elseif f1  > PARAMS.fmax * 0.999
            disp_msg('High End Freq too Large for Bandpass')
            disp_msg('Set to Max for Filter :')
            PARAMS.ff2 = PARAMS.fmax * 0.999;
            disp_msg(num2str(PARAMS.ff2))
            set(HANDLES.filt.edtxt2,'String',num2str(PARAMS.ff2));
        elseif length(f1) == 0
            disp_msg('Wrong format')
            PARAMS.cancel = 1;
            return
        else
            PARAMS.ff2 = f1;
        end
        pflag = 1;
    end
    
    if pflag == 1
        readseg
        plot_triton
        if sgco == HANDLES.filt.edtxt1
            % the following give focus to the uicontrol obj just used (ver>=7.0)
            uicontrol(HANDLES.filt.edtxt1)
        elseif sgco == HANDLES.filt.edtxt2
            % the following give focus to the uicontrol obj just used (ver>=7.0)
            uicontrol(HANDLES.filt.edtxt2)
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'faxlinear')
    %
    % Freq Axis linear
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.faxcontrol,'Value',0);
    set(HANDLES.fax.linear,'Value',1);
    PARAMS.fax = 0;
    plot_triton
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'faxlog')
    %
    % Freq Axis log
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.faxcontrol,'Value',0);
    set(HANDLES.fax.log,'Value',1);
    PARAMS.fax = 1;
    plot_triton
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'specgramlinear')
    %
    % Freq Axis linear
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.sgfaxcontrol,'Value',0);
    set(HANDLES.fax.sglinear,'Value',1);
    PARAMS.sgfax = 0;
    plot_triton
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'specgramlog')
    %
    % Freq Axis log
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.sgfaxcontrol,'Value',0);
    set(HANDLES.fax.sglog,'Value',1);
    PARAMS.sgfax = 1;
    plot_triton
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'TF')
    %
    % Transfer Function ON
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     set(HANDLES.tfradios,'Value',0);
    PARAMS.tf.flag = get(HANDLES.tf.rad1,'Value');
    if isempty(PARAMS.tf.filename)  % reset values if no tf file loaded
        disp_msg('No Transfer Function file')
        disp_msg('Load TF file via Tools Menu')
        PARAMS.tf.flag = 0;
        set(HANDLES.tf.rad1,'Value',0)
        return
    end
    plot_triton
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % elseif strcmp(action,'TFoff')
    %     %
    %     % Transfer Function OFF
    %     %
    %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %     set(HANDLES.tfradios,'Value',0);
    % %     set(HANDLES.tf.rad2,'Value',1);
    %     set(HANDLES.tf.rad1,'Value',0);
    %     PARAMS.tf.flag = 0;
    %     plot_triton
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'setchan')
    %
    % Set Channel number
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ch = get(HANDLES.ch.pop,'Value');
    PARAMS.ch = ch;
    readseg
    plot_triton
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'toggleSGEqual')
    %
    % Push button Pick time to average spectrogram equalization
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    state1 = get(HANDLES.sgeq.tog,'Value');
    if state1 == get(HANDLES.sgeq.tog,'Max')
        set(HANDLES.sgeq.tog,'String','ON')
    elseif state1 == get(HANDLES.sgeq.tog,'Min')
        set(HANDLES.sgeq.tog,'String','OFF')
    end
    plot_triton
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'toggleMean')
    %
    % Toggle Spectrogram Equalization Pick and Full Mean
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    state1 = get(HANDLES.sgeq.tog,'Value');
    state2 = get(HANDLES.sgeq.tog2,'Value');
    if state2 == get(HANDLES.sgeq.tog2,'Max') & ...
            state1 == get(HANDLES.sgeq.tog,'Max')
        set(HANDLES.sgeq.tog2,'String','Pick')
        figure(HANDLES.fig.main)
        [t,f] = ginput(2);
        dt = PARAMS.t(2)-PARAMS.t(1);	%sec/pixel
        x = floor((t+dt/2)./dt) + 1;
        if x(1) > x(2)
            xs = x(1);
            x(1) = x(2);
            x(2) = xs;
        elseif x(1) == x(2)
            x(2) = x(1) + 1;
        end
        PARAMS.mean.save = mean(PARAMS.pwr(:,x(1):x(2)),2) ;
    elseif state2 == get(HANDLES.sgeq.tog2,'Min')
        set(HANDLES.sgeq.tog2,'String','Full')
    end
    plot_triton
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'setspeedFactor')
    %
    % Set Speed Factor for Sound Playback
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    spf = str2num(get(HANDLES.snd.edtxt,'String'));
    if spf > 10 | spf < 0.1
        disp_msg(['Out of Range Sound Playback Speed : ',num2str(spf)])
        disp_msg('Use 0.1 to 10')
        set(HANDLES.snd.edtxt,'String','1')
    else
        PARAMS.speedFactor = spf;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'setVolume')
    %
    % Set Volume for Sound Playback
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PARAMS.sndVol = get(HANDLES.snd.svsld,'Value');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'delimit')
    %
    % Set Delimiter (red line) flag/toggle
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PARAMS.delimit.value = get(HANDLES.delimit.but,'Value');
    plot_triton
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'stopSound')
    %
    % Set Speed Factor for Sound Playback
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.snd.stop,'Userdata',-1)
    set(HANDLES.snd.stop,'Enable','off')
    set(HANDLES.snd.play,'Enable','on')
    plot_triton
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'playSound')
    %
    % Set Speed Factor for Sound Playback
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.snd.stop,'Enable','on')
    set(HANDLES.snd.play,'Enable','off')
    audvidplayer
    plot_triton
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action, 'playSound2')
    %
    % Makes the bandpass visible
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.snd, 'Visible', 'on');
    set(HANDLES.fig.snd,...
        'CloseRequestFcn', {@close_figure, 'hide'});
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action, 'bandpass')
    %
    % Makes the bandpass visible
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.bandpass, 'Visible', 'on');
    set(HANDLES.fig.bandpass,...
        'CloseRequestFcn', {@close_figure, 'hide'});
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'amp_spec_scaling')
    %
    % dialog box for changing, loading or saving plotparameters.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    
    amp_spec_scaling
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'time_slider_set')
    %
    % Handle for changing the time with the slider.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    value = get(HANDLES.time.slider, 'Value');
    % slider is set to seconds out of total seconds in file so value will
    % be seconds from the START of the first raw file.
    new_time = PARAMS.raw.dnumStart(1)+datenum([2000 0 0 0 0 value]);
    set(HANDLES.time.edtxt1, 'String', datestr(new_time, 'mm/dd/yyyy HH:MM:SS'));
    % update the plot
    control('newtime1')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % elseif strcmp(action,'timeformat')
    %     %
    %     % Switches the time from american to standard
    %     %
    %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     time = get(HANDLES.time.edtxt1, 'String');
    %     date = regexp(time, '\s', 'split');
    %     bigtime = regexp(date{1}, '/', 'split');
    %   if get(HANDLES.time.formatcheck, 'Value') %indicates use the triton time convention
    %     set(HANDLES.time.txt1, 'String','yyyy/mm/dd HH:MM:SS')
    %     bigtime = [bigtime{3} '/' bigtime{1} '/' bigtime{2}];
    %     set(HANDLES.time.edtxt1, 'String',[bigtime ' ' date{2}] )
    %   else
    %     set(HANDLES.time.txt1, 'String','mm/dd/yyyy HH:MM:SS')
    %     bigtime = [bigtime{2} '/' bigtime{3} '/' bigtime{1}];
    %     set(HANDLES.time.edtxt1, 'String',[bigtime ' ' date{2}] )
    %   end
    %
    %   if PARAMS.ltsa.infile
    %     time = get(HANDLES.ltsa.time.edtxt1, 'String');
    %     date = regexp(time, '\s', 'split');
    %     bigtime = regexp(date{1}, '/', 'split');
    %     if get(HANDLES.time.formatcheck, 'Value') %indicates use the triton time convention
    %       set(HANDLES.ltsa.time.txt1, 'String','yyyy/mm/dd HH:MM:SS')
    %       bigtime = [bigtime{3} '/' bigtime{1} '/' bigtime{2}];
    %       set(HANDLES.ltsa.time.edtxt1, 'String',[bigtime ' ' date{2}] )
    %     else
    %       set(HANDLES.ltsa.time.txt1, 'String','mm/dd/yyyy HH:MM:SS')
    %       bigtime = [bigtime{2} '/' bigtime{3} '/' bigtime{1}];
    %       set(HANDLES.ltsa.time.edtxt1, 'String',[bigtime ' ' date{2}] )
    %     end
    %   end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action, 'MultiCh')
    %
    % enables user to choose multi-channel view
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    mcstate = get(HANDLES.mc.on,'Value');
    if mcstate == 1
        %     set(HANDLES.mc.on, 'Value', 1)
        %     set(HANDLES.mc.off, 'Value', 0)
        set(HANDLES.ch.txt, 'Visible', 'off')
        set(HANDLES.ch.pop, 'Visible', 'off')
        set(HANDLES.display.spectra, 'Value', 0)
        set(HANDLES.display.specgram, 'Value', 0)
        set(HANDLES.display.timeseries,'Value', 1)
        set(HANDLES.fax.linear, 'Visible', 'off')
        set(HANDLES.fax.log, 'Visible', 'off')
        control('ampoff')
        set(HANDLES.sgequal,'Visible','off')
        set(HANDLES.tfradios,'Visible','off')
        set(HANDLES.mc.lock,'Visible', 'on')
        readseg
        plot_triton
        savalue = get(HANDLES.display.ltsa, 'Value');
        fig_hand = get(HANDLES.plot1,'Parent');
        all_hands = findobj(fig_hand, 'type', 'axes', 'tag', '');
        if savalue
            % set the value of the ltsa handle to 0 so that it's not linked
            % with the zoom in
            all_hands (PARAMS.ch + savalue) = 0;
        end
        linkaxes(all_hands,'off');
    else
        if get(HANDLES.mc.lock, 'Value')
            fig_hand = get(HANDLES.plot1,'Parent');
            all_hands = findobj(fig_hand, 'type', 'axes', 'tag', '');
            linkaxes(all_hands,'off');
        end
        set(HANDLES.mc.lock, 'Value', 0)
        set(HANDLES.mc.lock, 'Visible', 'off')
        if get(HANDLES.mc.on,'Value')
            set([HANDLES.display.spectra HANDLES.display.specgram], 'Value', 0)
            set(HANDLES.display.timeseries,'Value', 1)
            %             set(HANDLES.mc.off, 'Value', 1)
            set(HANDLES.mc.on, 'Value', 0)
            clf(get(HANDLES.plot1,'Parent'))
            ch = get(HANDLES.ch.pop,'Value');
            PARAMS.ch = ch;
            readseg
            plot_triton
        end
        %         set(HANDLES.mc.off, 'Value', 1)
        set(HANDLES.mc.on, 'Value', 0)
        set([HANDLES.ch.txt HANDLES.ch.pop], 'Visible', 'on')
        plot_triton
    end
    %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     %
    % elseif strcmp(action, 'MultiChOff')
    %     %
    %     % turn off multi-channel view
    %     %
    %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     if get(HANDLES.mc.lock, 'Value')
    %       fig_hand = get(HANDLES.plot1,'Parent');
    %       all_hands = findobj(fig_hand, 'type', 'axes', 'tag', '');
    %       linkaxes(all_hands,'off');
    %     end
    %     set(HANDLES.mc.lock, 'Value', 0)
    %     set(HANDLES.mc.lock, 'Visible', 'off')
    %     if get(HANDLES.mc.on,'Value')
    %       set([HANDLES.display.spectra HANDLES.display.specgram], 'Value', 0)
    %       set(HANDLES.display.timeseries,'Value', 1)
    %       set(HANDLES.mc.off, 'Value', 1)
    %       set(HANDLES.mc.on, 'Value', 0)
    %       clf(get(HANDLES.plot1,'Parent'))
    %       ch = get(HANDLES.ch.pop,'Value');
    %       PARAMS.ch = ch;
    %       readseg
    %       plot_triton
    %     end
    %     set(HANDLES.mc.off, 'Value', 1)
    %     set(HANDLES.mc.on, 'Value', 0)
    %     set([HANDLES.ch.txt HANDLES.ch.pop], 'Visible', 'on')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action, 'LockAxes')
    %
    % locks axes together so they'll zoom in together
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    savalue = get(HANDLES.display.ltsa, 'Value');
    fig_hand = get(HANDLES.plot1,'Parent');
    all_hands = findobj(fig_hand, 'type', 'axes', 'tag', '');
    %     disp(all_hands);
    if get(HANDLES.mc.lock,'Value')
        if savalue
            % set the value of the ltsa handle to 0 so that it's not linked
            % with the zoom in
            all_hands (PARAMS.ch + savalue) = 0;
            %         disp(all_hands);
        end
        linkaxes(all_hands,'x');
    else
        linkaxes(all_hands,'off');
    end
end;