function sm_get_headers_recur
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sm_get_headers.m
%
% open data files and read headers for making an ltsa file
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global PARAMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if PARAMS.metadata.recursiveSearch == 1
    PARAMS.fname = dir(fullfile(PARAMS.metadata.inputDir, '**', [PARAMS.metadata.FilenamePattern_ '.x.wav']));
elseif PARAMS.metadata.recursiveSearch == 0
    PARAMS.fname = dir(fullfile(PARAMS.metadata.inputDir, '*.x.wav'));    % xwav files
end


fnsz = size(PARAMS.fname);        % number of data files in directory
nfiles = fnsz(1);
disp_msg(' ')
disp_msg([num2str(nfiles),'  data files for all LTSAs'])
if fnsz(2)>80
    disp_msg('Error: filename length too long')
    disp_msg('Rename to 80 characters or less')
    disp_msg('Abort LTSA generation')
    return
end

if nfiles < 1
    disp_msg(['No data files in this directory: ',PARAMS.inputDir])
    disp_msg('Pick another directory')
    %sm_ltsa_params_window; % in gui folder, related to the pop up window with all of our inputted parameters
end



PARAMS.nxwav = fnsz(1);           % number of xwav files


m_total = 0;
for k = 1:PARAMS.nxwav
    fid = fopen(fullfile(PARAMS.fname(k).folder, PARAMS.fname(k).name),'r');
    fseek(fid, 80, 'bof');
    nrf = fread(fid,1,'uint16');
    m_total = m_total + nrf;
    fclose(fid);
end


% === Preallocate arrays ===
PARAMS.ltsahd.rfileid = zeros(1, m_total, 'uint16');
PARAMS.ltsahd.year    = zeros(1, m_total, 'uint8');
PARAMS.ltsahd.month   = zeros(1, m_total, 'uint8');
PARAMS.ltsahd.day     = zeros(1, m_total, 'uint8');
PARAMS.ltsahd.hour    = zeros(1, m_total, 'uint8');
PARAMS.ltsahd.minute  = zeros(1, m_total, 'uint8');
PARAMS.ltsahd.secs    = zeros(1, m_total, 'uint8');
PARAMS.ltsahd.ticks   = zeros(1, m_total, 'uint16');
PARAMS.ltsahd.byte_loc     = zeros(1, m_total, 'uint32');
PARAMS.ltsahd.byte_length  = zeros(1, m_total, 'uint32');
PARAMS.ltsahd.write_length = zeros(1, m_total, 'uint32');
PARAMS.ltsahd.sample_rate  = zeros(1, m_total, 'uint32');
PARAMS.ltsahd.gain         = zeros(1, m_total, 'uint8');
PARAMS.ltsahd.dnumStart    = zeros(1, m_total);
PARAMS.ltsahd.fnum         = zeros(1, m_total, 'uint16');
max_fname_len = max(cellfun(@(s) length(s), {PARAMS.fname.name}));
PARAMS.ltsahd.fname = char(zeros(m_total, max_fname_len));
PARAMS.ltsahd.padding = zeros(1, m_total, 'uint8');    % Padding to make it 32 bytes...misc info can be added here


m = 0;                                  % total number of raw files used for ltsa

for k = 1:PARAMS.nxwav            % loop over all files in directory


    if PARAMS.metadata.recursiveSearch == 1
        try
            info = audioinfo(fullfile(PARAMS.fname(k).folder, PARAMS.fname(k).name));    % xwav files
            disp(['Compiling xwav times for batch processing: ', PARAMS.fname(k).name])

        catch ME
            disp(ME.message)
            dmsg = sprintf('Is %s a real wave file?', ...
                fullfile(PARAMS.fname(k).folder, PARAMS.fname(k).name));
            disp(dmsg);
            PARAMS.ltsa.gen = 0; % need to cancel
            return
        end

        fid = fopen(fullfile(PARAMS.fname(k).folder, PARAMS.fname(k).name),'r');


    elseif PARAMS.metadata.recursiveSearch == 0
        try
            info = audioinfo(fullfile(PARAMS.fname(k).folder, PARAMS.fname(k).name));    % xwav files
            disp(['Compiling xwav times for batch processing: ', PARAMS.fname(k).name])

        catch ME
            disp(ME.message)
            dmsg = sprintf('Is %s a real wave file?', ...
                fullfile(PARAMS.fname(k).folder, PARAMS.fname(k).name));
            disp(dmsg);
            PARAMS.ltsa.gen = 0; % need to cancel
            return
        end
        fid = fopen(fullfile(PARAMS.fname(k).folder, PARAMS.fname(k).name),'r');

    end
    PARAMS.ltsahd.nsamp(k) = info.TotalSamples;


    fseek(fid,22,'bof');
    PARAMS.ltsa.nch = fread(fid,1,'uint16');         % Number of Channels

    fseek(fid,34,'bof');
    PARAMS.ltsa.nBits = fread(fid,1,'uint16');       % # of Bits per Sample : 8bit = 8, 16bit = 16, etc
    if PARAMS.ltsa.nBits == 16
        PARAMS.ltsa.dbtype = 'int16';
    elseif PARAMS.ltsa.nBits == 32
        PARAMS.ltsa.dbtype = 'int32';
    else
        disp('PARAMS.ltsa.nBits = ')
        disp(PARAMS.ltsa.nBits)
        disp('not supported')
        return
    end

    fseek(fid,80,'bof');
    nrf = fread(fid,1,'uint16');         % Number of RawFiles in XWAV file (80 bytes from bof)

    fseek(fid,100,'bof');
    for r = 1:nrf                           % loop over the number of raw files in this xwav file
        m = m + 1;                                              % count total number of raw files
        PARAMS.ltsahd.rfileid(m) = r;                           % raw file id / number in this xwav file
        PARAMS.ltsahd.year(m) = fread(fid,1,'uchar');          % Year
        PARAMS.ltsahd.month(m) = fread(fid,1,'uchar');         % Month
        PARAMS.ltsahd.day(m) = fread(fid,1,'uchar');           % Day
        PARAMS.ltsahd.hour(m) = fread(fid,1,'uchar');          % Hour
        PARAMS.ltsahd.minute(m) = fread(fid,1,'uchar');        % Minute
        PARAMS.ltsahd.secs(m) = fread(fid,1,'uchar');          % Seconds
        PARAMS.ltsahd.ticks(m) = fread(fid,1,'uint16');        % Milliseconds
        PARAMS.ltsahd.byte_loc(m) = fread(fid,1,'uint32');     % Byte location in xwav file of RawFile start
        PARAMS.ltsahd.byte_length(m) = fread(fid,1,'uint32');    % Byte length of RawFile in xwav file
        PARAMS.ltsahd.write_length(m) = fread(fid,1,'uint32'); % # of blocks in RawFile length (default = 60000)
        PARAMS.ltsahd.sample_rate(m) = fread(fid,1,'uint32');  % sample rate of this RawFile
        PARAMS.ltsahd.gain(m) = fread(fid,1,'uint8');          % gain (1 = no change)
        PARAMS.ltsahd.padding = fread(fid,7,'uchar');    % Padding to make it 32 bytes...misc info can be added here
        PARAMS.ltsahd.fname(m,:) = PARAMS.fname(k).name;        % xwav file name for this raw file header
        PARAMS.ltsahd.fnum(m) = k;

        PARAMS.ltsahd.dnumStart(m) = datenum([double(PARAMS.ltsahd.year(m)) double(PARAMS.ltsahd.month(m))...
            double(PARAMS.ltsahd.day(m)) double(PARAMS.ltsahd.hour(m)) double(PARAMS.ltsahd.minute(m)) ...
            double(PARAMS.ltsahd.secs(m))+double((PARAMS.ltsahd.ticks(m)/1000))]);

    end
    fclose(fid);


end

PARAMS.ltsa.nrftot = m;     % total number of raw files
PARAMS.ltsa.ver = 4;    % 64 bits (2^64 byte locations and nrftot allowed)
PARAMS.ltsahd.rfileid = double(PARAMS.ltsahd.rfileid);
PARAMS.ltsahd.year = double(PARAMS.ltsahd.year);          % Year
PARAMS.ltsahd.month = double(PARAMS.ltsahd.month);         % Month
PARAMS.ltsahd.day = double(PARAMS.ltsahd.day);           % Day
PARAMS.ltsahd.hour = double(PARAMS.ltsahd.hour);          % Hour
PARAMS.ltsahd.minute = double(PARAMS.ltsahd.minute);        % Minute
PARAMS.ltsahd.secs = double(PARAMS.ltsahd.secs);          % Seconds
PARAMS.ltsahd.ticks = double(PARAMS.ltsahd.ticks);        % Milliseconds
PARAMS.ltsahd.byte_loc = double(PARAMS.ltsahd.byte_loc);     % Byte location in xwav file of RawFile start
PARAMS.ltsahd.byte_length = double(PARAMS.ltsahd.byte_length);    % Byte length of RawFile in xwav file
PARAMS.ltsahd.write_length = double(PARAMS.ltsahd.write_length); % # of blocks in RawFile length (default = 60000)
PARAMS.ltsahd.sample_rate = double(PARAMS.ltsahd.sample_rate);  % sample rate of this RawFile
PARAMS.ltsahd.gain = double(PARAMS.ltsahd.gain);          % gain (1 = no change)
PARAMS.ltsahd.fname(m,:) = PARAMS.fname(k).name;        % xwav file name for this raw file header
PARAMS.ltsahd.fnum(m) = k;
disp(['Total number of raw files: ',num2str(PARAMS.ltsa.nrftot)])
disp(['Version ',num2str(PARAMS.ltsa.ver)])