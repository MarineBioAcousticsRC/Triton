function data = sp_io_readXWAV(Handle, hdr, start_s, stop_s, channels, ~)
% function data = sp_ioReadXWAV(Handle, hdr, start_s, stop_s, channels, ftype, filename)
% Given a handle to an open XWAV file and header information,
% retrieve the data between start and stop s.
%
% When multiple channels are present, only returns the first channel
% unless the user specifies which channels should be returned
% (e.g. channels 2 and 4: [2 4]).
%
% Note that provided that the hdr was created with a call
% to ioReadWavHeader, this function will also work for
% wav files.
%
%  2008/11/24 04:54:15 mroch

if isempty(channels)
    channels = 1;  % default to channel 1
end


if strcmp(hdr.fType, 'wav')    % Microsoft RIFF WAVE file
    data = sp_io_readWav(Handle, hdr, start_s, stop_s, ...
        'Units', 's', 'Channels', channels, ...
        'Normalize', 'unscaled')';
    
elseif strcmp(hdr.fType, 'xwav')

    if hdr.nBits == 16
        dtype = 'int16';
    elseif hdr.nBits == 32
        dtype = 'int32';
    else
        disp_msg('hdr.nBits = ')
        disp_msg(hdr.nBits)
        disp_msg('not supported')
        return
    end
    dnum2sec = 60*60*24;
    rawStarts = (hdr.raw.dnumStart-hdr.raw.dnumStart(1))*dnum2sec;
    
    % find the correct raw file:
    rawIdx = find(rawStarts<=start_s,1,'last');
    if isempty(rawIdx)
        rawIdx = 1;
    end
    % how much additional data do you need to skip?
    skip = floor((start_s-rawStarts(rawIdx)) * hdr.fs); % offset into data
    samples = floor((stop_s - start_s) * hdr.fs);
    
    % then read the segment you want:
    fseek(Handle, ...
        hdr.xhd.byte_loc(rawIdx) + skip*hdr.nch*hdr.samp.byte,'bof');
    data = fread(Handle,[hdr.nch, samples],dtype);
    
    if hdr.xgain > 0
        data = data ./ hdr.xgain(1);
    end
    if ~isempty(data)
        data = data(channels,:);  % Select specific channel(s)
    end 
else
    error('Bad file type');
end



