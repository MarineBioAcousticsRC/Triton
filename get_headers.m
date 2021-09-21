function get_headers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% get_headers.m
%
% open data files and read headers for making an ltsa file
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global PARAMS

m = 0;                                  % total number of raw files used for ltsa
fnsz = size(PARAMS.ltsa.fname);        % number of data files in directory
PARAMS.ltsa.nxwav = fnsz(1);           % number of xwav files
PARAMS.ltsahd.fname = char(zeros(PARAMS.ltsa.nxwav,80));         % make empty matrix - filenames need to be 80 char or less
for k = 1:PARAMS.ltsa.nxwav            % loop over all xwavs
    
    if PARAMS.ltsa.ftype == 1 || PARAMS.ltsa.ftype == 3     % do the following for wav or flac files
        m = m + 1;
        % check wav file goodness
%         mm = [];
%         [mm dd] = wavfinfo(fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(k,:)));
%         if isempty(mm)
%             disp(dd)
%             disp(fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(k,:)))
%             disp('Run wavDirTestFix.m on this directory first, then try again')
%             return
%         end

        % read wav header and fill up PARAMS
%         [y, fs, PARAMS.ltsa.nBits, OPTS] = wavread( fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(k,:)),10);
%         PARAMS.ltsahd.sample_rate(m) = fs;  % sample rate of this file
%         siz = wavread( fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(k,:)), 'size' );
%         PARAMS.ltsahd.nsamp(m) = siz(1);
%         PARAMS.ltsa.nch(m) = siz(2);
        try
            info = audioinfo(fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(k,:)));
        catch ME
            disp(ME.message)
            dmsg = sprintf('Is %s a real wave or flac file?', ...
                fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(k,:)));
            disp(dmsg);
            PARAMS.ltsa.gen = 0; % need to cancel
            return 
        end
        PARAMS.ltsa.nBits = info.BitsPerSample;
        PARAMS.ltsahd.sample_rate(m) = info.SampleRate;
        PARAMS.ltsahd.nsamp(m) = info.TotalSamples;
        PARAMS.ltsa.nch(m) = info.NumChannels;
      
        bytespersample = floor(PARAMS.ltsa.nBits/8);
        
        PARAMS.ltsahd.fname(m,1:fnsz(2)) = PARAMS.ltsa.fname(k,:);        % xwav file name for this raw file header
        PARAMS.ltsahd.rfileid(m) = 1;                           % raw file id / number in this xwav file
        
        % timing stuff:
        dnums = wavname2dnum(PARAMS.ltsa.fname(k,:),0); % 0 toggles disp msg off

        if isempty(dnums)
            PARAMS.ltsahd.dnumStart(m) = datenum([0 1 1 0 0 0]);
        else
            PARAMS.ltsahd.dnumStart(m) = dnums - datenum([2000 0 0 0 0 0]);
        end
        
        PARAMS.ltsahd.dvecStart(m,:) = datevec(PARAMS.ltsahd.dnumStart(m));
        
        PARAMS.ltsahd.year(m) = PARAMS.ltsahd.dvecStart(m,1);          % Year
        PARAMS.ltsahd.month(m) = PARAMS.ltsahd.dvecStart(m,2);         % Month
        PARAMS.ltsahd.day(m) = PARAMS.ltsahd.dvecStart(m,3);           % Day
        PARAMS.ltsahd.hour(m) = PARAMS.ltsahd.dvecStart(m,4);          % Hour
        PARAMS.ltsahd.minute(m) = PARAMS.ltsahd.dvecStart(m,5);        % Minute
        PARAMS.ltsahd.secs(m) = PARAMS.ltsahd.dvecStart(m,6);          % Seconds
        PARAMS.ltsahd.ticks(m) = 0;
        
    elseif PARAMS.ltsa.ftype == 2               % do the following for xwavs
        fid = fopen(fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(k,:)),'r');
        
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
            PARAMS.ltsahd.fname(m,1:fnsz(2)) = PARAMS.ltsa.fname(k,:);        % xwav file name for this raw file header
            
            PARAMS.ltsahd.dnumStart(m) = datenum([PARAMS.ltsahd.year(m) PARAMS.ltsahd.month(m)...
                PARAMS.ltsahd.day(m) PARAMS.ltsahd.hour(m) PARAMS.ltsahd.minute(m) ...
                PARAMS.ltsahd.secs(m)+(PARAMS.ltsahd.ticks(m)/1000)]);
            
        end
        fclose(fid);
    end
    
end

PARAMS.ltsa.nrftot = m;     % total number of raw files
PARAMS.ltsa.ver = 4;    % 32 bits (~ 4billon nave and nrftot allowed)

disp(['Number of channels: ', num2str(PARAMS.ltsa.nch(1))])
disp(['Total number of raw files: ',num2str(PARAMS.ltsa.nrftot)])
disp(['LTSA version ',num2str(PARAMS.ltsa.ver)])