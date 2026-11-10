function [ratio, nSampled, note] = flac_sample_ratio(files, exe, varargin)
%FLAC_SAMPLE_RATIO  Measure how well this data compresses, by trying a little of it.
%
%   [ratio, n, note] = flac_sample_ratio(files, exe)
%
%   files   cell array of wav paths
%   exe     the flac program, from flac_exe
%   ratio   output size to budget, as a fraction of input. NaN if it could not
%           be measured, and the caller must then fall back to its own worst
%           case and say so.
%   note    one line describing what was measured, for the user
%
% Options
%   'nFiles'   how many files to sample (default 5)
%   'seconds'  how much audio from each (default 20)
%   'margin'   safety factor on the measured figure (default 1.10)
%
% WHY THIS EXISTS
%
% Budgeting the full input size for a compression run is safe but wildly
% pessimistic, and the pessimism has a real cost: a 9.9 TB deployment was
% reported as needing 10110 GB on the destination when it actually wanted about
% a third of that. People then go and free space they did not need to free, or
% conclude the drive they have is too small.
%
% How well audio compresses cannot be known without compressing it -- but it
% can be measured, cheaply, because a short piece of a recording compresses
% almost exactly as well as the whole of it. Checked against whole-file
% encodes of three real recordings:
%
%   SOCAL 200 kHz x.wav, 900 MB   whole 36.2%   20 s sample 36.4%
%   GOM 4-channel x.wav, 744 MB   whole 32.8%   20 s sample 32.5%
%   SanctSound plain wav, 518 MB  whole 36.4%   20 s sample 37.9%
%
% Within one and a half percentage points, for 0.1 s of work against 3-5 s to
% encode the file in full. flac seeks straight to the sampled region rather
% than reading up to it, so the cost does not grow with file size.
%
% The sample is taken from a quarter of the way in rather than the start,
% because the beginning of a deployment often holds the quietest water -- the
% instrument settling, before anything is nearby -- and that would flatter the
% ratio.
%
% The figure returned is the WORST of the files sampled, not the average, with
% a further margin on top. Being a little over is dull; being under means a
% run stops part way.
%
% See also XWAV_CONVERT_PLAN, DISK_FREE, FLAC_EXE.

p = inputParser;
addParameter(p,'nFiles',5);
addParameter(p,'seconds',20);
addParameter(p,'margin',1.10);
parse(p,varargin{:});
opt = p.Results;

ratio = NaN; nSampled = 0; note = '';

if isempty(files) || isempty(exe)
    note = 'could not measure compression; budgeting the full source size';
    return
end

% Spread the picks across the set rather than taking the first few: a
% deployment's folders are often in time order, and the first card is not
% representative of the rest.
n = numel(files);
idx = unique(round(linspace(1, n, min(opt.nFiles, n))));

tmp = [tempname '.flac'];
cleanup = onCleanup(@() local_rm(tmp));

ratios = [];
for k = idx
    r = local_one(files{k}, exe, tmp, opt.seconds);
    if ~isnan(r); ratios(end+1) = r; end %#ok<AGROW>
end

nSampled = numel(ratios);
if nSampled == 0
    note = 'could not measure compression; budgeting the full source size';
    return
end

% Worst case seen, plus a margin, and never claim better than 5% or worse
% than no compression at all.
ratio = min(1, max(0.05, max(ratios) * opt.margin));

note = sprintf(['measured on %d file(s): about %.0f%% of the source, ' ...
    'budgeted at %.0f%%'], nSampled, 100*max(ratios), 100*ratio);
end


%% ================================================================== helpers
function r = local_one(f, exe, tmp, secs)
%LOCAL_ONE  Encode a slice of one file and report its compressed fraction.
r = NaN;
try
    I = audioinfo(f);
catch
    return
end
if I.TotalSamples <= 0 || I.NumChannels <= 0; return; end

bytesPerSlice = I.NumChannels * floor(I.BitsPerSample/8);
if bytesPerSlice <= 0; return; end

want = round(secs * I.SampleRate);
skip = floor(I.TotalSamples/4);
if skip + want > I.TotalSamples
    skip = 0;
    want = I.TotalSamples;          % short file: take all of it
end
if want <= 0; return; end

% No --keep-foreign-metadata here: this is a slice, not a conversion, and all
% that is wanted from it is the ratio of audio bytes in to bytes out. The real
% conversion adds the preserved header, which is a kilobyte or so against files
% measured in gigabytes.
cmd = sprintf('"%s" --channel-map=none --skip=%d --until=%d -f -s -o "%s" "%s"', ...
    exe, skip, skip+want, tmp, f);
[st, ~] = system(cmd);
if st ~= 0 || ~exist(tmp,'file'); return; end

d = dir(tmp);
rawBytes = want * bytesPerSlice;
if rawBytes <= 0 || d(1).bytes <= 0; return; end
r = d(1).bytes / rawBytes;
end


function local_rm(f)
try %#ok<TRYNC>
    if exist(f,'file'); delete(f); end
end
end
