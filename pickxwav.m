function pickxwav
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% pickxwav.m
%
% turn on picking time in ltsa file and open corresponding xwav file
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS HANDLES DATA

currentaxispoint = get(get(HANDLES.fig.main,'CurrentAxes'),'CurrentPoint');
x = currentaxispoint(1,1);
% y = currentaxispoint(1,2);

% get value for active windows
% savalue = get(HANDLES.display.ltsa,'Value');

if gco == HANDLES.subplt.ltsa || gco == HANDLES.plt.ltsa
    % calc time
    [rawIndex,tBin] = getIndexBin(x);
    fname = char( deblank(PARAMS.ltsahd.fname(rawIndex,:)) );%convert to char for human readability
    rfileid = PARAMS.ltsahd.rfileid(rawIndex);

    disp_msg([fname,'  ',num2str(rfileid),'  ',num2str(tBin)])

    % calculate the number of blocks in the opened file
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    PARAMS.inpath = PARAMS.ltsa.inpath;
    PARAMS.infile= fname;
    if ~exist([PARAMS.inpath,PARAMS.infile],'file')
        disp_msg([PARAMS.inpath,PARAMS.infile,' does not exist'])
        disp_msg('Select correct directory & file')
        % get file name
        %
        filterSpec1 = '*.x.wav';
        boxTitle1 = 'Open XWAV based on LTSA';
        % user interface retrieve file to open through a dialog box
        DefaultName = PARAMS.inpath;
        [infile,inpath]=uigetfile(filterSpec1,boxTitle1,DefaultName);
        % if the cancel button is pushed, then no file is loaded
        % so exit this script
        disp_msg(['File : ',PARAMS.infile])
        disp_msg(['Directory : ',PARAMS.inpath])
        if strcmp(num2str(infile),'0') || ~exist([inpath,infile],'file')
            disp_msg('Canceled file opening')
            return
        else
            PARAMS.infile = infile;
            PARAMS.inpath = inpath;
            disp_msg('Opened File: ')
            disp_msg([PARAMS.inpath,PARAMS.infile])
            cd(PARAMS.inpath)
            PARAMS.ltsa.inpath = PARAMS.inpath;
        end
    end

    fstr = [];
    fstr = regexp(char(fname),'.x.wav','match');
    if ~isempty(fstr)
        PARAMS.ftype = 2;       % xwav format
    else
        PARAMS.ftype = 1;       % wav format
        PARAMS.start.dnum = PARAMS.ltsa.dnumStart(rawIndex);
        PARAMS.start.dvec = PARAMS.ltsa.dvecStart(rawIndex);
    end

    % initialize data format
    initdata
    if ~isempty(PARAMS.xhd.byte_length)
        PARAMS.plot.initbytel = PARAMS.xhd.byte_loc(1);
    end


    PARAMS.plot.dnum = PARAMS.ltsa.dnumStart(rawIndex) + (tBin - 0.5) * PARAMS.ltsa.tave / (60*60*24);
    PARAMS.plot.dvec = datevec(PARAMS.plot.dnum);

    if isempty(DATA) ||...
            (get(HANDLES.display.timeseries,'Value') == 0 && ...
            get(HANDLES.display.spectra,'Value') == 0 && ...
            get(HANDLES.display.specgram,'Value') == 0)

        set(HANDLES.display.specgram,'Value',1);    % turn on spectrogram
    end
    readseg
    if get(HANDLES.display.timeseries,'Value') == 0 && ...
            get(HANDLES.display.spectra,'Value') == 0 && ...
            get(HANDLES.display.specgram,'Value') == 1

        displaybut('specgram')
    else
        plot_triton
    end

    control('timeon')   % was timecontrol(1)
    % turn on other menus now
    control('menuon')
    control('button')
    if PARAMS.plot.dnum == PARAMS.start.dnum
        set([HANDLES.motion.seekbof HANDLES.motion.back HANDLES.motion.autoback HANDLES.motion.stop],...
            'Enable','off');
    elseif PARAMS.plot.dnum + PARAMS.tseg.sec/(60*60*24) == PARAMS.end.dnum
        set([HANDLES.motion.seekeof HANDLES.motion.forward HANDLES.motion.autoforward HANDLES.motion.stop],...
            'Enable','off');
    elseif PARAMS.plot.dnum < PARAMS.start.dnum || PARAMS.plot.dnum + PARAMS.tseg.sec/(60*60*24) > PARAMS.end.dnum
        disp_msg('Error: Plot start time after or before file times')
    else
        set(HANDLES.motion.stop,'Enable','off');
    end
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.motioncontrols,'Visible','on')
    set(HANDLES.delimit.but,'Visible','on')

    PARAMS.expand.button.value = 0;
    set(HANDLES.ltsa.expand.button,'Value',PARAMS.expand.button.value);

    % Set the pointer back to an arrow if nobody else is using it.
    if ~ PARAMS.pick.button.value
        set(HANDLES.fig.main,'Pointer','arrow');
    end
    %
    seconds_from_start = (PARAMS.plot.dnum - PARAMS.start.dnum) * 60 * 60 * 24;
    init_tslider(seconds_from_start)
end
