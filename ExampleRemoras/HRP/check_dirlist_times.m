function check_dirlist_times(void)
%
% check_dirlist_times
%
% asks for one file or whole directory, then get recording parameters and
% run difftime_dirlist for one file or whole directory
%
% called from toolpd
%
% 061030 smw
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS HANDLES

prompt={'Whole directory [0] or One File [1] : '};

def={num2str(1)};

dlgTitle='Difftime One HRP Head File or Whole Directory ?';
lineNo=1;
AddOpts.Resize='on';
AddOpts.WindowStyle='normal';
AddOpts.Interpreter='tex';
% display input dialog box window
in=inputdlg(prompt,dlgTitle,lineNo,def,AddOpts);
if length(in) == 0	% if cancel button pushed
    disp_msg('Canceled button pushed')
    return
else
    fflag = str2num(deal(in{1}));
end

%%%%%%%%%%%%%%%%%%%%%%%

if fflag == 1   % only one file
    [fname,fpath]=uigetfile('*.hrp','Select HRP HEAD file to Check Directory Listing Times');
    filename = [fpath,fname];

    % if the cancel button is pushed, then no file is loaded so exit this script
    if strcmp(num2str(fname),'0')
        disp_msg('Canceled button pushed')
        return
    else % get raw HARP disk directory
        get_recordingparams;  % get recording parameters
        difftime_dirlist(filename,2);
        if PARAMS.head.numTimingError > 1
            figure(HANDLES.fig.main)
            if max(PARAMS.head.baddirlist(:,2)) ~= min(PARAMS.head.baddirlist(:,2))
                dh = ceil(max(PARAMS.head.baddirlist(:,2)) - min(PARAMS.head.baddirlist(:,2)));
            else
                dh = 10;
            end
            hist(PARAMS.head.baddirlist(:,2),dh)
            title(filename)
            xlabel('Time between successive Directory Listings [seconds]')
            ylabel('Number')
        end
    end
elseif fflag == 0   % all *.head.hrp in directory
    PARAMS.headall = [];
    PARAMS.inpath = uigetdir(PARAMS.inpath,'Select Directory with *.hrp files');
    if PARAMS.inpath == 0	% if cancel button pushed
        disp_msg('Canceled button pushed')
        return
    end
%     d = dir(fullfile(PARAMS.inpath,'*head.hrp'));    % hrp head files
    d = dir(fullfile(PARAMS.inpath,'*.hrp'));    % hrp head files
    fn = char(d.name);      % file names in directory
    fnsz = size(fn);        % number of data files in directory
    nfiles = fnsz(1);
    
    if nfiles < 1
        disp_msg(['No data files in this directory: ',PARAMS.inpath])
        disp_msg('Pick another directory')
        check_dirlist_times
    end
    get_recordingparams;  % get recording parameters
    for k = 1:nfiles
        difftime_dirlist(fullfile(PARAMS.inpath,fn(k,:)),0);
        mk_headSummary(k);
    end
    disp_headSummary(nfiles);
else
    disp_msg(' ')
    disp_msg('Error : Choose [1] or [0]')
    disp_msg(['You chose : ',num2str(fflag)])
    disp_msg(' ')
    check_dirlist_times
end
