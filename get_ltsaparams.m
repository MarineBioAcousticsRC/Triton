function get_ltsaparams
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% get_ltsaparams.m
%
% get parameters needed for generating LTSA's from user
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS 

if PARAMS.ltsa.ftype == 1 || PARAMS.ltsa.ftype == 3  % wav or flac file
    prompt={'Enter Time Average Length [seconds] : ',...
        'Enter Frequency Bin Size [Hz] :'};
elseif PARAMS.ltsa.ftype == 2    % xwav file type
    prompt={'Enter Time Average Length [seconds] : ',...
        'Enter Frequency Bin Size [Hz] :'};
         %'XWAV data recorded by HARP = 1, ARP = 2, OBS = 3 : '};
end


def={num2str(PARAMS.ltsa.tave),...
    num2str(PARAMS.ltsa.dfreq)};

dlgTitle='Set Long-Term Spectrogram Parameters';
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

PARAMS.ltsa.tave = str2num(deal(in{1}));

PARAMS.ltsa.dfreq = str2num(deal(in{2}));

if PARAMS.ltsa.ftype == 1 || PARAMS.ltsa.ftype == 3    % wav or flac file
    PARAMS.ltsa.dtype = 4;
else %PARAMS.ltsa.ftype == 2    % xwav file
    PARAMS.ltsa.dtype = 1;
end

% choose channel to LTSA if there is more than one channel in data file(s)
if PARAMS.ltsa.nch(1) > 1

    prompt={['Enter which channel to LTSA from 1 to ',...
        num2str(max(PARAMS.ltsa.nch)),' : ']};

    def={num2str(1)};

    dlgTitle='Choose Channel to LTSA';
    lineNo=1;
    AddOpts.Resize='on';
    AddOpts.WindowStyle='normal';
    AddOpts.Interpreter='tex';
    % display input dialog box window
    in2=inputdlg(prompt,dlgTitle,lineNo,def,AddOpts);
    if length(in2) == 0	% if cancel button pushed
        PARAMS.ltsa.ch = 1
    else
        PARAMS.ltsa.ch = str2num(deal(in2{1}));
    end

end