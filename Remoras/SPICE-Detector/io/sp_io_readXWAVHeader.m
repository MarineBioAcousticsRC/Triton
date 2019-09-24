function hdr = sp_io_readXWAVHeader(Filename, p, varargin)
% hdr = ioReadXWAVHeader(Filename, OptionalArgs)
%
% reads pseudo-wav (XWAV or *.x.wav) file header
% Optional arguments:
%       'ftype', N - Read file of type N.  N=1 --> wav, N=2 --> xwav (default)
%
% Do not modify the following line, maintained by CVS
% $Id: ioReadXWAVHeader.m,v 1.11 2008/06/23 16:42:56 mroch Exp $

% make hdr.xhd empty
PARAMS = [];
hdr.xhd = [];
PARAMS.fnameTimeRegExp = p.DateRegExp;
% Default for optional argument
ftype = 2;

vidx=1;
while vidx <= length(varargin)
    switch varargin{vidx}
        case 'fType'
            ftype = varargin{vidx+1};
            vidx=vidx+2;
        otherwise
            error('Optional argument %s not recognized', varargin{vidx});
    end
end



if ftype == 1       % do the following for wav files

    hdr = sp_io_readWavHeader(Filename, p.DateRegExp);

elseif ftype == 2               % do the following for xwavs
    fid = fopen(Filename,'r');
    if fid == -1
        error('Unable to open %s', Filename)
    end
    hdr.filetype = 'xwav';
    hdr.fType = 'xwav';
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % RIFF chunk
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hdr.xhd.ChunkID = char(fread(fid,4,'uchar'))';       % "RIFF"
    hdr.xhd.ChunkSize = fread(fid,1,'uint32');           % File size - 8 bytes
    filesize = getfield(dir(Filename),'bytes');
    if hdr.xhd.ChunkSize ~= filesize - 8
        warning('Error - incorrect Chunk Size')
        %     return    % comment to work with bad files
    end
    hdr.xhd.Format = char(fread(fid,4,'uchar'))';        % "WAVE"

    if ~strcmp(hdr.xhd.ChunkID,'RIFF') || ~strcmp(hdr.xhd.Format,'WAVE')
        error('not wav file - exit')
        
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Format Subchunk
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hdr.xhd.fSubchunkID = char(fread(fid,4,'uchar'))';    % "fmt "
    hdr.xhd.fSubchunkSize = fread(fid,1,'uint32');        % (Size of Subchunk - 8) = 16 bytes (PCM)
    hdr.xhd.AudioFormat = fread(fid,1,'uint16');         % Compression code (PCM = 1)
    hdr.xhd.NumChannels = fread(fid,1,'uint16');         % Number of Channels
    hdr.xhd.SampleRate = fread(fid,1,'uint32');          % Sampling Rate (samples/second)
    hdr.xhd.ByteRate = fread(fid,1,'uint32');            % Byte Rate = SampleRate * NumChannels * BitsPerSample / 8
    hdr.xhd.BlockAlign = fread(fid,1,'uint16');          % # of Bytes per Sample Slice = NumChannels * BitsPerSample / 8
    hdr.xhd.BitsPerSample = fread(fid,1,'uint16');       % # of Bits per Sample : 8bit = 8, 16bit = 16, etc

    if ~strcmp(hdr.xhd.fSubchunkID,'fmt ') || hdr.xhd.fSubchunkSize ~= 16
        error('unknown wav format - exit')
        
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
    hdr.nBits = hdr.xhd.BitsPerSample;       % # of Bits per Sample : 8bit = 8, 16bit = 16, etc
    hdr.samp.byte = floor(hdr.nBits/8);       % # of Bytes per Sample

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % HARP Subchunk
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hdr.xhd.hSubchunkID = char(fread(fid,4,'uchar'))';    % "harp"
    if strcmp(hdr.xhd.hSubchunkID,'data')
        disp('normal wav file - read data now')
        return
    elseif ~strcmp(hdr.xhd.hSubchunkID,'harp')
        disp('unsupported wav format')
        error(['SubchunkID = ',hdr.xhd.hSubchunkID])
        return
    end
    hdr.xhd.hSubchunkSize = fread(fid,1,'uint32');        % (Size of Subchunk - 8) includes write subchunk
    hdr.xhd.WavVersionNumber = fread(fid,1,'uchar');     % Version number of the "harp" header (0-255)
    hdr.xhd.FirmwareVersionNuumber = char(fread(fid,10,'uchar'))';  % HARP Firmware Vesion
    hdr.xhd.InstrumentID = char(fread(fid,4,'uchar'))';         % Instrument ID Number (0-255)
    hdr.xhd.SiteName = char(fread(fid,4,'uchar'))';             % Site Name, 4 alpha-numeric characters
    hdr.xhd.ExperimentName = char(fread(fid,8,'uchar'))';       % Experiment Name
    hdr.xhd.DiskSequenceNumber = fread(fid,1,'uchar');   % Disk Sequence Number (1-16)
    hdr.xhd.DiskSerialNumber = char(fread(fid,8,'uchar'))';     % Disk Serial Number
    hdr.xhd.NumOfRawFiles = fread(fid,1,'uint16');         % Number of RawFiles in XWAV file
    hdr.xhd.Longitude = fread(fid,1,'int32');           % Longitude (+/- 180 degrees) * 100,000
    hdr.xhd.Latitude = fread(fid,1,'int32');            % Latitude (+/- 90 degrees) * 100,000
    hdr.xhd.Depth = fread(fid,1,'int16');               % Depth, positive == down
    hdr.xhd.Reserved = fread(fid,8,'uchar')';            % Padding to extend subchunk to 64 bytes

    if hdr.xhd.hSubchunkSize ~= (64 - 8 + hdr.xhd.NumOfRawFiles * 32)
        disp('Error - HARP SubchunkSize and NumOfRawFiles discrepancy?')
        disp(['hSubchunkSize = ',num2str(hdr.xhd.hSubchunkSize)])
        error(['NumOfRawFiles = ',num2str(hdr.xhd.NumOfRawFiles)])
        
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % write sub-sub chunk
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1:hdr.xhd.NumOfRawFiles
        % Start of Raw file :
        hdr.xhd.year(i) = fread(fid,1,'uchar');          % Year
        hdr.xhd.month(i) = fread(fid,1,'uchar');         % Month
        hdr.xhd.day(i) = fread(fid,1,'uchar');           % Day
        hdr.xhd.hour(i) = fread(fid,1,'uchar');          % Hour
        hdr.xhd.minute(i) = fread(fid,1,'uchar');        % Minute
        hdr.xhd.secs(i) = fread(fid,1,'uchar');          % Seconds
        hdr.xhd.ticks(i) = fread(fid,1,'uint16');        % Milliseconds
        hdr.xhd.byte_loc(i) = fread(fid,1,'uint32');     % Byte location in xwav file of RawFile start
        hdr.xhd.byte_length(i) = fread(fid,1,'uint32');    % Byte length of RawFile in xwav file
        hdr.xhd.write_length(i) = fread(fid,1,'uint32'); % # of blocks in RawFile length (default = 60000)
        hdr.xhd.sample_rate(i) = fread(fid,1,'uint32');  % sample rate of this RawFile
        hdr.xhd.gain(i) = fread(fid,1,'uint8');          % gain (1 = no change)
        hdr.xhd.padding = fread(fid,7,'uchar');    % Padding to make it 32 bytes...misc info can be added here

        % should only be needed for special case bad data
        % remove after debugging
        %     if hdr.xhd.sample_rate(i) == 100000
        %         %   disp('Warning, changing sample rate from 100,000 to 200,000 Hz')
        % %         hdr.xhd.sample_rate(i) = 200000;
        %          hdr.xhd.sample_rate(i) = 500000;
        %
        %     end

        % calculate starting time [dnum => datenum in days] for each raw
        % write/buffer flush
        if hdr.xhd.year(i)<1900 % catch for year 2000 issue if comparing with guided detector dates.
            hdr.xhd.year(i) = hdr.xhd.year(i)+2000;
        end
        hdr.raw.dnumStart(i) = datenum([hdr.xhd.year(i) hdr.xhd.month(i)...
            hdr.xhd.day(i) hdr.xhd.hour(i) hdr.xhd.minute(i) ...
            hdr.xhd.secs(i)+(hdr.xhd.ticks(i)/1000)]);
        hdr.raw.dvecStart(i,:) = [hdr.xhd.year(i) hdr.xhd.month(i)...
            hdr.xhd.day(i) hdr.xhd.hour(i) hdr.xhd.minute(i) ...
            hdr.xhd.secs(i)+(hdr.xhd.ticks(i)/1000)];

        % end of RawFile:
        hdr.raw.dnumEnd(i) = hdr.raw.dnumStart(i) ...
            + datenum([0 0 0 0 0 (hdr.xhd.byte_length(i) - 2)  ./  hdr.xhd.ByteRate]);
        hdr.raw.dvecEnd(i,:) = hdr.raw.dvecStart(i,:) ...
            + [0 0 0 0 0 (hdr.xhd.byte_length(i) - 2)  ./  hdr.xhd.ByteRate];
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DATA Subchunk
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hdr.xhd.dSubchunkID = char(fread(fid,4,'uchar'))';    % "data"
    if ~strcmp(hdr.xhd.dSubchunkID,'data')
        warning('hummm, should be "data" here?')
        error(['SubchunkID = ',hdr.xhd.dSubchunkID])
        
    end
    hdr.xhd.dSubchunkSize = fread(fid,1,'uint32');        % (Size of Subchunk - 8) includes write subchunk

    % read some data and check
    %data = fread(fid,[4,100],'int16');

    fclose(fid);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % rename a few things
    %
    hdr.nch = hdr.xhd.NumChannels;         % Number of Channels
    hdr.fs = hdr.xhd.sample_rate(1);      % Real xwav Sampling Rate (samples/second)
    % hdr.fs = hdr.xhd.SampleRate;        % Sampling Rate(samples/second)
    % this is 'wav sample rate,
    % could be fake...

    % vectors (NumOfWrites)
    hdr.xgain = hdr.xhd.gain;          % gain (1 = no change)
    samp = hdr.xhd.byte_length ./ (hdr.nch * hdr.samp.byte); % # of Samples = Bytes of data / (# of Bytes per Sample Slice = NumChannels * BitsPerSample / 8)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % the following assume continuous recording (no schedule)
    % total number of samples in file
    % hdr.samp.data = sum(sum(samp));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % set up some triton timing stuff:

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % new stuff to count in samples and simplify timing
    %
    % smw 050511
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % hdr.start.dvec(1) = hdr.xhd.year(1);
    % hdr.start.dvec(2) = hdr.xhd.month(1);
    % hdr.start.dvec(3) = hdr.xhd.day(1);
    % hdr.start.dvec(4) = hdr.xhd.hour(1);
    % hdr.start.dvec(5) = hdr.xhd.minute(1);
    % hdr.start.dvec(6) = hdr.xhd.secs(1) + hdr.xhd.ticks(1)/1000;
    %
    % hdr.start.dnum = datenum(hdr.start.dvec);

    hdr.start.dnum = hdr.raw.dnumStart(1);
    hdr.start.dvec = hdr.raw.dvecStart(1,:);
    %hdr.end.sample = hdr.samp.data;       % last sample of file
    %hdr.end.dnum = hdr.start.dnum + datenum([0 0 0 0 0 hdr.end.sample/hdr.fs]);
    hdr.end.dnum = hdr.raw.dnumEnd(hdr.xhd.NumOfRawFiles);

    % hdr.end.dvec = datevec(datenum(hdr.start.dvec + [0 0 0 0 0
    % hdr.end.sample/hdr.fs]));
else
    fclose(all)
    error('Bad ftype')
end
