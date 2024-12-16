function [ gpsTrack ] = plotCountCofiTrackWithEffort_200121(GPScsv,type,effFile,oDir)
% 
% Takes ship GPS track, and effort file ( containing GPS/effort info ) and
% calculates on effort distances/times.  
%
% Code checks for number of GPS positions for on effort segments in visual
% log data and underway data.  Uses dataset with most points for distance
% calculations
%
% Distances are measured using great circles ( better would be using
% bowditch method ) 
%
% This function requires two file inputs
%
% GPScsv ( .csv file )
%             col1 = UTC date string 
%             col2 = Latitude ( decimal degree )
%             col3 = Longitude ( decimal degree )
% 
% type - indicates effort file type ( 0 = no effort 
%                                     1 = count cofi 
%                                     2 = acoustic
%                                     
%               
% effFile - full file name to effort file ( countCofi/Acoustic effort )
%       count cofi = combined file containing daily expanded file data
%       acoustic = csv, col1 = UTC date string, col2 = lat, col3 = lon 
%                       col4 = deployment name col5 = event type
%
% oDir = output directory for plots
% 
% output 
%       GPS Track variable argument: struct with 3 fields
%           datetimes = UTC datenumber
%           lats = Latitude ( decimal degree )
%           lons = Longitude ( decimal degree )
%
% 200121 BJT 
% % Bruce J. Thayre (bthayre@ucsd.edu)

% Only process southern transects, STransects = 1
% process all transects, STransects = 0
STransects = 0;

% plot cal cofi transects/stations plotTransects = 1
% plot cruise data only, plotTransects = 0
plotTransects = 1;


% read in GPS Track

fid1 = fopen(GPScsv,'r');
GPSData = textscan(fid1,'%s %f %f','Delimiter',',','CollectOutput',1);
fclose(fid1);

gmt = datenum(GPSData{1});

pos = GPSData{2};
latdd = pos(:,1);
londd = pos(:,2);

% make sure gpsTrack is increasing...assuming it's sorted..and we
% passed it in...haven't added to the default behavior
bidxs = find(diff(gmt) < 0)+1;
gmt(bidxs) = [];
latdd(bidxs) = [];
londd(bidxs) = [];
fprintf('Found %d non-increasing entries in GpsTrack!!\n', length(bidxs));
        
% Check for nonsense points
bidxs2 = unique( [ find(isnan(gmt)); ...
    find(isnan(latdd)); ...
    find(isnan(londd)); ]);
fprintf('Found %d bad points in GPS track\n', length(bidxs2))
gmt(bidxs2) = []; 
latdd(bidxs2) = []; 
londd(bidxs2) =[]; 

% constants
mnum2secs = 24*60*60;
sTh = 5*60; % threshold for matching time in GPS track

if type == 1 % count cofi file  
    
    A = '%s '; % read all columns as strings
    expFormatSpec =strtrim(repmat(A,1,60)); % this is the expanded data
    
    ffn = effFile;
    fid2 = fopen(ffn,'r');
    expData = textscan(fid2,expFormatSpec,'Delimiter',',','CollectOutput',1);
    fclose(fid2);

    expData = [ expData{:} ]; % flatten cell
    % remove white space padding...shows up in data that had
    % formatting/expansion problems
    % will mess up comments...hopefully nothing else
    expData = strip(expData);
    
    %save header info and remove header rows
    hdrIdxs = find(strcmpi(strip(expData(:,1)),'EID'));
    hdr = expData(hdrIdxs(1),:);
    expData(hdrIdxs,:) = [];

    % find column index for data we want
    hdr = strip(hdr); % remove white space padding...normally not an issue
    evCol = find(strcmpi(hdr,'ev')); % even column 
    effCol = find(strcmpi(hdr,'eff')); % effort column
    latCol = find(strcmpi(hdr,'y')); % lat column
    lonCol = find(strcmpi(hdr,'x')); % lon column
    dtCol =  find(strcmpi(hdr,'when'));% date/time column
    
    fprintf('Input file %s\n', ffn);
    fprintf('\t%d events\n', size(expData,1));
    
    %positions from effort file
    effCode = strip(expData(:,effCol));
    effLat = str2double(expData(:,latCol)); 
    effLon = str2double(expData(:,lonCol));
    % Need to make local times GMT
    effTimes = datetime(expData(:,dtCol),'TimeZone','America/Los_Angeles');
    % look for bad times and remove from data
    effLat(isnat(effTimes)) = [];
    effLon(isnat(effTimes)) = [];
    effCode(isnat(effTimes)) = [];
    effTimes(isnat(effTimes)) = [];
    % change timezone to GMT and save as datenum ( what code expects )
    effTimes.TimeZone = 'UTC';
    effGMT = datenum(effTimes);
    % boolean event effort = ON
    effortBin = strcmpi(effCode,'0');
    fprintf('\t%d on effort events\n', length(find(effortBin)));
    1;
    
    %for plot formatting
    eclr = 'b';
    els = '-';
    uwclr = 'r';
    uwls = '-';
    
elseif type == 2 % acoustic effort file ( made from PAMguard database )
    
    % files made from acoustic effort database from each trip
    % should be csv file with format:
    %       UTC datetime string, Decimal degree latitude, decimal degree
    %       longitude, deployment name, event type
    %
    % event types:
    %   S = sonobuoy deployment
    %   A = deploy array
    %   XA = recover array
    expFormatSpec = '%s %f %f %s %s';
    ffn = effFile;
    fid2 = fopen(ffn,'r');
    expData = textscan(fid2,expFormatSpec,...
        'Delimiter',',',...
        'CollectOutput',1,...
        'HeaderLines',1);
    fclose(fid2);
    
    effGMT = strip(expData{1});
    effGMT = datenum(effGMT);
    effPos = expData{2};
    effLat = effPos(:,1);
    effLon = effPos(:,2);
    effEvents = expData{3};
    effName = strip(effEvents(:,1));
    effCode = strip(effEvents(:,2));
    
    XAi = strcmpi(effCode,'XA');
    fprintf('\t%d Array deployments\n',sum(XAi));
    
    % seperate sonobuoy events
    sbi = find(strcmpi(effCode,'S'));
    fprintf('\t%d Sonobuoy deployments\n',length(sbi));
    if ~isempty(sbi)
        sbGMT = effGMT(sbi);
        sbLat = effLat(sbi);
        sbLon = effLon(sbi);
        sbName = effName(sbi);
        
        effGMT(sbi) = [];
        effLat(sbi) = [];
        effLon(sbi) = [];
        effName(sbi) = [];
        effCode(sbi) = []; 
    end
    
    % boolean event effort = ON
    effortBin = strcmpi(effCode,'A');
    fprintf('\t%d on effort events\n', length(find(effortBin)));
    
    % for plot formatting
    eclr = 'b';
    els = '-';
    uwclr = 'k';
    uwls = ':';
    1;
end


% fprintf('Using threshold of %d seconds for matching GPS positions!\n', sTh);

h=figure(3001);
clf

m_proj('Miller Cylindrical','lat',[29.3 38.5],'lon',[-127.25 -116],'aspect'); % sets lat/lon bounds of map and projection type
%m_tbase('contourf');                                       %add contour
%m_gshhs_i('color','k');  % plots coastline with white land
m_gshhs_h('patch',[.5 .5 .5]);   %plots coastline with gray land
m_grid('box','fancy','tickdir','out'); % plots grid overlay 

% m_track(londd, latdd, gmt,'color','r'); % plot trackline with timestamps
m_track(londd, latdd,'LineWidth',2,'color',uwclr,'LineStyle',uwls); % plot trackline without timestamps
hold on

% numEl = size(effortBin,1);
numEl = length(effGMT);
vtc = 1;
x = find(effortBin,1,'first');
effTransect = [];   % on effort visual transects
                    % col1 = start time, col2 = end time, col3 = distance
diffE = diff(effortBin); % 
fprintf('Time threshold for matching GPS positions: %d seconds\n', sTh);
% fprintf('Visual observation, ON EFFORT periods:\n')
while x <= numEl
%     xn = x+find(diffE(x:end),1,'first')-1; % find next change in
%     effort...seems to work with on effort periods that last more than one
%     event 

% I like this version better 01/22/2020
      xn = x+find(diffE(x:end),1,'first'); % find next change in
%       effort...gives different visEffort results for 2019-02/04/07 than
%       above line...seems to be when a day ends "ON" effort
% 

    if isempty(xn)
        break; 
    end
    
    % for debugging
    %arrayfun(@(x,y) fprintf('%d - %s\n',x,datestr(x2mdate(y),'mm/dd/yy HH:MM:SS')), effortBin(2:70), cell2mat(vraw(2:70,gmtCol)));
    % end debugging
    d0 = effGMT(x);
    dn = effGMT(xn);
    et_idx = x:xn;
    
    % underway data indices for current on effort segment
    gps0 = find(gmt>=d0,1,'first');
    gpsn = find(gmt<=dn,1,'last');

   
    % use underway data if there are more points to work with 
    if (gpsn-gps0) > (xn-x)  
        if isempty(gps0) || isempty(gpsn)
            fprintf('\tCould not match following on-effort segment to GPS track\n');
            fprintf('\tUsing Effort log positions\n');
            eSegLats = effLat(x:xn);
            eSegLons = effLon(x:xn);
        elseif abs(d0-gmt(gps0))*mnum2secs > sTh || ...
                abs(dn-gmt(gpsn))*mnum2secs > sTh
            fprintf('\tCould not match following on-effort segment to GPS track within %.2f minutes\n', sTh/60);
            fprintf('\tUsing Effort log positions\n');
            eSegLats = effLat(x:xn);
            eSegLons = effLon(x:xn);
        else
            eSegLats = latdd(gps0:gpsn);
            eSegLons = londd(gps0:gpsn);
        end
        dsrc = 'Underway GPS';
    else
            eSegLats = effLat(x:xn);
            eSegLons = effLon(x:xn);
            dsrc = 'Effort Log';
    end
    % get distance of on effort segments
    segD = zeros(length(eSegLats)-1,1);
%     if vtc == 7
%         1;
%     end
    

    if STransects % only include southern 6 CC transects
        % station info for line 76.7...don't include anything after this
        % station #, lat, lon 
        STLim = [
            100.0,33.38824,-124.32289;
            90.0,33.72158,-123.63335;
            80.0,34.05491,-122.94109;
            70.0,34.38824,-122.24608;
            60.0,34.72158,-121.54828;
            55.0,34.88824,-121.19831;
            51.0,35.02158,-120.91782;
            49.0,35.08824,-120.77740;
            ];
        
        % judge by first position in on-effort segment
        pos = [ eSegLats(1), eSegLons(1) ]; 
        
        % fudge factor to allow for trip loitering around station
        ff = 0.1; % degrees
        
        % check if position NW of any of the 76.7 stations 
        NWb = arrayfun(@(x,y) pos(1) > x && pos(2) < y, STLim(:,2)+ff, STLim(:,3)+ff);
        if any(NWb)
            fprintf('skipping on-effort segment past line 76.7 (%s)\n',...
                 datestr(d0,'mm/dd/yyyy HH:MM:SS'));
              % skip to next on effort segment
             x = find(effortBin(xn+1:end),1,'first')+xn;
             vtc = vtc+1;
            continue;
        end
                
        1;
    end
    

    for y = 2:length(segD)
        
        if 0 % great cirsize eScle method
            d = distance('gc',eSegLats(y-1), eSegLons(y-1), ...
                            eSegLats(y), eSegLons(y));
            if isnan(d)
                fprintf('\t%s - %s segment missing position info, setting distance for this segment to zero\n', ...
                    datestr(effGMT(x) ,'mm/dd/yy HH:MM'),...
                    datestr(effGMT(xn) ,'mm/dd/yy HH:MM'));
                segD(y-1) = 0;
            else        
                segD(y-1) = distdim(d, 'deg', 'km');
            end
        else % bowditch method
            [xc,yc] = latlon2xy(eSegLats(y-1), eSegLons(y-1),...
                eSegLats(y), eSegLons(y));
            d_m = sqrt(xc^2+yc^2); % distance in meters
            segD(y-1) = d_m/1e3; % distance in kilometers
        end
        
    end
    tranD = sum(segD);
    
    fprintf('%s - %s => %.2f km ( %s )\n', datestr(d0,'mm/dd/yyyy HH:MM:SS'), ...
        datestr(dn,'mm/dd/yyyy HH:MM:SS'), tranD,dsrc);
    m_track(eSegLons,eSegLats,'LineWidth',2,'color',eclr,'LineStyle',els); % plot trackline without timestamps
%     if vtc ==28
%         1;
%     end 
    effTransect(vtc,1) = d0;
    effTransect(vtc,2) = dn;
    effTransect(vtc,3) = tranD;
    
%     x = find(effortBin(xn:end),1,'first')+xn-1; % commented out
%     12/02/2019
     x = find(effortBin(xn+1:end),1,'first')+xn;
    vtc = vtc+1;    
end
    
    

if plotTransects

    csv_file = 'CalCOFIStaPosNDepth113.csv'; 
    csv_data = csvread(csv_file,1,0);
    % lons need to be negative
    csv_data(:,5) = csv_data(:,5) .* -1;
    CCTransects = struct;

    line_nums = unique(csv_data(:,2));
    for ccline = 1:length(line_nums)
        line_idxs = find(csv_data(:,2)== line_nums(ccline));
        CCTransects(ccline).name = line_nums(ccline);
        CCTransects(ccline).lats = csv_data(line_idxs,4);
        CCTransects(ccline).lons = csv_data(line_idxs,5);
        % plot CalCofi stations (linestyle controls marker type)
        m_line(CCTransects(ccline).lons, CCTransects(ccline).lats,'LineWidth', 2, 'Color', 'k','Marker','o','LineStyle','none'); 
    end

end

if 1
    if type==1
        % for debugging w/ countCofi data
        % plot marker where new local day starts ( i.e. midnight local time )
        shipTime = datetime(gmt,'TimeZone','UTC','ConvertFrom','datenum');
        shipTime.TimeZone = 'America/Los_Angeles';
        % for debugging
        
        cdays = unique(floor(datenum(shipTime)));
        for d=2:length(cdays)
            if d == 19
                1;
            end
            di = find(shipTime.Day==day(cdays(d)) & shipTime.Month==month(cdays(d)));
            di = di(1);
            if shipTime.Hour(di) > 0
                fprintf('\tMissing GPS data for midnight %s...not plotting\n', datestr(cdays(d)));
                continue
            else
                m_line(londd(di),latdd(di),'marker','square','color','k','linewi',2);
            end
        end
        
        % plot markers where effort updates happen
        % on effort updates
        oneffi = find( strcmpi(expData(:,effCol),'0') & strcmpi(expData(:,evCol),'EFF'));
        m_line(str2double(expData(oneffi,lonCol)),str2double(expData(oneffi,latCol)), ...
            'marker','o','linewi',2,'Color','b','LineStyle', 'none' );
        % off effort updates
        noeffi = find( ~strcmpi(expData(:,effCol),'0') & strcmpi(expData(:,evCol),'EFF'));
        m_line(str2double(expData(noeffi,lonCol)),str2double(expData(noeffi,latCol)), ...
            'marker','o','linewi',2,'Color','r','LineStyle', 'none' );
        %          m_range_ring(str2double(onEffData(:,lonCol)),str2double(onEffData(:,latCol)),2);
        
        % positions won't match plotted track perfectly if underway data
        % used for plotting effort track
        
        1;
    elseif type == 2
        % check if sonobuoy deployments found
        if exist('sbGMT','var')
            for sb=1:length(sbi)
                if isnan(sbLon(sb)) || isnan(sbLat(sb))
                    sbdt = abs(sbGMT(sb)-gmt);
                    minti = find(sbdt==min(sbdt),1,'first');
                    sbLon(sb) = londd(minti);
                    sbLat(sb) = latdd(minti);
                    if sbdt(minti)*mnum2secs > sTh
                        fprintf('Couldn''t find %s deployment position!!  EXIT!\n', sbName{sb});
                        return
                    end
                end
                
                % plot sonobuoy markers
                m_line(sbLon, sbLat,'marker','o','markersize',10,...
                    'color','r','MarkerFaceColor','r','LineStyle','none');
            end
        end
    end
end

[ p, f, e ] = fileparts(effFile);
% try matching cruise number with format YYYYMM
cstr = regexp(f,'\d{6}','match');
if isempty(cstr)
   % try matching cruise number with format YYYY-MM
   cstr = regexp( f,'\d{4}-\d{2}','match');
   if isempty(cstr) 
       fprintf('Cant match cruise number, effort filename format should include year/month as format YYYYMM or YYYY-MM\n');
       return
   else
       cnum = cstr{1};
   end
else
    cstr = cstr{1};
    cnum = sprintf('%s-%s',cstr(1:4),cstr(5:6));
end


% plot line numbers
m_text(-124.217,29.509,'93.3','FontSize',9,'FontWeight','bold','Rotation',33);  %Line 93.3  %-123.8,29.95
m_text(-124.472,30.222,'90','FontSize',9,'FontWeight','bold','Rotation',33);  %Line 90     %-124.2,30.5
m_text(-124.311,31.062,'86.7','FontSize',9,'FontWeight','bold','Rotation',33);  %Line 86.7  %-124,31.39
m_text(-124.776,31.632,'83.3','FontSize',9,'FontWeight','bold','Rotation',33);  %Line 83.3   %-124.4,32
m_text(-124.386,32.604,'80','FontSize',9,'FontWeight','bold','Rotation',33);  %Line 80    %-124.1,32.95
m_text(-124.952,33.115,'76.7','FontSize',9,'FontWeight','bold','Rotation',33);  %Line 76.7 %-124.5,33.5
m_text(-125.332,33.682,'73.3','FontSize',9,'FontWeight','bold','Rotation',33);  %Line 73.3
m_text(-125.680,34.328,'70','FontSize',9,'FontWeight','bold','Rotation',33);  %Line 70
m_text(-126.162,34.863,'66.7','FontSize',9,'FontWeight','bold','Rotation',33);  %Line 66.7
m_text(-126.632,35.424,'63.3','FontSize',9,'FontWeight','bold','Rotation',33);  %Line 63.3
m_text(-126.951,36.064,'60','FontSize',9,'FontWeight','bold','Rotation',33);  %Line 60

% add some text
m_text(-119.236,30.719,(cnum),'FontSize',22,'FontWeight','bold');  %title line 1
if type == 1
    m_text(-120.065,30.195,('Visual Effort'),'FontSize',22,'FontWeight','bold');  %title line 2
elseif type == 2 
    m_text(-120.065,30.195,('Acoustic Effort'),'FontSize',22,'FontWeight','bold');  %title line 2
end
m_text(-117.1625,32.7150,('San Diego'),'FontSize',10,'FontWeight','bold','VerticalAlignment','bottom');  %San Diego label
m_line(-117.1625,32.7150,'Marker','.','MarkerSize',12,'Color','k'); %San Diego point
m_text(-120.374,34.522,('Point Conception'),'FontSize',10,'FontWeight','bold','VerticalAlignment','bottom');  %Pt Conception label
m_line(-120.4714,34.4481,'Marker','.','MarkerSize',12,'Color','k'); %Pt Conception point
m_text(-118.1937,33.7701,('Long Beach'),'FontSize',10,'FontWeight','bold','VerticalAlignment','bottom');  %Long Beach label
m_line(-118.1937,33.7701,'Marker','.','MarkerSize',12,'Color','k'); %Long Beach point
m_text(-121.759,36.571,('Monterey'),'FontSize',10,'FontWeight','bold','VerticalAlignment','bottom');  %Monterey label
m_line(-121.895,36.600,'Marker','.','MarkerSize',12,'Color','k'); %Montery point    
m_text(-122.243,37.775,('San Francisco'),'FontSize',10,'FontWeight','bold','VerticalAlignment','bottom');  %San Francisco label
m_line(-122.419,37.779,'Marker','.','MarkerSize',12,'Color','k'); %San Francisco point 

set(h,'Position',[ 50 50 900 900 ] );
set(h,'PaperOrientation','landscape');

if ~isempty(oDir) % enable this and update odir to save output plots
%     odir = 'K:\Projects\CalCofi\Summaries\191205\';
%     odir = 'K:\Projects\CalCofi\Reports\2019-12\AcousticEffort\plots';
%     odir = 'K:\Projects\CalCofi\Reports\2019-12\VisualEffort\AllTransects';
    title(cnum,'FontSize',14);
    fno{1} = fullfile(oDir,sprintf('%s.fig',cnum));
    fno{2} = fullfile(oDir,sprintf('%s.png',cnum));
    fno{3} = fullfile(oDir,sprintf('%s.eps',cnum));
    savefig(h,fno{1});
    print(h,'-dpng','-r600',fno{2})
    saveas(h,fno{3},'epsc')
end
% [ p,f,n ] = fileparts(visLog);
% cnum = regexp(f,'\d{4}-\d{2}','match');
% if isempty(cnum)
%     cnum = datestr(gmt(1),'yyyy-mm');
% else
%     cnum = cnum{1};
% end
% 
% titlestr = sprintf('%s\nBlue = On Effort',cnum);
% title(titlestr,'FontSize',14);

if ~isempty(gmt)
    gpsTime = gmt(end) - gmt(1);
else
    gpsTime = 0;
end

if isempty(effTransect)
    onEffortTime = 0; 
    totD = 0;
else
    onEffortTime = sum(effTransect(:,2) - effTransect(:,1));
    totD = sum(effTransect(:,3));
end

fprintf('\n\n');
if ~isempty(gmt)
    fprintf('Cruise Dates: %s - %s\n', datestr(gmt(1),'mm/dd/yyyy'), datestr(gmt(end),'mm/dd/yyyy'));
end
% fprintf('Duration of GPS track = %.2f hours\n', gpsTime*24);
fprintf('Duration of on effort track = %.2f hours\n', onEffortTime*24);
fprintf('Distance of on effort track = %.2f km\n', totD);

gpsTrack.gpsTime = gpsTime;
gpsTrack.onEffortTime = onEffortTime;
gpsTrack.totD = totD;

% disp('!');

