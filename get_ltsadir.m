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
prompt={'Enter File Type: (1 = WAVE, 2 = XWAV (.x.wav or .x.flac), 3 = FLAC)'};
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
    str1 = 'Select Directory with XWAV files (.x.wav or .x.flac)';
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
    if isempty(d)
        % An x.flac is an xwav that happens to be compressed: same harp header,
        % same raw files, same times. Everything downstream of here treats it
        % as ftype 2, and only xwav_read knows the difference. Type 3 is for
        % plain flacs, which have no harp header at all.
        d = dir(fullfile(PARAMS.ltsa.indir,'*.x.flac'));
    else
        dflac = dir(fullfile(PARAMS.ltsa.indir,'*.x.flac'));
        if ~isempty(dflac)
            disp_msg(['Note: this directory holds both .x.wav and .x.flac files. ', ...
                'Using the ',num2str(length(d)),' .x.wav files.'])
        end
    end
elseif PARAMS.ltsa.ftype == 3
    d = dir(fullfile(PARAMS.ltsa.indir,'*.flac'));    % flac files
    % *.flac also matches *.x.flac, which is an xwav and must not be read as a
    % plain flac: that would ignore the harp header and take each file's start
    % time from its name instead, which is wrong by however much the recorder
    % clock drifted, with nothing on screen to show it. Decide from the files
    % themselves, since an xwav need not be named .x.flac.
    nXwav = 0;
    for fk = 1:length(d)
        if ck_xflac_isxwav(fullfile(PARAMS.ltsa.indir,d(fk).name))
            nXwav = nXwav + 1;
        end
    end
    if nXwav == length(d) && nXwav > 0
        disp_msg('These flac files carry harp headers - treating them as XWAVs')
        PARAMS.ltsa.ftype = 2;
    elseif nXwav > 0
        disp_msg(['Warning - ',num2str(nXwav),' of ',num2str(length(d)), ...
            ' flac files carry a harp header'])
        disp_msg('  Reading them as plain flac ignores their recording times.')
        disp_msg('  Put the compressed XWAVs in their own folder and use type 2.')
    end
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


