function report = ck_xflac_metadata(target, varargin)
%CK_XFLAC_METADATA  Check that x.flac files still carry their harp header.
%
%   ck_xflac_metadata('E:\path\to\flac')            % walk a folder
%   ck_xflac_metadata('one_file.x.flac')            % check one file
%   r = ck_xflac_metadata(folder, 'verbose', true)  % list every file
%
% When an x.wav is compressed with `flac --keep-foreign-metadata`, the original
% RIFF chunks -- including the `harp` chunk with the raw-file directory -- are
% stored inside the flac as APPLICATION metadata blocks with the id 'riff'. That
% is what makes the conversion reversible and what lets the recording times and
% raw-file structure survive.
%
% Compress *without* that flag and the audio is preserved but the harp chunk is
% gone for good. The file still plays, still reports the right sample rate, and
% looks entirely healthy -- but the deployment timing, the raw-file boundaries
% and the gain are unrecoverable, and it can never be turned back into an x.wav.
%
% Conversion scripts often fall back to a no-metadata command when the first
% attempt fails, so a folder can contain a mix without anyone noticing. This
% checks for the harp block and reports which files lack it.
%
% Returns a struct with .ok, .missing and .unreadable lists.
%
% Also reports a mismatch between the number of raw files the harp chunk
% declares and the number of directory entries it actually contains, which
% indicates a truncated or edited header.

p = inputParser;
addParameter(p,'verbose',false);
parse(p,varargin{:});
opt = p.Results;

if exist(target,'dir')
    listing = dir(fullfile(target,'**','*.flac'));
    files = arrayfun(@(d) fullfile(d.folder,d.name), listing, 'UniformOutput', false);
elseif exist(target,'file')
    files = {target};
else
    error('ck_xflac_metadata: no such file or folder: %s', target);
end

report = struct('ok',{{}}, 'missing',{{}}, 'unreadable',{{}});

fprintf('Checking %d flac file(s) for a preserved harp header\n\n', numel(files));

for k = 1:numel(files)
    f = files{k};
    try
        [hasHarp, nDeclared, nEntries] = local_scan(f);
    catch e
        report.unreadable{end+1} = f; %#ok<AGROW>
        fprintf('  UNREADABLE  %s\n              %s\n', local_short(f), e.message);
        continue
    end

    if ~hasHarp
        report.missing{end+1} = f; %#ok<AGROW>
        fprintf('  NO HARP     %s\n', local_short(f));
    elseif nDeclared ~= nEntries
        report.missing{end+1} = f; %#ok<AGROW>
        fprintf('  HEADER BAD  %s\n              declares %d raw files, holds %d entries\n', ...
            local_short(f), nDeclared, nEntries);
    else
        report.ok{end+1} = f; %#ok<AGROW>
        if opt.verbose
            fprintf('  ok          %s  (%d raw files)\n', local_short(f), nEntries);
        end
    end
end

fprintf('\n  with harp header : %d\n', numel(report.ok));
fprintf('  MISSING or bad   : %d\n', numel(report.missing));
fprintf('  unreadable       : %d\n', numel(report.unreadable));

if ~isempty(report.missing)
    fprintf('\n  Files listed above cannot be turned back into x.wav and have lost\n');
    fprintf('  their recording times and raw-file structure. If the original x.wav\n');
    fprintf('  still exists, reconvert with --keep-foreign-metadata-if-present.\n');
else
    fprintf('\n  All files carry a harp header and can be converted back.\n');
end
end


%% ================================================================== helpers
function [hasHarp, nDeclared, nEntries] = local_scan(f)
%LOCAL_SCAN  Walk the flac metadata blocks looking for an APPLICATION/riff harp.
hasHarp = false; nDeclared = NaN; nEntries = NaN;

fid = fopen(f,'r');
if fid < 0; error('cannot open file'); end
c = onCleanup(@() fclose(fid));

magic = fread(fid,4,'*char')';
if ~strcmp(magic,'fLaC'); error('not a flac file (magic is %s)', magic); end

while true
    h = fread(fid,4,'*uint8');
    if numel(h) < 4; break; end
    isLast = bitand(h(1),128) > 0;
    btype  = double(bitand(h(1),127));
    len    = double(h(2))*65536 + double(h(3))*256 + double(h(4));
    body   = fread(fid,len,'*uint8');
    if numel(body) < len; error('metadata block truncated'); end

    if btype == 2 && len >= 8
        appid = char(body(1:4))';
        tag   = char(body(5:8))';
        if strcmp(appid,'riff') && strcmp(tag,'harp')
            hasHarp = true;
            p = body(5:end);                       % the harp chunk itself
            % NumOfRawFiles is a uint16 at offset 44 within the chunk
            if numel(p) >= 46
                nDeclared = double(p(45)) + double(p(46))*256;
            end
            % fixed part is 64 bytes, each raw-file entry is 32
            nEntries = floor((double(numel(p)) - 64) / 32);
        end
    end
    if isLast; break; end
end
end


function s = local_short(f)
[p,n,e] = fileparts(f);
[~,parent] = fileparts(p);
s = fullfile(parent,[n e]);
end
