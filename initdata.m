function initdata
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% initdata.m
%
% initializes data and timing info
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES PARAMS

set(HANDLES.fig.ctrl, 'Pointer', 'watch');

% Initialize PARAMS.xhd and PARAMS.raw
PARAMS.xhd = [];    % cleans out previous xwav file header params
PARAMS.raw = [];
PARAMS.xhd.byte_length = [];
% Initial times for both formats:
PARAMS.save.dnum = PARAMS.start.dnum;
PARAMS.start.dvec = datevec(PARAMS.start.dnum);

% Harp Chunk stuff incase it doesn't get set some other way ie wav file
% read
PARAMS.xhd.WavVersionNumber = 0;            % harp wav header version number
PARAMS.xhd.FirmwareVersionNumber = '1.xxxyyyzz';   % arp firmware version number, 10 chars
PARAMS.xhd.InstrumentID = '01  ';       % harp instrument number
PARAMS.xhd.SiteName = 'ABCD';             % site name
PARAMS.xhd.ExperimentName = 'EXP12345';   % experiment name
PARAMS.xhd.DiskSequenceNumber = 1;             % disk sequence number
PARAMS.xhd.DiskSerialNumber = '12345678'; % disk serial number
PARAMS.xhd.NumOfRawFiles = 1;
PARAMS.xhd.Longitude = -17912345;
PARAMS.xhd.Latitude = 8912345;
PARAMS.xhd.Depth = 6666;

if PARAMS.ftype == 1 || PARAMS.ftype == 3 % wav or flac
    % initialize data format
%     m = [];
%     [m d] = wavfinfo([PARAMS.inpath PARAMS.infile]);
%     if isempty(m)
%         disp_msg(d)
%         disp_msg('Try running wavDirTestFix.m on this directory to fix wav files')
%         return
%     end


%     [y, Fs, PARAMS.nBits, OPTS] = wavread( [PARAMS.inpath PARAMS.infile],10);
%     siz = wavread( [PARAMS.inpath PARAMS.infile], 'size' );
%     PARAMS.samp.data = siz(1);
%     PARAMS.nch = siz(2);
%     PARAMS.samp.byte = floor(PARAMS.nBits/8);
%     PARAMS.fs = Fs; % sample rate
    inwav = fullfile(PARAMS.inpath, PARAMS.infile); 
    try
        info = audioinfo(inwav);
    catch ME
        disp_msg(ME.message)
        dmsg = sprintf('Is %s a real wave file?', inwav);
        disp_msg(dmsg);
        return
    end
    PARAMS.nBits = info.BitsPerSample;
    PARAMS.samp.data = info.TotalSamples;
    PARAMS.nch = info.NumChannels;
    PARAMS.fs = info.SampleRate;
    PARAMS.samp.byte = floor(PARAMS.nBits/8);
    
    % just in case making xwav file out of wav file
    %     PARAMS.xhd.BitsPerSample = PARAMS.nch * PARAMS.samp.byte;
    PARAMS.xhd.BitsPerSample = PARAMS.nch * PARAMS.nBits;
    PARAMS.xhd.ByteRate = PARAMS.fs*PARAMS.xhd.BitsPerSample;
    PARAMS.end.sample = PARAMS.samp.data;       % last sample of file
    PARAMS.end.dnum = PARAMS.start.dnum + datenum([0 0 0 0 0 PARAMS.end.sample/PARAMS.fs]);
    
    % needed for saving wav file displayed as xwav
    PARAMS.xhd.gain = 1;
    PARAMS.xhd.sample_rate = PARAMS.fs;
    
elseif PARAMS.ftype == 2
    rdxwavhd
end
PARAMS.ch = 1;  % set to first channel for reading single after multichannel files
% data block set up
PARAMS.samp.head = 0;
PARAMS.samp.null = 0;
%*********************************
%
% set up time stuff
%
%*********************************

if PARAMS.freq1 == -1 || PARAMS.freq1 > PARAMS.fs/2
    PARAMS.freq1 = PARAMS.fs/2;
    set(HANDLES.endfreq.edtxt,'String',PARAMS.freq1);
    PARAMS.freq0 = 0;
end
PARAMS.fmax = PARAMS.fs/2;
%
if PARAMS.freq1 > PARAMS.fmax
    PARAMS.freq1 = PARAMS.fmax;  %  display full scale if new file is different size
    set(HANDLES.endfreq.edtxt,'String',PARAMS.freq1);   % update editable text control
    
else
    set(HANDLES.endfreq.edtxt,'String',PARAMS.freq1);
    set(HANDLES.stfreq.edtxt,'String',PARAMS.freq0);
end

if PARAMS.ftype == 1
    PARAMS.plot.dvec = PARAMS.start.dvec;
    PARAMS.plot.dnum = PARAMS.start.dnum;
    % new stuff needed v1.60
    PARAMS.raw.dnumStart = PARAMS.start.dnum;
    PARAMS.raw.dvecStart = PARAMS.start.dvec;
    PARAMS.raw.dnumEnd = PARAMS.end.dnum;
    PARAMS.raw.dvecEnd = datevec(PARAMS.end.dnum);
elseif PARAMS.ftype == 2
    % plot initial start time
    PARAMS.plot.dvec = PARAMS.start.dvec;
    PARAMS.plot.dnum = PARAMS.start.dnum;
end
%
set(HANDLES.chan,'Visible','on');
if PARAMS.nch == 1
    set(HANDLES.ch.pop,'String','1')
    set(HANDLES.ch.pop,'Value',1)
    set(HANDLES.ch.txt, 'Visible', 'off')
    set(HANDLES.ch.pop, 'Visible', 'off')
    set(HANDLES.mc.on,'Value',0)
    set(HANDLES.mc.on,'Visible','off')
elseif PARAMS.nch > 1 && PARAMS.nch < 33
    for k = 1:PARAMS.nch
        str{k} = num2str(k);
    end
    set(HANDLES.ch.pop,'String',str);
    set(HANDLES.ch.txt, 'Visible', 'on')
    set(HANDLES.ch.pop, 'Visible', 'on')
elseif PARAMS.nch >= 33
    disp_msg(['Too many channels - should be less than 33'])
    disp_msg(['Total number of channel is : ',num2str(PARAMS.nch)])
end
%
% turn on mouse movement display
set(HANDLES.fig.main,'WindowButtonMotionFcn','control(''coorddisp'')');
set(HANDLES.fig.main,'WindowButtonDownFcn',@pickxyz);

% turn on msg window edit text box for pickxyz display
set(HANDLES.pick.disp,'Visible','on')
% turn on pickxyz toggle button
set(HANDLES.pick.button,'Visible','on')
% enable msg window File pulldown save pickxyz
set(HANDLES.savepicks,'Enable','on')

set(HANDLES.filtcontrol,'Visible','on')
set(HANDLES.snd.button,'Visible','on')
set(HANDLES.displaycontrol,'Visible','on')
% turn on tools
% turn on sound control
if( exist('audioplayer') )
    %audvidplayer
    set(HANDLES.sndcontrol,'Visible','on')
else
    disp_msg('no audioplayer')
    % snd_v140
end
set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
