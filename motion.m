function motion(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% motion.m
%
% control motion of plot windown with push buttons in control window
%
% Parameters:
%       action - a string that represenst the action the user clicked on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS HANDLES DATA

% forward button
if strcmp(action,'forward')
    % plot next frame
    if PARAMS.tseg.step ~= -1 && PARAMS.tseg.step ~= -2
        PARAMS.plot.dnum = PARAMS.plot.dnum + datenum([0 0 0 0 0 PARAMS.tseg.step]);
        if ~isempty(PARAMS.xhd.byte_length)
            PARAMS.plot.bytelength = PARAMS.plot.bytelength + (PARAMS.xhd.ByteRate * PARAMS.tseg.step);
        end
    elseif PARAMS.tseg.step == -1
        PARAMS.plot.dnum = PARAMS.plot.dnum + datenum([0 0 0 0 0 PARAMS.tseg.sec]);
        if ~isempty(PARAMS.xhd.byte_length)
            PARAMS.plot.bytelength = PARAMS.plot.bytelength + PARAMS.xhd.ByteRate * PARAMS.tseg.sec;
        end
    elseif PARAMS.tseg.step == -2
        disp_msg('Under Construction')
    end
    PARAMS.plot.dvec = datevec(PARAMS.plot.dnum);
    if ~isempty(PARAMS.xhd.byte_length)
        PARAMS.plot.initbytel = PARAMS.plot.bytelength;
    end
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    readseg
    plot_triton
    seconds_from_start = (PARAMS.plot.dnum - PARAMS.start.dnum) * 60 * 60 * 24;
    set(HANDLES.time.slider, 'Value', seconds_from_start);
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow'); % put pointer back
    
    % back button
elseif strcmp(action,'back')
    % plot previous frame
    if PARAMS.tseg.step ~= -1 & PARAMS.tseg.step ~= -2
        PARAMS.plot.dnum = PARAMS.plot.dnum - datenum([0 0 0 0 0 PARAMS.tseg.step]);
        if ~isempty(PARAMS.xhd.byte_length)
            PARAMS.plot.bytelength = PARAMS.plot.bytelength - (PARAMS.xhd.ByteRate * PARAMS.tseg.step);
        end
    elseif PARAMS.tseg.step == -1
        PARAMS.plot.dnum = PARAMS.plot.dnum - datenum([0 0 0 0 0 PARAMS.tseg.sec]);
        if ~isempty(PARAMS.xhd.byte_length)
            PARAMS.plot.bytelength = PARAMS.plot.bytelength - (PARAMS.xhd.ByteRate * PARAMS.tseg.sec);
        end
    elseif PARAMS.tseg.step == -2
        disp_msg('Under Construction')
    end
    PARAMS.plot.dvec = datevec(PARAMS.plot.dnum);
    if ~isempty(PARAMS.xhd.byte_length)
        PARAMS.plot.initbytel = PARAMS.plot.bytelength;
    end
    readseg
    plot_triton
    seconds_from_start = (PARAMS.plot.dnum - PARAMS.start.dnum) * 60 * 60 * 24;
    set(HANDLES.time.slider, 'Value', seconds_from_start);
    % autof button - plot next frame
elseif strcmp(action,'autof')
    % turn off menus and buttons while autorunning
    control('menuoff');
    control('buttoff');
    %
    % turn Stop button back on
    set(HANDLES.motion.stop,'Userdata',1);	% turn on while loop condition
    set(HANDLES.motion.stop,'Enable','on');	% turn on the Stop button
    while (get(HANDLES.motion.stop,'Userdata') == 1)
        motion('forward')
        if PARAMS.aptime ~= 0
            pause(PARAMS.aptime);
        end
    end
    % turn buttons and menus back on
    control('menuon')
    figure(HANDLES.fig.ctrl)
    
    % autob button - plot previous frame
elseif strcmp(action,'autob')
    % turn off menus and buttons while autorunning
    control('menuoff');
    control('buttoff');
    % turn Stop button back on
    set(HANDLES.motion.stop,'Userdata',1);	% turn on while loop condition
    set(HANDLES.motion.stop,'Enable','on');	% turn on the Stop button
    while (get(HANDLES.motion.stop,'Userdata') == 1)
        motion('back')	% step back one frame
        if PARAMS.aptime ~= 0
            pause(PARAMS.aptime);
        end				% wait (needed on fast machines)
    end
    % turn menus back on
    control('menuon')
    
    % stop button - keep current frame
elseif strcmp(action,'stop')
    set(HANDLES.motion.stop,'Userdata',-1)
    control('button')
    control('menuon')
    set(HANDLES.motion.stop,'Enable','off');	% turn off Stop button
    
elseif strcmp(action,'nextDet')
    [~,nextDet]= lt_lVis_envDet_rf;
    if~isempty(nextDet)
        winLength = PARAMS.tseg.sec;
        stepFW = winLength*0.5; %where to plot next
        PARAMS.plot.dnum = nextDet - datenum(0,0,0,0,0,stepFW);
        
        %rest is same as with forward button
        PARAMS.plot.dvec = datevec(PARAMS.plot.dnum);
        if ~isempty(PARAMS.xhd.byte_length)
            PARAMS.plot.initbytel = PARAMS.plot.bytelength;
        end
        readseg
        plot_triton
        seconds_from_start = (PARAMS.plot.dnum - PARAMS.start.dnum) * 60 * 60 * 24;
        set(HANDLES.time.slider, 'Value', seconds_from_start);
    else
        disp('Last detection! No detections found after current window for this LTSA file')
    end
    
elseif strcmp(action,'prevDet')
    [prevDet,~]= lt_lVis_envDet_rf;
    if ~isempty(prevDet)
        winLength = PARAMS.tseg.sec;
        stepFW = winLength*0.5; %where to plot next
        PARAMS.plot.dnum = prevDet - datenum(0,0,0,0,0,stepFW);
        
        %rest is same as with normal back button
        PARAMS.plot.dvec = datevec(PARAMS.plot.dnum);
        if ~isempty(PARAMS.xhd.byte_length)
            PARAMS.plot.initbytel = PARAMS.plot.bytelength;
        end
        readseg
        plot_triton
        seconds_from_start = (PARAMS.plot.dnum - PARAMS.start.dnum) * 60 * 60 * 24;
        set(HANDLES.time.slider, 'Value', seconds_from_start);
    else
        disp('First detection! No detections found prior to current window for this LTSA file')
    end
    
    % goto beginning of file button - plot first frame
elseif strcmp(action,'seekbof')
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    PARAMS.plot.dnum = PARAMS.start.dnum;
    PARAMS.plot.dvec = datevec(PARAMS.plot.dnum);
    readseg
    plot_triton
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    seconds_from_start = (PARAMS.plot.dnum - PARAMS.start.dnum) * 60 * 60 * 24;
    set(HANDLES.time.slider, 'Value', seconds_from_start);
    % goto end of file button - plot last frame
elseif strcmp(action,'seekeof')
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    PARAMS.plot.dnum = PARAMS.end.dnum - datenum([0 0 0 0 0 PARAMS.tseg.sec]); %plus
    PARAMS.plot.dvec = datevec(PARAMS.plot.dnum);
    readseg
    plot_triton
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    seconds_from_start = (PARAMS.plot.dnum - PARAMS.start.dnum) * 60 * 60 * 24;
    set(HANDLES.time.slider, 'Value', seconds_from_start);
    
    % goto next file in directory
elseif strcmp(action,'nextfile')
    %     % a way to automatically get the filter, is it an xwav or wav?
    %     filter = char( PARAMS.infile( length( PARAMS.infile )-5:length( PARAMS.infile ) ) );
    %     if ~strcmp( filter, '.x.wav' )
    %         filter = '.wav'; %it wasn't an xwav file so it's a wav.
    %     end
    %     files = dir( [PARAMS.inpath '*' filter] );
    if PARAMS.ftype == 1
        ftstr = '.wav';
    elseif PARAMS.ftype == 2
        ftstr = '.x.wav';
    else
        disp_msg('Error: no wav or xwav files')
        return
    end
    files = dir( [PARAMS.inpath '*' ftstr] );
    if length(files) == 1
        disp_msg('Only one file');
        set(HANDLES.motion.nextfile, 'Enable', 'off')
        return
    end
    NPplot(ftstr, 1) %1 for forward
    
    % goto previous file in directory
elseif strcmp(action, 'prevfile')
    %     fstr = regexp(char(PARAMS.infile),'.x.wav','match');
    %     if ~isempty( fstr )
    %         filter = '.x.wav'; %it wasn't an xwav file so it's a wav.
    %     else
    %         filter = '.wav';
    %     end
    if PARAMS.ftype == 1
        ftstr = '.wav';
    elseif PARAMS.ftype == 2
        ftstr = '.x.wav';
    else
        disp_msg('Error: no wav or xwav files')
        return
    end
    files = dir( [PARAMS.inpath '*' ftstr] );
    if length(files) == 1
        disp_msg('Only one file');
        set(HANDLES.motion.prevfile, 'Enable', 'off')
        return
    end
    NPplot(ftstr, -1) %-1 for backward
end;
    function NPplot(ftstr, direction)
        % get the files. Should be given in lexigraphical order, which is what
        % we want
        files = dir( [PARAMS.inpath '*' ftstr] );
        for y = 1:length( files )
            if strcmp(files( y ).name, char( PARAMS.infile ) )
                if length(files) == y + direction
                    disp_msg( 'At the end of the directory' )
                    set(HANDLES.motion.nextfile, 'Enable', 'off')
                    set( HANDLES.fig.ctrl, 'Pointer', 'arrow' )
                elseif y + direction == 1
                    disp_msg( 'At beginning of directory')
                    set(HANDLES.motion.prevfile, 'Enable', 'off')
                    set( HANDLES.fig.ctrl, 'Pointer', 'arrow' )
                end
                PARAMS.infile = files( y + direction ).name;
                if strcmp(ftstr,'.wav') %need the start time for wav files
                    %
                    % enter start date and time
                    %
                    prompt={'Enter Start Date and Time'};
                    %           tstr = [];
                    %           tstr = regexp(PARAMS.infile,'\d\d\d\d\d\d-\d\d\d\d\d\d','match');
                    %           if isempty(tstr)
                    %             PARAMS.start.dnum = datenum([0 1 1 0 0 0]);
                    %           else
                    %             PARAMS.start.dnum = datenum(tstr,'yymmdd-HHMMSS') - datenum([2000 0 0 0 0 0]);
                    %           end
                    %                     tstr = [];
                    %                     pattern = '\d\d\d\d\d\d(-|_)\d\d\d\d\d\d';
                    %                     tstr = char(regexp(PARAMS.infile,pattern,'match'));
                    %                     if isempty(tstr)
                    dnums = wavname2dnum(PARAMS.infile);
                    if isempty(dnums)
                        PARAMS.start.dnum = datenum([0 1 1 0 0 0]);
                    else
                        %                         if strcmp(tstr(7),'-')
                        %                             dn1 = datenum(tstr,'yymmdd-HHMMSS');
                        %                         elseif strcmp(tstr(7),'_')
                        %                             dn1 = datenum(tstr,'yymmdd_HHMMSS');
                        %                         end
                        %                         PARAMS.start.dnum = dn1 - datenum([2000 0 0 0 0 0]);
                        PARAMS.start.dnum = dnums - datenum([2000 0 0 0 0 0]);
                    end
                    def={timestr(PARAMS.start.dnum,6)};
                    dlgTitle=['Set Start for File : ',PARAMS.infile];
                    lineNo=1;
                    AddOpts.Resize='on';
                    AddOpts.WindowStyle='normal';
                    AddOpts.Interpreter='tex';
                    in=inputdlg(prompt,dlgTitle,lineNo,def,AddOpts);
                    if length(in) == 0	% if cancel button pushed
                        PARAMS.cancel = 1;
                        return
                    end
                    PARAMS.start.dnum=timenum(deal(in{1}),6);
                end
                % plots the new xwav/wav file
                set( HANDLES.fig.ctrl, 'Pointer', 'watch' );
                % initialize data format
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                initdata
                if strcmp(ftstr, '.x.wav') && ~isempty( PARAMS.xhd.byte_length )
                    PARAMS.plot.initbytel = PARAMS.xhd.byte_loc(1);
                end
                if isempty( DATA(:,PARAMS.ch) )
                    set(HANDLES.display.timeseries,'Value',1);
                end
                % got to end of file for previous file
                if direction == -1
                    PARAMS.plot.dnum = PARAMS.raw.dnumEnd(end) - datenum([0 0 0 0 0 PARAMS.tseg.sec]);
                    PARAMS.raw.currentIndex = PARAMS.xhd.NumOfRawFiles;
                    seconds_from_start = (PARAMS.plot.dnum - PARAMS.start.dnum) * 60 * 60 * 24;
                end
                readseg
                plot_triton
                control( 'timeon' )   % was timecontrol(1)
                % turn on other menus now
                control( 'menuon' )
                control( 'button' )
                if direction == 1
                    set( [HANDLES.motion.seekbof HANDLES.motion.back ...
                        HANDLES.motion.autoback HANDLES.motion.stop], 'Enable','off' );
                    init_tslider(0)
                else
                    set( [HANDLES.motion.seekeof HANDLES.motion.fwd ...
                        HANDLES.motion.autofwd HANDLES.motion.stop], 'Enable','off' );
                    init_tslider(seconds_from_start)
                end
                set( HANDLES.fig.ctrl, 'Pointer', 'arrow' )
                set( HANDLES.motioncontrols,'Visible','on' )
                set( HANDLES.delimit.but,'Visible','on' )
                if length(files) == y + direction
                    set(HANDLES.motion.nextfile, 'Enable', 'off')
                elseif y + direction == 1
                    set(HANDLES.motion.prevfile, 'Enable', 'off')
                end
                % set the time slider based on the opened file.
                seconds_from_start = (PARAMS.plot.dnum - PARAMS.start.dnum) * 60 * 60 * 24;
                set(HANDLES.time.slider, 'Value', seconds_from_start);
                break; %mission accomplised, get out of here now.
            end
        end
    end
end
