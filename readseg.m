function readseg
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% readseg.m
%
% read a segment of data from opened file
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global PARAMS DATA
check_time      % check to see if ok plot start time (PARAMS.plot.dvec or
                % PARAMS.plot.dnum)

DATA = [];  % clear DATA vector

fullfname = fullfile(PARAMS.inpath,PARAMS.infile);

% if multich_on % multi channel mode! read all channels into a MATRIX
%     if PARAMS.ftype == 1        % wav file
%         [ m d ] = wavfinfo(fullfname);
%         if isempty(m)
%             disp_msg(sprintf([ 'Unable to get info on file %s: Not a wave ',...
%                 'or unsupported bit depth ( > 16-bit )?' ], fullfname));
%             return
%         end
%         skip = floor((PARAMS.plot.dnum - PARAMS.start.dnum) * 24 * 60 * 60 * PARAMS.fs);   % number of samples to skip over
%         % %
%         %PARAMS.tseg.samp = floor( PARAMS.tseg.sec * PARAMS.fs )+1;
%         PARAMS.tseg.samp = ceil( PARAMS.tseg.sec * PARAMS.fs );	% number of samples in segment
% %        DATA = wavread(fullfname, [skip+1 skip+PARAMS.tseg.samp], 'Native' );
%
%         mDATA = double(wavread(fullfname, [skip+1 skip+PARAMS.tseg.samp], 'Native' ));
%         %DATA = DATA(:,PARAMS.ch).*2^15;     % un-normalize wavread
%
%     elseif PARAMS.ftype == 2    % xwav file
%         index = PARAMS.raw.currentIndex;
%         if PARAMS.nBits == 16
%             dtype = 'int16';
%         elseif PARAMS.nBits == 32
%             dtype = 'int32';
%         else
%             disp_msg('PARAMS.nBits = ')
%             disp_msg(PARAMS.nBits)
%             disp_msg('not supported')
%             return
%         end
%         skip = floor((PARAMS.plot.dnum - PARAMS.raw.dnumStart(index)) * 24 * 60 * 60 * PARAMS.fs);   % number of samples to skip over
%         % %
%         PARAMS.tseg.samp = ceil( PARAMS.tseg.sec * PARAMS.fs );	% number of samples in segment
%         fid = fopen(fullfname,'r');
%         fseek(fid,PARAMS.xhd.byte_loc(index) + skip*PARAMS.ch*PARAMS.samp.byte,'bof');
%         mDATA = fread(fid,[ PARAMS.nch,PARAMS.tseg.samp ],dtype)';
%         fclose(fid);
%         if PARAMS.xgain > 0
%             mDATA(:,:) = mDATA(:,:) ./ PARAMS.xgain(1);
%         end
%         % calculate where the first raw file ends in the current plot
%         raw_end_times(1) = (PARAMS.raw.dnumEnd(PARAMS.raw.currentIndex) - PARAMS.plot.dnum)...
%             * 60 * 60 * 24;
%         % assuming that all raw files are the same length
%         bytes_on_plot = PARAMS.tseg.sec*PARAMS.xhd.ByteRate(1);
%         % how many bytes are left after the first raw file ends
%         bytes_left = bytes_on_plot - raw_end_times(1)*PARAMS.xhd.ByteRate(1);%PARAMS.fs*2;
%         if bytes_left > 0 % only true when two raw files in plot
%             seconds_per_raw = PARAMS.xhd.byte_length(1)/PARAMS.xhd.ByteRate(1);
%             num_of_raw = ceil((PARAMS.tseg.sec - raw_end_times(1))/seconds_per_raw) + 1; % +1 for first rawfile
%             raw_end_times(2:num_of_raw) = raw_end_times(1) + [1:num_of_raw-1]*seconds_per_raw;
%         end
%         PARAMS.raw.delimit_time = raw_end_times;
%         %calculate micro seconds skipped since time resolution is too low
%     %     micro_samples = mod(skip,PARAMS.fs/1000);
%     %     if micro_samples < PARAMS.fs/1000 && micro_samples ~= 0
%     %       %number of samples per microsecond times divided by the number of
%     %       %samples skipped. It's floored for display in matlab purposes
%     %       PARAMS.plot.uuu = floor(micro_samples/(PARAMS.fs*.000001));
%     %     else
%     %       PARAMS.plot.uuu = 0;
%     %     end
%     %
%     end
% else
    if PARAMS.ftype == 1        % wav file
        skip = floor((PARAMS.plot.dnum - PARAMS.start.dnum) * 24 * 60 * 60 * PARAMS.fs);   % number of samples to skip over
        % %
        %PARAMS.tseg.samp = floor( PARAMS.tseg.sec * PARAMS.fs )+1;
        PARAMS.tseg.samp = ceil( PARAMS.tseg.sec * PARAMS.fs );	% number of samples in segment
%         DATA = double(wavread( fullfname, [skip+1 skip+PARAMS.tseg.samp], 'Native' ));
        [DATA,Fs] = audioread( fullfname, [skip+1 skip+PARAMS.tseg.samp], 'native' );
        DATA = double(DATA);
%         DATA = DATA(:,PARAMS.ch).*2^15;     % un-normalize wavread
    elseif PARAMS.ftype == 2    % xwav file
        index = PARAMS.raw.currentIndex;
        if PARAMS.nBits == 16
            dtype = 'int16';
        elseif PARAMS.nBits == 24
            dtype = 'int24';
        elseif PARAMS.nBits == 32
            dtype = 'int32';
        else
            disp_msg('PARAMS.nBits = ')
            disp_msg(PARAMS.nBits)
            disp_msg('not supported')
            return
        end

        skip = floor((PARAMS.plot.dnum - PARAMS.raw.dnumStart(index)) * 24 * 60 * 60 * PARAMS.fs);   % number of samples to skip over
        PARAMS.tseg.samp = ceil( PARAMS.tseg.sec * PARAMS.fs );	% number of samples in segment

        fid = fopen(fullfname,'r');
        fseek(fid,PARAMS.xhd.byte_loc(index) + skip*PARAMS.nch*PARAMS.samp.byte,'bof');
        DATA = fread(fid,[PARAMS.nch,PARAMS.tseg.samp],dtype)';
        fclose(fid);

        if PARAMS.xgain > 0
            DATA(:,PARAMS.ch) = DATA(:,PARAMS.ch) ./ PARAMS.xgain(1);
        end

        % Work out, for this plot window, where each raw file actually ends
        % and where the real recording gaps are. Both are measured in
        % seconds from the start of the window.
        %
        % Boundaries are read from PARAMS.raw.dnumEnd rather than
        % extrapolated from the first raw file's length, which was wrong
        % whenever a segment was short or a gap intervened.
        %
        % DATA is deliberately NOT modified here. Gaps are reported through
        % PARAMS.raw.gap_time so the plotting code can mark them, while
        % every analysis caller keeps receiving exactly the samples it
        % always has.

        winStart = PARAMS.plot.dnum;                    % window start [days]
        winEnd   = winStart + PARAMS.tseg.sec / 86400;  % window end   [days]

        % A gap only counts if it is longer than a millisecond. Measured
        % timestamp rounding between consecutive raw files is about one
        % sample, which is far below this; real duty cycles are far above.
        gapTol = 1e-3;                                  % [seconds]

        raw_end_times = [];   % boundary positions, seconds into the window
        gap_time      = [];   % one row per gap: [position_sec, length_sec]

        for k = PARAMS.raw.currentIndex : numel(PARAMS.raw.dnumEnd)
            if PARAMS.raw.dnumStart(k) >= winEnd
                break                                   % starts after the window
            end

            endSec = (PARAMS.raw.dnumEnd(k) - winStart) * 86400;
            inWindow = endSec > 0 && endSec < PARAMS.tseg.sec;

            if inWindow
                raw_end_times(end+1) = endSec;                       %#ok<AGROW>
            end

            if k < numel(PARAMS.raw.dnumStart)
                gapSec = (PARAMS.raw.dnumStart(k+1) - PARAMS.raw.dnumEnd(k)) * 86400;
                if gapSec > gapTol && inWindow
                    gap_time(end+1, 1:2) = [endSec, gapSec];         %#ok<AGROW>
                end
            end
        end

        if isempty(raw_end_times)
            raw_end_times = 0;   % keeps the existing "one value = draw nothing" behaviour
        end

        PARAMS.raw.delimit_time = raw_end_times;
        PARAMS.raw.gap_time     = gap_time;
        %calculate micro seconds skipped since time resolution is too low
    %     micro_samples = mod(skip,PARAMS.fs/1000);
    %     if micro_samples < PARAMS.fs/1000 && micro_samples ~= 0
    %       %number of samples per microsecond times divided by the number of
    %       %samples skipped. It's floored for display in matlab purposes
    %       PARAMS.plot.uuu = floor(micro_samples/(PARAMS.fs*.000001));
    %     else
    %       PARAMS.plot.uuu = 0;
    %     end
    %
    end
% end

PARAMS.save.dnum = PARAMS.plot.dnum;    % save it for next time
end

