function control_ltsa(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% control_ltsa.m
%
% toggle on/off control window pull-down menus and buttons
% set and implement newtime, newtseg, newstep,coordinate display
%
% Parameters: action - the action that the user initiated.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES PARAMS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if strcmp(action,'buttoff')
    %
    % turn off buttons and menues (during picks)
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.ltsa.motioncontrols,'Enable','off');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'button')
    %
    % turn on buttons and menues (after picks)
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.ltsa.motioncontrols,'Enable','on');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'menuon')
    %
    % turn on  and menues (after picks)
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set([HANDLES.filemenu HANDLES.savefig],...
        'Enable','on');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'menuoff')
    %
    % turn off buttons and menues (during picks)
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set([HANDLES.filemenu ],...
        'Enable','off');
    % time stuff in control window
elseif strcmp(action,'timeon')
    % turn on time controls
    set(HANDLES.ltsa.timecontrols,'Visible','on');
elseif strcmp(action,'timeoff')
    % turn off time controls
    set(HANDLES.ltsa.timecontrols,'Visible','off');
    % amp stuff in control window
elseif strcmp(action,'ampon')
    % turn on amplitude controls
    set(HANDLES.ltsa.ampcontrols,'Visible','on');
elseif strcmp(action,'ampoff')
    % turn off amplitude controls
    set(HANDLES.ltsa.ampcontrols,'Visible','off');
    % frequency stuff in control window
elseif strcmp(action,'freqon')
    % turn on frequency controls
    set(HANDLES.ltsa.freqcontrols,'Visible','on');
    %
elseif strcmp(action,'freqoff')
    % turn off frequency controls
    set(HANDLES.ltsa.freqcontrols,'Visible','off');
    % log stuff control window
elseif strcmp(action,'logon')
    % turn on logfile radiobuttons
    set(HANDLES.ltsa.logcontrols,'Visible','on');
    set(HANDLES.ltsa.logcontrols,'Value',0);
elseif strcmp(action,'logoff')
    % turn off logfile radiobuttons
    set(HANDLES.ltsa.logcontrols,'Visible','off');
    set(HANDLES.ltsa.logcontrols,'Value',0);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'newtime1')
    %
    % plot with new time
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    PARAMS.ltsa.save.dnum = PARAMS.ltsa.plot.dnum;
    PARAMS.ltsa.plot.dnum = timenum(get(HANDLES.ltsa.time.edtxt1,'String'),6);
    % readpsds
    read_ltsadata
    plot_triton
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    % the following give focus to the uicontrol obj just used (ver>=7.0)
    uicontrol(HANDLES.ltsa.time.edtxt1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'newtseg')
    %
    % plot with new time segment
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    PARAMS.ltsa.save.dnum = PARAMS.ltsa.plot.dnum;
    tseg = str2num(get(HANDLES.ltsa.time.edtxt3,'String'));
    
    if tseg < PARAMS.ltsa.tave/(60 * 60); % if less than one psd bin size in hours
        disp_msg('Duration too small')
        set(HANDLES.ltsa.time.edtxt3,'String',num2str(PARAMS.ltsa.tseg.hr));
    else
        PARAMS.ltsa.tseg.hr = tseg;
        PARAMS.ltsa.tseg.sec = tseg * (60 * 60);  % convert from hours to seconds
    end
    %     readpsds
    read_ltsadata
    plot_triton
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    % the following give focus to the uicontrol obj just used (ver>=7.0)
    uicontrol(HANDLES.ltsa.time.edtxt3)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'newtstep')
    %
    % plot with new time step
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PARAMS.ltsa.tseg.step = str2num(get(HANDLES.ltsa.time.edtxt4,'String'));
    if PARAMS.ltsa.tseg.step < 0 & PARAMS.ltsa.tseg.step ~= -1 & PARAMS.ltsa.tseg.step ~= -2
        PARAMS.ltsa.tseg.step = -1;
        set(HANDLES.ltsa.time.edtxt4,'String',num2str(PARAMS.ltsa.tseg.step));
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'delay')
    %
    % delay between auto displays
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % time delay between Auto Display
    delay= str2num(get(HANDLES.ltsa.time.edtxt6,'String'));
    maxdelay = 10;
    mindelay = 0;
    if maxdelay < delay
        disp_msg(['Error: Delay greater than ' num2str(maxdelay) ' seconds!'])
        %         disp(' ')
        PARAMS.ltsa.cancel = 1;
        return
    elseif delay < mindelay
        disp_msg(['Error: Delay shorter than ' num2str(mindelay) ' seconds?'])
        %         disp(' ')
        PARAMS.ltsa.cancel = 1;
        return
    elseif delay <= maxdelay & delay >= mindelay
        PARAMS.ltsa.aptime = delay;
    else
        PARAMS.ltsa.cancel = 1;
        disp_msg('Error: Unknown amount')
        %         disp(' ')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action, 'setcmap')
    %
    % change the color of the spectogram
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %get the cell array of options from the popup menu
    options = get(HANDLES.ltsa.amp.cmap, 'String');
    %get the index indicating which option is selected
    index = get(HANDLES.ltsa.amp.cmap, 'Value');
    PARAMS.ltsa.cmap = options{index};
    
    figure(HANDLES.fig.main);%focus on the main window
    if strcmp(PARAMS.ltsa.cmap,'gray')
        PARAMS.ltsa.cmap = flipud(PARAMS.ltsa.cmap);
    end
    colormap(PARAMS.ltsa.cmap);%change color
  
    %set the color in wav control to represent the color that HANDLES.fig.main was
    %change to
    set(HANDLES.amp.cmap, 'Value', index)
    PARAMS.cmap = PARAMS.ltsa.cmap;
    figure(HANDLES.fig.ctrl)%change focus so the changes are immediatly shown
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(action,'toggleEqual')
    %
    % Push button Pick time to average spectrogram equalization
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    state1 = get(HANDLES.ltsa.eq.tog,'Value');
    if state1 == get(HANDLES.ltsa.eq.tog,'Max')
        set(HANDLES.ltsa.eq.tog,'String','ON')
    elseif state1 == get(HANDLES.ltsa.eq.tog,'Min')
        set(HANDLES.ltsa.eq.tog,'String','OFF')
    end
    plot_triton
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'toggleMean')
    %
    % Toggle Spectrogram Equalization Pick and Full Mean
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    state1 = get(HANDLES.ltsa.eq.tog,'Value');
    state2 = get(HANDLES.ltsa.eq.tog2,'Value');
    if state2 == get(HANDLES.ltsa.eq.tog2,'Max') & ...
            state1 == get(HANDLES.ltsa.eq.tog,'Max')
        set(HANDLES.ltsa.eq.tog2,'String','Pick')
        figure(HANDLES.fig.main)
        [t,f] = ginput(2);
        dt = PARAMS.ltsa.t(2)-PARAMS.ltsa.t(1);	%sec/pixel
        x = floor((t+dt/2)./dt) + 1;
        if x(1) > x(2)
            xs = x(1);
            x(1) = x(2);
            x(2) = xs;
        elseif x(1) == x(2)
            x(2) = x(1) + 1;
        end
        PARAMS.ltsa.mean.save = mean(PARAMS.ltsa.pwr(:,x(1):x(2)),2) ;
    elseif state2 == get(HANDLES.ltsa.eq.tog2,'Min')
        set(HANDLES.ltsa.eq.tog2,'String','Full')
    end
    plot_triton
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'ampadj')
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    brsld = get(HANDLES.ltsa.amp.brsld,'Value');
    bredt = str2num(get(HANDLES.ltsa.amp.bredt,'String'));
    consld = get(HANDLES.ltsa.amp.consld,'Value');
    conedt = str2num(get(HANDLES.ltsa.amp.conedt,'String'));
    if bredt ~= PARAMS.ltsa.bright
        PARAMS.ltsa.bright = bredt;
    elseif brsld ~= PARAMS.ltsa.bright
        PARAMS.ltsa.bright = round(brsld);
    end
    set(HANDLES.ltsa.amp.bredt,'String',num2str(PARAMS.ltsa.bright));
    set(HANDLES.ltsa.amp.brsld,'Value',PARAMS.ltsa.bright);
    if conedt ~= PARAMS.ltsa.contrast
        PARAMS.ltsa.contrast = conedt;
    elseif consld ~= PARAMS.ltsa.contrast
        PARAMS.ltsa.contrast = round(consld);
    end
    set(HANDLES.ltsa.amp.consld,'Value',PARAMS.ltsa.contrast)
    set(HANDLES.ltsa.amp.conedt,'String',num2str(PARAMS.ltsa.contrast))
    
    % check and apply/remove spectrogram equalization:
    state = get(HANDLES.ltsa.eq.tog,'Value');
    if state == get(HANDLES.ltsa.eq.tog,'Max')
        set(HANDLES.ltsa.eq.tog,'String','ON')
        pwr = PARAMS.ltsa.pwr - mean(PARAMS.ltsa.pwr,2) * ones(1,length(PARAMS.ltsa.t));
    elseif state == get(HANDLES.ltsa.eq.tog,'Min')
        set(HANDLES.ltsa.eq.tog,'String','OFF')
        pwr = PARAMS.ltsa.pwr;
    end
    
    c = (PARAMS.ltsa.contrast/100) .* pwr + PARAMS.ltsa.bright;
    set(HANDLES.ltsa.BC,'String',['B = ',num2str(PARAMS.ltsa.bright),', C = ',num2str(PARAMS.ltsa.contrast)]);
    
    if PARAMS.ltsa.fax == 0
        set(HANDLES.plt.ltsa,'CData',c(PARAMS.ltsa.fimin:PARAMS.ltsa.fimax,:));
    elseif PARAMS.ltsa.fax == 1
        flen = length(PARAMS.ltsa.f);
        [M,N] = logfmap(flen,4,flen);
        c = M*c;
        %         f = M*PARAMS.f;
        %         HANDLES.plt = image(PARAMS.t,f,c);
        %         set(get(HANDLES.plt,'Parent'),'YScale','log');
        set(HANDLES.plt.ltsa,'CData',c(PARAMS.ltsa.fimin:PARAMS.ltsa.fimax, :));
    end
    drawnow
    % pause(0.02)     % this is a lame hack to get colorbar to update
    % after changing brightness and contrast
    % without pause it is as if the following isn't
    % executed or that it is executed before
    % set(HANDLES.plt.ltsa,'CData',c); is completed???
    
    % adjust colorbar
    minc = min(min(c));
    maxc = max(max(c));
    %difc = floor(maxc-minc / 100);
    difc = 2;
    
    minp = min(min(PARAMS.ltsa.pwr));
    maxp = max(max(PARAMS.ltsa.pwr));
    
    set(PARAMS.ltsa.cb,'YLim',[minp maxp])
    PARAMS.ltsa.cbb = findobj(get(PARAMS.ltsa.cb, 'Children'), 'Type', 'image');
    set(PARAMS.ltsa.cbb,'CData',[minc:difc:maxc]')
    set(PARAMS.ltsa.cbb,'YData',[minp maxp])
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'newstfreq')
    %
    % Start Frequency
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    f0 = str2num(get(HANDLES.ltsa.stfreq.edtxt,'String'));
    if f0 >= PARAMS.ltsa.freq1
        disp_msg('Freq larger than End Freq :')
        disp_msg(num2str(PARAMS.ltsa.freq1))
        set(HANDLES.ltsa.stfreq.edtxt,'String',PARAMS.ltsa.freq0);
        return
    elseif f0 < 0
        disp_msg('Freq smaller than Min Freq : 0')
        disp_msg('Using Min Freq')
        PARAMS.ltsa.freq0 = 0;
        PARAMS.ltsa.fimin = ceil(PARAMS.ltsa.freq0 / PARAMS.ltsa.freq(2))+1;
        PARAMS.ltsa.f = PARAMS.ltsa.freq(PARAMS.ltsa.fimin:PARAMS.ltsa.fimax);
        plot_triton;
        set(HANDLES.ltsa.stfreq.edtxt,'String',PARAMS.ltsa.freq0);
    elseif length(f0) == 0
        disp_msg('Wrong format')
        PARAMS.ltsa.cancel = 1;
        set(HANDLES.ltsa.stfreq.edtxt,'String',PARAMS.ltsa.freq0);
        return
    else
        PARAMS.ltsa.freq0 = f0;
        % change plot freq axis
        PARAMS.ltsa.fimin = ceil(PARAMS.ltsa.freq0 / PARAMS.ltsa.freq(2))+1;
        PARAMS.ltsa.f = PARAMS.ltsa.freq(PARAMS.ltsa.fimin:PARAMS.ltsa.fimax);
        plot_triton;
    end
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    % the following give focus to the uicontrol obj just used (ver>=7.0)
    uicontrol(HANDLES.ltsa.stfreq.edtxt)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'newendfreq')
    %
    % End Frequency
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    f1 = str2num(get(HANDLES.ltsa.endfreq.edtxt,'String'));
    if f1 <= PARAMS.ltsa.freq0
        disp_msg('Freq smaller than Start Freq :')
        disp_msg(num2str(PARAMS.ltsa.freq0));
        set(HANDLES.ltsa.endfreq.edtxt,'String',PARAMS.ltsa.freq1);
        return
    elseif f1 > PARAMS.ltsa.fmax
        disp_msg(['Freq greater than Max Freq : ' num2str(PARAMS.ltsa.fmax)]);
        disp_msg('Using Max Freq');
        PARAMS.ltsa.freq1 =  PARAMS.ltsa.fmax;
        PARAMS.ltsa.fimax = ceil(PARAMS.ltsa.freq1 / PARAMS.ltsa.freq(2) + 1);
        PARAMS.ltsa.f = PARAMS.ltsa.freq(PARAMS.ltsa.fimin:PARAMS.ltsa.fimax);
        plot_triton;
        set(HANDLES.ltsa.endfreq.edtxt,'String',PARAMS.ltsa.freq1);
    elseif length(f1) == 0
        disp_msg('Wrong format')
        set(HANDLES.ltsa.endfreq.edtxt,'String',PARAMS.ltsa.freq1);
        return
    else
        PARAMS.ltsa.freq1 = f1;
        % change plot freq axis
        PARAMS.ltsa.fimax = ceil(PARAMS.ltsa.freq1 / PARAMS.ltsa.freq(2) + 1);
        PARAMS.ltsa.f = PARAMS.ltsa.freq(PARAMS.ltsa.fimin:PARAMS.ltsa.fimax);
        plot_triton;
    end
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    % the following give focus to the uicontrol obj just used (ver>=7.0)
    uicontrol(HANDLES.ltsa.endfreq.edtxt)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(action,'delimit')
    %
    % Set Delimiter (red line) flag/toggle
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PARAMS.ltsa.delimit.value = get(HANDLES.ltsa.delimit.but,'Value');
    plot_triton
end;