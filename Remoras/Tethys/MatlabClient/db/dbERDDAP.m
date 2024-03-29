function result = dbERDDAP(queryH, Query, squeezeP)
% result = dbERDDAP(queryH, Query, squeezeP)
% Return the results of an ERDDAP query.  
% ERDDAP returns data as either a table or grid.  Some
% grids have singleton dimensions.  Setting the optional squeezeP
% will remove any singleton dimensions for grid data and has no
% effect on table data.
%
% Query is a string that specifies the ERDDAP data to retrieve and is
% data set dependent.   As an example, the 1-day composite for sea
% surface temperature, erdGAssta1day (see 
% https://coastwatch.pfeg.noaa.gov/erddap/griddap/erdGAssta1day.html)
% is a grid with 4 dimensions:
%   time, altitude, latitude, longitude
% When specifying the search, the Query string has the format:
%   data_set_name?variable[span1][span2][...][spanN]
% where 
%   variable is the name of the variable that we wish to return
%   span_i is a data range over each of the variables.
%       All spans have three colon separate values:   
%              [start:step:end]
%
%       Span starts and ends are indices into the grid, but this is
%       rarely convenient.  Starts and ends can be specified in the 
%       unit of the data set axes by placing values in ( ), e.g.:
%           sst observations between July 24 2009 and September 16, 2009
%           sst[(2009-07-24T00:00:00Z):1:(2009-09-16T00:00:00Z)]
%       Note that the units must be in the same format as ERDDAP.
%       Note that both Tethys and ERDDAP use ISO8601 for time
%       YYYY-MM-DDTHH:MM:SSZ where Z means UTC (function
%       dbSerialToISO8601 will convert Matlab serial date numbers to
%       ISO8601).  Longitude is always expressed in degrees east, but
%       read the documentation for the data set to determine the interval.
%       It may be in the range [-179, 180) in which case you will need
%       to convert longitudes that are stored in Tethys's [0, 360).
%
%       Sometimes, a variable only has a single value, such as elevation in 
%       a sea surface temperature plot.  These axes can be represented as
%       a span with the same start/end value: [(0.0):1:(0.0)] or [0:1:0].
%
% A complete query string for the sea surface temperature data might
% look like the following:
% 'erdGAssta1day?sst[(2009-07-24T00:00:00Z):1:(2009-09-16T00:00:00Z)][(0.0):1:(0.0)][(32.559):1:(32.759)][(240.423):1:(240.623)]'
%
% result is a structure with the following structure:
%
% For grids ------------------------------------------------------------
%   dims - Vector of grid dimensions
%   Axes - Structure with information about the axes, fields:
%       names - Cell array with axis names
%       units - Cell array of units associated with type
%       types - Cell array of data type of axis values:  
%               datenum, String, numeric type
%               Note that numeric types are stored as doubles in Matlab,
%               but their original precision (e.g. float, double, int)
%               can be determined from this field.
%       values - Cell array of grid axis labels
%   Data - Structure with grid data
%       names - Cell array with data variable names
%       units - Cell array with data units
%       types - Cell array of data types:
%               datenum, String, double
%       values - Cell array of data values.
%           Each cell entry is one variable
%
% Grid example:
% r = dbERDDAP(q, 'erdGAssta1day?sst[(2009-07-24T00:00:00Z):1:(2009-09-16T00:00:00Z)][(0.0):1:(0.0)][(32.559):1:(32.759)][(240.423):1:(240.623)]');
%
% r.Axes.names:  'time'    'altitude'    'latitude'    'longitude'
% r.Axes.units:  'UTC'    'm'    'degrees_north'    'degrees_east'
% r.Axes.types:  'datenum'    'double'    'double'    'double'
% r.Axes.values{1} contains datenums indicating the sampling points on the 
%   time axis, r.Axes.units{3} contains latitudes, etc.
% r.Data.names:  'sst'
% r.Data.units:  'degree_C'
% r.Data.types:  'float'
% r.Data.values{1} contains sea surface temperature (SST) measurements
% 
% If mulitple varaibles were requested (not possible with this specific
% dataset), then r.Data.values would contain additional cells.
%
% Removing singleton axes (squeeze predicate)
% Note that the altitude is constant as the altitude of the sea surface
% is always zero, making for r.Data.values matrices that have a only
% one value along the altitude axis.  (In this example, a 55 x 1 x 5 x 5
% matrix).  To remove the singleton axis, set the optional squeeze predicate
% (squeezeP) to true.
% 
% The query format
% Squeeze exmaple:
% r = dbERDDAP(q, 'erdGAssta1day?sst[(2009-07-24T00:00:00Z):1:(2009-09-16T00:00:00Z)][(0.0):1:(0.0)][(32.559):1:(32.759)][(240.423):1:(240.623)]', true);
% 
% Ouput will be similar, the Axes and Data fields will have the same
% structure except elements that contain only a single value will be 
% removed.  Hence, in this example, altitude will be removed and 
% results.Data.values{1} will be 55 x 5 x 5 instead of 55 x 1 x 5 x 5.
%
% A new constants field shows the singleton axes that were "squeezed" out.
% r.Constants:
%     names: {'altitude'}
%     units: {'m'}
%     types: {'double'}
%    values: {[0]}
%
% for Tables ------------------------------------------------------------
%   rows - Number of rows in table
%   Columns - Structure containing information about each table
%       names - Cell array of column names
%       types - Cell array of column types
%               datenum, String, numeric type
%               Note that numeric types are stored as doubles in Matlab,
%               but their original precision (e.g. float, double, int)
%               can be determined from this field.
%       units - Cell array of units of measure if applicable ([] if not)
%   Data
%       fields corresponding to the names.  Each field is a cell array
%       or vector depending upon its data type.
%
% Example:
% r = dbERDDAP(q, 'erdCalcofiBio?line_station,line,station,longitude,latitude,depth,time,occupy,obsCommon,obsScientific,obsValue,obsUnits&time>=2004-11-12T00:00:00Z&time<=2004-11-19T08:32:00Z');
% r
%       Columns: [1x1 struct]
%       Data: [1x1 struct]
%       rows: 296
% r.Columns.names'
%    'line_station' 'line' 'station' 'longitude' 'latitude' 'depth' 
%    'time' 'occupy' 'obsCommon' 'obsScientific' 'obsValue' 'obsUnits'
%     7
% datestr(r.Data.time)  OR using a technique that can be applied to loops
%       fieldname = 'time';
%       datestr(r.Data.(fieldname))  % .(variable) use contents as name
% returns
%   18-Nov-2004 11:57:00
%   18-Nov-2004 11:57:00
%   18-Nov-2004 11:57:00
%   ...

debug = false;

xQuery = sprintf('collection("ext:erddap")/%s!', Query);

dom = queryH.QueryReturnDoc(xQuery);

if nargin < 3
    squeezeP = false;
end

% Determine data type
types = {
    'Table', @(x) dbGetTableDap(x)
    'Grid', @(x) dbGetGridDap(x, squeezeP)
    };
found = false;
idx = 1;
while ~ found && idx <= size(types, 1)
    node = dbXPathDomQuery(dom, types{idx, 1});
    found = node.getLength() == 1;
    if found
        result = types{idx, 2}(dom);  % process
    else
        idx = idx + 1;
    end
end

if ~ found || debug
    text = dbDom2XML(dom);
    if debug
        debugH = fopen('queryresults.xml', 'w');
        fwrite(debugH, xQuery);
        fwrite(debugH, '\n');
        fwrite(debugH, char(queryH.xmlpp(text)));
        fwrite(debugH, '\n');
        fclose(debugH);
    end
    if ~ found
        error('Unable to parse\n%s', text);
    end
end

