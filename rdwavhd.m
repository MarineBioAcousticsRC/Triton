function rdwavhd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% rdwavhd.m
%
% reads wav (WAV or *.wav) file header
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global PARAMS

PARAMS.wav.complete = 0;
% make PARAMS.xhd empty
PARAMS.xhd = [];
PARAMS.xhd.byte_length = [];
fid = fopen([PARAMS.inpath PARAMS.infile],'r');


% RIFF chunk
PARAMS.xhd.ChunkID = char(fread(fid,4,'uchar'))';       % "RIFF"
PARAMS.xhd.ChunkSize = fread(fid,1,'uint32');           % File size - 8 bytes
filesize = getfield(dir([PARAMS.inpath,PARAMS.infile]),'bytes');
if PARAMS.xhd.ChunkSize ~= filesize - 8
    disp_msg('Error - incorrect Chunk Size')
%     return    % comment to work with bad files
end
PARAMS.xhd.Format = char(fread(fid,4,'uchar'))';        % "WAVE"

if ~strcmp(PARAMS.xhd.ChunkID,'RIFF') || ~strcmp(PARAMS.xhd.Format,'WAVE')
    disp_msg('not wav file - exit')
    PARAMS.df = -1;
    return
end


% Format Subchunk
PARAMS.xhd.fSubchunkID = char(fread(fid,4,'uchar'))';   % "fmt "
PARAMS.xhd.fSubchunkSize = fread(fid,1,'uint32');       % (Size of Subchunk - 8) = 16 bytes (PCM)
while ~strcmp(PARAMS.xhd.fSubchunkID,'fmt ') || PARAMS.xhd.fSubchunkSize ~= 16
    
    try 
        seek1 = fseek(fid,PARAMS.xhd.fSubchunkSize,'cof');
        PARAMS.xhd.fSubchunkID = char(fread(fid,4,'uchar'))';
        PARAMS.xhd.fSubchunkSize = fread(fid,1,'uint32');
    catch e
        disp_msg('unknown wav format - exit')
        return
    end
end

PARAMS.xhd.AudioFormat = fread(fid,1,'uint16');         % Compression code (PCM = 1)
PARAMS.xhd.NumChannels = fread(fid,1,'uint16');         % Number of Channels
PARAMS.xhd.SampleRate = fread(fid,1,'uint32');          % Sampling Rate (samples/second)
PARAMS.xhd.ByteRate = fread(fid,1,'uint32');            % Byte Rate = SampleRate * NumChannels * BitsPerSample / 8
PARAMS.xhd.BlockAlign = fread(fid,1,'uint16');          % # of Bytes per Sample Slice = NumChannels * BitsPerSample / 8
PARAMS.xhd.BitsPerSample = fread(fid,1,'uint16');       % # of Bits per Sample : 8bit = 8, 16bit = 16, etc

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
PARAMS.samp.byte = floor(PARAMS.nBits/8);      % # of Bytes per Sample


% DATA Subchunk
PARAMS.xhd.dSubchunkID = char(fread(fid,4,'uchar'))';    % "data"
PARAMS.xhd.dSubchunkSize = fread(fid,1,'uint32');        % (Size of Subchunk - 8) includes write subchunk
PARAMS.xhd.dataIndex = ftell(fid);
while ~strcmp(PARAMS.xhd.dSubchunkID,'data')
    try
        seek = fseek(fid,PARAMS.xhd.dSubchunkSize,'cof');
        PARAMS.xhd.dSubchunkID = char(fread(fid,4,'uchar'))';    % "data"
        PARAMS.xhd.dSubchunkSize = fread(fid,1,'uint32');        % (Size of Subchunk - 8) includes write subchunk
        PARAMS.xhd.dataIndex = ftell(fid);
    catch
        disp_msg('hummm, should be "data" here?')
        disp_msg(['SubchunkID = ',PARAMS.xhd.dSubchunkID])
    end
end

fclose(fid);

% rename a few things
PARAMS.nch = PARAMS.xhd.NumChannels;         % Number of Channels
PARAMS.fs = PARAMS.xhd.SampleRate;          % Sampling Rate(samples/second)
                                            % this is 'wav sample rate,
                                            % could be fake...
PARAMS.wav.complete = 1;