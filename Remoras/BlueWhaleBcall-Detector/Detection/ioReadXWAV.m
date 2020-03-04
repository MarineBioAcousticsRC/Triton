function data = ioReadXWAV(Handle, hdr, start_s, stop_s, channels, ftype, filename)
% function data = ioReadXWAV(Handle, hdr, start_s, stop_s, channels, ftype, filename)
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
% Do not modify the following line, maintained by CVS
% $Id: ioReadXWAV.m,v 1.8 2008/11/24 04:54:15 mroch Exp $

error(nargchk(4,7,nargin));
if nargin < 6
    ftype = 2;  % default to x.wav file type
    if nargin < 5
        channels = 1;    % default to channel 1'
        ftype = 2;      % default to x.wav filetype
    end
end

if isempty(channels);
    channels = 1;  %default to channel 1
end

switch ftype
    case 1    % Microsoft RIFF WAVE file
     data = ioReadWav(Handle, hdr, start_s, stop_s, ...
                      'Units', 's', 'Channels', channels, ...
                      'Normalize', 'unscaled')';
        
    case 2    % XWav file
        skip = floor(start_s * hdr.fs); % offset into data
        samples = floor((stop_s - start_s) * hdr.fs);
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
        % Assume that raw files embedded within the XWAV file are
        % contiguous.  Check with Sean that this will always
        % be the case.  If not, we need to read on a per raw
        % file basis.
        fseek(Handle, ...
            hdr.xhd.byte_loc(1) + skip*hdr.nch*hdr.samp.byte,'bof');
        data = fread(Handle,[hdr.nch, samples],dtype);

        if hdr.xgain > 0
            data = data ./ hdr.xgain(1);
        end
        data = data(channels,:);  % Select specific channel(s)

    otherwise
        error('Bad file type');
end



