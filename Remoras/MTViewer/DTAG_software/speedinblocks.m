function     [s,t,v] = speedinblocks(p,Aw,fs,T)
%
%     [s,t,v] = vertical(p,Aw,fs,T)
%     Estimate the vertical velocity and acceleration from the depth time
%     series.
%     p is the depth time series in meters, sampled at fs Hz. Aw is the
%     whale frame accelerometry sampled at fs Hz.
%     T is the duration of the averaging window in s. Default value is
%     5 second. Blocks are overlapped by 50%.
%
%     s is the speed estimate in m/s. NaN is used wherever the speed cannot
%     be determined (due to excessive specific acceleration or low pitch angle)
%     t is the time in s for each value in s and v
%     v is the vertical velocity in m/s
%
%     mark johnson, WHOI
%     mjohnson@whoi.edu
%     February 2008

MAXNA = 0.1 ;
MINSP = 0.25 ;
MINPR = 0.5 ;

if nargin<3,
   help('speedinblocks') ;
   return
end

if nargin<4,
   T = 5 ;
end

nT = round(fs*T) ;
k = 1:nT/2:length(p)-nT ;
v = (p(k+nT)-p(k))*(fs/nT) ;
na = norm2(Aw) ;
sp = -Aw(:,1)./na ;
xa = abs(na-1) ;
sp(xa>MAXNA) = NaN ;
bsp = buffer(sp,nT,nT/2,'nodelay') ;
msp = nanmean(bsp)' ;
n = sum(~isnan(bsp))' ;
msp(n<(MINPR*nT) | abs(msp)<MINSP | [v.*msp(1:length(v));-1]<0) = NaN ;
s = v./msp(1:length(v)) ;
t = (k-1+nT/2)/fs ;
