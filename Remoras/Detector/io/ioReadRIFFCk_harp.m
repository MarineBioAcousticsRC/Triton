function harp = ioReadRIFFCk_harp(fid, Chunk, Fmt)
% harp = ioReadRIFFCk_harp(f_handle, Chunk, Fmt)
% Read HARP information chunk

harp.xhd.hSubchunkSize = Chunk.DataSize;    % bytes in HARP chunk data
harp.xhd.WavVersionNumber = fread(fid,1,'uchar');     % Version number of the "harp" header (0-255)
harp.xhd.FirmwareVersionNuumber = char(fread(fid,10,'uchar'))';  % HARP Firmware Vesion
harp.xhd.InstrumentID = char(fread(fid,4,'uchar'))';         % Instrument ID Number (0-255)
harp.xhd.SiteName = char(fread(fid,4,'uchar'))';             % Site Name, 4 alpha-numeric characters
harp.xhd.ExperimentName = char(fread(fid,8,'uchar'))';       % Experiment Name
harp.xhd.DiskSequenceNumber = fread(fid,1,'uchar');   % Disk Sequence Number (1-16)
harp.xhd.DiskSerialNumber = char(fread(fid,8,'uchar'))';     % Disk Serial Number
harp.xhd.NumOfRawFiles = fread(fid,1,'uint16');         % Number of RawFiles in XWAV file
harp.xhd.Longitude = fread(fid,1,'int32');           % Longitude (+/- 180 degrees) * 100,000
harp.xhd.Latitude = fread(fid,1,'int32');            % Latitude (+/- 90 degrees) * 100,000
harp.xhd.Depth = fread(fid,1,'int16');               % Depth, positive == down
harp.xhd.Reserved = fread(fid,8,'uchar')';            % Padding to extend subchunk to 64 bytes

if harp.xhd.hSubchunkSize ~= (64 - 8 + harp.xhd.NumOfRawFiles * 32)
    disp_msg('Error - HARP SubchunkSize and NumOfRawFiles discrepancy?')
    disp_msg(['hSubchunkSize = ',num2str(harp.xhd.hSubchunkSize)])
    disp_msg(['NumOfRawFiles = ',num2str(harp.xhd.NumOfRawFiles)])
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read sub-sub chunk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:harp.xhd.NumOfRawFiles
    % Start of Raw file :
    harp.xhd.year(i) = fread(fid,1,'uchar');          % Year
    harp.xhd.month(i) = fread(fid,1,'uchar');         % Month
    harp.xhd.day(i) = fread(fid,1,'uchar');           % Day
    harp.xhd.hour(i) = fread(fid,1,'uchar');          % Hour
    harp.xhd.minute(i) = fread(fid,1,'uchar');        % Minute
    harp.xhd.secs(i) = fread(fid,1,'uchar');          % Seconds
    harp.xhd.ticks(i) = fread(fid,1,'uint16');        % Milliseconds
    harp.xhd.byte_loc(i) = fread(fid,1,'uint32');     % Byte location in xwav file of RawFile start
    harp.xhd.byte_length(i) = fread(fid,1,'uint32');    % Byte length of RawFile in xwav file
    harp.xhd.write_length(i) = fread(fid,1,'uint32'); % # of blocks in RawFile length (default = 60000)
    harp.xhd.sample_rate(i) = fread(fid,1,'uint32');  % sample rate of this RawFile
    harp.xhd.gain(i) = fread(fid,1,'uint8');          % gain (1 = no change)
    harp.xhd.padding = fread(fid,7,'uchar');    % Padding to make it 32 bytes...misc info can be added here

    % should only be needed for special case bad data
    % remove after debugging
    %     if harp.xhd.sample_rate(i) == 100000
    %         %   disp('Warning, changing sample rate from 100,000 to 200,000 Hz')
    % %         harp.xhd.sample_rate(i) = 200000;
    %          harp.xhd.sample_rate(i) = 500000;
    %
    %     end

    % calculate starting time [dnum => datenum in days] for each raw
    % write/buffer flush
    harp.raw.dnumStart(i) = datenum([harp.xhd.year(i) harp.xhd.month(i)...
        harp.xhd.day(i) harp.xhd.hour(i) harp.xhd.minute(i) ...
        harp.xhd.secs(i)+(harp.xhd.ticks(i)/1000)]);
    harp.raw.dvecStart(i,:) = [harp.xhd.year(i) harp.xhd.month(i)...
        harp.xhd.day(i) harp.xhd.hour(i) harp.xhd.minute(i) ...
        harp.xhd.secs(i)+(harp.xhd.ticks(i)/1000)];

    % QUESTION FOR SEAN:  Why - 2, are we assuming 16 bits?
    % end of RawFile:
    ByteRate = Fmt.Info.nSamplesPerSec * Fmt.Info.nBlockAlign;
    harp.raw.dnumEnd(i) = harp.raw.dnumStart(i) ...
        + datenum([0 0 0 0 0 (harp.xhd.byte_length(i) - 2)  ./  ByteRate]);
    harp.raw.dvecEnd(i,:) = harp.raw.dvecStart(i,:) ...
        + [0 0 0 0 0 (harp.xhd.byte_length(i) - 2)  ./  ByteRate];
end

