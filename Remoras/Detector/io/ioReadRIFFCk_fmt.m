function Fmt = ioReadRIFFCk_fmt(f_handle, Chunk)
% Given a handle to a file positioned at the first data byte
% of a RIFF format chunk, read the format information.

% Data encoding format
Fmt.wFormatTag      = fread(f_handle,1,'uint16');
% Number of channels
Fmt.nChannels       = fread(f_handle,1,'uint16');
% Samples per second
Fmt.nSamplesPerSec  = fread(f_handle,1,'uint32');
% Avg transfer rate
Fmt.nAvgBytesPerSec = fread(f_handle,1,'uint32');
% Block alignment
Fmt.nBlockAlign     = fread(f_handle,1,'uint16');

err_msg = [];
% Read format-specific info:
switch Fmt.wFormatTag
    case 1        % PCM Format
        Fmt.fmt.nBitsPerSample = ...
            fread(f_handle, 1, 'uint16');
        % Optional cbSize field let's us know if
        % how many bits are significant.
        if ioRIFFCk_BytesRemainingP(f_handle, Chunk, 2)
            Fmt.fmt.cbSize = ...
                fread(f_handle, 1, 'uint16');
        end
    case 2
        err_msg = 'Microsoft ADPCM';
    case 3
        % normalized floating-point
    case 6
        err_msg = 'CCITT a-law';
    case 7
        err_msg = 'CCITT mu-law';
    case 17
        err_msg = 'IMA ADPCM';
    case 34
        err_msg = 'DSP Group TrueSpeech TM';
    case 49
        err_msg = 'GSM 6.10';
    case 50
        err_msg = 'MSN Audio';
    case 257
        err_msg = 'IBM Mu-law';
    case 258
        err_msg = 'IBM A-law';
    case 259
        err_msg = 'IBM AVC Adaptive Differential';
    otherwise
        err_msg = sprintf('#%d', wavefmt.wFormatTag);
end

if ~ isempty(err_msg)
    fclose(f_handle)
    error('io:Unsupported codec:  %s', err_msg);
end

% Determine # of bytes per sample
Fmt.nBytesPerSample = ...
    ceil(Fmt.nBlockAlign/Fmt.nChannels);
% Type of data can be determined by the number
% of bytes per sample.
switch Fmt.nBytesPerSample
    case 1
        Fmt.fmt.dtype = 'uchar'; % unsigned 8-bit
    case 2
        Fmt.fmt.dtype = 'int16'; % signed 16-bit
    case 3
        Fmt.fmt.dtype = 'bit24'; % signed 24-bit
    case 4
        % Check format tag to see whether signed 32-bit or
        % floating point.
        switch Fmt.wFormatTag
            case 1
                Fmt.fmt.dtype = 'int32'; % signed 32-bit
            case 3
                Fmt.fmt.dtype = 'float'; % normalized floating point
            case 4
                Fmt.fmt.dtype = 'float'; % floating point
            otherwise
                error('io:Unsupported wFormatTag %d', ...
                    Fmt.wFormatTag);
        end
end

% Handle special case for 24 bit data
if Fmt.wFormatTag ~= 3 && ...
        Fmt.fmt.nBitsPerSample == 24
    Fmt.BytesPerSample = 3;
end

