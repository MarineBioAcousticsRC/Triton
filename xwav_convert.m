function [ok, outFile, info] = xwav_convert(inFile, varargin)
%XWAV_CONVERT  Compress or expand one audio file, safely.
%
%   [ok, outFile, info] = xwav_convert(f)                  % direction from the file
%   [ok, outFile, info] = xwav_convert(f, 'outdir', d)
%   [ok, outFile, info] = xwav_convert(f, 'direction', 'expand')
%
% The single file-level worker behind audio2flac, flac2audio, audiodir2flac and
% flacdir2audio. It owns the disk-space guard, the temporary-file discipline and
% the verification, so those exist once and cannot drift apart.
%
% Options
%   'direction'   'auto' (default), 'compress' or 'expand'
%   'outdir'      where to write; default alongside the input
%   'keepInput'   keep the source after a verified conversion (default true)
%   'verify'      verify before reporting success (default true)
%   'minFree'     bytes to leave free on the destination (default 2 GiB)
%   'overwrite'   what to do when the output already exists:
%                 'verified' (default) keep it only if it passes the same check
%                 a fresh conversion would; 'skip' keep it unexamined;
%                 'replace' always redo; 'error' refuse
%   'flac'        path to the flac tool; found automatically if omitted
%
% Never throws for a per-file problem -- it returns ok=false and a reason in
% info.why, so a folder run can log it and carry on. It throws only on bad
% arguments.
%
% WHAT THE OUTPUT IS CALLED
%
% From what the file *is*, never from what it is named. A `.wav` that turns out
% to carry a harp chunk becomes a `.x.flac`, because it is an xwav regardless of
% what someone called it. Converting it down the plain path would discard the
% raw-file directory and the deployment times with nothing to show for it.
%
% WHY NOT --keep-foreign-metadata-if-present
%
% Because of what flac's own manual says about it: "all foreign metadata related
% errors are treated as warnings." Under that flag flac can exit 0 having
% written no harp chunk at all -- which is the silent loss this whole format is
% careful about, handed back as a success. Strict --keep-foreign-metadata is
% used instead, and on decode the flag is passed only when the file actually has
% preserved chunks to restore.
%
% Note also that -V/--verify is an *encoding* option. On decode the integrity
% guarantee comes from flac's own per-frame CRCs and the whole-stream MD5.
%
% See also AUDIO2FLAC, FLAC2AUDIO, XWAV_CONVERT_DIR, AUDIO_FILE_KIND, DISK_FREE.

p = inputParser;
addParameter(p,'direction','auto');
addParameter(p,'outdir','');
addParameter(p,'keepInput',true);
addParameter(p,'verify',true);
addParameter(p,'minFree',2*2^30);
addParameter(p,'overwrite','verified');
addParameter(p,'flac','');
parse(p,varargin{:});
opt = p.Results;

ok = false; outFile = '';
info = struct('kind','','direction','','bytesIn',NaN,'bytesOut',NaN, ...
              'predictedOut',NaN,'why','','skipped',false,'stop','');

%% ---- what is it, and which way are we going
[kind, k] = audio_file_kind(inFile);
info.kind = kind;
info.bytesIn = k.bytes;

if strcmp(kind,'notaudio')
    info.why = k.why;
    return
end

isCompressed = any(strcmp(kind,{'flac','xflac'}));
switch lower(opt.direction)
    case 'auto';     direction = local_tern(isCompressed,'expand','compress');
    case 'compress'; direction = 'compress';
    case 'expand';   direction = 'expand';
    otherwise
        error('xwav_convert:direction','direction must be auto, compress or expand');
end
info.direction = direction;

if strcmp(direction,'compress') && isCompressed
    info.why = 'already compressed'; info.skipped = true; return
end
if strcmp(direction,'expand') && ~isCompressed
    info.why = 'not compressed'; info.skipped = true; return
end
if strcmp(direction,'compress') && ~k.encodable
    info.why = k.why; return
end

%% ---- where it goes
[srcDir, ~] = fileparts(inFile);
if isempty(opt.outdir); opt.outdir = srcDir; end
if ~exist(opt.outdir,'dir')
    [made, mkmsg] = mkdir(opt.outdir);
    if ~made
        info.why = sprintf('cannot create %s: %s', opt.outdir, mkmsg);
        return
    end
end

outFile = fullfile(opt.outdir, xwav_outname(inFile, kind, direction));
info.predictedOut = local_predict(k, direction);

%% ---- is it already there
if exist(outFile,'file')
    switch lower(opt.overwrite)
        case 'error'
            info.why = 'output already exists'; outFile = ''; return
        case 'skip'
            ok = true; info.skipped = true; info.why = 'already there';
            d = dir(outFile); info.bytesOut = d(1).bytes; return
        case 'verified'
            % The important case. After a run that filled a disk, the outputs
            % most in need of redoing are exactly the ones that exist -- so
            % "exists" is not good enough, it has to pass the same check a
            % fresh conversion would.
            if local_verify(inFile, outFile, kind, direction, k)
                ok = true; info.skipped = true; info.why = 'already there, verified';
                d = dir(outFile); info.bytesOut = d(1).bytes; return
            end
            % falls through and redoes it
        case 'replace'
            % falls through
        otherwise
            error('xwav_convert:overwrite','overwrite must be verified, skip, replace or error');
    end
end

%% ---- will it fit
[usable, ~, fsType, maxFileBytes] = disk_free(opt.outdir);
if ~isnan(info.predictedOut)
    if info.predictedOut > maxFileBytes
        % A warning, not a refusal: most drives are NTFS or exFAT, and the
        % filesystem report can be wrong. If it really is FAT32 the write will
        % fail and be caught, which is why this is not fatal.
        info.why = sprintf(['warning: %.2f GB output may exceed the %s limit ' ...
            'of %.2f GB'], info.predictedOut/2^30, fsType, maxFileBytes/2^30);
    end
    if ~isnan(usable)
        if info.predictedOut >= usable
            info.stop = sprintf(['destination full: needs %.2f GB, %.2f GB free'], ...
                info.predictedOut/2^30, usable/2^30);
            info.why = info.stop; outFile = ''; return
        end
        if usable - info.predictedOut < opt.minFree
            info.stop = sprintf(['would leave less than the %.2f GB reserve ' ...
                '(needs %.2f GB, %.2f GB free)'], opt.minFree/2^30, ...
                info.predictedOut/2^30, usable/2^30);
            info.why = info.stop; outFile = ''; return
        end
    end
end

%% ---- the tool
[exe, whyNot] = flac_exe(opt.flac);
if isempty(exe)
    info.why = whyNot; outFile = ''; return
end

%% ---- convert, to a temporary name in the destination folder
% The marker goes in the stem, not the extension, so flac still sees the file
% type it expects. Nothing that looks like a finished file ever exists until it
% has been verified, which is what makes a killed run or a full disk leave an
% obvious orphan rather than a plausible-looking truncated recording.
[~, outStem, outExt] = fileparts(outFile);
tmpFile = fullfile(opt.outdir, ['__triton_tmp__' outStem outExt]);
cleanTmp = onCleanup(@() local_rm(tmpFile));

if strcmp(direction,'compress')
    % --channel-map=none is needed above two channels: an x.wav fmt chunk
    % declares plain PCM where the WAV spec wants WAVE_FORMAT_EXTENSIBLE.
    % -V decodes each frame while encoding and compares, so a corrupted stream
    % is caught here rather than years from now.
    cmd = sprintf('"%s" -V --channel-map=none --keep-foreign-metadata -f -s -o "%s" "%s"', ...
        exe, tmpFile, inFile);
else
    % Restore the original chunks only if there are any; asking flac to restore
    % metadata that is not there is an error in strict mode.
    keepFlag = '';
    if local_has_chunks(inFile); keepFlag = '--keep-foreign-metadata '; end
    cmd = sprintf('"%s" -d %s-f -s -o "%s" "%s"', exe, keepFlag, tmpFile, inFile);
end

[st, out] = system(cmd);
if st ~= 0 || ~exist(tmpFile,'file')
    info.why = sprintf('flac failed: %s', strtrim(out));
    outFile = ''; return
end

d = dir(tmpFile);
info.bytesOut = d(1).bytes;
if info.bytesOut == 0
    info.why = 'flac produced an empty file'; outFile = ''; return
end

%% ---- verify before anything is allowed to look finished
if opt.verify
    [good, vwhy] = local_verify(inFile, tmpFile, kind, direction, k);
    if ~good
        info.why = vwhy; outFile = ''; return
    end
end

%% ---- put it in place
if exist(outFile,'file'); delete(outFile); end
[moved, mvmsg] = movefile(tmpFile, outFile, 'f');
if ~moved
    info.why = sprintf('cannot put the result in place: %s', mvmsg);
    outFile = ''; return
end
clear cleanTmp                      % nothing left to clean up

%% ---- only now is removing the source safe
if ~opt.keepInput
    % MATLAB's recycle setting would send it to the bin and free no space at
    % all, which defeats the point on a drive that is filling up.
    r = recycle('off');
    delete(inFile);
    recycle(r);
end

ok = true;
end


%% ================================================================== helpers
function bytes = local_predict(k, direction)
if strcmp(direction,'expand')
    bytes = k.decodedBytes;         % exact, from the header
else
    bytes = k.bytes;                % upper bound; flac does not grow real PCM
end
end


function tf = local_has_chunks(flacFile)
tf = false;
try
    tf = ~isempty(xflac_riff_chunks(flacFile));
catch
end
end


function [ok, why] = local_verify(srcFile, outFile, kind, direction, k)
%LOCAL_VERIFY  The same question in both directions.
%
% Whichever way the conversion went, one side is a wav and the other is a flac
% carrying that wav's non-audio chunks. So the check is the same: reassemble the
% preserved chunks and require them to reproduce the wav's leading bytes. That
% covers the harp header, the fmt chunk, and anything a partner's recorder wrote
% -- and it is the one thing flac's own integrity checks do not cover.
ok = false;

d = dir(outFile);
if isempty(d) || d(1).bytes == 0
    why = 'output is empty'; return
end

if strcmp(direction,'compress')
    flacFile = outFile; wavFile = srcFile;

    % A flac keeps its metadata at the START of the file, so one truncated
    % half way still has a perfectly good header -- the comparison below would
    % pass it while most of the audio is missing. That is not hypothetical: it
    % is what a drive filling mid-write leaves behind, and what a resumed run
    % would then skip over.
    %
    % STREAMINFO says how many samples the file should hold. Asking for the
    % last few is O(1) -- the seek table jumps straight there -- and a
    % truncated file simply cannot produce them.
    [tailOk, tailWhy] = local_check_tail(flacFile);
    if ~tailOk; why = tailWhy; return; end
else
    flacFile = srcFile; wavFile = outFile;

    % Expanding has an exact expected size, so check it. A short write is the
    % failure mode flac's CRCs cannot see.
    if ~isnan(k.decodedBytes) && d(1).bytes ~= k.decodedBytes
        why = sprintf('expected %d bytes, got %d', k.decodedBytes, d(1).bytes);
        return
    end
end

try
    chunks = xflac_riff_chunks(flacFile);
catch e
    why = ['cannot read flac metadata: ' e.message]; return
end

if isempty(chunks)
    if any(strcmp(kind,{'xwav','xflac'}))
        why = 'the harp header was NOT preserved'; return
    end
    % A plain flac with no preserved chunks: nothing to compare. flac's own
    % CRCs and stream MD5 already cover the audio.
    ok = true; why = ''; return
end

rebuilt = cat(1, chunks{:});
fid = fopen(wavFile,'r');
if fid < 0; why = 'cannot reopen the wav to compare headers'; return; end
original = fread(fid, numel(rebuilt), '*uint8');
fclose(fid);

if numel(original) ~= numel(rebuilt)
    why = sprintf('header length differs: %d in the wav, %d preserved', ...
        numel(original), numel(rebuilt));
    return
end
if ~isequal(original, rebuilt)
    why = sprintf('preserved header differs from the wav at %d of %d bytes', ...
        sum(original ~= rebuilt), numel(rebuilt));
    return
end

% If it started as an xwav it must still be one.
if any(strcmp(kind,{'xwav','xflac'})) && ~any(local_is_harp(chunks))
    why = 'the harp chunk was NOT preserved'; return
end

ok = true; why = '';
end


function [ok, why] = local_check_tail(flacFile)
%LOCAL_CHECK_TAIL  Can this flac still produce its last samples?
%
% Catches a truncated file without decoding the whole thing. STREAMINFO records
% the total sample count; if the audio frames that hold the end of the file are
% missing, reading there fails or comes back short.
ok = false;
try
    I = audioinfo(flacFile);
catch e
    why = ['cannot read the flac back: ' e.message]; return
end
n = I.TotalSamples;
if n <= 0
    % Written from a stream, so there is no recorded length to check against.
    % flac's own per-frame CRCs still cover what is there.
    ok = true; why = ''; return
end
want = min(1024, n);
first = n - want + 1;
try
    tail = audioread(flacFile, [first n], 'native');
catch e
    why = sprintf('truncated or corrupt: cannot read the last %d samples (%s)', ...
        want, e.message);
    return
end
if size(tail,1) ~= want
    why = sprintf('truncated: asked for the last %d samples, got %d', ...
        want, size(tail,1));
    return
end
ok = true; why = '';
end


function tf = local_is_harp(chunks)
tf = false(1,numel(chunks));
for k = 1:numel(chunks)
    b = chunks{k};
    tf(k) = numel(b) >= 4 && strcmp(char(b(1:4))','harp');
end
end


function local_rm(f)
try %#ok<TRYNC>
    if exist(f,'file'); delete(f); end
end
end


function v = local_tern(c, a, b)
if c; v = a; else; v = b; end
end
