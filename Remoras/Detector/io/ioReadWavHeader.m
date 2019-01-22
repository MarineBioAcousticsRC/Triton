function hdr = ioReadWavHeader(Filename, DateRE)
% hdr = ioReadWavHeader(Filename, DateRE)
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
% $Id: ioReadWavHeader.m,v 1.7 2012/03/22 20:03:17 mroch Exp $

global PARAMS

error(nargchk(1,2,nargin));
if nargin < 2
    % Use global timestamp if available
    if exist('PARAMS', 'var') && isfield(PARAMS, 'fnameTimeRegExp')
            DateRE = PARAMS.fnameTimeRegExp;
    else
        DateRE = [];
    end
end

hdr.filetype = 'wav';  % Assume until we find otherwise

f_handle = ioOpenWav(Filename);
if f_handle == -1
  error('io:Unable to open file %s', Filename);
end

Riff = ioReadRIFFCkHdr(f_handle);
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
    Chunk = ioReadRIFFCkHdr(f_handle);

    while ~ strcmp(Chunk.ID, 'EOF')

        switch Chunk.ID
            case 'fmt'
                % Read format data
                % There should be only one format chunk, we could
                % run into problems if there is more than one.
                Chunk.Info = ioReadRIFFCk_fmt(f_handle, Chunk);
                hdr.fmtChunk = length(Chunks)+1;  % Note chunk idx

            case 'data'
                hdr.dataChunk = length(Chunks)+1;  % Note chunk idx

            case 'harp'
                %error('harp not yet supported');
                % stopped here - header read seems to be buggy.
                % check to make sure at right position...
                hdr.filetype = 'xwav';
                if isfield(hdr, 'fmtChunk')
                    Chunk.Info = ioReadRIFFCk_harp(f_handle, Chunk, ...
                        Chunks{hdr.fmtChunk});
                    % Copy fields to hdr for backward compatibility
                    fields = fieldnames(Chunk.Info);
                    for f = 1:length(fields)
                        hdr.(fields{f}) = Chunk.Info.(fields{f});
                    end
                    hdr.harpChunk = length(Chunks)+1;  % Note chunk idx
                else
                    error('io:fmt chunk must come before harp chunk');
                end

            otherwise
                Chunk.info = [];    % no meta information to store
        end
        Chunks{end+1} = Chunk;        % store new chunk

        fseek(f_handle, Chunk.StartByte + Chunk.ChunkSize, 'bof');
        if 0    % debug
            fprintf('seek:  ');
            fprintf('%X \n', Chunk.StartByte, Chunk.ChunkSize, ...
                Chunk.StartByte+Chunk.ChunkSize);
        end
        Chunk = ioReadRIFFCkHdr(f_handle);
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

    % determine timestamp
    hdr.start.dnum = dateregexp(Filename, DateRE, ...
        datenum([0 1 1 0 0 0]), ... % default if we cannot match
        dateoffset());  % offset from
    hdr.start.dvec = datevec(hdr.start.dnum);
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




