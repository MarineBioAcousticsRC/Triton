function get_recordingparams
%
% get recording parameters needed for checking dirlist times
%
% called by tool_pd
%
% 061030 smw
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS

prompt={'Enter Sample Rate [kHz] : ',...
    'Enter Recording Interval [min, 0=continuous] :',...
    'Enter Recording Duration [min, 0=continuous] : ',...
    'Enter Recording Number of Channels [1 or 4] :'};

def={num2str(PARAMS.rec.sr),...
    num2str(PARAMS.rec.int),...
    num2str(PARAMS.rec.dur),...
    num2str(PARAMS.rec.nch)};

dlgTitle='Enter Recording Parameters';
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

    PARAMS.rec.sr = str2num(deal(in{1}));

    PARAMS.rec.int = str2num(deal(in{2}));
    
    % 0 if continuous
    if PARAMS.rec.int == 0
        PARAMS.rec.dur = 0;
    else
        PARAMS.rec.dur = str2num(deal(in{3}));
    end
    
    PARAMS.rec.nch = str2num(deal(in{4}));
end
