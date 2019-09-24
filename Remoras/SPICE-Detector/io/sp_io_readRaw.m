function data = sp_io_readRaw(Handle, hdr, rawNum, channels)
% function data = sp_io_readRaw(Handle, hdr, rawNum, channels)
% Given a handle to an open XWAV file and header information,
% retrieve the data in raw file number rawNum.
%
% When multiple channels are present, only returns the first channel
% unless the user specifies which channels should be returned
% (e.g. channels 2 and 4: [2 4]).

if isempty(channels)
    channels = 1;  %default to channel 1
end

if strcmp(hdr.fType, 'xwav')
   
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
    samples = hdr.xhd.byte_length(rawNum)./(hdr.nch * hdr.samp.byte);
  
    fseek(Handle, hdr.xhd.byte_loc(rawNum),'bof');
    data = fread(Handle,[hdr.nch, samples],dtype);
    if isempty(data) % sometimes the last raw file seems to be empty. 
        return
    end
    if hdr.xgain(rawNum) > 0
        data = data ./ hdr.xgain(rawNum);
    end
    data = data(channels,:);  % Select specific channel(s)
    
else
    error('Bad file type');
end



