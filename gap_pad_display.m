function D = gap_pad_display(D, gap_time, fs, nWant)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% gap_pad_display.m
%
% Insert silence for real recording gaps -- FOR DISPLAY ONLY.
%
%   D = gap_pad_display(D, gap_time, fs, nWant)
%
% readseg returns DATA spliced across real recording gaps: the samples either
% side of a gap are adjacent in the array, so plotted seconds and real elapsed
% seconds drift apart by the gap length at every gap. Anything positioned by
% calendar time then lands in the wrong place -- raw file delimiters, a pick
% read back through coorddisp, and the bounding boxes a Remora overlays on the
% axes Triton created.
%
% This returns a copy with zero samples inserted for each gap, so that sample n
% sits at real elapsed n/fs seconds from the start of the plot window. It is
% called only by the plotting code, on a local copy. The DATA every analysis
% caller receives is untouched: no detector, no Remora and no LTSA ever sees
% these zeros.
%
% The inserted span is fabricated silence, not recorded quiet, so the caller is
% expected to mark it -- see the gap shading in plot_specgram and
% plot_timeseries, which reads the same PARAMS.raw.gap_time.
%
% input:
%       D         - samples x channels, as readseg returned them
%       gap_time  - one row per gap, [position_sec, length_sec], as readseg
%                   sets PARAMS.raw.gap_time. position_sec is real elapsed
%                   seconds from the window start, which is also where the gap
%                   belongs once the copy is padded
%       fs        - sample rate [Hz]
%       nWant     - optional. Samples the window should span (PARAMS.tseg.samp).
%                   The copy is trimmed to this so the window keeps its
%                   requested width; the audio trimmed off the end belongs to
%                   the next window
% return:
%       D         - the padded display copy
%
% See also READSEG, PLOT_SPECGRAM, PLOT_TIMESERIES, MKSPECGRAM
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(D) || isempty(gap_time)
    return
end

gap_time = sortrows(gap_time, 1);   % left to right, so the walk below holds
nch = size(D,2);

for r = 1:size(gap_time,1)
    % Every gap to the left of this one has already been inserted, so this
    % gap's position on the padded axis is its index in D as it now stands.
    % That is why no running offset is needed here.
    idx  = round(gap_time(r,1) * fs);
    idx  = max(0, min(idx, size(D,1)));
    nPad = round(gap_time(r,2) * fs);

    if nPad <= 0
        continue
    end

    D = [D(1:idx,:); zeros(nPad, nch); D(idx+1:end,:)];
end

% Keep the window at the width the GUI asked for. Without this the plot grows
% by the total gap length and the axis no longer matches PARAMS.tseg.sec.
if nargin > 3 && ~isempty(nWant) && size(D,1) > nWant
    D = D(1:nWant,:);
end
