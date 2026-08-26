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
    if PARAMS.ftype == 1 || PARAMS.ftype == 3   % wav or flac file
        skip = floor((PARAMS.plot.dnum - PARAMS.start.dnum) * 24 * 60 * 60 * PARAMS.fs);   % number of samples to skip over
        % %
        %PARAMS.tseg.samp = floor( PARAMS.tseg.sec * PARAMS.fs )+1;
        PARAMS.tseg.samp = ceil( PARAMS.tseg.sec * PARAMS.fs );	% number of samples in segment
%         DATA = double(wavread( fullfname, [skip+1 skip+PARAMS.tseg.samp], 'Native' ));
        [DATA,Fs] = audioread( fullfname, [skip+1 skip+PARAMS.tseg.samp], 'native' );
        DATA = double(DATA);
%         DATA = DATA(:,PARAMS.ch).*2^15;     % un-normalize wavread
    elseif PARAMS.ftype == 2    % xwav file
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

    PARAMS.tseg.samp = ceil( PARAMS.tseg.sec * PARAMS.fs );  % number of samples in segment

    fid = fopen(fullfname,'r');            % open once, reused across the rest of the code

    segIdx = PARAMS.raw.currentIndex;      % raw segment containing the window's start time
    samplesNeeded = PARAMS.tseg.samp;      % how many samples we still owe the window
    DATA = [];                              
    raw_end_times = [];                     % one real boundary per segment crossed
    readStartDnum = PARAMS.plot.dnum;       % calendar time this chunk's read should start at

    while samplesNeeded > 0 && segIdx <= numel(PARAMS.raw.dnumStart)

        % how many samples into THIS segment does our read start point fall?
        skip = round((readStartDnum - PARAMS.raw.dnumStart(segIdx)) * 24*60*60 * PARAMS.fs);

        % how many samples does this segment actually have left, from here to its own true end?
        segSamplesAvail = round((PARAMS.raw.dnumEnd(segIdx) - readStartDnum) * 24*60*60 * PARAMS.fs);

        samplesToRead = min(samplesNeeded, segSamplesAvail);   % never read past this segment's real end

        fseek(fid, PARAMS.xhd.byte_loc(segIdx) + skip*PARAMS.nch*PARAMS.samp.byte, 'bof');
        chunk = fread(fid, [PARAMS.nch, samplesToRead], dtype)';
        DATA = [DATA; chunk];                                   % tack this segment's audio onto the window

        samplesNeeded = samplesNeeded - samplesToRead;

        raw_end_times(end+1) = (PARAMS.raw.dnumEnd(segIdx) - PARAMS.plot.dnum) * 60*60*24;
                                                                  % this segment's real boundary, for the marker line

        if samplesNeeded > 0                                    % window still isn't full
            if segIdx == numel(PARAMS.raw.dnumStart)
                % no raw segments left at all -- pad the remainder so the plot still spans the GUI's requested length
                disp_msg('Reached the end of the last raw file before filling the plot window; padding remainder');
                DATA = [DATA; zeros(samplesNeeded, PARAMS.nch)];
                samplesNeeded = 0;
                break
            end

            gapSec = (PARAMS.raw.dnumStart(segIdx+1) - PARAMS.raw.dnumEnd(segIdx)) * 24*60*60;
            if gapSec >  1/PARAMS.fs % setting the need for padding based on any time skip that is smaller than one sample's worth of time (similar to check_time.m)
                % real recording gap -- pad just the missing duration, then keep reading real audio after it
                disp_msg('Recording gap encountered mid plot window; padding the gap to preserve requested plot length');
                gapSamples = min(round(gapSec * PARAMS.fs), samplesNeeded);
                DATA = [DATA; zeros(gapSamples, PARAMS.nch)];
                samplesNeeded = samplesNeeded - gapSamples;
            end

            if samplesNeeded > 0
                segIdx = segIdx + 1;                             % move on to the next segment and keep collecting
                readStartDnum = PARAMS.raw.dnumStart(segIdx);
            end
        end
    end

    fclose(fid);

    if PARAMS.xgain > 0
        DATA(:,PARAMS.ch) = DATA(:,PARAMS.ch) ./ PARAMS.xgain(1);
    end

    PARAMS.raw.delimit_time = raw_end_times;
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

