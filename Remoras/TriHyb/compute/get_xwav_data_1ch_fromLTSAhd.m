function DATA = get_xwav_data_1ch_fromLTSAhd( xwav, startt, endt, localParams)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  DATA = get_xwav_data_1ch( xwav, startt, endt )
%
%  Given start/end strings, returns data from single channel xwav
%
%  xwav - xwav w/ path
%  startt - start time in datenum() friendly format, if time is before
%         start time of file, data is read in from BOF
%  endt - end time in datenum() friendly format, if time is after end time
%         of file, data is read in until EOF
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DATA = [];

if ~ischar(startt) || ~ischar(endt)
    disp('Input time should be date strings!')
    disp('Try again!')
    return
end

Y2K = datenum([ 2000 0 0 0 0 0 ]);
mnum2secs = 24*60*60;

dnum0 = datenum(startt);
dnumN = datenum(endt);


[ xpath, xfn, xext ] = fileparts(xwav);
localParams.infile = sprintf('%s%s',xfn,xext);
localParams.inpath = xpath;

% need to initialize this stuff, rdxwavhd does not
%localParams.xhd = [];
%localParams.raw = [];
localParams.ftype = 2;
%rdxwavhd;


if localParams.ltsa.nBits == 16
    dtype = 'int16';
elseif localParams.ltsa.nBits== 32
    dtype = 'int32';
else
    disp('localParams.nBits = ')
    disp(localParams.nBits)
    disp('not supported')
    return
end


% a lil sanity check doesn't hurt anybody
if dnum0 < ( localParams.start.dnum + Y2K )
    fprintf('Start time is before XWAV start!\n')
    fprintf('Setting start time to BOF\n');
    dnum0 = localParams.start.dnum + Y2K;
end

if dnumN > ( localParams.end.dnum + Y2K )
    fprintf('End time is after XWAV end!\n')
    fprintf('Setting end time to EOF\n');
    dnumN = localParams.end.dnum + Y2K;
end

if dnumN < dnum0
    disp('End time before the start time!')
    DATA = [];
    return
end

rfStarts = localParams.raw.dnumStart + Y2K;
rfEnds = localParams.raw.dnumEnd + Y2K;
rfIdx0 = find( rfStarts <= dnum0,1,'last' );
rfIdxN = find( rfEnds >= dnumN, 1,'first' );

if isempty(rfIdx0)
    disp('Couldn''t find date range in XWAV...PANIC!');
    return;
end

% check that start time is not in gap
if rfEnds(rfIdx0) < dnum0
    rfIdx0 = rfIdx0+1;
    fprintf('Start time not found in data, data starts %s\n', datestr(rfStarts(rfIdx0),'mm/dd/yy HH:MM:SS.FFF'));
    skip_s = 0;
else
    skip_s = (dnum0 - rfStarts(rfIdx0)) * mnum2secs;
end

% check that end time is not in gap
if rfStarts(rfIdxN) > dnumN
    rfIdxN = rfIdxN-1;
    fprintf('End time not found in data, data ends %s\n', datestr(rfEnds(rfIdxN),'mm/dd/yy HH:MM:SS.FFF'));
    end_s = (rfEnds(rfIdxN)-rfStarts(rfIdxN) )*mnum2secs;
else
    end_s = (dnumN - rfStarts(rfIdxN)) * mnum2secs;
end

% check that raw files are still ordered
if rfIdxN < rfIdx0
    disp('No data available for time period!\n');
    DATA = [];
    return;
end


skip_samp = round(skip_s * localParams.ltsa.fs);
% bytes to skip from start of file
start_B = localParams.xhd.byte_loc(rfIdx0) + skip_samp * floor(localParams.ltsa.nBits/8);

end_samp = round(end_s*localParams.ltsa.fs);
end_B = localParams.xhd.byte_loc(rfIdxN) + end_samp*floor(localParams.ltsa.nBits/8);

%define how much data to read in
bin_B = end_B-start_B;
bin_samps = bin_B/floor(localParams.ltsa.nBits/8);


% fprintf('end_s = %f,\tend_samp = %d,\tend_B = %d\n\n', ...
%     end_s, end_samp, end_B);

DATA = nan(bin_samps,1);
dataIdx = 1;

% Sample layout, for xwav_read. audioStart is where this file's audio begins
% in the equivalent x.wav; xwav_read needs it to address a compressed xwav by
% sample, and ignores it for an .x.wav. localParams.xhd holds only this file's
% raw files, so entry 1 is the right one.
geom = struct('nch', 1, 'nBits', localParams.ltsa.nBits, ...
    'audioStart', localParams.xhd.byte_loc(1));

bytesPerSample = floor(localParams.ltsa.nBits / 8);

for rf=rfIdx0:rfIdxN
    % Byte offset of this read within the equivalent x.wav. The old code did
    % this as a seek to the raw file start followed by a relative seek; the
    % sum is the same number, and stating it outright is what lets xwav_read
    % turn it into a sample index when the file is a flac.
    b1 = 0;

    % all data in 1 rawfile
    if rfIdx0 == rfIdxN
        % skip past data we don't want in first raw file
        b1 = skip_samp*floor(localParams.ltsa.nBits/8);
        % read from start loc to end loc in 1 raw file
        nb = (end_samp - skip_samp) * bytesPerSample;

    elseif rf == rfIdx0
        % First raw file in a multi-file segment
        b1 = skip_samp * bytesPerSample;
        nb = localParams.xhd.byte_length(rf) - b1;
    elseif rf == rfIdxN
        % Final raw file in a multi-file segment
        nb = end_samp * bytesPerSample;

    else
        % Fully included raw file in between
        nb = localParams.xhd.byte_length(rf);
    end

    if nb < 0
        disp('Buffer wrap around or sync loss is causing missing data in this rawfile, skipping to the next rawfile.');
        continue
    end

    nr = nb / bytesPerSample;
    % xwav_read fetches from either container.
    raw = xwav_read(double(localParams.xhd.byte_loc(rf)) + b1, nr, xwav, geom);
    if numel(raw) < nr
        warning('%s: rawfile %d has fewer bytes on disk than its header claims (expected %d samples, found %d) -- likely truncated/corrupt, skipping this rawfile.', ...
            xwav, rf, nr, numel(raw));
        continue
    end
    DATA(dataIdx:dataIdx + nr - 1) = raw;
    
    dataIdx = dataIdx + nr;

end

naIdx = find(isnan(DATA),1,'first');
if ~isempty(naIdx)
    fprintf('Read %d of %d requested samples for %s (rawfile gap or corruption)\n', naIdx-1, bin_samps, xwav);
    DATA(naIdx:end) = [];
end

end
