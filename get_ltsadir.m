function get_ltsadir
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% get_ltsadir.m
%
% get directory of wave/xwav files
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global PARAMS 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the file type
%
prompt={'Enter File Type: (1 = WAVE, 2 = XWAV, 3 = FLAC)'};
def={num2str(PARAMS.ltsa.ftype)};
dlgTitle='Select File Type';
lineNo=1;
AddOpts.Resize='on';
AddOpts.WindowStyle='normal';
AddOpts.Interpreter='tex';
% display input dialog box window
in=inputdlg(prompt,dlgTitle,lineNo,def,AddOpts);
if length(in) == 0	% if cancel button pushed
    PARAMS.ltsa.gen = 0;
    return
else
    PARAMS.ltsa.gen = 1;
end
PARAMS.ltsa.ftype = str2num(deal(in{1}));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the directory
%
if PARAMS.ltsa.ftype == 1
    str1 = 'Select Directory with WAV files';
elseif PARAMS.ltsa.ftype == 2
    str1 = 'Select Directory with XWAV files';
elseif PARAMS.ltsa.ftype == 3
    str1 = 'Select Directory with FLAC files';
else
    disp_msg('Wrong file type. Input 1, 2, or 3 only')
    disp_msg(['Not ',num2str(PARAMS.ltsa.ftype)])
    get_ltsadir
end
ipnamesave = PARAMS.ltsa.indir;
PARAMS.ltsa.indir = uigetdir(PARAMS.ltsa.indir,str1);
if PARAMS.ltsa.indir == 0	% if cancel button pushed
    PARAMS.ltsa.gen = 0;
    PARAMS.ltsa.indir = ipnamesave;
    return
else
    PARAMS.ltsa.gen = 1;
    PARAMS.ltsa.indir = [PARAMS.ltsa.indir,'\'];
end

%%%%%%%%%%%%%%%%%%%%%%
% check for empty directory
%
if PARAMS.ltsa.ftype == 1
    d = dir(fullfile(PARAMS.ltsa.indir,'*.wav'));    % wav files
elseif PARAMS.ltsa.ftype == 2
    d = dir(fullfile(PARAMS.ltsa.indir,'*.x.wav'));    % xwav files
elseif PARAMS.ltsa.ftype == 3
    d = dir(fullfile(PARAMS.ltsa.indir,'*.flac'));    % flac files
end

fn = char(d.name);      % file names in directory
fnsz = size(fn);        % number of data files in directory
nfiles = fnsz(1);
disp_msg(' ')
disp_msg([num2str(nfiles),'  data files for LTSA'])
if fnsz(2)>80
    disp_msg('Error: filename length too long')
    disp_msg('Rename to 80 characters or less')
    disp_msg('Abort LTSA generation')
    return
end

if nfiles < 1
    disp_msg(['No data files in this directory: ',PARAMS.ltsa.indir])
    disp_msg('Pick another directory')
    get_ltsadir
end

if PARAMS.ltsa.ftype == 1 || PARAMS.ltsa.ftype == 3
    % sort filenames into ascending order based on time stamp of file name
    % don't rely on filename only for order
    % timing stuff:
    dnums = wavname2dnum(fn);
    if isempty(dnums)
        dnumStart = datenum([0 1 1 0 0 0]);
    else
        dnumStart = dnums - datenum([2000 0 0 0 0 0]);
    end    
   
    % sort times
    [B,index] = sortrows(dnumStart');
    % put file name in PARAMS
    PARAMS.ltsa.fname = fn(index,:);
elseif PARAMS.ltsa.ftype == 2
    % filenames
    PARAMS.ltsa.fname = fn;
end


