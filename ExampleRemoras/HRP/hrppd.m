function hrppd(action)
global HANDLES PARAMS
if strcmp(action,'convert_multiHRP2XWAVS')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    %need a gui input here
    make_multixwav
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box
elseif strcmp(action,'convert_HRP2XWAVS')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    % get HRP input file name
    [fname,fpath]=uigetfile('*.hrp','Select HRP file to convert to XWAVS');
    infilename = [fpath,fname];
    cflag = 0;
    % if the cancel button is pushed
    if strcmp(num2str(fname),'0')
        disp_msg('Cancel button pushed')
        cflag = 1;
    end
    % get HDR XWAV header file name
    [fname,fpath]=uigetfile('*.hdr','Select XWAV Header file');
    hdrfilename = [fpath,fname];
    % if the cancel button is pushed
    if strcmp(num2str(fname),'0')
        disp_msg('Cancel button pushed')
        cflag = 1;
    end
    % get XWAV directory name
    outdir = uigetdir(PARAMS.inpath,'Select Directory to output XWAVs');
    if outdir == 0	% if cancel button pushed
        disp_msg('Cancel button pushed')
        cflag = 1;
    end
    % display obtained names in message window
    disp_msg(['Input FileName = ',infilename])
    disp_msg(['XWAV Header FileName = ',hdrfilename])
    disp_msg(['XWAV DirectoryName = ',outdir])
    d = 1;  % display progress info
    if ~cflag
        write_hrp2xwavs(infilename,hdrfilename,outdir,d)
    end
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box
elseif strcmp(action,'get_HRPhead')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    % need gui input here
    d = 1;      % d=1: display output to command window
    [fname,fpath]=uigetfile('*.hrp','Select HRP file to read disk Header');
    filename = [fpath,fname];
    % if the cancel button is pushed, then no file is loaded so exit this script
    if strcmp(num2str(fname),'0')
        return
    else % get raw HARP disk header
        read_rawHARPhead(filename,d)
    end

    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box
elseif strcmp(action,'get_HRPdir')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    d = 1;      % d=1: display output to command window
    [fname,fpath]=uigetfile('*.hrp','Select HRP file to read disk Directory');
    filename = [fpath,fname];
    % if the cancel button is pushed, then no file is loaded so exit this script
    if strcmp(num2str(fname),'0')
        return
    else % get raw HARP disk directory
        read_rawHARPdir(filename,d)
    end
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box
elseif strcmp(action,'ck_dirlist_times')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    
    check_dirlist_times
    
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box
elseif strcmp(action,'plotSectorTimes')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    
    plot_hrpSectorTimes
    
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');

end

