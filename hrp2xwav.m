function hrp2xwav() 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% hrp2xwav.m
%
% it takes ftp or usb raw HARP file and converts into XWAV file
% need to input sample rate since not contained in raw file
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS HANDLES DATA
build_gui;
    function close(~,~)
        delete(HANDLES.fig.convert)
    end
    function convert(~,~)
        dflag = 1;  % display flag
        fs = str2num( get(HANDLES.sampfreq.edit, 'String'));
        %
        if strcmp(get(get(HANDLES.file_type_buttons, 'SelectedObject'), 'String'),'USB/*.hrp') 
            ftype = 1;
        else
            ftype = 2;
        end
        
        nch = str2num(get(get(HANDLES.num_channels_buttons, 'SelectedObject'), 'String'));
        if strcmp(get(get(HANDLES.data_type_buttons, 'SelectedObject'), 'String'),'Compressed')
            dtype = 3;
        else
            dtype = 1;
        end
        
        if strcmp(get(get(HANDLES.FIFO_buttons, 'SelectedObject'), 'String'), 'No')
            remFIFO = 0;
        else
            remFIFO = 1; % run rmFIFO
        end
        
        delete(HANDLES.fig.convert) %don't need it anymore
        
        % open file stuff
        inpath = PARAMS.inpath;             % some place to start
        if inpath ~= 0
            cd(inpath);                         % go there
        end
        
        if ftype == 1
            filterSpec1 = '*.hrp';
        elseif ftype == 2
            filterSpec1 = '*.*';
        end
        
        % user interface retrieve file to open through a dialog box
        boxTitle1 = 'Open Raw HARP file to convert to XWAV format';
        [infile,inpath]=uigetfile(filterSpec1,boxTitle1);
        
        disp_msg('Opened File: ')
        disp_msg([inpath,infile])
        
        % if the cancel button is pushed, then no file is loaded
        % so exit this script
        if infile == 0
            disp_msg('Cancel Open File')
            return
        end
        
        if ftype == 1
            fid = fopen([inpath,infile],'r','l'); %for usb file
        elseif ftype == 2
            fid = fopen([inpath,infile],'r','b'); %for ftp file
        end
        
        if fid == -1
            disp_msg('Error: no such file')
            return
        end
        
        outfile = [infile,'.x.wav'];
        outpath = inpath;
        cd(outpath);            % go there
        
        boxTitle2 = 'Save XWAV file';
        [outfile,outpath] = uiputfile(outfile,boxTitle2);
 %     written to provide a unique variable name for each FTP file that's
%     converted, not put in yet because I don't know where to put it
%     for a = 1:length(outfile) %arbitrary number to loop to
%       if outfile(a) == '.' && outfile(a+1) == 'x' && outfile(a+2) == '.'
%         jpeg_name = strrep(outfile, '.x.wav', '');
%         break;
%       end
%     end       
        if outfile == 0
            disp_msg('Cancel Save XWAV File')
            return
        end
%     if ftype == 2
%       % a ftp file, so ask if they want to autogenerate deployment
%       % plots
%       eval_plots_bool = questdlg('Would you like to autogenerate deployment plots?',...
%         'Autogenerate plots?', 'yes', 'no', 'yes');
%     end        
        % calculate how many bytes -> not checking data file if correct
        filesize = getfield(dir([inpath,infile]),'bytes');
        
        % HARP data structure
        byteblk = 512;	                    % bytes per head+data+null block
        headblk = 12;		                    % bytes per head block
        if nch == 1;
            tailblk = 0;
        elseif nch == 4
            tailblk = 4;                % bytes after data and before next header
        end
        
        datablk = byteblk - headblk - tailblk;  % bytes per data block
        bytesamp = 2;	                        % bytes per sample
        datasamp = datablk/bytesamp;	        % number of samples per data block
        
        % number of data blocks in input file
        blkmx = floor(filesize/byteblk);    % calculate the number of sectors in the opened file
        disp_msg(['Total Number of Sectors in ',infile,' : ']);
        disp_msg(blkmx);
        
        % defaults
        srfactor = 1;                              % sample rate factor
        nfiles = 1;                                 % number of XWAV files to make
        display_count = 1000;           % some feedback for the user while waiting....
        gain = 1;                      % make XWAV file louder so easier to hear on
        
        % the following was for MAWSON ARP data and outreach program
        % this would allow speed up and slow down and increase in gain
        % so that the file would play differently in wav reading program
        % but correctly in Triton
        % we haven't used it in a long time to turn off 100827 smw
        if 0
            %
            % user input dialog box for XWAV file size in data blocks
            prompt={'Enter number of Sectors to read from raw file ',...
                'Enter XWAV file sample rate change factor' ,...
                'Enter number of XWAV file to generate 0 < nfile < 27 ',...
                'Enter Gain for XWAV file (0 < gain < 50)'};
            def={num2str(blkmx),...
                num2str(srfactor),...
                num2str(nfiles),...
                num2str(gain)};
            dlgTitle='Set XWAV: file size, fake sample rate factor, # of files';
            lineNo=1;
            AddOpts.Resize='on';
            AddOpts.WindowStyle='normal';
            AddOpts.Interpreter='tex';
            in=inputdlg(prompt,dlgTitle,lineNo,def,AddOpts);
            if length(in) == 0	% if cancel button pushed
                return
            else
                blkmx = str2num(deal(in{1}));
                if blkmx ~= fix(blkmx)
                    disp_msg('Error - need integer number of Sectors')
                    return
                else
                    disp_msg('Number of Sectors used for XWAV file :')
                    disp_msg(num2str(blkmx))
                end
                srfactor = str2num(deal(in{2}));
                disp_msg('Sample rate change factor for XWAV file :')
                disp_msg(num2str(srfactor))
                nfiles = str2num(deal(in{3}));
                if nfiles > 26 || nfiles < 1
                    disp_msg('Error - too many or too few files to be generated')
                    return
                else
                    disp_msg('Number of XWAV files to generate :')
                    disp_msg(num2str(nfiles))
                end
                gain = str2num(deal(in{4}));
                if gain <= 0 || gain >= 50
                    disp_msg('Error - too big or two small (0 < gain < 50')
                    return
                end
            end
            
        end
        
        % wav file header parameters
        
        % RIFF Header stuff:
        %  harpsize = blkmx / byteblk * 32 + 64 - 8;% length of the harp chunk
        harpsize = 1 * 32 + 64 - 8;% length of the harp chunk
        wavsize = (datablk*blkmx)+36+harpsize+8;  % required for the RIFF header
        
        % Format Chunk stuff:
        fsize = 16;  % format chunk size
        fcode = 1;   % compression code (PCM = 1)
        bitps = 16;	% bits per sample
        
        % Harp Chunk stuff:
        %  harpsize = blkmx / 60000 * 32 + 64 - 8;% length of the harp chunk
        harpwavversion = 0;            % harp wav header version number
        if nch == 1
            harpfirmware = '1.07b     ';   % arp firmware version number, 10 chars
            if dtype == 2
                harpfirmware = '2.02Q     ';
            elseif dtype == 3
                harpfirmware = '2.02R     ';
            end
        elseif nch == 4
            harpfirmware = '2.10      ';   % arp firmware version number, 10 chars
        else
            disp_msg('Error - only 1 or 4 channels for HARP data')
            return
        end
        harpinstrument = '41  ';       % harp instrument number - 4 char
        sitename = '2004';             % site name - 4 char
        experimentname = 'HARP    ';   % experiment name - 8 char
        diskseqnumber = 1;             % disk sequence number
        diskserialnumber = '00000000'; % disk serial number - 8 char
        %   numofwrites = blkmx / 60000;   % number of writes
        numofwrites = 1;
        longitude = 17900000;         % longitude
        latitude = 8900000;          % latitude
        depth = 6000;                   % depth
        
        % HARP Write Header info (one listing per write)
        byteloc = 8+4+8+16+64+32+8;
        
        % number of data blocks in output file
        %writelength = 60000;             % number of blocks per write
        writelength = blkmx;            % use total number of Sectors since only one 'write' for Mawson data
        bytelength = writelength * datablk;    % number of blocks of data per write
        
        % loop over the number of file to make
        for ii=1:nfiles                    % make N files
            if ftype == 1
                dvec(2) = fread(fid,1,'uint8');
                dvec(1) = fread(fid,1,'uint8');
                dvec(4) = fread(fid,1,'uint8');
                dvec(3) = fread(fid,1,'uint8');
                dvec(6) = fread(fid,1,'uint8');
                dvec(5) = fread(fid,1,'uint8');
                ticks = fread(fid,1,'uint16');
                %   msec = msec/4;      % quick fix for wrong header time
                fseek(fid,-8,0);            % rewind to start of header
            elseif ftype == 2
                dvec(1) = fread(fid,1,'uint8');
                dvec(2) = fread(fid,1,'uint8');
                dvec(3) = fread(fid,1,'uint8');
                dvec(4) = fread(fid,1,'uint8');
                dvec(5) = fread(fid,1,'uint8');
                dvec(6) = fread(fid,1,'uint8');
                ticks = fread(fid,1,'uint16');
                % msec = msec/4;      % quick fix for wrong header time
                fseek(fid,-8,0);
            end
            
            sample_rate = fs; % true sample rate
            disp_msg('true sample rate is : ')
            disp_msg(num2str(sample_rate))
            
            fs = sample_rate * srfactor;                % fake sampling rate
            %     bps	=	fs*ch*bytesamp;	                    % bytes per second for xwav header
            bps	=	fs*nch*bytesamp;	                    % bytes per second for xwav header
            disp_msg('fake sample rate is : ')
            disp_msg(num2str(fs))
            
            % open output file
            outfile = [outfile(1:length(outfile)-6),char(64+ii),'.x.wav'];
            fod = fopen([outpath,outfile],'w');
            
            % make global for calling programs
            PARAMS.outfile = outfile;
            PARAMS.outpath = outpath;
            
            % write xwav file header
            %
            % RIFF file header
            fprintf(fod,'%c','R');
            fprintf(fod,'%c','I');
            fprintf(fod,'%c','F');
            fprintf(fod,'%c','F');
            fwrite(fod,wavsize,'uint32');
            fprintf(fod,'%c','W');
            fprintf(fod,'%c','A');
            fprintf(fod,'%c','V');
            fprintf(fod,'%c','E');
            
            %
            % Format information
            fprintf(fod,'%c','f');
            fprintf(fod,'%c','m');
            fprintf(fod,'%c','t');
            fprintf(fod,'%c',' ');
            fwrite(fod,fsize,'uint32');
            fwrite(fod,fcode,'uint16');
            fwrite(fod,nch,'uint16');
            fwrite(fod,fs,'uint32');
            fwrite(fod,bps,'uint32');
            fwrite(fod,bytesamp,'uint16');
            fwrite(fod,bitps,'uint16');
            
            %
            % "harp" chunk
            fprintf(fod,'%c', 'h');
            fprintf(fod,'%c', 'a');
            fprintf(fod,'%c', 'r');
            fprintf(fod,'%c', 'p');
            fwrite(fod, harpsize, 'uint32');
            fwrite(fod, harpwavversion, 'uchar');
            fwrite(fod, harpfirmware, 'uchar');
            fprintf(fod, harpinstrument, 'uchar');
            fprintf(fod, sitename, 'uchar');
            fprintf(fod, experimentname, 'uchar');
            fwrite(fod, diskseqnumber, 'uchar');
            fprintf(fod, '%s', diskserialnumber);
            fwrite(fod, numofwrites, 'uint16');
            fwrite(fod, longitude, 'int32');
            fwrite(fod, latitude, 'int32');
            fwrite(fod, depth, 'int16');
            fwrite(fod, 0, 'uchar');   % padding
            fwrite(fod, 0, 'uchar');
            fwrite(fod, 0, 'uchar');
            fwrite(fod, 0, 'uchar');
            fwrite(fod, 0, 'uchar');
            fwrite(fod, 0, 'uchar');
            fwrite(fod, 0, 'uchar');
            fwrite(fod, 0, 'uchar');
            
            % "harp" write entries
            % entry 1
            fwrite(fod, dvec(1), 'uchar');
            fwrite(fod, dvec(2), 'uchar');
            fwrite(fod, dvec(3), 'uchar');
            fwrite(fod, dvec(4), 'uchar');
            fwrite(fod, dvec(5), 'uchar');
            fwrite(fod, dvec(6), 'uchar');
            fwrite(fod, ticks, 'uint16');
            fwrite(fod, byteloc, 'uint32');
            fwrite(fod, bytelength, 'uint32');
            fwrite(fod, writelength, 'uint32');
            fwrite(fod, sample_rate, 'uint32');
            fwrite(fod, gain , 'uint8');
            fwrite(fod, 0, 'uchar'); % padding
            fwrite(fod, 0, 'uchar');
            fwrite(fod, 0, 'uchar');
            fwrite(fod, 0, 'uchar');
            fwrite(fod, 0, 'uchar');
            fwrite(fod, 0, 'uchar');
            fwrite(fod, 0, 'uchar');
            
            % Data area -- variable length
            fprintf(fod,'%c','d');
            fprintf(fod,'%c','a');
            fprintf(fod,'%c','t');
            fprintf(fod,'%c','a');
            fwrite(fod,datablk*blkmx,'uint32');
            
            % standard data type, no compression, 1 or 4 channels
            if dtype == 1
                % output vector
                if nch == 4
                    if sample_rate == 100000
                        Tnsamp = 14.384e6;  % 58000sectors 248samples/sector
                    else
                        disp_msg(['Unknown sample rate: ',num2str(sample_rate)])
                        disp_msg(['for number of channels: ',num2str(nch)])
                    end
                elseif nch == 1
                    if sample_rate == 320000 % 56000 sectors 250 samples/sector
                        Tnsamp = 14e6;    % total number of samples in one raw file
                    else
                        Tnsamp = 15e6;  % 60000 sectors 250samples/sector
                        disp_msg(['Sample rate: ',num2str(sample_rate)])
                    end
                else
                    msg_disp(['Unknown number of channels: ',num2str(nch)])
                end
                odata = zeros(Tnsamp,1);  % pre-allocate memory for output data - this is very important for processing speed
                % read data blocks (Sectors) from ARP file and write to XWAV file
                count = 1;
                disp_msg('reading/writing : ')
                for i= 1:blkmx
                    fseek(fid,headblk,0);	                            % skip over header
                    if nch == 4
                        data = fread(fid,datasamp,'uint16');
                    else
                        data = fread(fid,datasamp,'int16');
                    end
                    odata(datasamp*(i-1)+1:datasamp*i) = data;      %   fill up data vector
%                     
%                     if remFIFO
%                         data = rmFIFO(data);
%                     end
%                     
%                     
%                     if nch == 4
%                         fwrite(fod,gain * data-32767,'int16'); % read and write(4-channel)
%                     else
%                         fwrite(fod,gain * data,'int16'); % read and write (1-channel)
%                     end
                    
                    if count == display_count
                        disp_msg(['data block ',num2str(i)])    % give the user some feed back during this long process
                        count = 0;
                    end
                    count = count + 1;
                    fseek(fid,tailblk,0);
                end
                fclose(fid);
                
                if nch == 4
                    odata = odata-32767;
                end
                if remFIFO
                    odata = rmFIFO(odata);
                end
                fwrite(fod,gain * odata,'int16'); % 
                    
                fclose(fod);
                disp_msg(['done with ',outpath,outfile])

            % for compressed data type    
            elseif dtype == 2 || dtype == 3
                h = 1;  % ie only one raw file
                nhrp = 1;
                bpsect = 512;       % bytes per sect
                if PARAMS.nch == 1
                    datasamp = 250; % number of samples per data block
                    tailblk = 0;
                elseif PARAMS.nch == 4
                    datasamp = 248;   % number of samples per data block
                    tailblk = 4;    % skip the last two 'samples' ie 4 bytes
                end
                nbytesPerSect = datasamp * 2;
                
                raw1head_byteloc = (8+4) + (8+16) + 64;     % start of 1st raw file header
                raw1data_byteloc = raw1head_byteloc + (32 * nhrp) + 8;  % start of 1st raw file data
                
                saveByteLoc1 = ftell(fod);
                if remFIFO
                    data = rmFIFO(decompressRawHRP(fid,1,dtype,'ftype',ftype,...
                        'usb_ftp_flag',1,'filesize',filesize,'dvec',dvec,...
                        'ticks',ticks,'samplerate', fs));
                else
                    data = decompressRawHRP(fid,1,dtype,'ftype',ftype,...
                        'usb_ftp_flag',1,'filesize',filesize,'dvec',dvec,...
                        'ticks',ticks,'samplerate', fs);
                end
                fwrite(fod,data,'int16');
                
                % finish off some file bookkeeping
                % need to modify XWAV header to correct sector values/indexing for each
                % raw file
                saveByteLoc2 = ftell(fod);      % current byte location in output XWAV file
                byte_length(h) = saveByteLoc2 - saveByteLoc1;       % number of bytes in raw file
                
                % error if total disk write is larger than 30e6 bytes (ie 60000 sectors)
                wmax = 30e6;
                if byte_length(h) > wmax
                    disp(['Triton Error : ',num2str(byte_length(h)),' > 30e6 bytes in this Disk Write / Raw File'])
                    %             disp([datestr(dnum),'  ',num2str(ticks)])           % debugging info
                    disp(['last     datetime: ',datestr(dnum,'yy mm dd HH MM SS FFF')])
                    dw = byte_length(h) - wmax; % how much larger read data is than max
                    fseek(fod,dw,0);        % skip back to fill only wmax
                    saveByteLoc2 = saveByteLoc2 - dw;   % move xwav file pointer back
                    byte_length(h) = wmax;  % set byte length to wmax
                    disp(['Set byte_length = ',num2str(wmax),' and fseek back ',num2str(dw),' bytes in xwav file'])
                end
                
                if rem(byte_length(h),nbytesPerSect) ~= 0
                    disp_msg(['Triton Error : not integer number of sectors for raw file ',num2str(h)])
                end
                write_length(h) = floor(byte_length(h) / nbytesPerSect);    % number of full (uncompressed) 16-bit sectors
                if h > 1
                    byte_loc(h) = raw1data_byteloc + sum(byte_length(1:h-1));
                else
                    byte_loc(h) = raw1data_byteloc;
                end
                skip = raw1head_byteloc + 8 + (h-1)*32;   % skip to byte_loc in XWAV raw file header
                status = fseek(fod,skip,'bof');
                
                % write values for btye_loc, byte_length, write_length
                fwrite(fod, byte_loc(h) , 'uint32');
                fwrite(fod, byte_length(h), 'uint32');
                fwrite(fod, write_length(h), 'uint32');
                %
                status = fseek(fod,saveByteLoc2,'bof');     % go back to writing data location
                
                % need to modify XWAV header to correct for filesize for each XWAV file
                fsize = byte_loc(nhrp) + byte_length(nhrp) - 8;
                status = fseek(fod,4,'bof');     % go back to writing data location
                fwrite(fod,fsize,'uint32');     % wave file size - 8 bytes
                skip = raw1head_byteloc + nhrp*32 + 4;   % skip to dSubchunkSize
                status = fseek(fod,skip,'bof');     % go back to writing data location
                fwrite(fod,sum(byte_length(1:nhrp)),'uint32');
                
                % close XWAV file
                fclose(fod);
                
            end % end dtype - data type
            
        end  % end ii - loop on number of files to make from this one raw file
        plot_xwav;
        %uncomment this section later to allow user to make eval plots
        % If user wanted eval plots make them
        %     if strcmp(eval_plots_bool, 'yes')
        %       make_eval_plots(PARAMS.fs*15);
        %     end
        %all the conversion is done, time to plot the file now
        %plot;
    end
function make_eval_plots(offset)
    % function for making the evaluation plots from the just made xwav. There are 
    % 5 evaluation plots, .1, 1, 10 seconds each taken from the offset. It
    % will always take the first 15 seconds and the whole xwav file
    % inputs:
    %       offset - The number of SAMPLES to skip over when making the .1, 1 
    %                and 10 second plots. Must be > 0, and should be set to
    %                the number of samples after the disk write.
    
    
    % read all xwav into DATA
    mnum2secs = 24*60*60;
    file_dur = (PARAMS.raw.dnumEnd - PARAMS.raw.dnumStart)* mnum2secs;    
    PARAMS.tseg.sec = file_dur;
    readseg;
    

    off_in_sec = offset/PARAMS.fs;
    % Parallel vectors that hold where the samples should start and end
    start_samp_vec = [offset offset offset 1 1];
    % how many seconds you want * the sample rate
    end_samp_vec = [.1+off_in_sec 1+off_in_sec 10+off_in_sec 15 ...
                    PARAMS.xhd.byte_length/PARAMS.xhd.ByteRate(1)]*PARAMS.fs;
    HANDLES.fig.plot = figure( ...
      'NumberTitle','off', ...
      'Name','Evaluation Plot', ...
      'Units','normalized',...
      'Position',[.2 .2 .5 .5], ...
      'Visible', 'On');
    % subplot for the timeseries
    ts_plot = subplot(2,1,1);
    sp_plot = subplot(2,1,2);% makes a second plot on the same screen
    for x = 1:length(start_samp_vec)
      % get the right amount of data. DATA should be set to the entire xwav
      data_slice = DATA(start_samp_vec(x):end_samp_vec(x));
      data_length = length(data_slice);
      if data_length < PARAMS.fs
        nfft = PARAMS.fs / 10;
      else
        nfft = PARAMS.fs;
      end
      window = hanning(nfft);
      overlap = 0;
      % set relative bounds
      mean_data = mean(data_slice);
      uppery = mean_data+1000;
      lowery = mean_data-1000;
      % plots data_slice along the correct amount of time
      plot(ts_plot, (0:data_length-1)/PARAMS.fs,data_slice);
      v = axis(ts_plot);
      % correct if the time series plot is to large. Happends when taking
      % full raw file time.
      if v(2) > (data_length-1)/PARAMS.fs
        v(2) = (data_length-1)/PARAMS.fs;
      end
      axis(ts_plot, [0 10 lowery uppery]) % correct the axis with the right bounds
      ylabel(ts_plot, 'Amplitude [counts]')
      xlabel(ts_plot, 'Time [seconds]')
      
      % subplot for the spectra
      [ Pxx, Fxx ] = pwelch(data_slice, window, overlap, nfft, PARAMS.fs);
      Pxx = 10*log10(Pxx); % else it's logarithmic.
      semilogx(sp_plot, Fxx,Pxx)
      axis(sp_plot, [ 10 PARAMS.fs/2 -50 50]) % correct the axis with the right bounds
      grid(sp_plot, 'on')
      ylabel(sp_plot, 'Spectrum Level [dB re counts^2/Hz]')
      xlabel(sp_plot, 'Frequency [Hz]')
      sec_string = num2str(end_samp_vec(x)/PARAMS.fs - (offset/PARAMS.fs));
      % save it with the appropiate name.
      file_name_start = pwd;

      infname = regexp(PARAMS.infile,'.x.wav','split');
      if end_samp_vec(x) - start_samp_vec(x) == length(DATA(:,PARAMS.ch))-1 % full file
        saveas(HANDLES.fig.plot,sprintf('%s.jpeg',infname{1}), 'jpg');
        %can't access this with the data I entered
      elseif end_samp_vec(x) == 15*PARAMS.fs % first 15 seconds
       % saveas(HANDLES.fig.plot, 'Eval_plot_disk_write(15s).jpeg');
        saveas(HANDLES.fig.plot, sprintf('%s_hddWrite.jpeg', infname{1}));
      elseif strcmp(sec_string, '0.1')
       % saveas(HANDLES.fig.plot, 'Eval_plot_100ms_after_diskwrite.jpeg');
        saveas(HANDLES.fig.plot, sprintf('%s_100ms.jpeg',infname{1}));
      else
        num_secs =  num2str(end_samp_vec(x)/PARAMS.fs - (offset/PARAMS.fs));
        output_str = sprintf('%s_%ss.jpeg', infname{1}, num_secs);
        saveas(HANDLES.fig.plot, output_str);

      end
    end
  end
  function plot_xwav
    mnum2secs = 24*60*60;
    %all the conversion is done, time to plot the file now
    PARAMS.infile = PARAMS.outfile;
    PARAMS.inpath = PARAMS.outpath;
    % initialize the  PARAMS, read a segment, then plot it
    PARAMS.ftype = 2;   % XWAV file format
    initdata
    if isempty(DATA)
      set(HANDLES.display.timeseries,'Value',1);
    end
    if ~isempty(PARAMS.xhd.byte_length)
      PARAMS.plot.initbytel = PARAMS.xhd.byte_loc(1);
    end
    file_dur = (PARAMS.raw.dnumEnd - PARAMS.raw.dnumStart)* mnum2secs;
    if file_dur < 10
      % below line will display the entire xwav file
      PARAMS.tseg.sec = file_dur;
    else
      % we only want 10s
      PARAMS.tseg.sec = 10;
    end
    readseg
    plot_triton
    
    control('timeon')   % was timecontrol(1)
    % turn on other menus now
    control('menuon')
    control('button')
    % turn some other buttons/pulldowns on/off
    set([HANDLES.motion.seekbof HANDLES.motion.back HANDLES.motion.autoback HANDLES.motion.stop],...
      'Enable','off');
    % set(HANDLES.pickxyz,'Enable','on')
    set(HANDLES.motioncontrols,'Visible','on')
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');
    
    
  end
  function build_gui
            bgColor = [1 1 1]; %white
        bgColor2 = [.75 .875 1]; % light blue for XWAV
        defaultPos = [0.1, 0.7, 0.1, 0.2];
        bw = .4; %buttonw width
        bh = .15; %button height
        HANDLES.fig.convert = figure('NumberTitle', 'off',...
            'MenuBar', 'none',...
            'Name', 'Set Conversion Parameters',...
            'Units', 'normalized',...
            'Visible', 'on',...
            'Position', defaultPos,...
            'Color', bgColor2,...
            'CloseRequestFcn', @close);
        btnPos = [0.03 .78 bw .2];
        HANDLES.sampfreq.txt = uicontrol(HANDLES.fig.convert,...
            'Style','text',...
            'Units','normalized',...
            'Position',btnPos,...
            'BackgroundColor',bgColor2,...
            'String','Sample Frequency (Hz)',...
            'FontUnits','normalized', ...
            'Visible','on');
        btnPos=[.5 .85 bw .1];
        HANDLES.sampfreq.edit = uicontrol(HANDLES.fig.convert,...
            'Style','edit',...
            'Units','normalized',...
            'Position',btnPos,...
            'BackgroundColor',bgColor,...
            'String','200000',...
            'FontUnits','normalized', ...
            'Visible','on');
        HANDLES.file_type_buttons = uibuttongroup(HANDLES.fig.convert,...
            'Position', [.5 .69 bw bh],...
            'Units', 'normalized',...
            'BorderType', 'none');
        HANDLES.ftype.txt = uicontrol(HANDLES.fig.convert,...
            'Style','text',...
            'Units','normalized',...
            'Position',[.03 .6 bw .2],...
            'BackgroundColor',bgColor2,...
            'String','File Type',...
            'FontUnits','normalized', ...
            'Visible','on');
        btnPos1 = [0 .5 1 .5];%since these will be realative to the panel
        btnPos2 = [0 0 1 .5];%these coordinates work for all the radio buttons
        HANDLES.filetype.usb = uicontrol( HANDLES.file_type_buttons,...
            'Style','radiobutton',...
            'Units','normalized',...
            'Position',btnPos1,...
            'BackgroundColor',bgColor2,...
            'String','USB/*.hrp',...
            'FontUnits','normalized', ...
            'Visible','on',...
            'Value',0);
        HANDLES.filetype.ftp = uicontrol( HANDLES.file_type_buttons,...
            'Style','radiobutton',...
            'Units','normalized',...
            'Position',btnPos2,...
            'BackgroundColor',bgColor2,...
            'String','FTP',...
            'FontUnits','normalized', ...
            'Visible','on',...
            'Value',1);
        HANDLES.num_channels_buttons = uibuttongroup(HANDLES.fig.convert,...
            'Position', [.5 .52 bw bh],...
            'Units', 'normalized',...
            'BorderType', 'none');
        HANDLES.num_chan.txt = uicontrol(HANDLES.fig.convert,...
            'Style','text',...
            'Units','normalized',...
            'Position',[.02 .47 bw .2],...
            'BackgroundColor',bgColor2,...
            'String','Number of Channels',...
            'FontUnits','normalized', ...
            'Visible','on');
        HANDLES.channels.one = uicontrol( HANDLES.num_channels_buttons,...
            'Style','radiobutton',...
            'Units','normalized',...
            'Position',btnPos1,...
            'BackgroundColor',bgColor2,...
            'String','1',...
            'FontUnits','normalized', ...
            'Visible','on',...
            'Value',0);
        HANDLES.filetype.ftp = uicontrol( HANDLES.num_channels_buttons,...
            'Style','radiobutton',...
            'Units','normalized',...
            'Position',btnPos2,...
            'BackgroundColor',bgColor2,...
            'String','4',...
            'FontUnits','normalized', ...
            'Visible','on',...
            'Value',0);
        HANDLES.data_type_buttons = uibuttongroup(HANDLES.fig.convert,...
            'Position', [.5 .35 .5 bh],...
            'Units', 'normalized',...
            'BorderType', 'none');
        HANDLES.dtype.txt = uicontrol(HANDLES.fig.convert,...
            'Style','text',...
            'Units','normalized',...
            'Position',[.02 .3 bw .2],...
            'BackgroundColor',bgColor2,...
            'String','Data Type',...
            'FontUnits','normalized', ...
            'Visible','on');
        HANDLES.FIFO_buttons = uibuttongroup(HANDLES.fig.convert,...
            'Position', [.5 .19 .5 bh],...
            'Units', 'normalized',...
            'BorderType', 'none');
        HANDLES.FIFO_button.one = uicontrol( HANDLES.FIFO_buttons,...
            'Style','radiobutton',...
            'Units','normalized',...
            'Position',btnPos1,...
            'BackgroundColor',bgColor2,...
            'String','Yes',...
            'FontUnits','normalized', ...
            'Visible','on',...
            'Value',0);
        HANDLES.filetype.ftp = uicontrol( HANDLES.FIFO_buttons,...
            'Style','radiobutton',...
            'Units','normalized',...
            'Position',btnPos2,...
            'BackgroundColor',bgColor2,...
            'String','No',...
            'FontUnits','normalized', ...
            'Visible','on',...
            'Value',1);
        HANDLES.FIFO.txt = uicontrol(HANDLES.fig.convert,...
            'Style','text',...
            'Units','normalized',...
            'Position',[.035 .1 bw .2],...
            'BackgroundColor',bgColor2,...
            'String','Remove FIFO',...
            'FontUnits','normalized', ...
            'Visible','on');
        HANDLES.datatype.comp = uicontrol( HANDLES.data_type_buttons,...
            'Style','radiobutton',...
            'Units','normalized',...
            'Position',btnPos1,...
            'BackgroundColor',bgColor2,...
            'String','Compressed',...
            'FontUnits','normalized', ...
            'Visible','on',...
            'Value',0);
        HANDLES.datatype.std = uicontrol( HANDLES.data_type_buttons,...
            'Style','radiobutton',...
            'Units','normalized',...
            'Position',btnPos2,...
            'BackgroundColor',bgColor2,...
            'String','Standard',...
            'FontUnits','normalized', ...
            'Visible','on',...
            'Value',0);
        btnPos=[.1 0 bw bh];
        HANDLES.convert = uicontrol(HANDLES.fig.convert,...
            'Style','pushbutton',...
            'Units','normalized',...
            'Position',btnPos,...
            'BackgroundColor',bgColor2,...
            'String','Convert',...
            'FontUnits','normalized', ...
            'Visible','on',...
            'Callback', @convert);
        HANDLES.cancel = uicontrol(HANDLES.fig.convert,...
            'Style','pushbutton',...
            'Units','normalized',...
            'Position',[.5 0 bw bh],...
            'BackgroundColor',bgColor2,...
            'String','Cancel',...
            'FontUnits','normalized', ...
            'Visible','on',...
            'Callback', @close);
  end
end