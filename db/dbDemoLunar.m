function dbDemoLunar()

% handle to query manager, typically done once per session and reused
queries = dbInit();

% Example:  Somewhere in San Diego, CA:  32°42'52.9''N 117°09'21.6''W, 
lat = 32 + 42/60 + 52.9/3600;
long = 360 - (117 + 09/60 + 21.6/3600);
start = datenum('2011-01-01 00:00:00');  % local time
stop = datenum('2011-01-31 00:00:00');
utc = -8;  % San Diego Pacific Standard Time (UTC-8)
everyN_m = 30;
illu = dbGetLunarIllumination(queries, lat, long, start, stop, ...
    everyN_m, 'UTCOffset', utc);

figure('Name', 'Lunar illumination');
illu_h = plot(illu(:,1), illu(:,2), '.');
set(gca, 'XTick', illu(1,1):7:illu(end,1));  % tick every week
% First three letters of month, two digits on date axis
datetick('x', 'mmmdd', 'keeplimits', 'keepticks');  
xlabel('Date')
ylabel('Illumination %')

% Use custom datatip that display date rather than datenum
dcm = datacursormode(gcf);
set(dcm, 'UpdateFcn', @show_datetime);

1;

function display = show_datetime(~, event)
% display = show_datetime(~, event)
% Customize datatip so that the time and date shows instead of a datenum

pos = get(event, 'Position');
display{1} = datestr(pos(1));
display{2} = sprintf('illumination %.0f%%', pos(2));
