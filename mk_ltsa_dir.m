function mk_ltsa_dir()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% mk_ltsa.m
%
% make long-term spectral averages from XWAV files in a directory
%
% edits made 2021 05 10 S. Fregosi to work for DASBRs/Soundtraps and latest
% version of Triton on Github
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS %REMORA

% wav data
if PARAMS.ltsa.ftype == 1
    d = dir(fullfile(PARAMS.ltsa.indir, '*.wav')); % wav files
elseif PARAMS.ltsa.ftype == 2
    d = dir(fullfile(PARAMS.ltsa.indir,'*.x.wav'));    % xwav files
end

PARAMS.ltsa.fname = char(d.name);      % file names in directory

% % read data file headers
% get_headers;

get_headers; % success = get_headers; % github version has no output
% if ~success
%     disp_msg('Issue with headers');
%     return
% end

ck_ltsaparams; % success = ck_ltsaparams; % github version has no output
% if ~success
%     disp_msg('Issue with LTSA parameters');
%     return
% end
% 
% ltsa parameters from user input earlier
% PARAMS.ltsa.dfreq = REMORA.hrp.dfreq(k);
% PARAMS.ltsa.tave = REMORA.hrp.tave(k);

info = audioinfo(fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(1,:)));
PARAMS.ltsa.fs = info.SampleRate;
PARAMS.ltsa.nfft = PARAMS.ltsa.fs / PARAMS.ltsa.dfreq;    
% compression factor (cfact = 1000 for tave=5sec,fs=200000Hz,dfreq=200)
PARAMS.ltsa.cfact = PARAMS.ltsa.tave * PARAMS.ltsa.fs / PARAMS.ltsa.nfft;

% number of frequencies in each spectral average:
if mod(PARAMS.ltsa.nfft,2) % odd
    PARAMS.ltsa.nfreq = (PARAMS.ltsa.nfft + 1)/2;
else        % even
    PARAMS.ltsa.nfreq = PARAMS.ltsa.nfft/2 + 1;
end

% % write header portion of ltsa
% write_ltsahead

% loop over xwavs and raw files
PARAMS.ltsa.window = hanning(PARAMS.ltsa.nfft);
PARAMS.ltsa.overlap = 0;
PARAMS.ltsa.noverlap = round((PARAMS.ltsa.overlap/100)*PARAMS.ltsa.nfft);

PARAMS.ltsa.sampPerAve = PARAMS.ltsa.tave * PARAMS.ltsa.fs;

% open output file
% PARAMS.ltsa.fod = fopen(fullfile(PARAMS.ltsa.outdir,PARAMS.ltsa.outfile),'r+');
total = PARAMS.ltsa.nxwav;
PARAMS.ltsa.rfNum = 0;                              % total number of raw file counter
count = 0;                          % total number of averages counter for output display

% if there is more than 1 channel, need new filenames for each of the
% channels
% open output file

% PARAMS.ltsa.fod = fopen(fullfile(PARAMS.ltsa.outdir,PARAMS.ltsa.outfile),'r+');
nch = PARAMS.ltsa.nch(1);
PARAMS.ltsa.fods = zeros(nch, 1);
curr_ofile = PARAMS.ltsa.outfile;
PARAMS.ltsa.outfiles = [];

for ch = 1:nch
    if nch ~= 1
        new_ofile = sprintf('%s_ch%d.ltsa',strrep(curr_ofile,'.ltsa',''),ch);
    else 
        new_ofile = curr_ofile;
    end
    
    PARAMS.ltsa.outfiles = [PARAMS.ltsa.outfiles; new_ofile];
    PARAMS.ltsa.fods(ch) = fopen(fullfile(PARAMS.ltsa.outdir, new_ofile),'w');
    
    % write header portion of ltsa for each ltsa
    PARAMS.ltsa.outfile = new_ofile;
    PARAMS.ltsa.ch = ch;
    write_ltsahead
end

% loop over all xwavs
for k = 1:PARAMS.ltsa.nxwav
    
    % globalize xwav # we're on so can access in calc_ltsa
    PARAMS.ltsa.currxwav = k;
    
    % HARP and ARP & OBS data
    if PARAMS.ltsa.ftype == 2           
        % open xwav file
        PARAMS.ltsa.fid = fopen(fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(k,:)),'r');
        fseek(PARAMS.ltsa.fid,80,'bof');
        nrf = fread(PARAMS.ltsa.fid,1,'uint16');         % Number of RawFiles in XWAV file (80 bytes from bof)
    % wav/Ishmael data
    else                                
        nrf = 1;
        PARAMS.ltsa.fid = fopen(fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(k,:)), 'r');
    end  
    
    % loop over each raw file in xwav
    for r = 1:nrf  
        PARAMS.ltsa.rfNum = PARAMS.ltsa.rfNum + 1; % total # of raw files processed
        
        % skip rfs we want to skip
        if ismember(PARAMS.ltsa.rfNum, PARAMS.ltsa.rf_skip)
            continue;
        end
        
        if PARAMS.ltsa.ftype ~= 1       % xwavs
            nave1 = (PARAMS.ltsahd.nsectPerRawFile(PARAMS.ltsa.rfNum) * ...
                PARAMS.ltsa.blksz / PARAMS.ltsa.nch)/(PARAMS.ltsa.nfft * PARAMS.ltsa.cfact);
        else                            % wavs
            nave1 = PARAMS.ltsahd.nsamp(PARAMS.ltsa.rfNum)/...
                (PARAMS.ltsa.nfft * PARAMS.ltsa.cfact);
        end
        
        % difference the number of averages and size of raw file
        dnave = PARAMS.ltsa.nave(PARAMS.ltsa.rfNum) - nave1;    
        
        % loop over channels
        for ch = 1:nch
            PARAMS.ltsa.fod = PARAMS.ltsa.fods(ch);
            PARAMS.ltsa.ch = ch;
            
            % jump to correct place in output file to put spectral averages
            fseek(PARAMS.ltsa.fod,PARAMS.ltsa.byteloc(PARAMS.ltsa.rfNum),'bof');
            xi = 0;

           % loop over averages
           for n = 1:PARAMS.ltsa.nave(PARAMS.ltsa.rfNum)

               % globalize for use in calc_ltsa 
               PARAMS.ltsa.currNave = n;

               % increment ltsa count from mk_ltsa
               count = count + 1;

                % number of samples to grab
                if dnave == 0       % number of averages divide evenly into size of raw file
                    nsamp = PARAMS.ltsa.sampPerAve;
                else
                    if n == PARAMS.ltsa.nave(PARAMS.ltsa.rfNum)     % last average, data not full number of samples
                        %                     nsamp = (PARAMS.ltsahd.nsectPerRawFile(r) * 250) - ((PARAMS.ltsa.nave(r) - 1) * PARAMS.ltsa.sampPerAve);
                        if PARAMS.ltsa.ftype ~= 1       % xwavs
                            nsamp = (PARAMS.ltsahd.nsectPerRawFile(PARAMS.ltsa.rfNum)...
                                * PARAMS.ltsa.blksz / PARAMS.ltsa.nch) - ...
                                ((PARAMS.ltsa.nave(PARAMS.ltsa.rfNum) - 1) * PARAMS.ltsa.sampPerAve);
                        else
                            nsamp = PARAMS.ltsahd.nsamp(PARAMS.ltsa.rfNum)  - ...
                                ((PARAMS.ltsa.nave(PARAMS.ltsa.rfNum) - 1) * PARAMS.ltsa.sampPerAve);
                        end                             % wav
                        PARAMS.ltsa.dur = nsamp / PARAMS.ltsa.fs;
                    else
                        nsamp = PARAMS.ltsa.sampPerAve;
                    end
                end

                % disp([num2str(k),'  ',num2str(r),'  ',num2str(n),'  ',num2str(nsamp)])      % for debugging

                if PARAMS.ltsa.ftype ~= 1       % xwavs (count bytes)
                    % start Byte location in xwav file of spectral average
                    if n == 1
                        xi = PARAMS.ltsahd.byte_loc(PARAMS.ltsa.rfNum);
                    else
                        %                     xi = xi + (bytesPerAve * PARAMS.ltsa.nch);
                        xi = xi + (nsamp * (PARAMS.ltsa.nBits/8) * PARAMS.ltsa.nch);
                    end
                else                    % wav files (count samples)
                    if n == 1
                        yi = 1;
                    else
                        %                     yi = yi + PARAMS.ltsa.sampPerAve;
                        yi = yi + nsamp;
                    end
                end

                % hold on to number of samples to calculate next byte location
                prev_nsamp = nsamp;

                % clear data vector
                data = [];

                % jump to correct location in xwav file
                if PARAMS.ltsa.ftype == 2
                    fseek(PARAMS.ltsa.fid,xi,'bof');
                    data = fread(PARAMS.ltsa.fid,[PARAMS.ltsa.nch,nsamp],PARAMS.ltsa.dbtype);
                else
                    [dall,Fs] = audioread( fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(k,:)), [yi yi-1+nsamp], 'native' );
                    dall = double(dall);
                    data = dall(:,PARAMS.ltsa.ch);
                end

                % no data - error message
                if ~isempty(data)
    %                 data = data(PARAMS.ltsa.ch,:);
                    data = data';
                else       
                    disp_msg(['Error: No data read, # of samples = ',num2str(nsamp)])
                    disp_msg(['xi = ',num2str(xi)])
                    disp_msg(['k,r,n = ',num2str(k),' ',num2str(r),' ',num2str(n)])
                    data = zeros(1,nsamp);
                end

               % write ltsa values
               calc_ltsa_dir(data);        
           end
        end % all channels
    end % all raw files within xwav
%         
%         % jump to correct place in output file to put spectral averages
%         fseek(PARAMS.ltsa.fod,PARAMS.ltsa.byteloc(PARAMS.ltsa.rfNum),'bof');
%         xi = 0;
%         
%        % loop over averages
%        for n = 1:PARAMS.ltsa.nave(PARAMS.ltsa.rfNum)
%            
%            % increment ltsa count from mk_ltsa
%            count = count + 1;
% 
%             % number of samples to grab
%             if dnave == 0       % number of averages divide evenly into size of raw file
%                 nsamp = PARAMS.ltsa.sampPerAve;
%             else
%                 if n == PARAMS.ltsa.nave(PARAMS.ltsa.rfNum)     % last average, data not full number of samples
%                     %                     nsamp = (PARAMS.ltsahd.nsectPerRawFile(r) * 250) - ((PARAMS.ltsa.nave(r) - 1) * PARAMS.ltsa.sampPerAve);
%                     if PARAMS.ltsa.ftype ~= 1       % xwavs
%                         nsamp = (PARAMS.ltsahd.nsectPerRawFile(PARAMS.ltsa.rfNum)...
%                             * PARAMS.ltsa.blksz / PARAMS.ltsa.nch) - ...
%                             ((PARAMS.ltsa.nave(PARAMS.ltsa.rfNum) - 1) * PARAMS.ltsa.sampPerAve);
%                     else
%                         nsamp = PARAMS.ltsahd.nsamp(PARAMS.ltsa.rfNum)  - ...
%                             ((PARAMS.ltsa.nave(PARAMS.ltsa.rfNum) - 1) * PARAMS.ltsa.sampPerAve);
%                     end                             % wav
%                     PARAMS.ltsa.dur = nsamp / PARAMS.ltsa.fs;
%                 else
%                     nsamp = PARAMS.ltsa.sampPerAve;
%                 end
%             end
% 
%             % disp([num2str(k),'  ',num2str(r),'  ',num2str(n),'  ',num2str(nsamp)])      % for debugging
% 
%             if PARAMS.ltsa.ftype ~= 1       % xwavs (count bytes)
%                 % start Byte location in xwav file of spectral average
%                 if n == 1
%                     xi = PARAMS.ltsahd.byte_loc(PARAMS.ltsa.rfNum);
%                 else
%                     %                     xi = xi + (bytesPerAve * PARAMS.ltsa.nch);
%                     xi = xi + (nsamp * (PARAMS.ltsa.nBits/8) * PARAMS.ltsa.nch);
%                 end
%             else                    % wav files (count samples)
%                 if n == 1
%                     yi = 1;
%                 else
%                     %                     yi = yi + PARAMS.ltsa.sampPerAve;
%                     yi = yi + nsamp;
%                 end
%             end
% 
%             % hold on to number of samples to calculate next byte location
%             prev_nsamp = nsamp;
% 
%             % clear data vector
%             data = [];
%                 
%             % jump to correct location in xwav file
%             if PARAMS.ltsa.ftype == 2
%                 fseek(PARAMS.ltsa.fid,xi,'bof');
%                 data = fread(PARAMS.ltsa.fid,[PARAMS.ltsa.nch,nsamp],PARAMS.ltsa.dbtype);
%             else
%                 [dall,Fs] = audioread( fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(k,:)), [yi yi-1+nsamp], 'native' );
%                 dall = double(dall);
%                 data = dall(:,PARAMS.ltsa.ch);
%             end
% 
%             % no data - error message
%             if ~isempty(data)
% %                 data = data(PARAMS.ltsa.ch,:);
%                 data = data';
%             else       
%                 disp_msg(['Error: No data read, # of samples = ',num2str(nsamp)])
%                 disp_msg(['xi = ',num2str(xi)])
%                 disp_msg(['k,r,n = ',num2str(k),' ',num2str(r),' ',num2str(n)])
%                 data = zeros(1,nsamp);
%             end
% 
%            % write ltsa values
%            calc_ltsa(data);             
%        end
%     end
    
    fclose(PARAMS.ltsa.fid);
    fprintf('Completed Processing XWAV file %d\n', k);
%     disp_msg(sprintf('Completed Processing XWAV file %d', k));
end     

% close output ltsa file
fclose all;