function modXWAVhead_rfhd(fod,rfidx,nrf,j,nsamp)
%
% function to modify XWAV header Timestamp, byteloc and bytelength
% for rawfile write
% Needed now that decompressRawHRP can catch sync loss and make smaller
% raw files than expected (i.e., non-full raw files)
%
% 221104 smw
%%

global PARAMS

floc = ftell(fod);  % output file current location

bytelength = nsamp .* 2;   % 2 bytes/sample
writelength = ceil(bytelength / 500);      % 500 bytes of data/sector

rfmod = mod(rfidx, nrf);
if rfmod == 0
    rfmod = nrf;   % last raw file
end

if  rfmod == 1  % first raw file in xwav
    fseek(fod, 36 + 64, 'bof');  % 36=wav hdr; 64=XWAV hdr
    % time header
    fwrite(fod, PARAMS.head.dirlist(j,2) , 'uchar');
    fwrite(fod, PARAMS.head.dirlist(j,3), 'uchar');
    fwrite(fod, PARAMS.head.dirlist(j,4), 'uchar');
    fwrite(fod, PARAMS.head.dirlist(j,5), 'uchar');
    fwrite(fod, PARAMS.head.dirlist(j,6), 'uchar');
    fwrite(fod, PARAMS.head.dirlist(j,7), 'uchar');
    fwrite(fod, PARAMS.head.dirlist(j,8), 'uint16');
    fseek(fod,4,'cof');
    fwrite(fod, bytelength, 'uint32');
    fwrite(fod, writelength, 'uint32');
      
else
    fseek(fod, 36 + 64 + 32*(rfmod-2) + 8, 'bof');  % previous rawfile
    byteloc1 = fread(fod,1,'uint32');
    bytelength1 = fread(fod,1,'uint32');
    byteloc2 = byteloc1 + bytelength1;  % location of this (next) rawfile data
    fseek(fod, 16 , 'cof'); % go to next rawfile timestamp
    % time header
    fwrite(fod, PARAMS.head.dirlist(j,2) , 'uchar');
    fwrite(fod, PARAMS.head.dirlist(j,3), 'uchar');
    fwrite(fod, PARAMS.head.dirlist(j,4), 'uchar');
    fwrite(fod, PARAMS.head.dirlist(j,5), 'uchar');
    fwrite(fod, PARAMS.head.dirlist(j,6), 'uchar');
    fwrite(fod, PARAMS.head.dirlist(j,7), 'uchar');
    fwrite(fod, PARAMS.head.dirlist(j,8), 'uint16');
    fwrite(fod, byteloc2, 'uint32');
    fwrite(fod, bytelength, 'uint32');
    fwrite(fod, writelength, 'uint32');
    
end

% put the pointer back to where is was writing xwav data to file:
fseek(fod,floc,'bof');


