function WavHandle = ioWavWrite(y,Fs,nbits,wavefile)
%WAVWRITE Write Microsoft WAVE (".wav") sound file.
%   WAVWRITE(Y,FS,NBITS,WAVEFILE) writes data Y to a Windows WAVE
%   file specified by the file name WAVEFILE, with a sample rate
%   of FS Hz and with NBITS number of bits.  NBITS must be 8, 16,
%   24, or 32.  Stereo data should be specified as a matrix with two 
%   columns. For NBITS < 32, amplitude values outside the range 
%   [-1,+1] are clipped.
%
%   WAVWRITE(Y,FS,WAVEFILE) assumes NBITS=16 bits.
%   WAVWRITE(Y,WAVEFILE) assumes NBITS=16 bits and FS=8000 Hz.
%
%   8-, 16-, and 24-bit files are type 1 integer PCM.  32-bit files 
%   are written as type 3 normalized floating point.
%
%   Large wave files may be written using shorter segments using any of the
%   above forms and providing an output argument in the initial call, e.g.:
%
%   WavHandle = WAVWRITE(y, Fs, nbits, wavefile)   % Write partial data 
%
%   When a handle is provided, subsequent writes can be made by specifying 
%   the data to write and the handle:
%
%   WavHandle = WAVWRITE(y, WavHandle);
%
%   To close the file after writing the last segment, simply omit the output
%   argument (y may be empty):
%
%   WAVWRITE(y, WavHandle);
%
%   See also WAVREAD, AUWRITE.
%
% Sample of writing a wave file incrementally:
%
%		n=4000; % n bytes at a time
%		load handel;    % read in y,Fs - Matlab demo audio data
%		segs = ceil(length(y)/n);
%		% write first segment
%		h = ioWavWrite(y(1:n), Fs, 'handleNshot.wav');
%		for k = 2:segs
%		  start = (k-1)*n+1;
%		  stop = min(start + n - 1, length(y));
%		  h = ioWavWrite(y(start:stop), h);
%		end
%		ioWavWrite([], h);  % close file
%
%     multi-channel example:
%     8 channel signal s is read incrementally N bytes at a time
%     h = ioWavWrite(zeros(0,8), Fs, 24, 'demo.wav');
%     samples = get_next_N_bytes();
%     while ~ isempty(samples)
%        h = ioWavWrite(samples, h);
%        samples = get_next_N_bytes();
%     end
%     ioWavWrite([], h);        % close up file
%		

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2008/10/06 21:04:57 $

%   D. Orofino, 11/95
%   Modified by Marie Roch, San Diego State University to support
%   writing of large files.

NewWrite = true;    % Assume new file until we learn otherwise...

error(nargoutchk(0,1,nargout));
% If user specified output, assume they want to write more later.
TerminateWrite = nargout < 1;

% Parse inputs:
error(nargchk(2,4,nargin));
if nargin < 3,
    % Check if continuation
    if isstruct(Fs)
        WavHandle = Fs;  % Second argument is really file information
        NewWrite = false;
    else
        wavefile = Fs;
        Fs       = 8000;
        nbits    = 16;
    end
elseif nargin < 4,
    wavefile = nbits;
    nbits    = 16;
end

% If we wish to continue writing to the file, the user must provide an
% output variable to track the current data size.
if ~ TerminateWrite
    error(nargoutchk(1,1,nargout));
end

% If input is a vector, force it to be a column:
if ndims(y) > 2,
  error('MATLAB:wavwrite:invalidInputFormat','Data array cannot be an N-D array.');
end
if size(y,1)==1,
   y = y(:);
end
[samples, channels] = size(y);

data_offset = 36;   % offset to data chunk

if NewWrite
    % Determine number of bytes in chunks
    % (not including pad bytes, if needed):
    % ----------------------------------
    %  'RIFF'           4 bytes
    %  size             4 bytes
    %  'WAVE'           4 bytes
    %  'fmt '           4 bytes
    %  size             4 bytes
    % <wave-format>     14 bytes
    % <format_specific> 2 bytes (PCM)
    %  'data'           4 bytes
    %  size             4 bytes
    % <wave-data>       N bytes
    % ----------------------------------
    bytes_per_sample = ceil(nbits/8);
    total_samples    = samples * channels;
    total_bytes      = total_samples * bytes_per_sample;

    WavHandle.samples = samples;    % Save info about data written so far

    riff_cksize = data_offset+total_bytes;   % Don't include 'RIFF' or its size field
    fmt_cksize  = 16;               % Don't include 'fmt ' or its size field
    data_cksize = total_bytes;      % Don't include 'data' or its size field

    % Determine pad bytes:
    data_pad    = rem(data_cksize,2);
    riff_cksize = riff_cksize + data_pad; % + fmt_pad, always 0

    % Open file for output:
    fid = OpenWaveWrite(wavefile);
    WavHandle.fid = fid;

    % file is now open, wrap the rest of the calls
    % in a try catch so we can close the file if there is a failure
    try
      % Prepare basic chunk structure fields:
      ck=[]; ck.fid=fid; ck.filename = wavefile;
      
      % Write RIFF chunk:
      ck.ID   = 'RIFF';
      ck.Size = riff_cksize;
      WavHandle.RIFF_chunk.data = ck;  % Save to rewrite later if needed
      WavHandle.RIFF_chunk.posn = ftell(fid);
      write_ckinfo(ck);
      
      % Write WAVE subchunk:
      ck.ID   = 'WAVE';
      ck.Size = [];  % Indicate a subchunk (no chunk size)
      write_ckinfo(ck);
      
      % Write <fmt-ck>:
      ck.ID   = 'fmt ';
      ck.Size = fmt_cksize;
      write_ckinfo(ck);

      % Write <wave-format>:
      fmt.filename        = wavefile;
      if nbits == 32,
        fmt.wFormatTag  = 3;            % Data encoding format (1=PCM, 3=Type 3 32-bit)
      else
        fmt.wFormatTag  = 1;
      end
      fmt.nChannels       = channels;     % Number of channels
      fmt.nSamplesPerSec  = Fs;           % Samples per second
      fmt.nAvgBytesPerSec = channels*bytes_per_sample*Fs; % Avg transfer rate
      fmt.nBlockAlign     = channels*bytes_per_sample;    % Block alignment
      fmt.nBitsPerSample  = nbits;        % standard <PCM-format-specific> info
      WavHandle.fmt = fmt;
      write_wavefmt(fid,fmt);

      % Write <data-ck>:
      ck.ID   = 'data';
      ck.Size = data_cksize;
      WavHandle.Data_chunk.data = ck;
      WavHandle.Data_chunk.posn = ftell(fid);
      write_ckinfo(ck);

      % Write <wave-data>
      if ~ isempty(y)
        write_wavedat(fid,fmt,y);
      end
    catch
      fclose(WavHandle.fid);    % close up file
      WavHandle.fid = -1;
      rethrow(lasterror);
    end

elseif ~ isempty(y)
    % Additional data to write to an open file
    if channels ~= WavHandle.fmt.nChannels
        error('MATLAB:wavwrite:InvalidChannelCount', ...
              'Continuation data must have %d channels', ...
              WavHandle.fmt.nChannels);
    end
    % Write the data and note the additional samples so we can
    % patch the header data later.
    write_wavedat(WavHandle.fid, WavHandle.fmt, y);
    WavHandle.samples = WavHandle.samples + samples * channels;
end

if TerminateWrite
    % Pad if needed
    total_samples = WavHandle.samples;
    total_bytes = total_samples * ceil(WavHandle.fmt.nBitsPerSample/8);
    data_pad = rem(total_bytes, 2);
    if data_pad
        fwrite(WavHandle.fid, 0, 'uchar');
    end
    
    if ~ NewWrite
        % Patch headers as the number of bytes is incorrect
        WavHandle.RIFF_chunk.data.Size = ...
            data_offset + total_bytes + data_pad;
        fseek(WavHandle.fid, WavHandle.RIFF_chunk.posn, 'bof');
        write_ckinfo(WavHandle.RIFF_chunk.data);
        
        WavHandle.Data_chunk.data.Size = total_bytes;
        fseek(WavHandle.fid, WavHandle.Data_chunk.posn, 'bof');
        write_ckinfo(WavHandle.Data_chunk.data);
    end
    % Close file:
    fclose(WavHandle.fid);
end
% end of wavwrite()


% ------------------------------------------------------------------------
% Private functions:
% ------------------------------------------------------------------------


% ------------------------------------------------------------------------
function [fid] = OpenWaveWrite(wavefile)
% OpenWaveWrite
%   Open WAV file for writing.
%   If filename does not contain an extension, add ".wav"

fid = [];
if ~ischar(wavefile),
   error('MATLAB:wavewrite:InvalidFileNameType', 'Wave file name must be a string.'); 
end
if isempty(findstr(wavefile,'.')),
  wavefile=[wavefile '.wav'];
end
% Open file, little-endian:
[fid,err] = fopen(wavefile,'wb','l');
if (fid == -1)
    error('MATLAB:wavewrite:unableToOpenFile', err );
end

return


% ------------------------------------------------------------------------
function write_ckinfo(ck)
% WRITE_CKINFO: Writes next RIFF chunk, but not the chunk data.
%   Assumes the following fields in ck:
%         .fid   File ID to an open file
%         .ID    4-character string chunk identifier
%         .Size  Size of chunk (empty if subchunk)
%
%
%   Expects an open FID pointing to first byte of chunk header,
%   and a chunk structure.
%   ck.fid, ck.ID, ck.Size, ck.Data

errMsg = ['Failed to write ' ck.ID ' chunk to WAVE file: ' ck.filename];
errMsgID = 'MATLAB:wavewrite:failedChunkInfoWrite';

if (fwrite(ck.fid, ck.ID, 'char') ~= 4),
  error(errMsgID, errMsg);
end

if ~isempty(ck.Size),
  % Write chunk size:
  if (fwrite(ck.fid, ck.Size, 'uint32') ~= 1),
    error(errMsgID, errMsg);
  end
end

return

% ------------------------------------------------------------------------
function write_wavefmt(fid, fmt)
% WRITE_WAVEFMT: Write WAVE format chunk.
%   Assumes fid points to the wave-format subchunk.
%   Requires chunk structure to be passed, indicating
%   the length of the chunk.

errMsg = ['Failed to write WAVE format chunk to file' fmt.filename];
errMsgID = 'MATLAB:wavewrite:failedWaveFmtWrite';

% Create <wave-format> data:
if (fwrite(fid, fmt.wFormatTag,      'uint16') ~= 1) | ...
   (fwrite(fid, fmt.nChannels,       'uint16') ~= 1) | ...
   (fwrite(fid, fmt.nSamplesPerSec,  'uint32' ) ~= 1) | ...
   (fwrite(fid, fmt.nAvgBytesPerSec, 'uint32' ) ~= 1) | ...
   (fwrite(fid, fmt.nBlockAlign,     'uint16') ~= 1),
   error(errMsgID,errMsg);
end

% Write format-specific info:
if fmt.wFormatTag==1 | fmt.wFormatTag==3,
  % Write standard <PCM-format-specific> info:
  if (fwrite(fid, fmt.nBitsPerSample, 'uint16') ~= 1),
     error(errMsgID,errMsg);
  end
  
else
  error('MATLAB:wavewrite:unknownDataFormat','Unknown data format.');
end

return


% -----------------------------------------------------------------------
function y = PCM_Quantize(x, fmt)
% PCM_Quantize:
%   Scale and quantize input data, from [-1, +1] range to
%   either an 8-, 16-, or 24-bit data range.

% Clip data to normalized range [-1,+1]:
ClipMsg  = ['Data clipped during write to file:' fmt.filename];
ClipMsgID = 'MATLAB:wavwrite:dataClipped';
ClipWarn = 0;

% Determine slope (m) and bias (b) for data scaling:
nbits = fmt.nBitsPerSample;
m = 2.^(nbits-1);

switch nbits
case 8,
   b=128;
case {16,24},
   b=0;
otherwise,
   error('MATLAB:wavwrite:invalidBitsPerSample','Invalid number of bits specified.');
end

y = round(m .* x + b);

% Determine quantized data limits, based on the
% presumed input data limits of [-1, +1]:
ylim = [-1 +1];
qlim = m * ylim + b;
qlim(2) = qlim(2)-1;

% Clip data to quantizer limits:
i = find(y < qlim(1));
if ~isempty(i),
   warning(ClipMsgID,ClipMsg); ClipWarn=1;
   y(i) = qlim(1);
end

i = find(y > qlim(2));
if ~isempty(i),
   if ~ClipWarn, warning(ClipMsgID,ClipMsg); end
   y(i) = qlim(2);
end

return


% -----------------------------------------------------------------------
function write_wavedat(fid,fmt,data)
% WRITE_WAVEDAT: Write WAVE data chunk
%   Assumes fid points to the wave-data chunk
%   Requires <wave-format> structure to be passed.

if fmt.wFormatTag==1 | fmt.wFormatTag==3,
   % PCM Format
   
   % 32-bit Type 3 is normalized, so no scaling needed.
   if fmt.nBitsPerSample ~= 32,
       data = PCM_Quantize(data, fmt);
   end
   
   switch fmt.nBitsPerSample
   case 8,
      dtype='uchar'; % unsigned 8-bit
   case 16,
      dtype='int16'; % signed 16-bit
   case 24,
	  dtype='bit24'; % signed 24-bit
   case 32,
      dtype='float'; % normalized 32-bit floating point
   otherwise,
      error('MATLAB:wavewrite:invalidBitsPerSample','Invalid number of bits specified.');
   end
   
   % Write data, one row at a time (one sample from each channel):
   [samples,channels] = size(data);
   total_samples = samples*channels;
   
   % reshape is slow, by transposing the data we place the channels
   % in the columns of the data.  As Matlab writes data in column-major
   % order, we write the data serially in the write format.
   %if (fwrite(fid, reshape(data',total_samples,1), dtype) ~= total_samples),2
   if (fwrite(fid, data', dtype) ~= total_samples),
      error('MATLAB:wavewrite:failedToWriteSamples','Failed to write PCM data samples.');
   end
   
   % Determine # bytes/sample - format requires rounding
   %  to next integer number of bytes:
   BytesPerSample = ceil(fmt.nBitsPerSample/8);
   
   % Determine if a pad-byte must be appended to data chunk:
   if rem(total_samples*BytesPerSample, 2) ~= 0,
      fwrite(fid,0,'uchar');
   end
   
else
  % Unknown wave-format for data.
  error('MATLAB:wavewrite:unsupportedDataFormat','Unsupported data format.');
end

return

% end of wavwrite.m
