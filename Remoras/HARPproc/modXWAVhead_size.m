function modXWAVhead_size(fod,nrf)
%
% function to modify XWAV header sizes
%
% Needed now that decompressRawHRP can catch sync loss and make smaller
% raw files than expected (i.e., non-full raw files)
%
% 221104 smw
%%


bytelength = zeros(nrf,1);

for crf = 1:nrf
    fseek(fod, 36 + 64 + 32*(crf-1) + 8+4, 'bof');
    bytelength(crf) = fread(fod,1,'uint32');
 end

Tbytelength = sum(bytelength);
harpsize = (nrf * 32) + 64 - 8;% length of the harp chunk
wavsize = Tbytelength+36+harpsize+8;  % required for the RIFF header

fseek(fod,4,'bof');  % go to ChunkSize
fwrite(fod,wavsize,'uint32');

fseek(fod,36 + 44,'bof');      % go to number of Rawfiles
fwrite(fod,nrf,'uint16');

headsize = 36 + 64 + (nrf * 32) + 4;
fseek(fod,headsize,'bof');  % go to dSubchunkSize
fwrite(fod,Tbytelength,'uint32');

