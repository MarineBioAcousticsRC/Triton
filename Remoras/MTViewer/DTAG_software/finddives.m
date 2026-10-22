function    T = finddives(p,fs,th,surface,findall)
%
%    T = finddives(p,fs,[th,surface,findall])
%    Find time cues for the edges of dives.
%    p is the depth time series in meters, sampled at fs Hz.
%    th is the threshold in m at which to recognize a dive - dives
%    more shallow than th will be ignored. The default value for th is 10m.
%    surface is the depth in meters at which it is considered that the
%    animal has reached the surface. Default value is 1.
%    findall = 1 forces the algorithm to include incomplete dives at the
%    start and end of the record. Default is 0
%    T is the matrix of cues with columns:
%    [start_cue end_cue max_depth cue_at_max_depth mean_depth mean_compression]
%
%    If there are n dives deeper than th in p, then T will be an nx6 matrix. Partial
%    dives at the beginning or end of the recording will be ignored - only dives that
%    start and end at the surface will appear in T. 
%
% Copyright (C) 2005-2013, Mark Johnson
% This is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software 
% Foundation, either version 3 of the License, or any later version.
% See <http://www.gnu.org/licenses/>.
%
% This software is distributed in the hope that it will be useful, but 
% WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
% or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License 
% for more details.
%
% markjohnson@st-andrews.ac.uk
% last modified: 27 Jan 2013 - replaced filtfilt with fir_nodelay

if nargin<2,
   help('finddives') ;
   return
end

if nargin<3 | isempty(th),
   th = 10 ;
end

if nargin<4 | isempty(surface),
   surface = 1 ;        % maximum p value for a surfacing (was 2)
end

if nargin<5,
   findall = 0 ;
end

if fs>1000,
   fprintf('Suspicious fs of %d Hz - check\n', round(fs)) ;
   return
end

searchlen = 20 ;        % how far to look in seconds to find actual surfacing
dpthresh = 0.25 ;        % vertical velocity threshold for surfacing
dp_lp = 0.5 ;           % low-pass filter frequency for vertical velocity

% first remove any NaN at the start of p
% (these are used to mask bad data points and only occur in a few data sets)
kgood = find(~isnan(p)) ;
p = p(kgood) ;
tgood = (min(kgood)-1)/fs ;

% find threshold crossings and surface times
tth = find(diff(p>th)>0) ;
tsurf = find(p<surface) ;
ton = 0*tth ;
toff = ton ;
k = 0 ;

% sort through threshold crossings to find valid dive start and end points
for kth=1:length(tth) ;
   if all(tth(kth)>toff),
      ks0 = find(tsurf<tth(kth)) ;
      ks1 = find(tsurf>tth(kth)) ;
      if findall | (~isempty(ks0) & ~isempty(ks1)),
         k = k+1 ;
         if isempty(ks0),
            ton(k) = 1 ;
         else
            ton(k) = max(tsurf(ks0)) ;
         end
         if isempty(ks1),
            toff(k) = length(p) ;
         else
            toff(k) = min(tsurf(ks1)) ;
         end
      end
   end
end

% truncate dive list to only dives with starts and stops in the record
ton = ton(1:k) ;
toff = toff(1:k) ;

% filter vertical velocity to find actual surfacing moments
n = round(4*fs/dp_lp) ;
dp = fir_nodelay([0;diff(p)]*fs,n,dp_lp/(fs/2)) ;

% for each ton, look back to find last time whale was at the surface
% for each toff, look forward to find next time whale is at the surface
dmax = zeros(length(ton),2) ;
for k=1:length(ton),
   ind = ton(k)+(-round(searchlen*fs):0) ;
   ind = ind(find(ind>0)) ;
   ki = max(find(dp(ind)<dpthresh)) ;
   if isempty(ki),
      ki=1 ;
   end
   ton(k) = ind(ki) ;
   ind = toff(k)+(0:round(searchlen*fs)) ;
   ind = ind(find(ind<=length(p))) ;
   ki = min(find(dp(ind)>-dpthresh)) ;
   if isempty(ki),
      ki=1 ;
   end
   toff(k) = ind(ki) ;
   [dm km] = max(p(ton(k):toff(k))) ;
   dmax(k,:) = [dm (ton(k)+km-1)/fs+tgood] ;
end

% measure dive statistics
pmean = 0*ton ;
pcomp = pmean ;
for k=1:length(ton),
   pdive = p(ton(k):toff(k)) ;
   pmean(k) = mean(pdive) ;
   pcomp(k) = mean((1+0.1*pdive).^(-1)) ;
end

% assemble output
T = [[ton toff]/fs+tgood dmax pmean pcomp] ;

