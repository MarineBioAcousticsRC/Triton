function odata = decompressRawHRP(fid,rf,vflag,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% decompressRawHRP.m
%
% Takes a raw HRP file and decompresses it.
%
% Parameters:
%       fid - input file identifier already fopen from calling code
%       rf - raw file (disk dump) number upon which to decompress
%       vflag - firmware/data version flag V2.02Q =0, V2.02R =1
%       varargin - extra variables used by hrp2xwav
% Return:
%       odata - vector of output data
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global PARAMS

usb_ftp_flag=0;
byteblk = 512;
ftype = 1;

k=1;
while k < length(varargin)  %should this include datasamp/tailblk for 4 channel data?
    switch varargin{k}
        case 'usb_ftp_flag'
            usb_ftp_flag = varargin{k+1};
            k = k+2;
        case 'ftype'
            ftype = varargin{k+1};
            k = k+2;
        case 'filesize'
            filesize = varargin{k+1};
            k = k+2;
        case 'dvec'
            dvec = varargin{k+1};
            k = k+2;
        case 'ticks'
            ticks = varargin{k+1};
            k = k+2;
        case 'samplerate'
            samplerate = varargin{k+1};
            k = k+2;
        otherwise
            disp('Didn''t match varargs for decompressRawHRP, Check inputs');
            disp_msg('Didn''t match varargs for decompressRawHRP, Check inputs');
    end
end

dflag = 0;
dbflag = 0;     % debug display flag

bpsect = 512;       % bytes per sector

% skip to start of raw file
if usb_ftp_flag
    PARAMS.error = struct;
    PARAMS.error.csl = 0;
    nhrp = 1;
    status = 0;
    blkmx = floor(filesize/byteblk);
    Nsect = blkmx;
    vflag = vflag-2; %offset between old hrp2xwav and new decompressRawHRP
else
    status = fseek(fid,PARAMS.head.dirlist(rf,1)*bpsect,'bof');
    Nsect = PARAMS.head.dirlist(rf,10);
    samplerate = PARAMS.head.samplerate;
end

if status ~= 0
    disp(['Error - failed fseek to byte ',num2str(PARAMS.head.dirlist(rf,1)*512)])
    return
end

csector = 0;              % sector count
csection = 0;           % section count

if usb_ftp_flag
    dvo = [dvec(1:5) dvec(6)+ticks/1000];
else
    dvo = [PARAMS.head.dirlist(rf,2:6) ...
        PARAMS.head.dirlist(rf,7)+0.001*PARAMS.head.dirlist(rf,8)];
end

dnumo = datenum(dvo);       % first old datenum is dirlist time
nBlksPerRawFile = 0;

% output vector
if samplerate == 320000
    Tnsamp = 14e6;    % total number of samples in one raw file
else
    Tnsamp = 15e6;
end
odata = zeros(Tnsamp,1);  % pre-allocate memory for output data - this is very important for processing speed
sn1 = 1;    % sample number for beginning of section

% loop over sectors in raw file
% typically there will be multiple number of sectors (=>8) in ea
% Section, so kinda looping over Sections in integer number of
% sectors
while csector < Nsect
    csection = csection + 1;
    if dbflag
        disp(['csector = ',num2str(csector)])   % debugging info
    end
    rlen = 0;     % remaining number of bytes to read to end of Section
    [dv,dcount] = fread(fid,8,'uint8');
    
    % the following shouldn't be needed except for perhaps last file
    % left over from hrp2xwav on single ftp/usb raw files
    if dcount ~= 8
        disp('*************** EOF - Stopped Writing XWAV *******************')
        disp(['only read ',num2str(dcount),' values for timing header'])
        disp('Since less than 8, must be EOF')
        [msg,errnum] = ferror(fid);
        disp(['msg= ',msg,'  errnum= ',num2str(errnum)])
        break       % break out of while csector
    end
    if ftype == 1
        ticks = (little2big_2byte([dv(8) dv(7)]));
        dnum = datenum([dv(2) dv(1) dv(4) dv(3) dv(6) dv(5)+ 0.001.* ticks]);
    elseif ftype == 2
        ticks = 2^8*dv(7)+ dv(8);
        dnum = datenum([dv(1) dv(2) dv(3) dv(4) dv(5) dv(6)+ 0.001.* ticks]);
    end
    ddnum = dnum - dnumo;   % difference in datenum new - old
    dsec = ddnum * 24 * 60 * 60;        % section header times should be 0.020 sec apart
    dsec = round(1000*dsec)/1000;
    
    %             if samplerate == 200000
    %                 header_diff1 = 0.020;
    %                 header_diff2 = 0.020;
    %             elseif samplerate == 320000
    %                 header_diff1 = .012;
    %                 header_diff2 = .013;
    %             elseif samplerate == 2000
    %                 header_diff1 = 2.000;
    %                 header_diff2 = 2.000;
    if samplerate <= 200000
        header_diff1 = 4000/samplerate;
        header_diff2 = header_diff1;
    elseif samplerate == 320000
        header_diff1 = .012;
        header_diff2 = .013;
    else
        errordlg(['Unknown sampling rate: ' num2str(samplerate)]);
        return
    end
    
    if (dsec ~= header_diff1 || dsec ~= header_diff2) && dbflag
        disp([num2str(csection),'  ',...
            datestr(dnum,'yy mm dd HH MM SS FFF'),' - ',...
            datestr(dnumo,'yy mm dd HH MM SS FFF'),' = ',num2str(dsec)])
    end
    % check for time diff and report
    % 1.020 and -0.98 are from 2.02Q.  This has bee fixed in 2.02R
    % .013 & .012 is from 2.05A (320KHz)
    % 320KHz requires extra checks due to DL rounding off
    % millisecond fractions
    if samplerate == 200000
        if (dsec ~= 0.020 && dsec ~= 1.020  && dsec ~= -0.98 && ...
                dsec ~= 0)
            disp([ 'Triton Error: Time difference between section ' ...
                'headers is ' num2str(dsec,6) ]);
        end
    elseif samplerate == 320000
        if (dsec ~= 0.012 && dsec ~= 0.013 && dsec ~= 0 && ...
                dsec ~= 1.013 && dsec ~= 1.012 && dsec ~= -0.987 ...
                && dsec ~= -0.988 )
            disp([ 'Triton Error: Time difference between section ' ...
                'headers is ' num2str(dsec,6) ]);
        end
    end
    % omit buffer wrap time -81.9s, as this is not a 'sync' loss
    dmin = -100;
    dmax = 100;
    if (dsec < dmin) || (dsec > dmax)   % if sync loss
        % save info on sync loss
        PARAMS.error.csl = PARAMS.error.csl + 1;    % count
        PARAMS.error.slrf(PARAMS.error.csl) = rf;   % rawfile #
        % give some feed back
        disp(['Triton Error: sync loss at sector = ',num2str(csector),' section = ',num2str(csection)])
        disp(['previous datetime: ',datestr(dnumo,'yy mm dd HH MM SS FFF')])
        disp(['current  datetime: ',datestr(dnum,'yy mm dd HH MM SS FFF')])
        disp(['diff = ',num2str(dsec),' seconds'])
        
        pos = ftell(fid);
        disp(['csection= ',num2str(csection),' csector=  ',num2str(csector),...
            ' ',datestr(dnum),' ',num2str(ticks),' bn= ',num2str(bn),...
            ' rlen= ',num2str(rlen),'  blen= ',num2str(blen),'  btag= ',...
            num2str(btag),' Position= ',dec2hex(pos)])
        % fix output XWAV file
        dnsamp = 4000 - nsamp;      % difference number of samples of previous write
        % from Sector size
        if btag > 2^15             % check for 8-bit data
            dbyte = dnsamp;
        else        % 16-bit
            dbyte = 2*dnsamp;
        end
        disp(['nsamp = ',num2str(nsamp),'   dnsamp = ',num2str(dnsamp),'    dbyte = ',num2str(dbyte)])
        if dnsamp < 0
            sn1 = sn1 + dnsamp;    % jump back in output file
        elseif dnsamp > 0
            A = samp1 .* ones(dnsamp,1);
            odata(sn1-dnsamp:sn1-1) = A;
        end
        % search for next section timing header sync
        cyy = 0;
        while dsec < dmin || dsec > dmax
            fseek(fid,-7,0); % go back 7 bytes so that each read only advances 1 byte
            dv = fread(fid,8,'uint8');
            if ftype == 1
                ticks = (little2big_2byte([dv(8) dv(7)]));
                dnum = datenum([dv(2) dv(1) dv(4) dv(3) dv(6) dv(5)+ 0.001.* ticks]);
            elseif ftype == 2
                ticks = 2^8*dv(7)+ dv(8);
                dnum = datenum([dv(1) dv(2) dv(3) dv(4) dv(5) dv(6)+ 0.001.* ticks]);
            end
            ddnum = dnum - dnumo;   % difference in datenum new - old
            dsec = ddnum * 24 * 60 * 60;        % section header times should be 0.020 sec apart
            dsec = round(1000*dsec)/1000;
            cyy = cyy + 1;
            if cyy >= 30e6
                disp('stepping too far - exit')
                return
            end
        end  % end while
        
        disp(['jumped ahead ', num2str(cyy),' bytes to next timestamp'])
        disp(['new      datetime: ',datestr(dnum,'yy mm dd HH MM SS FFF')])
        if dsec == 0.020
            disp(['Extra data: Jumped to next Section'])
        elseif dsec == 0.040
            disp(['Missing data: Skip to 2nd next Section'])
            csection = csection + 1;
        else
            disp(['Triton Error: off many Sections? dsec=',num2str(dsec)])
        end
        
    end % end if sync loss
    
    dnumo = dnum;
    slen = fread(fid,1,'uint16');   % length in bytes of remaining Section
    % including slen
    rlen = slen;                    % remaining bytes in Section
    rlen = rlen - 2;                % decrement after fread
    samp1 = fread(fid,1,'int16');   % first sample of Section
    rlen = rlen - 2;
    bn = 0;     % block number
    ldata = 0;  % last data value
    nsamp = 0;  % total number of samples in a Section from Block writes
    % loop over blocks of compressed data until next Section
    while rlen > 0
        nBlksPerRawFile = nBlksPerRawFile + 1;  % count number of blocks per raw file
        bn = bn + 1;
        if bn == 1
            sdata = samp1;
        else
            sdata = ldata;
        end
        
        btag = fread(fid,1,'uint16');  % block tag
        rlen = rlen - 2;
        data = [];
        ddata = [];
        
        % read blocks
        if btag > 2^15             % check for 8-bit data
            blen = btag - 2^15 ;     % number of samples
            rleno = rlen;
            rlen = rlen - blen;  % should this be here?
            if rlen < 0             % this is the major problem with leading to 'sync losses'
                disp(['Error: block length too long: blen=',num2str(blen),' rlen=',num2str(rlen)])
                pos = ftell(fid);
                disp(['      csection= ',num2str(csection),' csector=  ',num2str(csector),...
                    ' ',datestr(dnum),' ',num2str(ticks),' bn= ',num2str(bn),...
                    ' Position= ',dec2hex(pos)])
                blen = rleno;
                rlen = 0;
                disp(['Truncate: blen=',num2str(blen),' rlen=',num2str(rlen)])
                disp(' ')
                
                offset = -samp1;    % need neg since differencing 8-bit
                ddata = offset .* ones(blen,1); % force samples to one value, flat line
                fseek(fid,blen,0);      % skip over remaining bytes
            else                                        % normal operation
                if ftype == 1 % if USB
                    if rem(blen,2) % if odd
                        A = fread(fid,blen+1,'int8');   % read in differenced data vector
                        B = reshape(A,2,(blen+1)/2);    % convert to matrix
                        C = [B(2,:); B(1,:)];           % reordered - byte swap for 8-bit
                        D = reshape(C,blen+1,1);        % back to vector
                        ddata = D([1:end-2,end]);       % remove extra zero
                        if rlen ~= 0
                            rlen = rlen - 1;            % one less byte to read
                        else
                            fseek(fid,-1,0);            % skip back one byte if end of section
                        end
                    else  % if even
                        A = fread(fid,blen,'int8');     % read in differenced data
                        B = reshape(A,2,blen/2);        % convert to matrix
                        C = [B(2,:); B(1,:)];           % reordered - byte swap for 8-bit
                        ddata = reshape(C,blen,1);      % back to vector
                    end
                else % if FTP
                    if rem(blen,2) % if odd
                        A = fread(fid,blen+1,'int8');     % read in differenced data
                        ddata = A([1:end-2,end]);         % remove extra zero
                        if rlen ~= 0
                            rlen = rlen - 1;                % one less byte to read
                        else
                            fseek(fid,-1,0);                % skip back one byte if end of section
                        end
                    else  % if even
                        ddata = fread(fid,blen,'int8');     % read in differenced data
                    end
                end
            end
            if vflag == 1   % V2.02R and beyond ?
                data = cumsum([sdata,-ddata']);       % uncompress
            end
        else
            % 16-bit data
            blen = btag;                        % number of samples
            rleno = rlen;                       % hold on to previous remaining bytes in section
            rlen = rlen - 2*blen;                   % remaining bytes in Section
            if rlen < 0        % this is the major problem leading to 'sync losses'
                disp(['Error: block length too long: blen=',num2str(blen),' rlen=',num2str(rlen)])
                pos = ftell(fid);
                disp(['      csection= ',num2str(csection),' csector=  ',num2str(csector),...
                    ' ',datestr(dnum),' ',num2str(ticks),' bn= ',num2str(bn),...
                    ' Position= ',dec2hex(pos)])
                blen = floor(rleno/2);
                rlen = 0;
                disp(['Truncate: blen=',num2str(blen),' rlen=',num2str(rlen)])
                disp(' ')
                offset = samp1;
                ddata = offset .* ones(blen,1);% force samples to one value, flat line
                fseek(fid,blen*2,0);      % skip over remaining bytes
            else
                ddata = fread(fid,blen,'int16');     % read in differenced data
            end
            
            if vflag == 1   % V2.02R
                data = [sdata,ddata'];       % uncompress
            end
        end  % end if btag > 2^15
        
        if vflag == 0   % V2.02Q
            data = cumsum([sdata,-ddata']);
        end
        
        dlen = length(data);
        ldata = data(dlen);         % save for seed of next block
        
        if bn > 1
            data = data(2:dlen);        % remove seed data
        end
        
        % V2.02Q bug: 16-bit differences can make output data
        % > 2^15 or < -2^15 beyond int16 range
        %
        % solution: find when this happens and set data to 16bit
        % difference
        I = [];
        I = find(data > 2^15 | data < -2^15);
        if ~isempty(I)
            disp(['Error: decompressed data beyond 16-bit limit ',...
                datestr(dnum),' ',num2str(ticks)])
            disp([' sector ',num2str(csector), ...
                ' section ' ,num2str(csection), ...
                ' block ',num2str(bn), ...
                ' btag ',num2str(btag),...
                ' blen ', num2str(blen),...
                ' samples ' ,num2str(length(I))])
            
            % set data to differences, essentually setting the seed
            % to zero which will result in some offset
            data = -ddata(1) .* ones(dlen-1,1);
            ldata = data(dlen-1);
            
            J = [];
            J = find(data > 2^15 | data < -2^15);
            if ~isempty(J)
                disp('ERROR: this should not happen')
                disp([' samples ' ,num2str(length(J))])
            end
            
        end
        
        % output data
        sdlen = length(data);
        odata(sn1:sn1+sdlen-1) = data;      % fill up output data vector
        sn1 = sn1+sdlen;        % for the next section
        
        dlen = length(data);
        nsamp = nsamp + dlen;       % Total number of sample written for each Block
        
        if rlen == 0       % done with this Section
            tlen = slen + 8;       % total number of bytes of section including
            % timing header
            rbytes = rem(tlen,bpsect);  % remainder number of bytes in sector
            sbytes = bpsect - rbytes;  % bytes to skip over to next sector
            %                         rdata = fread(fid,sbytes,'uint8');  % test read
            if sbytes < bpsect && sbytes > 0
                fseek(fid,sbytes,0);      % skip over remaining bytes at
            elseif sbytes ~= bpsect && sbyte ~= 0
                disp('Triton ERROR: incorrect number of bytes to skip before next Section')
                disp(['Skip bytes = ',num2str(sbytes)])
            end
            % end of last sector of current
            % section
            csector = csector + ceil(tlen/bpsect);  % number of sectors used in this disk dump/write
            break       % break out of while rlen loop
        end  % end if rlen == 0
    end % end while rlen
    % hack to fix data
    % if too many samples, truncate and break from while csector loop
    if length(odata) > Tnsamp
        odata = odata(1:Tnsamp);
        break           % break out of while csector, effectively ending function call
    end
end % end while csector