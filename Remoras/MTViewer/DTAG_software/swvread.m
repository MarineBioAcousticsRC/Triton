function     [s,fs,ch_names,chips] = swvread(tag,chips,df,chs)
%
%    [s,fs,ch_names] = swvread(tag,[chips,df,chs])
%    Read 1 or more tag2 sensor wav (swv) files and produce a concatenated
%    12-column sensor matrix. The sensor data can be decimated by a factor
%    df. For tag1 data use readsen3.m
%    Useage:
%    [s,fs] = swvread(tag) ;        % read all swv files for a tag deployment
%    [s,fs] = swvread(tag,chips) ;  % read just the files for the specified chips
%    [s,fs] = swvread(fname) ;      % read a specific file - fname is the full file name
%
%    tag    The deployment name e.g., sw05_199a. The .swv files are assumed
%           to be in the same directory as the audio (.wav) files for this
%           deployment.
%    chips  List of chip numbers. If specified, swvread will only read the
%           swv files associated with these chips.
%    df     Optional decimation factor - an integer > 0. The output
%           sampling rate will be the input sampling rate / df. Decimation
%           uses decdc.m. The sensor sampling rate is typically 50Hz so
%           using a df=10 will give the standard decimated sampling rate of
%           5 Hz.
%    chs    Specifies which channels (1..12) to read. Only those channels
%           listed in chs will be returned. Default is (1:12).
%
%    return:
%    s      Multi-channel sensor matrix with each column containing the
%           time series for one of the sensor channels. The sensor channels
%           are sampled synchronously, i.e., each row of s corresponds to
%           the same sampling time. The columns of s are:
%           S = [ax,ay,az,mx,my,mz,pressure,temperature,sws,vb,mb,pb]
%           i.e., column   sensor         column   sensor
%                    1     ax                7     pressure
%                    2     ay                8     temperature
%                    3     az                9     sws
%                    4     mx               10     vb
%                    5     my               11     mb
%                    6     mz               12     pb
%           where:   ax = accelerometer x-axis
%                    ay = accelerometer y-axis
%                    az = accelerometer z-axis
%                    mx = magnetometer x-axis
%                    my = magnetometer y-axis
%                    mz = magnetometer z-axis
%                    sws = salt-water-switch voltage level
%                    vb = battery voltage
%                    mb = magnetometer bridge voltage
%                    pb = pressure sensor bridge voltage
%           Note that all measurements in s are in 'local units' - i.e., raw
%           ADC conversions. The conversion of these values to real world units
%           is handled by tag2cal.m
%    fs     The sampling rate of s in Hz. All channels are sampled at the
%           same rate.
%    ch_names  A structure of strings containing the name for each sensor
%           channel, e.g., ch_names(3) is 'az' 
%    chips  A vector containing the numbers of chips successfully read
%
%    Note on creating 'raw' files: a raw sensor data file should be produced for 
%    every tag deployment. This file will be given the name of the
%    deployment, e.g., sw03_165araw.mat and will contain s and fs as produced
%    by swvread.m. Normally, s will be decimated data with an fs of 5 Hz.
%    Example Matlab calls to produce a raw file:
%        [s fs]=swvread('sw03_249c');
%        saveraw('sw03_249c',s,fs)
%
%    mark johnson, WHOI
%    majohnson@whoi.edu
%    Last modified: 26 October 2006
%        fixed large swv file memory problem

FIXHOLES = 1 ;
FIXSWITCHES = 1 ;
MAXREAD = 1e6 ;

ch_names = {'ax','ay','az','mx','my','mz','press','temp','sws','vb','mb','pb'} ;
s = [] ; fs = [] ;

if nargin==0,
   return
end

if nargin<2,
   chips = [] ;
end

if nargin<3 | isempty(df),
   df = 10 ;
end

if nargin<4 | isempty(chs),
   chs = [7 1:6 8:12] ;
   CHI = [2:7 1 8:12] ;
else
   CHI = 1:length(chs) ;
end

if length(chs)>3,         % divide chs into multiple sets if necessary to reduce memory
   k = 1 ; done = 0 ;
   while ~done,
      kk = (k-1)*3+1 ;
      chans{k} = chs(kk:min([kk+2,length(chs)])) ;
      k = k+1 ;
      done = kk+3>length(chs) ;
   end
else
   chans{2} = chs ;
end

if ~isempty(findstr(tag,'.')) & isempty(chips),
   if exist(tag,'file'),
      fnames = {tag} ;           % complete filename was given
   else
      fprintf('Cannot open file %s - check path and name\n',tag) ;
      return
   end
else
   [fnames,chips] = makefnames(tag,'SWV',chips) ;
end

if length(fnames)==0,
   fprintf('No swv files found - check tag id and AUDIO path\n') ;
   return
end

nsamps = checksize(fnames) ;
ss = zeros(nsamps(end),length(chans{1})) ;
s = [] ;
holelist = [] ;
switchlist = [] ;

for k=1:length(chans),  % make multiple reads if necessary to avoid overloading the RAM
   chs = chans{k} ;
   if length(chs)>1,
      fprintf(' Reading channels %d to %d of chip ', min(chs), max(chs)) ;
   else
      fprintf(' Reading channel %d of chip ', chs) ;
   end

   if size(ss,2)>length(chs),
      ss = zeros(nsamps(end),length(chs)) ;
   end

   for kk=1:length(fnames),
      if ~isempty(chips),
         fprintf('%d ',chips(kk)) ;
      end
      flen = max(wavread16(fnames{kk},'size')) ;
      [v,Fs] = wavread16(fnames{kk},min([MAXREAD flen])) ;
      ss(nsamps(kk)+(1:size(v,1)),:) = v(:,chs) ;
      if size(v,1)<flen,
         [v,Fs] = wavread16(fnames{kk},[MAXREAD+1 flen]) ;
         ss(nsamps(kk)+MAXREAD+(1:size(v,1)),:) = v(:,chs) ;
      end 
   end

   fprintf('\n') ;
   if FIXHOLES,
      [ss,holelist] = fixholes(ss,holelist) ;
   end

   if FIXSWITCHES,
      [ss,switchlist] = fixswitches(ss,chs,switchlist) ;
   end

   if df>1,
      fprintf(' decimating\n') ;
      ss = decdc(ss,df) ;
   end

   s = [s ss] ;
end

s = s(:,CHI) ;
fs = Fs/df ;
return


function    nsamps = checksize(fnames)
%
%
ns = [0;zeros(length(fnames),1)] ;
for k=1:length(fnames),
   if ~exist(fnames{k},'file'),
      nsamps = 0 ;
      fprintf(' Cannot find file %s - check name and path\n', fnames{k}) ;
      return ;
   end
   ns(k+1) = wavread16(fnames{k},'size')*[1;0] ;
end
nsamps = cumsum(ns) ;
return


function    [s,hlist] = fixholes(s,hlist)
%
%
% find initial zero elements - upto NI

CHUNK_SIZE = 10 ;
NI = 2*CHUNK_SIZE ;

if isempty(hlist),
   % make holes list
   if size(s,2)==1,           % find all holes
      kk = find(s==0) ;
   else
      kk = find(all(s'==0)) ;
   end

   if ~isempty(kk),
      hh = find(diff([-1 kk])>1) ;   % get start cues of connected holes
      %hlist = [kk(1) kk(hh+1)';kk(hh)' kk(end)]' ;
      for kh=1:length(hh)-1,
         hlist(end+1,:) = [kk(hh(kh)) kk(hh(kh+1)-1)] ;
      end

      if hlist(1,1)==1 & hlist(1,2)>NI,    % check for a large starting hole
         fprintf(' Excess zeros at start of sensor data\n') ;
      end
      fprintf(' Repairing %d holes in the data covering %d samples\n', size(hlist,1),length(kk)) ;
   end
end

% now interpolate across the holes
if ~isempty(hlist),
   for k=1:size(hlist,1),            % for each hole...
      kk = (hlist(k,1):hlist(k,2))' ;
      if hlist(k,1)==1,
         s(kk,:) = ones(length(kk),1)*s(hlist(k,2)+1,:) ;
      elseif hlist(k,2)==size(s,1),
         s(kk,:) = ones(length(kk),1)*s(hlist(k,1)-1,:) ;
      else
         s(kk,:) = interp1(hlist(k,:)+[-1 1],s(hlist(k,:)+[-1 1],:),kk,'linear') ;
      end
   end
end
return


function [ss,switchlist] = fixswitches(ss,chans,switchlist)
%
%
kp = find(chans==7) ;
if ~isempty(kp),      % pressure channel
   while(1),
      ks = find(abs(diff(ss(:,kp(1))))>0.1)' ;    % look for sudden changes in the pressure
      if length(ks)<2, break ; end
      fprintf(' Fixing sensor error at sample %ld of length %ld\n',ks(1),ks(2)-ks(1)) ;
      switchlist = [switchlist;ks(1:2)] ;
      kv = ks(1):ks(2)+1 ;
      ks(1) = ks(1)-1 ;
      ks(2) = ks(2)+2 ;
      ss(kv,:) = interp1([0,ks(2)-ks(1)]',ss(ks(1:2),:),kv-ks(1)) ;
   end
else                 % fix any switches in other channels
   for k=1:size(switchlist,1),
      ks = switchlist(k,:) ;
      kv = ks(1):ks(2)+1 ;
      ks(1) = ks(1)-1 ;
      ks(2) = ks(2)+2 ;
      ss(kv,:) = interp1([0,ks(2)-ks(1)]',ss(ks(1:2),:),kv-ks(1)) ;
   end
end
return
