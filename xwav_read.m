function data = xwav_read(byteLoc, nSamples, fullname, geom)
%XWAV_READ  Read samples from an xwav, whether it is stored as wav or flac.
%
%   data = xwav_read(byteLoc, nSamples)
%   data = xwav_read(byteLoc, nSamples, fullname)
%   data = xwav_read(byteLoc, nSamples, fullname, geom)
%
% Returns nSamples x nch of raw sample values starting at byteLoc -- the byte
% offset the data would sit at in the equivalent x.wav. Values are the integers
% stored in the file, not normalised: the same thing fread returned before this
% function existed. Gain is not applied; callers do that themselves.
%
% fullname defaults to fullfile(PARAMS.inpath, PARAMS.infile). Pass it when the
% file being read is not the one PARAMS points at, as when calc_ltsa walks a
% directory.
%
% geom describes the file's sample layout, and defaults to the currently open
% file's, taken from PARAMS:
%
%   geom.nch         channels
%   geom.nBits       bits per sample
%   geom.audioStart  byte offset where audio begins in the equivalent x.wav,
%                    i.e. byte_loc of the file's first raw file (flac only)
%
% Pass it when reading during LTSA generation, where the geometry lives under
% PARAMS.ltsa rather than at the top level and PARAMS describes whatever file
% the display last opened, which is usually a different one.
%
% Whether the file is a flac is decided from its extension, not from a flag
% carried in PARAMS. There is then no state to thread through the LTSA
% pipeline and nothing that can fall out of step with the file actually open.
%
% WHY CALLERS STILL SPEAK IN BYTES
%
% Callers compute positions in x.wav bytes even when the file is a flac, and
% the translation happens here at the last moment. That is deliberate:
% calc_ltsa advances its read pointer with arithmetic that is known to be
% slightly wrong -- it moves by this average's length where it should move by
% the previous one's, see Triton_python/docs/OPEN_DECISIONS.md -- and that is
% baked into archived LTSAs. The flac path lands on the same positions, right or
% wrong, or an LTSA built from a flac would not match one built from the x.wav.
% Translating at the end keeps both containers wrong in identical ways, and
% means a future fix to that arithmetic reaches both at once.
%
% This is the only place that needs to know how an xwav is stored. Everything
% else -- the forty-odd branches on PARAMS.ftype, every Remora, all the timing
% arithmetic -- treats an x.flac exactly as it treats an x.wav, because
% logically it is one: same harp header, same raw files, same recording times.
% Only the addressing differs:
%
%   wav    absolute byte offset, seek and read
%   flac   sample index, because a compressed stream has no fixed byte per
%          sample; audioread and the flac SEEKTABLE resolve it
%
% Reading past the end returns fewer samples than asked for, exactly as fread
% does, and the caller decides what to do about it.
%
% The file is opened and closed on each call, where calc_ltsa used to hold one
% handle open for a whole file. That costs about 50 microseconds per read
% against 8 for the read itself -- measured, not guessed -- so roughly half a
% second per ten thousand spectral averages, a few percent of what pwelch costs
% on the same data. Paying it buys a function with no state at all: nothing to
% keep in step with the file actually open, and no handle to leak when a caller
% returns early. If a future profile shows it mattering, pass an open handle in
% geom rather than making this function remember one.
%
% See also RDXWAVHD, RDXFLACHD, READSEG, CALC_LTSA.

global PARAMS

data = [];

if nSamples <= 0
    return
end
if nargin < 3 || isempty(fullname)
    fullname = fullfile(PARAMS.inpath, PARAMS.infile);
end

[~, ~, ext] = fileparts(fullname);
isFlac = strcmpi(ext, '.flac');

if nargin < 4 || isempty(geom)
    geom = struct();
end
if ~isfield(geom,'nch');   geom.nch   = PARAMS.nch;   end
if ~isfield(geom,'nBits'); geom.nBits = PARAMS.nBits; end

nch      = double(geom.nch);
sampByte = floor(double(geom.nBits)/8);

if isFlac
    %% ---- flac: address by sample
    if ~isfield(geom,'audioStart') || isempty(geom.audioStart)
        if ~isfield(PARAMS,'xhd') || ~isfield(PARAMS.xhd,'byte_loc') ...
                || isempty(PARAMS.xhd.byte_loc)
            disp_msg('Error - flac read attempted without a parsed harp header');
            return
        end
        geom.audioStart = PARAMS.xhd.byte_loc(1);
    end

    % audioStart is where the audio begins in the equivalent x.wav, so
    % subtracting it turns an x.wav byte offset into an offset into the audio,
    % which divides cleanly into samples.
    audioStart    = double(geom.audioStart);
    bytesPerSlice = nch * sampByte;
    startSample   = (double(byteLoc) - audioStart) / bytesPerSlice;   % 0-based

    if startSample < 0
        disp_msg('Error - flac read starts before the first sample');
        return
    end
    if startSample ~= fix(startSample)
        disp_msg('Error - flac read offset is not a whole number of samples');
        return
    end

    try
        I = audioinfo(fullname);
    catch e
        disp_msg(['Error - cannot read flac: ', e.message]);
        return
    end

    first = startSample + 1;                          % audioread is 1-based
    if first > I.TotalSamples
        return                                        % entirely past the end
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
    switch geom.nBits
        case 16; dtype = 'int16';
        case 24; dtype = 'int24';
        case 32; dtype = 'int32';
        otherwise
            disp_msg([num2str(geom.nBits), ' bits per sample not supported']);
            return
    end

    fid = fopen(fullname,'r');
    if fid < 0
        disp_msg(['Error - cannot open ', fullname]);
        return
    end
    c = onCleanup(@() fclose(fid)); %#ok<NASGU>

    % A failed seek leaves the file pointer where it was, and reading on would
    % return real-looking samples from the wrong part of the file. Refuse.
    if fseek(fid, byteLoc, 'bof') == -1
        finfo = dir(fullname);
        disp_msg(sprintf('Error - seek to byte %d failed, file is %d bytes', ...
            byteLoc, finfo.bytes));
        return
    end

    data = fread(fid, [nch, nSamples], dtype)';
end
end
