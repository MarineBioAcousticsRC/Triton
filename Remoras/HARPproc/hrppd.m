function hrppd(action)
global HANDLES PARAMS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HRP Remora Pulldown selections
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if strcmp(action,'process_HRP')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    hrp2xwav_multidir;
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
        set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
        set(HANDLES.fig.main, 'Pointer', 'arrow');
        set(HANDLES.fig.msg, 'Pointer', 'arrow');
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
    if isfield(PARAMS, 'head')
        PARAMS = rmfield(PARAMS, 'head');
    end
    
    d = 1;      % d=1: display output to command window
    [fname,fpath]=uigetfile('*.hrp','Select HRP file to read disk Directory');
    filename = [fpath,fname];
    if isfield(PARAMS, 'head')
        PARAMS = rmfield(PARAMS, 'head');
    end
    % if the cancel button is pushed, then no file is loaded so exit this script
    if strcmp(num2str(fname),'0')
        set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
        set(HANDLES.fig.main, 'Pointer', 'arrow');
        set(HANDLES.fig.msg, 'Pointer', 'arrow');
        return
    else % get raw HARP disk directory
        read_rawHARPdir(filename,d)
    end
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');
    
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box
elseif strcmp(action,'make_SpotCheck')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    d = 1;      % d=1: display output to command window
    hpath=uigetdir('*.hrp','Select HRP directory for Spot Checking');
    % if the cancel button is pushed, then no file is loaded so exit this script
    if strcmp(num2str(hpath),'0')
        set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
        set(HANDLES.fig.main, 'Pointer', 'arrow');
        set(HANDLES.fig.msg, 'Pointer', 'arrow');
        return
    else % get raw HARP disk directory
        mk_SpotCheck(hpath,d)
    end
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'make_ltsa_multidir')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    xwav2ltsa_multidir;
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
    
    
    prompt={'Whole directory [0] or One File [1] : '};
    
    def={num2str(1)};
    
    dlgTitle='Difftime One HRP Head File or Whole Directory ?';
    lineNo=1;
    AddOpts.Resize='on';
    AddOpts.WindowStyle='normal';
    AddOpts.Interpreter='tex';
    % display input dialog box window
    in=inputdlg(prompt,dlgTitle,lineNo,def,AddOpts);
    if isempty(in)	% if cancel button pushed
        disp_msg('Cancel button pushed')
        return
    else
        fflag = str2num(deal(in{1}));
    end
    
    if fflag == 1   % only one file
        [fname,fpath]=uigetfile('*.hrp','Select HRP HEAD file to Check Directory Listing Times');
        filename = [fpath,fname];
        
        % if the cancel button is pushed, then no file is loaded so exit this script
        if strcmp(num2str(fname),'0')
            disp_msg('Cancel button pushed')
            return
        end
        
        check_dirlist_times(fullfile(fpath, fname))
        
    elseif fflag == 0   % all *.head.hrp in directory
        PARAMS.headall = [];
        PARAMS.inpath = uigetdir(PARAMS.inpath,'Select Directory with *.hrp files');
        if PARAMS.inpath == 0	% if cancel button pushed
            disp_msg('Cancel button pushed')
            return
        else
            d = dir(fullfile(PARAMS.inpath,'*.hrp'));    % hrp head files
            fn = char(d.name);      % file names in directory
            fnsz = size(fn);        % number of data files in directory
            nfiles = fnsz(1);
            
            filenames = [];
            for i = 1:nfiles
                filenames = vertcat(filenames, fullfile(PARAMS.inpath, fn(i, :)));
            end
        end
        
        if nfiles < 1
            disp_msg(['No data files in this directory: ',PARAMS.inpath])
            disp_msg('Pick another directory')
            hrppd('ck_dirlist_times');
        end
        
        check_dirlist_times(filenames)
    else
        disp_msg(' ')
        disp_msg('Error : Choose [1] or [0]')
        disp_msg(['You chose : ',num2str(fflag)])
        disp_msg(' ')
    end
    
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
    
elseif strcmp(action, 'fixtimes')
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    
    fix_dirlistTimes;
    
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');
    
    elseif strcmp(action, 'timecheck')
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    
    timeCheck_dirlist;
    
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');
    
end

