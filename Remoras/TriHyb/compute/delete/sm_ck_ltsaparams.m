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

% only doing for HARP data right now...


% get sample rate - only the first file sr for now.....

if PARAMS.metadata.recursiveSearch == 1

    ff = dir(fullfile(PARAMS.metadata.inputDir, '**', PARAMS.fname(1).name));

    fid = fopen([ff.folder, '\' ff.name],'r');

elseif PARAMS.metadata.recursiveSearch == 0

    % Read 1-minute chunk of data from file
    fid = fopen(fullfile(PARAMS.metadata.inputDir,PARAMS.metadata.fname(1,:)),'r');
end




 %   fid = fopen(fullfile(PARAMS.ltsa.inputDir,PARAMS.ltsa.fname(1,:)),'r');
    fseek(fid,24,'bof');
    PARAMS.ltsa.fs = fread(fid,1,'uint32');          % Sampling Rate (samples/second)
    fclose(fid);
% end

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
% if PARAMS.ltsa.dtype == 1       % HARP data => 12 byte header
    if PARAMS.ltsa.nch == 1
        PARAMS.ltsa.blksz = (512 - 12)/2;
    elseif PARAMS.ltsa.nch == 4
        
        PARAMS.ltsa.blksz = (512 - 12 - 4)/2;
    else
        disp('ERROR -- number of channels not 1 nor 4')
        disp(['nchan = ',num2str(PARAMS.ltsa.nch)])
    end


% check to see if tave is too big, if so, set to max length
%
 maxTave = (PARAMS.ltsahd.write_length(1) * 250) / PARAMS.ltsa.fs;

% number of samples for fft - make sure it is an integer
PARAMS.ltsa.nfft = floor(PARAMS.ltsa.fs / PARAMS.ltsa.dfreq);
disp(['Number of samples for fft: ', num2str(PARAMS.ltsa.nfft)])


Nsamp = floor(sum(PARAMS.ltsahd.byte_length)/(PARAMS.ltsa.nch *PARAMS.ltsa.nBits/8)); 

% number of frequencies in each spectral average:
if mod(PARAMS.ltsa.nfft,2) % odd
    PARAMS.ltsa.nfreq = (PARAMS.ltsa.nfft + 1)/2;
else        % even
    PARAMS.ltsa.nfreq = PARAMS.ltsa.nfft/2 + 1;
end