function    X = d3readswv(recdir,prefix,df)
%    X = d3readswv(recdir,prefix,df)
%     Reads a sequence of D3 format SWV (sensor wav) sensor files
%     and assembles a continuous sensor sequence in x.
%     Calls d3parseswv to read in each file.
%
%     Returns:
%     X  is a structure containing:
%        x: a cell array of sensor vectors. There are as many
%        cells in x as there are unique sensor channels in the
%        recording. Each cell may have a different length vector
%        according to the sampling rate of the sensor channel.
%        fs: a vector of sampling rates. Each entry in fs is the
%        sampling rate in Hz of the corresponding cell in x.
%        cn: a vector of channel id numbers corresponding to
%        the cells in x. Use d3channames to get the name and
%        description of each channel.
%
%     markjohnson@st-andrews.ac.uk
%     Licensed as GPL, 2012

% get file names
[fn,did,recn,recdir] = getrecfnames(recdir,prefix) ;
x = [] ;
X.x = [] ; X.fs = [] ; X.cn = [] ;
if isempty(fn), return, end

% read in swv data from each file
for k=1:length(fn),
   fprintf('Reading file %s\n', fn{k}) ;
   XX = d3parseswv([recdir,fn{k}]) ;
   fs = XX.fs ; cn = XX.cn ;
   if isempty(x),
      x = XX.x ; 
      if nargin>2 & ~isempty(df) & df>1,
         z = cell(size(x,2),1) ;
         for kk=1:length(x),
            [x{kk},z{kk}] = decz(x{kk},df) ;
         end
      else
         df = 1 ;
      end

   else
      xx = XX.x ;
      for kk=1:length(xx),
         if df==1,
            x{kk}(end+(1:length(xx{kk}))) = xx{kk} ;
         else 
            [xd,z{kk}] = decz(xx{kk},z{kk}) ;
            x{kk}(end+(1:length(xd))) = xd ;
         end
      end
   end
end

X.fs = fs/df ;
if df>1,
   % get the last few samples out of the decimation filter
   for kk=1:length(x),
      xd = decz([],z{kk}) ;
      x{kk}(end+(1:length(xd))) = xd ;
   end
end

X.x = x ;
X.cn = cn ;
