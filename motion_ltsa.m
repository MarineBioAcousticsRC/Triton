function motion_ltsa(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% motion_ltsa.m
%
% control motion of plot windown with push buttons in control window
%
% Parameters:
%       action - a string that represenst the action the user clicked on
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS HANDLES

% forward button
if strcmp(action,'forward')
    PARAMS.ltsa.save.dnum = PARAMS.ltsa.plot.dnum;
    if PARAMS.ltsa.tseg.step ~= -1 && PARAMS.ltsa.tseg.step ~= -2
        PARAMS.ltsa.plot.dnum = PARAMS.ltsa.plot.dnum + datenum([0 0 0 PARAMS.ltsa.tseg.step 0 0]);
    elseif PARAMS.ltsa.tseg.step == -2
        PARAMS.ltsa.plot.dnum = PARAMS.ltsa.plot.dnum + datenum([0 0 0 PARAMS.ltsa.tseg.hr 0 0]);
    elseif PARAMS.ltsa.tseg.step == -1
        stepPlotTimeLTSA('f')
    end
    read_ltsadata
    plot_triton

% back button
elseif strcmp(action,'back')
    PARAMS.ltsa.save.dnum = PARAMS.ltsa.plot.dnum;
    if PARAMS.ltsa.tseg.step ~= -1 && PARAMS.ltsa.tseg.step ~= -2
        PARAMS.ltsa.plot.dnum = PARAMS.ltsa.plot.dnum - datenum([0 0 0 PARAMS.ltsa.tseg.step 0 0]);
    elseif PARAMS.ltsa.tseg.step == -2
        PARAMS.ltsa.plot.dnum = PARAMS.ltsa.plot.dnum - datenum([0 0 0 PARAMS.ltsa.tseg.hr 0 0]);
    elseif PARAMS.ltsa.tseg.step == -1
        stepPlotTimeLTSA('b')
    end
    read_ltsadata
    plot_triton
   
% autof button - plot next frame   
elseif strcmp(action,'autof')
    % turn off menus and buttons while autorunning
    control_ltsa('menuoff');
    control_ltsa('buttoff');
    % turn Stop button back on
    set(HANDLES.ltsa.motion.stop,'Userdata',1);	% turn on while loop condition
    set(HANDLES.ltsa.motion.stop,'Enable','on');	% turn on the Stop button
    while (get(HANDLES.ltsa.motion.stop,'Userdata') == 1)
        motion_ltsa('forward')
        if PARAMS.aptime ~= 0
         pause(PARAMS.ltsa.aptime);
        end		
    end
    % turn buttons and menus back on
    control_ltsa('menuon')

% autob button - plot previous frame   
elseif strcmp(action,'autob')
    % turn off menus and buttons while autorunning
    control_ltsa('menuoff');
    control_ltsa('buttoff');
    % turn Stop button back on
    set(HANDLES.ltsa.motion.stop,'Userdata',1);	% turn on while loop condition
    set(HANDLES.ltsa.motion.stop,'Enable','on');	% turn on the Stop button
    while (get(HANDLES.ltsa.motion.stop,'Userdata') == 1)
        motion_ltsa('back')	% step back one frame
        if PARAMS.aptime ~= 0
         pause(PARAMS.ltsa.aptime); % wait (needed on fast machines)
        end
    end
    % turn menus back on
    control_ltsa('menuon')
    
elseif strcmp(action,'nextDet')
    [~,nextDet] = lt_lVis_envDet_LTSA;
    if ~isempty(nextDet)
        ltsaPad = PARAMS.ltsa.tseg.hr .* 0.1; %add some padding to where next detection/previous detection displays in window
        endLoc = PARAMS.ltsa.dnumEnd(end)-datenum(0,0,0,0,PARAMS.ltsa.tseg.hr,0);
        if endLoc< (nextDet-ltsaPad)
            PARAMS.ltsa.plot.dnum = endLoc;
        else
            PARAMS.ltsa.plot.dnum = nextDet - datenum(0,0,0,0,ltsaPad,0);
        end
        PARAMS.ltsa.save.dnum = PARAMS.ltsa.plot.dnum;
        read_ltsadata
        plot_triton
    else
        disp('Last detection! No detections found after current window for this LTSA file')
    end
    
elseif strcmp(action,'prevDet')
    [prevDet,~] = lt_lVis_envDet_LTSA;
    if ~isempty(prevDet)
        ltsaPad = PARAMS.ltsa.tseg.hr.*0.1; %add some padding to where next detection/previous detection displays in window
        PARAMS.ltsa.plot.dnum = prevDet - datenum(0,0,0,0,ltsaPad,0);
        PARAMS.ltsa.save.dnum = PARAMS.ltsa.plot.dnum;
        % if PARAMS.ltsa.plot.dnum
        read_ltsadata
        plot_triton
    else
        disp('First detection! No detections found prior to current window for this LTSA file')
    end
    
    % stop button doesn't work right away, has to click twice to stop the LTSA
% stop button - keep current frame
elseif strcmp(action,'stop')
    set(HANDLES.ltsa.motion.stop,'Userdata',-1)
    control_ltsa('button')
    control_ltsa('menuon')
    set(HANDLES.ltsa.motion.stop,'Enable','off');	% turn off Stop button

% goto beginning of file button - plot first frame 
elseif strcmp(action,'seekbof')
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    PARAMS.ltsa.plot.dnum = PARAMS.ltsa.start.dnum;
    read_ltsadata
    plot_triton
    set(HANDLES.ltsa.motion.seekbof,'Enable','off');
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');

% goto end of file button - plot last frame
elseif strcmp(action,'seekeof')
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    if PARAMS.ltsa.tseg.step == -2
        PARAMS.ltsa.plot.dnum = PARAMS.ltsa.end.dnum - datenum([0 0 0 PARAMS.ltsa.tseg.hr 0 0]);
        %     disp_msg(['plot.dnum= ',num2str(PARAMS.ltsa.plot.dnum)])
    elseif PARAMS.ltsa.tseg.step == -1
        % total number of time bins to plot
        tbin = floor((PARAMS.ltsa.tseg.hr * 60 *60 ) / PARAMS.ltsa.tave);
        cbin = 0;
        k = PARAMS.ltsa.nrftot+1;
        % count rawfile Indices backwards 
        while cbin < tbin
            k = k - 1;
            cbin = cbin + PARAMS.ltsa.nave(k);
        end
        sbin = cbin - tbin;

        PARAMS.ltsa.plotStartBin = sbin;
        PARAMS.ltsa.plotStartRawIndex = k;
        PARAMS.ltsa.plot.dnum = PARAMS.ltsa.dnumStart(PARAMS.ltsa.plotStartRawIndex)+ ...
            (PARAMS.ltsa.plotStartBin * PARAMS.ltsa.tave) / (60 * 60 * 24);

    end
    read_ltsadata
    plot_triton
    set(HANDLES.ltsa.motion.seekeof,'Enable','off');
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
end;
