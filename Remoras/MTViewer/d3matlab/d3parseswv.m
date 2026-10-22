function    X = d3parseswv(fname)
%    X = d3parseswv(fname)
%     Read a D3 format SWV (sensor wav) sensor file using
%     the accompanying xml file to interpret the sensor channels.
%     To read all sensor files from a deployment, use d3readswv
%     which calls this function.
%     fname is the full path (if needed) and filename of the swv
%     file to read. The .swv suffix is not needed.
%
%     Returns:
%     X.x  is a cell array of sensor vectors. There are as many
%        cells in x as there are unique sensor channels in the
%        recording. Each cell may have a different length vector
%        according to the sampling rate of the sensor channel.
%     X.fs is a vector of sampling rates. Each entry in fs is the
%        sampling rate in Hz of the corresponding cell in x.
%     X.cn is a vector of channel id numbers corresponding to
%        the cells in x. Use d3channames to get the name and
%        description of each channel.
%
%     mark johnson
%     30 Jan 2013

X.x = [] ; X.fs = [] ; X.cn = [] ;
% remove a suffix from the file name if there is one
if any(fname=='.'),
   fname = fname(1:find(fname=='.',1)-1) ;
end

% get sensor channel names from the xml file 
d3 = readd3xml([fname '.xml']) ;
if isempty(d3) | ~isfield(d3,'CFG'),
   fprintf('Unable to find or read file %s.xml - check the file name\n', fname);
   return
end

CFG = [] ;
for k=1:length(d3.CFG),
   c = d3.CFG{k} ;
   if isfield(c,'PROC') & strncmp(c.PROC,'SENSOR',6)
      CFG = c ;
      break ;
   end
end

if isempty(CFG),
   fprintf('No SENSOR configuration in file %s\n',fname) ;
   return
end

% find the channel count and numbers
N = str2num(CFG.CHANS.N) ;
if isempty(N),
   fprintf('Invalid attribute in CHANS field - check xml file\n') ;
   return
end

chans = sscanf(CFG.CHANS.CHANS,'%d,') ;

if length(chans)~=N,
   fprintf('Attribute N does not match value size in CHANS field - check xml file\n') ;
   return
end

chans = chans(:) ;
uchans = unique(chans) ;

% find the sensor sampling rate
switch CFG.MCLK.UNITS,
   case  'MHz'
      mf = 1e6 ;
   case  'kHz'
      mf = 1e3 ;
   case  'Hz'
      mf = 1 ;
   otherwise
      fprintf('Unknown unit in MCLK field "%s"\n',CFG.MCLK.UNITS) ;
      return
end

mclk = str2num(CFG.MCLK.MCLK)*mf ;
fb = mclk/str2num(CFG.CLKDIV)/N ;

% read the swv file and convert to fractional offset binary
n = wavread16([fname '.swv'],'size') ;
if n(1)*n(2)>50e6,
   fprintf(' File is too large to read into Matlab (%d bytes)\n',n(1)*n(2)*8) ;
   return ;
end
xb = wavread16([fname '.swv']) ;
xb(xb<0)=2+xb(xb<0) ;            % convert from two's complement to offset binary
xb=xb/2 ;                        % sensor reading range is 0..1 in Matlab

% group channels
x = cell(length(uchans),1) ;
fs = zeros(length(uchans),1) ;
for k=1:length(uchans),
   kk = find(chans==uchans(k)) ;
   fs(k) = fb*length(kk) ;
   x{k} = reshape(xb(:,kk)',[],1) ;
end

X.x = x ;
X.fs = fs ;
X.cn = uchans ;
