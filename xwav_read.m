function data = xwav_read(rawIndex, skipSamples, nSamples)
%XWAV_READ  Read samples from an xwav, whether it is stored as wav or flac.
%
%   data = xwav_read(rawIndex, skipSamples, nSamples)
%
% Returns nSamples x nch of raw sample values, starting skipSamples into raw
% file rawIndex. Values are the integers stored in the file, not normalised --
% the same thing fread returned before this function existed. Gain is not
% applied; callers do that themselves.
%
% This is the only place that needs to know how an xwav is stored. Everything
% else -- the forty-odd branches on PARAMS.ftype, every Remora, all the timing
% arithmetic -- treats an x.flac exactly as it treats an x.wav, because
% logically it is one: same harp header, same raw files, same recording times.
% Only the addressing differs, and it differs in one way:
%
%   wav    absolute byte offset, computed from byte_loc
%   flac   sample index, because a compressed stream has no fixed byte per
%          sample; audioread and the flac SEEKTABLE resolve it
%
% Reading a whole plot window can span more than one raw file. The caller asks
% for a position and a count, and this returns what is there; running past the
% end of the file returns fewer samples than asked for, exactly as fread does,
% and the caller decides what to do about it.
%
% See also RDXWAVHD, RDXFLACHD, READSEG.

global PARAMS

data = [];

isFlac = isfield(PARAMS,'container') && strcmpi(PARAMS.container,'flac');

if nSamples <= 0
    return
end

if isFlac
    %% ---- flac: address by sample
    if ~isfield(PARAMS.raw,'sampleStart')
        disp_msg('Error - flac read attempted without a parsed harp header');
        return
    end
    startSample = PARAMS.raw.sampleStart(rawIndex) + skipSamples;   % 0-based
    if startSample < 0
        disp_msg('Error - flac read starts before the beginning of the file');
        return
    end

    fullname = fullfile(PARAMS.inpath, PARAMS.infile);
    try
        I = audioinfo(fullname);
    catch e
        disp_msg(['Error - cannot read flac: ', e.message]);
        return
    end

    first = startSample + 1;                 % audioread is 1-based
    if first > I.TotalSamples
        return                               % entirely past the end
    end
    last = min(first + nSamples - 1, I.TotalSamples);

    try
        data = double(audioread(fullname, [first last], 'native'));
    catch e
        disp_msg(['Error - flac read failed: ', e.message]);
        return
    end

else
    %% ---- wav: address by byte, as Triton always has
    byteLoc = double(PARAMS.xhd.byte_loc(rawIndex)) ...
        + skipSamples * double(PARAMS.nch) * double(PARAMS.samp.byte);

    switch PARAMS.nBits
        case 16; dtype = 'int16';
        case 24; dtype = 'int24';
        case 32; dtype = 'int32';
        otherwise
            disp_msg(['PARAMS.nBits = ', num2str(PARAMS.nBits), ' not supported']);
            return
    end

    fullname = fullfile(PARAMS.inpath, PARAMS.infile);
    fid = fopen(fullname,'r');
    if fid < 0
        disp_msg(['Error - cannot open ', fullname]);
        return
    end
    c = onCleanup(@() fclose(fid));

    % A failed seek leaves the pointer where it was, and reading on would return
    % real-looking samples from the wrong part of the file. Refuse instead.
    if fseek(fid, byteLoc, 'bof') == -1
        finfo = dir(fullname);
        disp_msg(sprintf('Error - seek to byte %d failed, file is %d bytes', ...
            byteLoc, finfo.bytes));
        return
    end

    data = fread(fid, [double(PARAMS.nch), nSamples], dtype)';
end
end
