function calc_ltsa
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate spectral averages and save to ltsa file
%
% called by mk_ltsa
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS
tic
%disp('calculate spectral averages')

window = hanning(PARAMS.ltsa.nfft);
overlap = 0;
noverlap = round((overlap/100)*PARAMS.ltsa.nfft);

sampPerAve = PARAMS.ltsa.tave * PARAMS.ltsa.fs;
%bytesPerAve = sampPerAve * PARAMS.ltsa.nBits/8;

% open output file
fod = fopen(fullfile(PARAMS.ltsa.outdir,PARAMS.ltsa.outfile),'r+');
h = loadbar(' Creating LTSA ');
total = PARAMS.ltsa.nxwav;
m = 0;                              % total number of raw file counter
count = 0;                          % total number of averages counter for output display
% total = 0;
% rfc = 0;
% for k = 1:PARAMS.ltsa.nxwav            % loop over all xwavs
%     if PARAMS.ltsa.ftype ~= 1           % only for HARP and ARP & OBS data
%         % open xwav file
%         fid = fopen(fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(k,:)),'r');
%         fseek(fid,80,'bof');
%         nrf = fread(fid,1,'uint16');         % Number of RawFiles in XWAV file (80 bytes from bof)
%     else                                % wav/Ishmael data
%         nrf = 1;
%     end
%
%     for r = 1:nrf                   % loop over each raw file in xwav
%
%         total = total + PARAMS.ltsa.nave(rfc + r);
%     end
%     rfc = rfc + nrf;
% end

for k = 1:PARAMS.ltsa.nxwav            % loop over all xwavs
    if PARAMS.ltsa.ftype ~= 1 && PARAMS.ltsa.ftype ~= 3          % only for HARP and ARP & OBS data
        % open xwav file
        fid = fopen(fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(k,:)),'r');
        fseek(fid,80,'bof');
        nrf = fread(fid,1,'uint16');         % Number of RawFiles in XWAV file (80 bytes from bof)
    else                                % wav/flac files 
        nrf = 1;
    end

    for r = 1:nrf                   % loop over each raw file in xwav
        m = m + 1;                  % count total number of raw files
        
        % check to see if full data for average
        %             nave1 = (PARAMS.ltsahd.write_length(m) * 250)/(PARAMS.ltsa.nfft * PARAMS.ltsa.cfact);
        if PARAMS.ltsa.ftype ~= 1 && PARAMS.ltsa.ftype ~= 3      % xwavs
            nave1 = (PARAMS.ltsahd.write_length(m) * PARAMS.ltsa.blksz / PARAMS.ltsa.nch)/(PARAMS.ltsa.nfft * PARAMS.ltsa.cfact);
        else                            % wavs or flacs 
            nave1 = PARAMS.ltsahd.nsamp(m)/(PARAMS.ltsa.nfft * PARAMS.ltsa.cfact);
        end
        
        dnave = PARAMS.ltsa.nave(m) - nave1;    % difference the number of averages and size of raw file
        
        
        % jump to correct place in output file to put spectral averages
        fseek(fod,PARAMS.ltsa.byteloc(m),'bof');
        xi = 0;
        %total = total + PARAMS.ltsa.nave(m);
        for n = 1 : PARAMS.ltsa.nave(m) % loop over the number of spectral averages
            
            % number of samples to grab
            if dnave == 0       % number of averages divide evenly into size of raw file
                nsamp = sampPerAve;
            else
                if n == PARAMS.ltsa.nave(m)     % last average, data not full number of samples
                    %                     nsamp = (PARAMS.ltsahd.write_length(m) * 250) - ((PARAMS.ltsa.nave(m) - 1) * sampPerAve);
                    if PARAMS.ltsa.ftype ~= 1 && PARAMS.ltsa.ftype ~= 3      % xwavs
                        nsamp = (PARAMS.ltsahd.write_length(m) * PARAMS.ltsa.blksz / PARAMS.ltsa.nch) - ((PARAMS.ltsa.nave(m) - 1) * sampPerAve);
                    else       % wav or flac
                        nsamp = PARAMS.ltsahd.nsamp(m)  - ((PARAMS.ltsa.nave(m) - 1) * sampPerAve);
                    end                             % wav
                    PARAMS.ltsa.dur = nsamp / PARAMS.ltsa.fs;
                else 
                    nsamp = sampPerAve;
                end
            end
            
            %              disp([num2str(k),'  ',num2str(r),'  ',num2str(n),'  ',num2str(nsamp)])      % for debugging
            
            if PARAMS.ltsa.ftype ~= 1 && PARAMS.ltsa.ftype ~= 3      % xwavs (count bytes)
                % start Byte location in xwav file of spectral average
                if n == 1
                    xi = PARAMS.ltsahd.byte_loc(m);
                else
                    %                     xi = xi + (bytesPerAve * PARAMS.ltsa.nch);
                    xi = xi + (nsamp * (PARAMS.ltsa.nBits/8) * PARAMS.ltsa.nch);
                end
            else                    % wav or flac files (count samples)
                if n == 1
                    yi = 1;
                else
                    %                     yi = yi + sampPerAve;
                    yi = yi + nsamp;
                end
            end
            
            
            
            % clear data vector
            data = [];
            % jump to correct location in xwav file
            if PARAMS.ltsa.ftype ~= 1 && PARAMS.ltsa.ftype ~= 3
                fseek(fid,xi,'bof');
                % get data for spectra
                if nsamp == sampPerAve
                    data = fread(fid,[PARAMS.ltsa.nch,nsamp],PARAMS.ltsa.dbtype);   %
                else            % add pad with zeros if not full data for spectra average
                    data = fread(fid,[PARAMS.ltsa.nch,nsamp],PARAMS.ltsa.dbtype);
                    %                 padsize = sampPerAve - nsamp;
                    %                 data = padarray(data,padsize);
                end
                if ~isempty(data)
                    data = data(PARAMS.ltsa.ch,:);
                else
                    disp(['Error: No data read, # of samples = ',num2str(nsamp)])
                    disp(['xi = ',num2str(xi)])
                    disp(['k,r,n = ',num2str(k),' ',num2str(r),' ',num2str(n)])
                    data = zeros(1,nsamp);
                end
            else
                %                 dall = wavread(fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(k,:)),[yi yi-1+nsamp]);
                %                 dall = double(wavread(fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(k,:)),[yi yi-1+nsamp],'Native'));
                [dall,Fs] = audioread( fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(k,:)), [yi yi-1+nsamp], 'native' );
                dall = double(dall);
                data = dall(:,PARAMS.ltsa.ch);
            end
            
            % if not enough data samples, pad with zeroes
            %             if nsamp < PARAMS.ltsa.nfft
            dsz = length(data);
            % for debugging
            %             disp(['File# Raw# Ave# DataSize: ',num2str(k),'  ',num2str(r),'  ',num2str(n),'  ',num2str(dsz)])
            if dsz < PARAMS.ltsa.nfft
                %                 dz = zeros(PARAMS.ltsa.nfft-nsamp,1);
                dz = zeros(PARAMS.ltsa.nfft-dsz,1);
                if size(data,1) == 1 % row vector, typical for xwav 
                    data = [data,dz'];
                elseif size(data,2) == 1 % column vector, typical for wav/flac
                    data = [data;dz];
                end
                disp(['File# Raw# Ave# DataSize: ',num2str(k),'  ',num2str(r),'  ',num2str(n),'  ',num2str(dsz)])
                %                 disp('Paused ... press any key to continue')
                % pause
            end
            
            % disp(['File# Raw# Ave# DataSize: ',num2str(k),'  ',num2str(r),'  ',num2str(n),'  ',num2str(dsz)])
            
            % calculate spectra
            [ltsa,freq] = pwelch(data,window,noverlap,PARAMS.ltsa.nfft,PARAMS.ltsa.fs);   % pwelch is supported psd'er
            ltsa = 10*log10(ltsa); % counts^2/Hz
            % write data
            fwrite(fod,ltsa,'int8');
            count = count + 1;
        end     % end for n - loop over the number of spectral averages
%         pcntDone = m/PARAMS.ltsa.nrftot;
        pcntDone = ((k-1) + r/nrf)/total;
        loadbar(['Calculating, ',num2str(int8(pcntDone*100)),'% complete'],h, pcntDone)
    end     % end for r - loop over each raw file
    if PARAMS.ltsa.ftype ~= 1 && PARAMS.ltsa.ftype ~= 3         % only for xwav HARP and ARP data
        % close input xwav file
        fclose(fid);
    end
    disp(['Completed Processing audio file ',num2str(k)])
    
    
end     % end for k - loop over each file
% close output ltsa file
fclose(fod);
t = toc;
disp(['Time to calculate ',num2str(count),' spectra is ', num2str(t)])

close(h)    % turn off progress bar (loadbar)

