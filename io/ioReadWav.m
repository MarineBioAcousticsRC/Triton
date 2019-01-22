function y = ioReadWav(Handle, hdr, start, stop, varargin)
% y = ioReadWav(Handle, hdr, start, stop, OptionalArgs)
% 
% Given a handle to an open wav (Microsoft RIFF format) file
% and header information, retrieve the data between start and
% stop.  See optional arguments for interpretation of the units
% associated with start and stop.  
%
% Data is output as a matrix where each column vector is a channel.
%
% Optional arguments:
% 'Channels', ChanList - Return specified channels.  If omitted,
%       all channels are returned.
% 'Units', str - Interpretation of start and stop:
%       'samples' (default) - first sample is sample 1
%       's' - seconds
% 'Normalise', 
%       'scale' (default) - Normalize across dynamic range to [-1, 1].
%               This is what Matlab does with wavread
%       'unscaled' - Return values as stored in wav file.
%       'raw' - Return values as type that was read from the file.
%               May be int16, int24, etc.
%       
% Do not modify the following line, maintained by CVS
% $Id: ioReadWav.m,v 1.5 2009/11/13 13:43:57 mroch Exp $

error(nargchk(4, Inf, nargin));

% defaults
channels = 1:hdr.nch;
units = 'samples';
Conversion = 'scale';  % wavread default scaling [-1, 1]

k = 1;
while k < length(varargin)
  switch varargin{k}
   case 'Channels'      % which channels?
    channels = varargin{k+1}; k=k+2;
    if sum(channels > hdr.nch | channels < 1) > 0
      error('Bad channel specification.  File supports [1:%d]\n', hdr.nch);
    end
    
   case 'Units'         % start/stop interpretation
    units = varargin{k+1}; k=k+2;
    
   case 'Normalize'     % scaling
    Conversion = varargin{k+1}; k=k+2;
    
   otherwise
    error('Bad optional argument:  %s', varargin{k})
  end
end

switch units
 case 's'
  % start and stop are in s
  samples = floor([start, stop] * hdr.fs)+1;
  % n sec @ fs = X samples which will be indexed [1:X]
  % Time indices should be between [0:1/fs:X-1/fs]
  % but some callers will request X sec instead of X - 1/fs.
  % We'll fix this, but it could cause problems if the caller 
  % expects an exact number of samples
  if samples(2) - 1 == hdr.Chunks{hdr.dataChunk}.nSamples
    samples(2) = samples(2) - 1;
  end
  
 case 'samples'
  samples = [start, stop];
  
 otherwise
  error('io:Bad argument to Units');
end

switch Conversion
 case 'scale'
  isNative = false;
  
 case {'unscaled', 'raw'}
  isNative = true;
  
 otherwise
  error('io:Bad argument to Conversion');
end

if length(samples) ~= 2 || diff(samples) < 0
  error('io:Specify start_s, stop_s.  start_s must be <= stop_s')
end

% Set up Chunk structure for read_wavedat
Chunk.DataStart = hdr.Chunks{hdr.dataChunk}.DataStart;
Chunk.Size = hdr.Chunks{hdr.dataChunk}.DataSize;
Chunk.fid = Handle;

% Read <wave-data>:
[data,msg] = read_wavedat(Chunk, hdr.Chunks{hdr.fmtChunk}.Info, ...
                          samples, channels, isNative);
if ~isempty(msg)
    error('wavread:InvalidFile',msg);
end

if strcmp(Conversion, 'raw')
  y = data.Data;
else
    y = double(data.Data);
end

% ------------------------------------------------------------------------
% Local functions:
% Local functions are derived from Matlab's wavread and are 
% subject to Mathworks copyright 1984-2007.
% Currently taken from revision 1.1.6.9.
% ------------------------------------------------------------------------


  
% ---------------------------------------------
% READ_WAVEDAT: Read WAVE data chunk
%   Assumes fid points to the wave-data chunk
%   Requires <data-ck> and <wave-format> structures to be passed.
%   Requires extraction range to be specified.
%   Setting ext=[] forces ALL samples to be read.  Otherwise,
%       ext should be a 2-element vector specifying the first
%       and last samples (per channel) to be extracted.
%   Setting ext=-1 returns the number of samples per channel,
%       skipping over the sample data.
% ---------------------------------------------
function [dat,msg] = read_wavedat(datack,wavefmt,ext,channels,isNative)

% In case of unsupported data compression format:
dat     = [];
fmt_msg = '';

switch wavefmt.wFormatTag
case 1
   % PCM Format:
   [dat,msg] = read_dat_pcm(datack,wavefmt,ext,channels,isNative);
case 2
   fmt_msg = 'Microsoft ADPCM';
case 3
   % normalized floating-point
   [dat,msg] = read_dat_pcm(datack,wavefmt,ext,channels,isNative);
case 6
   fmt_msg = 'CCITT a-law';
case 7
   fmt_msg = 'CCITT mu-law';
case 17
   fmt_msg = 'IMA ADPCM';   
case 34
   fmt_msg = 'DSP Group TrueSpeech TM';
case 49
   fmt_msg = 'GSM 6.10';
case 50
   fmt_msg = 'MSN Audio';
case 257
   fmt_msg = 'IBM Mu-law';
case 258
   fmt_msg = 'IBM A-law';
case 259
   fmt_msg = 'IBM AVC Adaptive Differential';
otherwise
   fmt_msg = ['Format #' num2str(wavefmt.wFormatTag)];
end
if ~isempty(fmt_msg),
   msg = ['Data compression format (' fmt_msg ') is not supported.'];
end


% ---------------------------------------------
% READ_DAT_PCM: Read PCM format data from <wave-data> chunk.
%   Assumes fid points to the wave-data chunk
%   Requires <data-ck> and <wave-format> structures to be passed.
%   Requires extraction range to be specified.
%   Setting ext=[] forces ALL samples to be read.  Otherwise,
%       ext should be a 2-element vector specifying the first
%       and last samples (per channel) to be extracted.
%   Setting ext=-1 returns the number of samples per channel,
%       skipping over the sample data.
% ---------------------------------------------
function [dat,msg] = read_dat_pcm(datack,wavefmt,ext,channels,isNative)

dat = [];
msg = '';

% Determine # bytes/sample - format requires rounding
%  to next integer number of bytes: 
BytesPerSample = ceil(wavefmt.nBlockAlign / wavefmt.nChannels);
if (BytesPerSample == 1),
   dtype='uchar'; % unsigned 8-bit
elseif (BytesPerSample == 2),
   dtype='int16'; % signed 16-bit
elseif (BytesPerSample == 3)
	dtype='bit24'; % signed 24-bit
elseif (BytesPerSample == 4),
    if (wavefmt.wFormatTag == 1) % 32-bit 16.8 float (type 1 - 32-bit)
        dtype = 'int32'; %signed 32-bit
    elseif (wavefmt.wFormatTag == 3) % 32-bit normalized floating point
        dtype = 'float'; % floating point
    end

    if wavefmt.wFormatTag ~= 3 && wavefmt.nBitsPerSample == 24,
        BytesPerSample = 3;
    end
else
   msg = 'Cannot read PCM file formats with more than 32 bits per sample.';
   return
end
if isNative
	dtype=['*' dtype];
end

total_bytes       = datack.Size; % # bytes in this chunk
total_samples     = floor(total_bytes / BytesPerSample);
SamplesPerChannel = floor(total_samples / wavefmt.nChannels);

if ~isempty(ext) && isscalar(ext) && ext==-1
       % Just return the samples per channel, and fseek past data:
       dat = SamplesPerChannel;

       % Add in a pad-byte, if required:
       total_bytes = total_bytes + rem(datack.Size,2);

       if(fseek(datack.fid,total_bytes,'cof')==-1)
           % Not all files contain the necessary pad-byte.  Try seeking
           % again without the pad-byte.
           if(fseek(datack.fid, total_bytes-1,'cof') == -1)
               msg = 'Error reading PCM file format.';
           end
       end

       return
end

% Determine sample range to read:
if isempty(ext),
   ext = [1 SamplesPerChannel];    % Return all samples
else
   if numel(ext)~=2,
      msg = 'Sample limit vector must have 2 elements.';
      return
   end
   if ext(1)<1 || ext(2)>SamplesPerChannel,
      msg = 'Sample limits out of range.';
      return
   end
   if ext(1)>ext(2)
      msg = 'Sample limits must be given in ascending order.';
      return
   end
end

bytes_remaining = total_bytes;  % Preset byte counter

% Seek to correct position
offset_bytes = BytesPerSample * (ext(1)-1) * wavefmt.nChannels;
start_byte = datack.DataStart + offset_bytes;
    
if fseek(datack.fid, start_byte,'bof') == -1,
  msg = 'Error reading PCM file format.';
  return
end

% Update count of bytes remaining:
bytes_remaining = bytes_remaining - offset_bytes;

% Read desired data:
nSPCext    = ext(2)-ext(1)+1; % # samples per channel in extraction range
dat        = datack;  % Copy input structure to output
% extSamples = wavefmt.nChannels*nSPCext;
[dat.Data, readN]   = fread(datack.fid, [wavefmt.nChannels nSPCext], dtype);

if readN ~= nSPCext * wavefmt.nChannels
    msg = sprintf('Only able to read %d samples, expecting %d', ...
        readN, nSPCext);
    return
end

% Rearrange data into a matrix with one channel per column:
dat.Data = dat.Data(channels,:)';

if ~isNative
    % Normalize data range: min will hit -1, max will not quite hit +1.
    if BytesPerSample==1,
        dat.Data = (dat.Data-128)/128;  % [-1,1)
    elseif BytesPerSample==2,
        dat.Data = dat.Data/32768;      % [-1,1)
    elseif BytesPerSample==3,
        dat.Data = dat.Data/(2^23);     % [-1,1)
    elseif BytesPerSample==4,
        if wavefmt.wFormatTag ~= 3,    % Type 3 32-bit is already normalized
            dat.Data = dat.Data/32768; % [-1,1)
        end
    end
end
