function sm_ck_ltsaparams
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sm_ck_ltsaparams.m
%
% check user defined ltsa parameters and adjusts/gives suggestions of
% better parameters so that there is integer number of averages per xwav
% file and
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS

% get sample rate - only the first file sr for now.....
if PARAMS.ltsa.ftype == 1   % wav
%     [y, PARAMS.ltsa.fs, nBits, OPTS] = wavread( fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(1,:)),10);
    info = audioinfo(fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(1,:)));
    PARAMS.ltsa.fs = info.SampleRate;
elseif PARAMS.ltsa.ftype == 2   % xwav
    fid = fopen(fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(1,:)),'r');
    fseek(fid,24,'bof');
    PARAMS.ltsa.fs = fread(fid,1,'uint32');          % Sampling Rate (samples/second)
    fclose(fid);
end

% check that all sample rates match first file
I = [];
I = find(PARAMS.ltsahd.sample_rate ~= PARAMS.ltsa.fs);
if ~isempty(I)
    disp('different sample rates')
    disp(num2str(PARAMS.ltsahd.sample_rate(I)))
    disp(num2str(I))
    return
end

% check to see if header times are in correct order based on file names
tf = issorted(PARAMS.ltsahd.dnumStart);
if ~tf
    [B,IX] = sort(PARAMS.ltsahd.dnumStart);
    seq = 1:1:length(B);
    IY = find(IX ~= seq);
    disp('Raw files out of sequence are : ')
    disp(num2str(IX(IY)))
    disp('header times are NOT sequential')
    % return
end

% number of samples per data 'block' HARP=1sector(512bytes), ARP=64kB
if PARAMS.ltsa.dtype == 1       % HARP data => 12 byte header
    if PARAMS.ltsa.nch == 1
        PARAMS.ltsa.blksz = (512 - 12)/2;
    elseif PARAMS.ltsa.nch == 4
        
        PARAMS.ltsa.blksz = (512 - 12 - 4)/2;
    else
        disp('ERROR -- number of channels not 1 nor 4')
        disp(['nchan = ',num2str(PARAMS.ltsa.nch)])
    end
    % elseif PARAMS.ltsa.dtype == 2   % ARP data => 32 byte header + 2 byte tailer
    %     PARAMS.ltsa.blksz = (65536 - 34)/2;
    % elseif PARAMS.ltsa.dtype == 3   % OBS data => 128 samples per block
    %     PARAMS.ltsa.blksz = 128;
elseif PARAMS.ltsa.dtype == 4 || PARAMS.ltsa.dtype == 5 % wave files
    % don't worry about it for this type...
    % added for very long wav files with only one raw file

else
    disp('Error - non-supported data type')
    disp(['PARAMS.ltsa.dtype = ',num2str(PARAMS.ltsa.dtype)])
    return
end

% check to see if tave is too big, if so, set to max length
%
% maxTave = (PARAMS.ltsahd.write_length(1) * 250) / PARAMS.ltsa.fs;
if PARAMS.ltsa.ftype ~= 1
    maxTave = (PARAMS.ltsahd.write_length(1) * PARAMS.ltsa.blksz) / PARAMS.ltsa.fs;
    if PARAMS.ltsa.tave > maxTave
        PARAMS.ltsa.tave = maxTave;
        disp('Averaging time too long, set to maximum')
        disp(['Tave = ',num2str(PARAMS.ltsa.tave)])
    end
end
% number of samples for fft - make sure it is an integer
% PARAMS.ltsa.nfft = ceil(PARAMS.ltsa.fs / PARAMS.ltsa.dfreq);
PARAMS.ltsa.nfft = floor(PARAMS.ltsa.fs / PARAMS.ltsa.dfreq);
disp(['Number of samples for fft: ', num2str(PARAMS.ltsa.nfft)])

% compression factor
PARAMS.ltsa.cfact = PARAMS.ltsa.tave * PARAMS.ltsa.fs / PARAMS.ltsa.nfft;
if PARAMS.ltsa.ftype == 1
    disp(['WAV to LTSA Compression Factor: ',num2str(PARAMS.ltsa.cfact)])
else
    disp(['XWAV to LTSA Compression Factor: ',num2str(PARAMS.ltsa.cfact)])
end
disp(' ')

% LTSA version number based on number of samples (averages)
% Version number is also set in previously called program, get_headers based
% on number of raw files
if PARAMS.ltsa.ftype == 1   % wav file
    Nsamp = floor(sum(PARAMS.ltsahd.nsamp ./ PARAMS.ltsa.nch));
else    % xwav file
    Nsamp = floor(sum(PARAMS.ltsahd.byte_length)/(PARAMS.ltsa.nch *PARAMS.ltsa.nBits/8)); 
end

% number of frequencies in each spectral average:
if mod(PARAMS.ltsa.nfft,2) % odd
    PARAMS.ltsa.nfreq = (PARAMS.ltsa.nfft + 1)/2;
else        % even
    PARAMS.ltsa.nfreq = PARAMS.ltsa.nfft/2 + 1;
end