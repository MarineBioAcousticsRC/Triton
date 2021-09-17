function hdr = sp_io_readWavHeader(Filename,DateRE)
% hdr = sp_io_readWavHeader(Filename, DateRE)
%
% Read header of Microsoft RIFF wav header
% See http://www.sonicspot.com/guide/wavefiles.html for 
% layout of Microsoft RIFF wav files
%
% CAVEATS:  Assumes a single DATA chunk.
% To modify to handle multiple data chunks, be sure to also 
% consider ioReadWav which will need modifications as well.
%
% Attempts to infer the timestamp of the recording based
% upon the filename and the regular expression(s) DateRE 
% which must conform to the standards in function dateregexp.
%
% Do not modify the following line, maintained by CVS
% $Id: ioReadWavHeader.m,v 1.6 2008/12/09 19:35:38 mroch Exp $


hdr.fType = 'wav';

f_handle = sp_io_openWav(Filename);
if f_handle == -1
  error('io:Unable to open file %s', Filename);
end

Riff = sp_io_readRIFFCkHdr(f_handle);
if ~ strcmp(Riff.ID, 'RIFF')
    fclose(f_handle);
    error('io:%s is not a RIFF wave file', Filename);
else
    % Verify that we have a WAVE file.
    [RiffType, bytes] = fread(f_handle, 4, 'char');
    RiffType = deblank(char(RiffType'));
    if bytes ~= 4 || ~ strcmp(RiffType, 'WAVE')
        error('io:%s Riff type not WAVE', Filename);
    end

    Chunks = {};

    % Read all chunks
    Chunk = sp_io_readRIFFCkHdr(f_handle);

    while ~ strcmp(Chunk.ID, 'EOF')

        switch Chunk.ID
            case 'fmt'
                % Read format data
                % There should be only one format chunk, we could
                % run into problems if there is more than one.
                Chunk.Info = sp_io_readRIFFCk_fmt(f_handle, Chunk);
                hdr.fmtChunk = length(Chunks)+1;  % Note chunk idx

            case 'data'
                hdr.dataChunk = length(Chunks)+1;  % Note chunk idx

            otherwise
                Chunk.info = [];    % no meta information to store
        end
        Chunks{end+1} = Chunk;        % store new chunk

        fseek(f_handle, Chunk.StartByte + Chunk.ChunkSize, 'bof');

        Chunk = sp_io_readRIFFCkHdr(f_handle);
    end
end

  
fclose(f_handle);

hdr.Chunks = Chunks;

if ~ isfield(hdr, 'fmtChunk')
  error('Unable to find format chunk');
end
if ~ isfield(hdr, 'dataChunk')
  error('Unable to find data chunk');
end

% Calculate number of samples - round number to avoid small errors
hdr.Chunks{hdr.dataChunk}.nSamples = ...
    round(hdr.Chunks{hdr.dataChunk}.DataSize / ...
    (hdr.Chunks{hdr.fmtChunk}.Info.nBytesPerSample * ...
     hdr.Chunks{hdr.fmtChunk}.Info.nChannels));
 
hdr.fs = hdr.Chunks{hdr.fmtChunk}.Info.nSamplesPerSec;
hdr.nch = hdr.Chunks{hdr.fmtChunk}.Info.nChannels;
hdr.nBits = hdr.Chunks{hdr.fmtChunk}.Info.nBytesPerSample * 8;
hdr.samp.byte = hdr.Chunks{hdr.fmtChunk}.Info.nBytesPerSample;
hdr.xhd.ByteRate = hdr.Chunks{hdr.fmtChunk}.Info.nBlockAlign * hdr.fs;
hdr.xhd.byte_length = hdr.Chunks{hdr.dataChunk}.DataSize;
hdr.xhd.byte_loc = hdr.Chunks{hdr.dataChunk}.DataStart;

if isfield(hdr, 'harpChunk')
    hdr.xgain = hdr.Chunks{hdr.harpChunk}.Info.xhd.gain;
    hdr.start.dnum = hdr.raw.dnumStart(1);
    hdr.end.dnum = hdr.raw.dnumEnd(hdr.xhd.NumOfRawFiles);
else
    % no HARP format
    % Add HARP data structures for uniform access
    hdr.xgain = 1;          % gain (1 = no change)
    [~,shortName,~] = fileparts(Filename);
    % determine timestamp
    [~,~,~,~,k] = regexp(shortName, DateRE);
    if isempty(k)
        error('Date expression does not match file name')
    end
    catDate = cell2mat(k{1});
    if length(catDate)==12
        hdr.start.dvec = [str2double(catDate(1:2))+2000,str2double(catDate(3:4)),...
        str2double(catDate(5:6)),str2double(catDate(7:8)),...
        str2double(catDate(9:10)),str2double(catDate(11:12))];
    elseif length(catDate)==14
        hdr.start.dvec = [str2double(catDate(1:4)),str2double(catDate(5:6)),...
        str2double(catDate(7:8)),str2double(catDate(9:10)),...
        str2double(catDate(11:12)),str2double(catDate(13:14))];
    else
        error('Problem interpreting date from wave file name. Expected 12 or 14 digits.')
    end

    hdr.start.dnum = datenum(hdr.start.dvec);
    hdr.xhd.year = hdr.start.dvec(1);          % Year
    hdr.xhd.month = hdr.start.dvec(2);         % Month
    hdr.xhd.day = hdr.start.dvec(3);           % Day
    hdr.xhd.hour = hdr.start.dvec(4);          % Hour
    hdr.xhd.minute = hdr.start.dvec(5);        % Minute
    hdr.xhd.secs = hdr.start.dvec(6);          % Seconds
    
    samplesN = hdr.xhd.byte_length ./ (hdr.nch * hdr.samp.byte);
    hdr.end.dnum = hdr.start.dnum + datenum([0 0 0 0 0 samplesN/hdr.fs]);
end
hdr.start.dvec = datevec(hdr.start.dnum);




