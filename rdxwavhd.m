function rdxwavhd
% 3/2/2011
% rdxwavhd.m
%
% reads pseudo-wav (XWAV or *.x.wav) file header
%
% functionized it for triton (less general, but puts values in global
% varibable PARAMS space
% smw 20 Oct, 2004
%
% smw 3-12 Aug, 2004 update again...introduced gain
%
% 060203smw updated for using all timing headers
%
% 060610 smw renamed PARAMS.xhd.SubchunkID and SubchunkSize with
% prefixes f,h,d for format, harp, and data subchunks
%
%clear all
%clc

global PARAMS

% make PARAMS.xhd empty
PARAMS.xhd = [];

fid =  fopen(fullfile(PARAMS.inpath,PARAMS.infile),'r');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RIFF chunk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PARAMS.xhd.ChunkID = char(fread(fid,4,'uchar'))';       % "RIFF"
PARAMS.xhd.ChunkSize = fread(fid,1,'uint32');           % File size - 8 bytes
filesize = getfield(dir(fullfile(PARAMS.inpath,PARAMS.infile)),'bytes');
if PARAMS.xhd.ChunkSize ~= filesize - 8
    disp_msg('Error - incorrect Chunk Size')  
%     return    % comment to work with bad files
end
PARAMS.xhd.Format = char(fread(fid,4,'uchar'))';        % "WAVE"

if ~strcmp(PARAMS.xhd.ChunkID,'RIFF') || ~strcmp(PARAMS.xhd.Format,'WAVE')
    disp_msg('not wav file - exit')
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Format Subchunk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PARAMS.xhd.fSubchunkID = char(fread(fid,4,'uchar'))';    % "fmt "
PARAMS.xhd.fSubchunkSize = fread(fid,1,'uint32');        % (Size of Subchunk - 8) = 16 bytes (PCM)
PARAMS.xhd.AudioFormat = fread(fid,1,'uint16');         % Compression code (PCM = 1)
PARAMS.xhd.NumChannels = fread(fid,1,'uint16');         % Number of Channels
PARAMS.xhd.SampleRate = fread(fid,1,'uint32');          % Sampling Rate (samples/second)
PARAMS.xhd.ByteRate = fread(fid,1,'uint32');            % Byte Rate = SampleRate * NumChannels * BitsPerSample / 8
PARAMS.xhd.BlockAlign = fread(fid,1,'uint16');          % # of Bytes per Sample Slice = NumChannels * BitsPerSample / 8
PARAMS.xhd.BitsPerSample = fread(fid,1,'uint16');       % # of Bits per Sample : 8bit = 8, 16bit = 16, etc

if ~strcmp(PARAMS.xhd.fSubchunkID,'fmt ') || PARAMS.xhd.fSubchunkSize ~= 16
    disp_msg('unknown wav format - exit')
    return
end

% should only be needed for special case bad data
% remove after debugged
% if PARAMS.xhd.SampleRate == 100000
%     disp_msg('Warning, changing sample rate from 100,000 to 500,000 Hz')
% %     PARAMS.xhd.SampleRate = 200000;
% %     PARAMS.xhd.ByteRate = 400000;
%     PARAMS.xhd.SampleRate = 500000;
%     PARAMS.xhd.ByteRate = 1000000;
% end

% copy to another name, and get number of bytes per sample
PARAMS.nBits = PARAMS.xhd.BitsPerSample;       % # of Bits per Sample : 8bit = 8, 16bit = 16, etc
PARAMS.samp.byte = floor(PARAMS.nBits/8);       % # of Bytes per Sample

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HARP Subchunk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PARAMS.xhd.hSubchunkID = char(fread(fid,4,'uchar'))';    % "harp"
if strcmp(PARAMS.xhd.hSubchunkID,'data')
    PARAMS.fs = PARAMS.xhd.SampleRate;
    disp_msg('normal wav file - read data now')
    return
elseif ~strcmp(PARAMS.xhd.hSubchunkID,'harp')
    disp_msg('unsupported wav format')
    disp_msg(['SubchunkID = ',PARAMS.xhd.hSubchunkID])
    return
end
PARAMS.xhd.hSubchunkSize = fread(fid,1,'uint32');        % (Size of Subchunk - 8) includes write subchunk
PARAMS.xhd.WavVersionNumber = fread(fid,1,'uchar');     % Version number of the "harp" header (0-255)
PARAMS.xhd.FirmwareVersionNumber = char(fread(fid,10,'uchar'))';  % HARP Firmware Vesion
PARAMS.xhd.InstrumentID = char(fread(fid,4,'uchar'))';         % Instrument ID Number (0-255)
PARAMS.xhd.SiteName = char(fread(fid,4,'uchar'))';             % Site Name, 4 alpha-numeric characters
PARAMS.xhd.ExperimentName = char(fread(fid,8,'uchar'))';       % Experiment Name
PARAMS.xhd.DiskSequenceNumber = fread(fid,1,'uchar');   % Disk Sequence Number (1-16)
PARAMS.xhd.DiskSerialNumber = char(fread(fid,8,'uchar'))';     % Disk Serial Number
PARAMS.xhd.NumOfRawFiles = fread(fid,1,'uint16');         % Number of RawFiles in XWAV file
PARAMS.xhd.Longitude = fread(fid,1,'int32');           % Longitude (+/- 180 degrees) * 100,000
PARAMS.xhd.Latitude = fread(fid,1,'int32');            % Latitude (+/- 90 degrees) * 100,000
PARAMS.xhd.Depth = fread(fid,1,'int16');               % Depth, positive == down
if PARAMS.xhd.WavVersionNumber == 2
    PARAMS.xhd.drate = fread(fid,PARAMS.xhd.NumChannels,'single');
end
PARAMS.xhd.Reserved = fread(fid,8,'uchar')';            % Padding to extend subchunk to 64 bytes

if PARAMS.xhd.WavVersionNumber == 2
    hscs = (64 + 4*PARAMS.xhd.NumChannels) - 8 + PARAMS.xhd.NumOfRawFiles * (32 + 4*PARAMS.xhd.NumChannels);
else
    hscs = 64 - 8 + PARAMS.xhd.NumOfRawFiles * 32;
end
if PARAMS.xhd.hSubchunkSize ~= hscs
    disp_msg('Error - HARP SubchunkSize and NumOfRawFiles discrepancy?')
    disp_msg(['hSubchunkSize = ',num2str(PARAMS.xhd.hSubchunkSize)])
    disp_msg(['NumOfRawFiles = ',num2str(PARAMS.xhd.NumOfRawFiles)])
 %   return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write sub-sub chunk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:PARAMS.xhd.NumOfRawFiles
                                                        % Start of Raw file :
    PARAMS.xhd.year(i) = fread(fid,1,'uchar');          % Year
    PARAMS.xhd.month(i) = fread(fid,1,'uchar');         % Month
    PARAMS.xhd.day(i) = fread(fid,1,'uchar');           % Day
    PARAMS.xhd.hour(i) = fread(fid,1,'uchar');          % Hour
    PARAMS.xhd.minute(i) = fread(fid,1,'uchar');        % Minute
    PARAMS.xhd.secs(i) = fread(fid,1,'uchar');          % Seconds
    PARAMS.xhd.ticks(i) = fread(fid,1,'uint16');        % Milliseconds
    PARAMS.xhd.byte_loc(i) = fread(fid,1,'uint32');     % Byte location in xwav file of RawFile start
    PARAMS.xhd.byte_length(i) = fread(fid,1,'uint32');    % Byte length of RawFile in xwav file
    PARAMS.xhd.write_length(i) = fread(fid,1,'uint32'); % # of blocks in RawFile length (default = 60000)
    PARAMS.xhd.sample_rate(i) = fread(fid,1,'uint32');  % sample rate of this RawFile
    PARAMS.xhd.gain(i) = fread(fid,1,'uint8');          % gain (1 = no change)
    PARAMS.xhd.padding = fread(fid,7,'uchar');    % Padding to make it 32 bytes...misc info can be added here
    if PARAMS.xhd.WavVersionNumber == 2
        PARAMS.xhd.dt = fread(fid,PARAMS.xhd.NumChannels,'single');     % time diff to channel 1
    end
    
    % should only be needed for special case bad data
    % remove after debugging
%     if PARAMS.xhd.sample_rate(i) == 100000
%         %   disp('Warning, changing sample rate from 100,000 to 200,000 Hz')
% %         PARAMS.xhd.sample_rate(i) = 200000;
%          PARAMS.xhd.sample_rate(i) = 500000;
% 
%     end
    
    % calculate starting time [dnum => datenum in days] for each raw
    % write/buffer flush
    PARAMS.raw.dnumStart(i) = datenum([PARAMS.xhd.year(i) PARAMS.xhd.month(i)...
        PARAMS.xhd.day(i) PARAMS.xhd.hour(i) PARAMS.xhd.minute(i) ...
        PARAMS.xhd.secs(i)+(PARAMS.xhd.ticks(i)/1000)]);
    PARAMS.raw.dvecStart(i,:) = [PARAMS.xhd.year(i) PARAMS.xhd.month(i)...
        PARAMS.xhd.day(i) PARAMS.xhd.hour(i) PARAMS.xhd.minute(i) ...
        PARAMS.xhd.secs(i)+(PARAMS.xhd.ticks(i)/1000)];
    
    % end of RawFile:
    PARAMS.raw.dnumEnd(i) = PARAMS.raw.dnumStart(i) ...
        + datenum([0 0 0 0 0 (PARAMS.xhd.byte_length(i) - 2)  ./  PARAMS.xhd.ByteRate]);
    PARAMS.raw.dvecEnd(i,:) = PARAMS.raw.dvecStart(i,:) ...
        + [0 0 0 0 0 (PARAMS.xhd.byte_length(i) - 2)  ./  PARAMS.xhd.ByteRate];
%     PARAMS.raw.dnumEnd(i) = PARAMS.raw.dnumStart(i) ...
%         + datenum([0 0 0 0 0 ceil((PARAMS.xhd.byte_length(i))  ./  (PARAMS.xhd.ByteRate * PARAMS.xhd.NumChannels))]);
%     PARAMS.raw.dvecEnd(i,:) = PARAMS.raw.dvecStart(i,:) ...
%         + [0 0 0 0 0 (PARAMS.xhd.byte_length(i))  ./  (PARAMS.xhd.ByteRate * PARAMS.xhd.NumChannels)];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATA Subchunk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PARAMS.xhd.dSubchunkID = char(fread(fid,4,'uchar'))';    % "data"
if ~strcmp(PARAMS.xhd.dSubchunkID,'data')
    disp_msg('hummm, should be "data" here?')
    disp_msg(['SubchunkID = ',PARAMS.xhd.dSubchunkID])
    return
end
PARAMS.xhd.dSubchunkSize = fread(fid,1,'uint32');        % (Size of Subchunk - 8) includes write subchunk

% read some data and check
%data = fread(fid,[4,100],'int16');

fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rename a few things
%
PARAMS.nch = PARAMS.xhd.NumChannels;         % Number of Channels
PARAMS.fs = PARAMS.xhd.sample_rate(1);      % Real xwav Sampling Rate (samples/second)
% PARAMS.fs = PARAMS.xhd.SampleRate;        % Sampling Rate(samples/second)
                                            % this is 'wav sample rate,
                                            % could be fake...

% vectors (NumOfWrites)
PARAMS.xgain = PARAMS.xhd.gain;          % gain (1 = no change)
samp = PARAMS.xhd.byte_length ./ (PARAMS.nch * PARAMS.samp.byte); % # of Samples = Bytes of data / (# of Bytes per Sample Slice = NumChannels * BitsPerSample / 8)

PARAMS.start.dnum = PARAMS.raw.dnumStart(1);
PARAMS.start.dvec = PARAMS.raw.dvecStart(1,:);
PARAMS.end.dnum = PARAMS.raw.dnumEnd(PARAMS.xhd.NumOfRawFiles);