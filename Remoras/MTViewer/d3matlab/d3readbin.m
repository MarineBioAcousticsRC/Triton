function    [B,BH,H] = d3readbin(fname,blk)
%
%    [B,BH,H]=d3readbin(fname,blk)
%     Read data from a D3 bin file.
%     fname is the full path and filename of the file to read
%     blk is the block number to read or 
%     blk = [start_block, number_of_blocks] or
%     blk = [] to read all blocks.
%
%     B is a matrix containing the data from the requested block
%        (if one block is requested) or a cell array of matrices
%        (if multiple blocks are requested).
%     BH is a structure array containing the block headers for each
%        requested block. Fields are:
%        blk      block number
%        rtime    Unix time of the first sample in the block
%        mticks   time offset from rtime in microseconds of the first 
%                 sample in the block
%        n        number of data points in the block
%        ns       number of samples per channel in the block
%     H is a structure array containing the file header with fields:
%        nblks    number of blocks in the file
%        fs       sampling rate in Hz
%        nbits    number of bits per sample
%        nchs     number of channels
%
%     NOTE: currently only supports 16 bit data.
%
%     markjohnson@st-andrews.ac.uk
%     Licensed as GPL, 2013

%     BIN files have a header of 28 bytes containing:
%     byte 1-8    8-byte data source name
%     byte 9-12   number of blocks in the file
%     byte 13-16  configuration number
%     byte 17-20  sampling rate in Hz
%     byte 21-24  number of bits per word
%     byte 25-28  number of channels per sample
%
%     Blocks of data follow the header. Each block has
%     a 20 byte block header containing:
%     byte 1-4    4-byte flag ("blck")
%     byte 5-8    block number (first block is 0)
%     byte 9-12   rtime (Unix seconds)
%     byte 13-16  mticks (microseconds)
%     byte 17-20  number of 16-bit words in the block

B = [] ; BH = [] ; H = [] ;
if nargin<1,
   help d3readbin
   return
end

BY2LN = 2.^[24 16 8 0]' ;

f = fopen(fname,'rb') ;
if f<1,
   fprintf('Unable to open file %s\n',fname) ;
   return
end

% read in the file header
h = fread(f,28,'uint8') ;
H.nblks = h(9:12)'*BY2LN ;
H.fs = h(17:20)'*BY2LN ;
H.nbits = h(21:24)'*BY2LN ;
H.nchs = h(25:28)'*BY2LN ;
H.s = h ;
if nargin<2,
   B = H ;
   return
end

if isempty(blk),
   blk = [1 H.nblks] ;
end

if any(blk<=0) | sum(blk)>H.nblks+1,
   fprintf('Block number(s) must be between 1 and %d\n',H.nblks) ;
   return
end

if length(blk)==1,
   blk(2) = 1 ;
end

% skip the blocks up to the first requested one
for k=1:blk(1)-1,
   bh = getnextblockheader(f,BY2LN) ;
   if isempty(bh), return, end
   fseek(f,bh.n*2,0) ;        % skip over the data in the block
end

BH = struct('blk',[],'rtime',[],'mticks',[],'n',[],'ns',[]) ;
for k=1:blk(2),
   bh = getnextblockheader(f,BY2LN) ;
   if isempty(bh), return, end
   x = fread(f,bh.n*2,'uint8') ;
   B{k} = reshape(x(1:2:end)*256+x(2:2:end),H.nchs,[])' ;
   bh.ns = bh.n/H.nchs ;
   BH(k) = bh ;
end

fclose(f) ;
if blk(2)==1,
   B = B{1} ;
end
return


function    BH = getnextblockheader(f,BY2LN)
% find the next block header - it should be at the current file cursor but
% may not be in some error situations.
key = 'blck' ;
BH = [] ;
h = zeros(1,3) ;
while 1,
   h = [h(end+(-2:0)) fread(f,20,'uint8')'] ;
   if length(h)<23, return, end  % check for end of file
   k = strfind(char(h),key) ;
   if ~isempty(k), break, end    % found a block header
end

% adjust file pointer and h in case the key is not where it should be
h = h(k:end) ;
nh = length(h) ;
if nh>20,
   fseek(f,20-nh,0) ;       % give back a few bytes to the file
elseif nh<20,
   h = [h fread(f,20-nh,'uint8')'] ;
end

% check once more that there is a full header
if length(h)<20, return, end  % check for end of file

% if we get here, h contains a valid block header
BH.blk = h(5:8)*BY2LN ;
BH.rtime = h(9:12)*BY2LN ;
BH.mticks = h(13:16)*BY2LN ;
BH.n = h(17:20)*BY2LN ;
return
