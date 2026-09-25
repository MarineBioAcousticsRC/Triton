function [exe, why, ver] = flac_exe(preferred)
%FLAC_EXE  Locate the flac command-line tool.
%
%   exe = flac_exe()
%   exe = flac_exe('C:\tools\flac.exe')     % check this first
%   [exe, why] = flac_exe()                 % why is '' when found
%
% Returns '' if flac is not installed, with a sentence in `why` saying so.
% Callers report that themselves rather than this erroring, because for most of
% them compression is optional and its absence is not a failure.
%
% MATLAB cannot do this conversion itself: audiowrite writes flac, but not the
% APPLICATION metadata blocks that carry the harp header, so a MATLAB-written
% flac would lose the recording times. The command-line tool is required.
%
% Looked for, in order: the path given, the TRITON_FLAC environment variable,
% anything named flac on the system PATH, then the usual install locations.
%
% Download from https://xiph.org/flac/ or, on macOS, `brew install flac`.
%
% See also XWAV2FLAC, RDXFLACHD.

persistent cached cachedVer
exe = ''; why = ''; ver = '';

candidates = {};
if nargin >= 1 && ~isempty(preferred); candidates{end+1} = preferred; end
if ~isempty(cached); candidates{end+1} = cached; end

envPath = getenv('TRITON_FLAC');
if ~isempty(envPath); candidates{end+1} = envPath; end

for k = 1:numel(candidates)
    % isfile, not exist(...,'file'): exist returns 7 for a DIRECTORY, so a
    % folder that happens to be called flac would be accepted as the program.
    if isfile(candidates{k})
        [ok, v] = local_version(candidates{k});
        if ok
            exe = candidates{k}; ver = v; cached = exe; cachedVer = v;
            return
        end
    end
end

% on the PATH?
if ispc
    [st, out] = system('where flac');
else
    [st, out] = system('which flac');
end
if st == 0
    lines = strsplit(strtrim(out), newline);
    first = strtrim(lines{1});
    if ~isempty(first) && isfile(first)
        [ok, v] = local_version(first);
        if ok; exe = first; ver = v; cached = exe; cachedVer = v; return; end
    end
end

% the usual places
if ispc
    guesses = { 'C:\Program Files\flac-1.4.3-win\Win64\flac.exe', ...
                'C:\Program Files\flac\flac.exe', ...
                'C:\Program Files (x86)\flac\flac.exe' };
else
    guesses = { '/usr/bin/flac', '/usr/local/bin/flac', '/opt/homebrew/bin/flac' };
end
for k = 1:numel(guesses)
    if isfile(guesses{k})
        [ok, v] = local_version(guesses{k});
        if ok; exe = guesses{k}; ver = v; cached = exe; cachedVer = v; return; end
    end
end

why = ['No usable flac command-line tool was found (version 1.4.0 or newer ' ...
       'is required). Install it from https://xiph.org/flac/ and either put ' ...
       'it on the PATH or set the TRITON_FLAC environment variable to its ' ...
       'full path.'];
end


function [ok, ver] = local_version(exe)
%LOCAL_VERSION  Ask the program its version, and whether it is new enough.
%
% 1.4.0 is the floor. Before it, --keep-foreign-metadata behaved differently
% and --keep-foreign-metadata-if-present did not exist at all, so an older
% binary fails on every file with a message about an unrecognised option --
% which looks like a data problem and is not.
ok = false; ver = '';
[st, out] = system(['"' exe '" --version']);
if st ~= 0; return; end
t = regexp(strtrim(out), '(\d+)\.(\d+)(?:\.(\d+))?', 'tokens', 'once');
if isempty(t); return; end
ver = strtrim(out);
major = str2double(t{1}); minor = str2double(t{2});
ok = (major > 1) || (major == 1 && minor >= 4);
end
