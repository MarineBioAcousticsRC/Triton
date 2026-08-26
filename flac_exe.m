function [exe, why] = flac_exe(preferred)
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

persistent cached
exe = ''; why = '';

candidates = {};
if nargin >= 1 && ~isempty(preferred); candidates{end+1} = preferred; end
if ~isempty(cached); candidates{end+1} = cached; end

envPath = getenv('TRITON_FLAC');
if ~isempty(envPath); candidates{end+1} = envPath; end

for k = 1:numel(candidates)
    if exist(candidates{k},'file')
        exe = candidates{k};
        cached = exe;
        return
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
    if ~isempty(first) && exist(first,'file')
        exe = first; cached = exe; return
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
    if exist(guesses{k},'file')
        exe = guesses{k}; cached = exe; return
    end
end

why = ['The flac command-line tool was not found. Install it from ' ...
       'https://xiph.org/flac/ and either put it on the PATH or set the ' ...
       'TRITON_FLAC environment variable to its full path.'];
end
