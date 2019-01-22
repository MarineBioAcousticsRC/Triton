function url = dbERDDAPSearch(queryH, SearchParams, Open)
% url = dbERDDAPSearch(queryH, SearchParams, Open)
% Search NOAA's Environmental Research Division Data Access Program
% (ERDDAP) catalog for datasets matching desired parameters.
% SearchParams arguments are any valid set of ERDDAP keywords.  Each
% keyword is followed by an = sign with a search value.  Multiple keywords
% are joined by &.
% queryH is the qeury handler, see dbInit()
%
% If the optional Open argument (default true) is true, a web browser
% will display the search results.  The return value url is the url that
% is returned.
%
% ERDDAP's web services discussion gives a couple of examples and contains
% a pointer to a GUI which will let people observe all settable parameters:
% http://coastwatch.pfeg.noaa.gov/erddap/rest.html
%         
% Search parameters as of this writing:
%         searchFor - search terms separated by +, e.g. night+modis
%         protocol
%         cdm_data_type
%         institution
%         ioos_category
%         long_name
%         standard_name
%         minLat  - Latitude is in degrees North
%         maxLat
%         minLon  - Longitude is in degrees East
%         MaxLon
%         minTime - Time is in the ISO 8601:2004 format
%         maxTime   e.g. 2012-01-01T18:34:22Z
%         
%
% Examples:
% dbERDDAPSearch(queryH, 'ioos_category=ice_distribution')
%
% dbERDDAPSearch(queries, 'keywords=sea_surface_temperature&minLat=33.47&maxLat=33.56&minLon=240.71&maxLon=240.80')


if nargin < 3
    Open = true;  % default if omitted
    if nargin < 2
        SearchParams = '';
    end
end

dom = queryH.QueryReturnDoc(sprintf('collection("ext:erddap_search")/%s!', ...
    SearchParams));

[dontcare, url] = dbXPathDomQuery(dom, 'url');
if iscell(url)
    url = url{1};
end
if Open
    web(url, '-browser');
end

