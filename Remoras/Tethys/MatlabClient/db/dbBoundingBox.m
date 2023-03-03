function [lat_low,lat_up,lon_lt,lon_rt] = dbBoundingBox(nwse)
%Helper function which creates a XQuery criteria for bounding box
%selection.
% It is assumed that the bounding box specification contains two
% rows of longitude, latitude.  The first row specifies
% the NW corner, the second row the SE.
%
% Returns a set of criteria that can be used to identify
% points as being in or out of the bounding box.

nw = nwse(1,:);
se = nwse(2,:);

if nw(2) < se(2)
    error('Northern latitude is south of southern');
end

% Longitude is circular, determine if we need to wrap
if nw(1) < se(1)
    lat_low = {'>=', nw(1)};
    lat_high = {'<=', se(1)};
    conj = 'and';
else
    % latitude wraps around 0
    lat_low = {'<=', se(1)};
    lat_high = {'>=', nw(1)};

lats = sort(lats);
longs = sort(longs);

lat_low={'>=',lats(1)};
lat_up={'<=',lats(2)};

lon_lt={'>=',longs(1)};
lon_rt={'<=',longs(2)};