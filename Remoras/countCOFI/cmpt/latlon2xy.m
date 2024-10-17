function [x,y] = latlon2xy(dlat,dlon,dlat0,dlon0)
%
% [x,y] = latlon2xy(dlat,dlon,dlat0,dlon0)
%
% calculate xy distances in meters from Earth coordinates in decimal
% degrees
%
% latlon2xy.m spin off of earlier mkcoords.m
% 
% smw 3 Feb, 2004
%

% calc average lat/lon
alat = mean(dlat);
alon = mean(dlon);

rlat = alat * pi/180;
% Ref: American Practical Naviagator, Bowditch 1958, table 6 (explanation)
% page 1187
m = 111132.09 - 566.05 * cos(2*rlat) + 1.2 * cos(4*rlat) - 0.003 * cos(6*rlat);
p = 111415.10 * cos(rlat) - 94.55 * cos(3*rlat) - 0.12 * cos(5*rlat);

% convert from decimal degrees to meters from 0,0
x = (dlon - dlon0) .* p;
y = (dlat - dlat0) .* m;
