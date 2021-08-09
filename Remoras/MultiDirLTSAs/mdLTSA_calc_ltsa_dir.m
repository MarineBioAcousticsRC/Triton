function mdLTSA_calc_ltsa_dir(data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate spectral averages and save to ltsa file
%
% called by mdLTSA_mk_ltsa_dir
% copied from A.Allen 1.93.20190212
% adapted to MultiDirLTSA Remora by S. Fregosi 2021 08 09
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS 

window = PARAMS.ltsa.window;
noverlap = PARAMS.ltsa.noverlap;

% check to see if full data for average
%             nave1 = (PARAMS.ltsahd.nsectPerRawFile(m) * 250)/(PARAMS.ltsa.nfft * PARAMS.ltsa.cfact);
% don't need this info if already have data
% if ~isfield(PARAMS, 'fromProc')
%     if PARAMS.ltsa.ftype ~= 1       % xwavs
%         nave1 = (PARAMS.ltsahd.nsectPerRawFile(m) * PARAMS.ltsa.blksz / PARAMS.ltsa.nch)/(PARAMS.ltsa.nfft * PARAMS.ltsa.cfact);
%     else                            % wavs
%         nave1 = PARAMS.ltsahd.nsamp(m)/(PARAMS.ltsa.nfft * PARAMS.ltsa.cfact);
%     end
%     dnave = PARAMS.ltsa.nave(m) - nave1;    % difference the number of averages and size of raw file
% end

% jump to correct place in output file to put spectral averages
% fseek(PARAMS.ltsa.fod,PARAMS.ltsa.byteloc(m),'bof');
% xi = 0;
% %total = total + PARAMS.ltsa.nave(m);
% 
% % todo: figure out a better way to do this
% if isfield(PARAMS, 'fromProc')
%     PARAMS.ltsa.nave(m) = PARAMS.ltsa.nave;
% end
    
% for n = 1 : PARAMS.ltsa.nave(m) % loop over the number of spectral averages
    
   % from triton (making ltsa from xwavs/wavs)
%    if ~isfield(PARAMS, 'fromProc')
%        
%        % increment ltsa cound from mk_ltsa
%        PARAMS.ltsa.count = PARAMS.ltsa.count + 1;
%        
%         % number of samples to grab
%         if dnave == 0       % number of averages divide evenly into size of raw file
%             nsamp = PARAMS.ltsa.sampPerAve;
%         else
%             if n == PARAMS.ltsa.nave(m)     % last average, data not full number of samples
%                 %                     nsamp = (PARAMS.ltsahd.nsectPerRawFile(m) * 250) - ((PARAMS.ltsa.nave(m) - 1) * PARAMS.ltsa.sampPerAve);
%                 if PARAMS.ltsa.ftype ~= 1       % xwavs
%                     nsamp = (PARAMS.ltsahd.nsectPerRawFile(m) * PARAMS.ltsa.blksz / PARAMS.ltsa.nch) - ((PARAMS.ltsa.nave(m) - 1) * PARAMS.ltsa.sampPerAve);
%                 else
%                     nsamp = PARAMS.ltsahd.nsamp(m)  - ((PARAMS.ltsa.nave(m) - 1) * PARAMS.ltsa.sampPerAve);
%                 end                             % wav
%                 PARAMS.ltsa.dur = nsamp / PARAMS.ltsa.fs;
%             else
%                 nsamp = PARAMS.ltsa.sampPerAve;
%             end
%         end
% 
%         % disp([num2str(k),'  ',num2str(r),'  ',num2str(n),'  ',num2str(nsamp)])      % for debugging
% 
%         if PARAMS.ltsa.ftype ~= 1       % xwavs (count bytes)
%             % start Byte location in xwav file of spectral average
%             if n == 1
%                 xi = PARAMS.ltsahd.byte_loc(m);
%             else
%                 %                     xi = xi + (bytesPerAve * PARAMS.ltsa.nch);
%                 xi = xi + (nsamp * (PARAMS.ltsa.nBits/8) * PARAMS.ltsa.nch);
%             end
%         else                    % wav files (count samples)
%             if n == 1
%                 yi = 1;
%             else
%                 %                     yi = yi + PARAMS.ltsa.sampPerAve;
%                 yi = yi + nsamp;
%             end
%         end
% 
%         % clear data vector
%         data = [];
% 
%         % get outer loop indices from mk_ltsa.m

% 
%         % jump to correct location in xwav file
%         if PARAMS.ltsa.ftype ~= 1
%             fseek(PARAMS.ltsa.fid,xi,'bof');
%             % get data for spectra
%             if nsamp == PARAMS.ltsa.sampPerAve
%                 data = fread(PARAMS.ltsa.fid,[PARAMS.ltsa.nch,nsamp],PARAMS.ltsa.dbtype);   %
%             else            % add pad with zeros if not full data for spectra average
%                 data = fread(PARAMS.ltsa.fid,[PARAMS.ltsa.nch,nsamp],PARAMS.ltsa.dbtype);
%                 %                 padsize = PARAMS.ltsa.sampPerAve - nsamp;
%                 %                 data = padarray(data,padsize);
%             end
%         else
% %             dall = wavread(fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(k,:)),[yi yi-1+nsamp]);
% %             dall = double(wavread(fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(k,:)),[yi yi-1+nsamp],'Native'));
%             [dall,Fs] = audioread( fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(k,:)), [yi yi-1+nsamp], 'native' );
%             dall = double(dall);
%             data = dall(:,PARAMS.ltsa.ch);
%         end
%         
%         % no data - error message
%         if ~isempty(data)
%             data = data(PARAMS.ltsa.ch,:);
%         else       
%             disp_msg(['Error: No data read, # of samples = ',num2str(nsamp)])
%             disp_msg(['xi = ',num2str(xi)])
%             disp_msg(['k,r,n = ',num2str(k),' ',num2str(r),' ',num2str(n)])
%             data = zeros(1,nsamp);
%         end
        
   % from proc stream (making ltsa from raw files)
%    else 
%        data = PARAMS.proc.data((n-1)*PARAMS.ltsa.sampPerAve + 1:n*PARAMS.ltsa.sampPerAve);
%        data = double(int16(data));
% %        startInd = (n-1)*length(PARAMS.proc.data)/PARAMS.ltsa.nave(m)+1;
% %        endInd = n*length(PARAMS.proc.data)/PARAMS.ltsa.nave(m);
% %        data = PARAMS.proc.data(startInd:endInd);
% %        data = PARAMS.proc.data(n:n+length(PARAMS.proc.data)/PARAMS.ltsa.nave(m)-1); 
%    end
   
    % if not enough data samples, pad with zeroes
    %             if nsamp < PARAMS.ltsa.nfft
    dsz = length(data);
    % for debugging
    %             disp(['File# Raw# Ave# DataSize: ',num2str(k),'  ',num2str(r),'  ',num2str(n),'  ',num2str(dsz)])
    if dsz < PARAMS.ltsa.nfft
        %                 dz = zeros(PARAMS.ltsa.nfft-nsamp,1);
        dz = zeros(PARAMS.ltsa.nfft-dsz,1);
        try
            data = [data;dz];
        catch
            data = [data,dz'];
        end
        
        if ~isfield(PARAMS.ltsa, 'multidir')
            k = PARAMS.ltsa.currxwav;
            r = PARAMS.ltsa.rfNum;
            n = PARAMS.ltsa.currNave;
            disp_msg(['File# Raw# Ave# DataSize: ',num2str(k),'  ',num2str(r),'  ',num2str(n),'  ',num2str(dsz)])
        %                 disp_msg('Paused ... press any key to continue')
        % pause
        end
    end

    % disp_msg(['File# Raw# Ave# DataSize: ',num2str(k),'  ',num2str(r),'  ',num2str(n),'  ',num2str(dsz)])

    % calculate spectra
    [ltsa,freq] = pwelch(data,window,noverlap,PARAMS.ltsa.nfft,PARAMS.ltsa.fs);   % pwelch is supported psd'er
    ltsa = 10*log10(ltsa); % counts^2/Hz
    1;
    % write data
    fwrite(PARAMS.ltsa.fod,ltsa,'int8');
end  

