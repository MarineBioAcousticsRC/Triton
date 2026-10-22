function    h=plott(p,fs,reverse)
%
%    h=plott(p,fs,reverse)
%   Plot sensor time series, p, sampled at fs Hertz against time in seconds
%   By default, plott shows the y-axis reversed as for a dive profile.
%   To prevent reversal, use:
%    plott(s,fs,0)
%   where s is the time series to plot.
%   Optionally returns a handle to the line plotted.
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
%   5 July, 2007

if nargin<2,
   help plott
   return
end

hh=plot((1:size(p,1))/fs,p); grid
if nargin<3 | isempty(reverse) | reverse==1,
   set(gca,'YDir','reverse') ;
end

xlabel('Time since tag on, seconds')
ylabel('Sensor value')

if nargout==1,
   h = hh ;
end
