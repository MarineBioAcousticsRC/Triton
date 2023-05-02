function visWeeklyCall(queryEng, varargin)


%SEAN WEEKLY3 for CALL plots
%based on plotpres_abs_min.m by MRoch - ed by KEF 20110114
%  read in .xls file produced by logger (low, mid, hi)
%  and produce presence/absence grid plot per species

path = 'C:\Users\seano\Documents\RachelDolphins\output\';
save=0;%default do not save

dbSpeciesFmt('Input','Abbrev','NOAA.NMFS.v1');%temp

%%%%%%%%%%%%%%%%%%%%%%%%%%SET UP VARIABLES%%%%%%%%%%%%%%%%%%%%%%%%%

vidx=1;
site_array={};
deployment_array={};
spp_array = {};
call_array = {};
call = '';

%input counts
site_count = 0;
depl_count = 0;
call_count = 0;
spp_count = 0;

req_input = 0; %totals up required arguments, verifys total afterwards
%project,site,deployment,species
while vidx <= length(varargin)
    switch varargin{vidx}
        case 'Project'
            project = varargin{vidx+1};
            req_input = req_input+1;
            vidx = vidx+2;
        case 'Site'
            if iscell(varargin{vidx+1})
                site_array = varargin{vidx+1};
                site_count = length(site_array);
            else
                site_array = varargin(vidx+1);
                site_count = 1;
            end
            req_input = req_input+1;
            vidx = vidx+2;
        case 'Deployment'
            %tis a vector, actually
            deployment_array = sort(varargin{vidx+1});
            depl_count = length(deployment_array);
            req_input = req_input+1;
            vidx = vidx+2;
        case 'SpeciesID'
            if iscell(varargin{vidx+1})
                spp_array = varargin{vidx+1};
                spp_count = length(spp_array);
            else
                spp_array = varargin(vidx+1);
                spp_count = 1;
            end
            req_input = req_input+1;
            vidx = vidx+2;
        case 'Call'
            if iscell(varargin{vidx+1})
                call_cells = varargin{vidx+1};
                call_count = length(call_cells);
            else
                call_cells = {varargin(vidx+1)};
            end
            req_input = req_input+1;
            vidx = vidx+2;
        case 'Save'
            save = varargin{vidx+1};
            vidx =vidx+2;
        otherwise
            error('Bad arugment:  %s', varargin{idx});
            return;
    end
end

%If there is only once species, and multiple calls, put call cells into
%another cell for processing. Why must this be done? Because I am an
%amateur programmer.

if spp_count == 1 && call_count >=1
    call_cells = {call_cells};
end
    



%Make sure all four required inputs have been input
if ~(req_input==5)
    error('Missing an Argument: Project, Deployment, Site, SpeciesID');
end



%%%%CREATE DATA STRUCTURES FOR DETECTION QUERIES%%%%
%Each structure will be based on a spp, contained within larger struct
%called 'spp'. The structure will be broken down and passed to dbGetEffort
%as well as dbGetDetections.
%
%spp.ID = speciesID
%spp.Deployments = the deployments of interest
%spp.Calls = the calls of interest
%spp.
%Design flaw - nonexistent calls will still be queried for, e.g.
% ID = 'Oo', Call = 'Explosion'
%(though explosive Orcas are good to watch out for). As long as site
%project and deployments are entered, Performance will not suffer much (I
%hope)
%
%


%Preallocate structure with appropriate fields

info.detIdx = [];
info.spp(length(spp_array)) = struct('ID','');




%Grab effort from Tethys for each spp structure
%TODO--- these loops
quer_count = 0;
call_count = 0;
for spidx=1:spp_count
    info.spp(spidx).ID = spp_array{spidx};
    info.spp(spidx).Site(site_count)=struct('Name','');
    info.spp(spidx).Calls = struct('Name','','Subtype','');
    cidx = 1; %loop index
    call_counter = 1;%loop counter
    while cidx<=length(call_cells{spidx})
        switch call_cells{spidx}{cidx}
            case 'Subtype'
                info.spp(spidx).Calls(call_counter-1).Subtype = call_cells{spidx}{cidx+1};
                cidx = cidx+2;
            otherwise
                info.spp(spidx).Calls(call_counter).Name = call_cells{spidx}{cidx};
                cidx = cidx+1;
                call_counter = call_counter+1;
                call_count = call_count+1;
        end
               
    end
end

num_queries = site_count*depl_count*call_count; %crossproduct of possible queries based on input
num_plots = call_count * site_count;
plotIdx = 1; %keeps track of which plot data will be added to

info.spdatenums{num_queries} = [];
info.efforts{num_queries} = [];

queries(num_queries)=struct('Site','','Deployment',0,'SpeciesID','',...
    'Call','','DetCount',0);
plots(num_plots) = struct('Site','','Deployments',[],'SpeciesID','',...
    'Call','','Subtype','','Effort',[],'Detections',[],'days_of_data',...
    [],'hours_of_effort',[],'length_deployment',[],'cum_hrs',[]);

for spidx=1:spp_count
    for cidx=1:length(info.spp(spidx).Calls)
        for sidx=1:site_count
            info.spp(spidx).Site(sidx).Name = site_array{sidx};
            info.spp(spidx).Site(sidx).Deployment(depl_count) = struct('DeploymentID',0);
            fprintf('\n*** PLOT %d ***\n',plotIdx);
            plot_has_info = 0;%info flag for each plot
            for didx=1:depl_count
                %Pause half a second between each query
                subbed = 0; %flag - does this query include a subtype?
                all = 0; %flag - are we asking for all call types?
                info.spp(spidx).Site(sidx).Deployment(didx).DeploymentID = deployment_array(didx);
                quer_count = quer_count + 1;
                queries(quer_count).Site = info.spp(spidx).Site(sidx).Name;
                queries(quer_count).Deployment = info.spp(spidx).Site(sidx).Deployment(didx).DeploymentID;
                queries(quer_count).SpeciesID = info.spp(spidx).ID;
                queries(quer_count).Call = info.spp(spidx).Calls(cidx).Name;
                if ~isempty(info.spp(spidx).Calls(cidx).Subtype)
                    queries(quer_count).Subtype = ...
                        info.spp(spidx).Calls(cidx).Subtype;
                    subbed = 1; %set subtype flag
                end
                if strcmpi(queries(quer_count).Call,'all')
                    all = 1;
                end
                disp(datestr(now));
                fprintf('Query %d: %s%d%s - %s %s %s\n',quer_count,project,...
                    queries(quer_count).Deployment, queries(quer_count).Site,...
                    queries(quer_count).SpeciesID,queries(quer_count).Call,...
                    queries(quer_count).Subtype);
                if ~plot_has_info
                    plots(plotIdx).Site = queries(quer_count).Site;
                    plots(plotIdx).SpeciesID = queries(quer_count).SpeciesID;
                    plots(plotIdx).Call = queries(quer_count).Call;
                    if subbed
                        plots(plotIdx).Subtype = queries(quer_count).Subtype;
                    end
                    plot_has_info = 1;
                end
                
                %%%%%SORT OUT THE EFFORT FOR THIS SITE+DEPL+SP+CALL%%%
                iseff = 1;
                if subbed
                    info.efforts{quer_count} = ...
                        dbGetEffort(queryEng,'Project',project,'Site',...
                        queries(quer_count).Site,'Deployment',...
                        queries(quer_count).Deployment,'SpeciesID',...
                        queries(quer_count).SpeciesID,'Call',...
                        queries(quer_count).Call,'Subtype',...
                        queries(quer_count).Subtype,...
                        'Granularity','call');
                elseif all
                    info.efforts{quer_count} = ...
                        dbGetEffort(queryEng,'Project',project,'Site',...
                        queries(quer_count).Site,'Deployment',...
                        queries(quer_count).Deployment,'SpeciesID',...
                        queries(quer_count).SpeciesID,...
                        'Granularity','call');
                else
                    info.efforts{quer_count} = ...
                        dbGetEffort(queryEng,'Project',project,'Site',...
                        queries(quer_count).Site,'Deployment',...
                        queries(quer_count).Deployment,'SpeciesID',...
                        queries(quer_count).SpeciesID,'Call',...
                        queries(quer_count).Call,...
                        'Granularity','call');
                end
                
                %if ~isempty(info.efforts{quer_count})
                plots(plotIdx).Effort = [plots(plotIdx).Effort; info.efforts{quer_count}];
                %end
                [x,y] = size(info.efforts{quer_count});
                if x*y > 2
                    fprintf('Multiple Efforts Detected (short breaks will be truncated)\n')
                    for i =1:x
                        fprintf('Range %d: %s  to  %s\n',i,...
                            datestr(info.efforts{quer_count}(i,1)),...
                            datestr(info.efforts{quer_count}(i,2)));
                    end
                elseif x*1 ==1
                    fprintf('Effort Range: %s  to  %s\n\n', ...
                        datestr(info.efforts{quer_count}(1,1)),...
                        datestr(info.efforts{quer_count}(1,2)));
                elseif x*y == 0
                    fprintf('***No Effort Found for Query %d\n\n',quer_count);
                    iseff=0;
                end
                pause(0.5);
                
                %%%%GRAB DETECTIONS IF THERE WAS EFFORT%%%%
                if iseff
                    if subbed
                        queries(quer_count).Detections = ...
                            dbGetDetections(queryEng,'Project',project,'Site',...
                            queries(quer_count).Site,'Deployment',...
                            queries(quer_count).Deployment,...
                            'SpeciesID',queries(quer_count).SpeciesID,'Call',...
                            queries(quer_count).Call,'Subtype',...
                            queries(quer_count).Subtype);
                    elseif all
                        queries(quer_count).Detections = ...
                            dbGetDetections(queryEng,'Project',project,'Site',...
                            queries(quer_count).Site,'Deployment',...
                            queries(quer_count).Deployment,...
                            'SpeciesID',queries(quer_count).SpeciesID);
                    else
                        queries(quer_count).Detections = ...
                            dbGetDetections(queryEng,'Project',project,'Site',...
                            queries(quer_count).Site,'Deployment',...
                            queries(quer_count).Deployment,...
                            'SpeciesID',queries(quer_count).SpeciesID,'Call',...
                            queries(quer_count).Call);
                    end
                    
                    if isempty(queries(quer_count).Detections)
                        fprintf('***No Detections for query: %d\n\n',quer_count);
                    else
                        plots(plotIdx).Detections = [plots(plotIdx).Detections; queries(quer_count).Detections];
                        plots(plotIdx).Deployments = [plots(plotIdx).Deployments queries(quer_count).Deployment];
                    end
                    
                    queries(quer_count).DetCount =...
                        length(queries(quer_count).Detections);
                    %info.spp(spidx).Site(sidx).Deployment(didx).Call(cidx).datenumIdx = quer_count;%index of where to find this query within spdatenums
                    info.spdatenums{quer_count} = queries(quer_count).Detections; %store this query's detections in a higher lvl
                    pause(0.5);
                    
                end
            end
            %finished deployments for that site, next plot for next site
            plotIdx = plotIdx+1;
        end
    end
end


%organize into columns
info.spdatenums = info.spdatenums';
queries = queries';
info.efforts = info.efforts';
%%%Population finished. Index which queries we will plot%%
for i=1:length(info.spdatenums)
    if ~isempty(info.spdatenums{i})
        info.detIdx = [info.detIdx i];
    end
end
1;

%%%%%%%%%%%Combine data that shares SITE, SP, CALL


%%%%%DETERMINE START/STOP OF GRAPH BASED ON EFFORT RETURNED%%%%%
%
%To sort by month, need to convert from datenum to datevec, remove year,
%then back to datenum, and sort
%


startnums = [];%matrix of start datenums
startyrs = []; %matrix to hold effort years
startmos = []; %matrix to hold start months(yearless datenums)
startdays = []; %matrix to hold start days

endnums = [];%same as above for end times
endyrs = [];
endmos = [];
enddays = [];


for eidx = info.detIdx
    %populate matrix of start times
    %if you get index errors here, probably means effort start/end is
    %missing
    startnums = [startnums; info.efforts{eidx}(:,1)];
    endnums = [endnums; info.efforts{eidx}(:,2)];
end

%%%dono wat to use these for yet%%%
earliest_start = min(startnums);
latest_end = max(endnums);

startvecs = cell(size(startnums));%storage cell array of start vectors
endvecs = cell(size(endnums)); % should be same size as startvecs
for nidx=1:length(startnums)
    %%%get months of start
    startvecs{nidx} = datevec(startnums(nidx));%populate storage
    startyrs = [startyrs; startvecs{nidx}(1)]; % add the years before deleting
    startdays = [startdays; startvecs{nidx}(3)];%add the day
    startvecs{nidx}(1) = 0;%remove months (by setting year to 0)
    startvecs{nidx}(3) = 1;%revert to first of the month
    startmos = [startmos; datenum(startvecs{nidx})];
    
    %%%get months of year
    endvecs{nidx} = datevec(endnums(nidx));%populate storage
    endyrs = [endyrs; endvecs{nidx}(1)];
    enddays = [enddays; endvecs{nidx}(3)];
    endvecs{nidx}(1)=0;
    endvecs{nidx}(3)=1;
    endmos = [endmos; datenum(endvecs{nidx})];
    
end
startmos=floor(startmos);
%endmos = ceil(endmos);

%%%need to arrange properly%%%

startmo = floor(min(startmos));%get the start/end month+day
endmo = max(endmos);
endmo = addtodate(endmo,1,'month'); %add a month to the end
endyr = max(endyrs);
startyr = min(startyrs);

%template
%start = datenum([2011 12 7 0 0 0]);
start = datevec(startmo);
start(1) = startyr;
%xstart = datenum(start);
xstart = floor(earliest_start);


stop = datevec(endmo);
stop(1) = endyr;
%xstop = floor(datenum(stop));
xstop = ceil(latest_end);


%%%rearrange start/stop for proper year%%
startvec = datevec(xstart);
endvec = datevec(xstop);
startvec(3) = 1; % pad to first of the month
endvec(3) = eomday(endvec(1),endvec(2)); %pad until end of month




pstart= datenum(startvec);      %earliest date
pstop = datenum(endvec);     %latest date

dif = pstop-pstart;
weeks = ceil(dif/7);
days = weeks*7;
pstop = pstart + days +7;%add an extra week...

%Hardcode option for plot start/end times
%pstop = datenum([2013 08 31 0 0 0]);

fprintf('Plot Start: %s\n',datestr(pstart));
fprintf('Plot End: %s\n\n',datestr(pstop));





%%%%%%%
%if there is a start month > any end month, yearly plot will be used
%
%otherwise, the plot will begin at the earliest start month,
%and end at the latest end month.
%start = floor(earliest_start);
%stop = ceil(latest_end);

do_yr = find(startmos>endmos,1);
if ~isempty(do_yr)
    start = datenum([2011 1 1 0 0 0]);
    stop = datenum([2012 12 31 0 0 0]);
end

%y axis limits
minY = 0;
halfY = 0.2;
maxY = 0.4;

xstep_length = 1;
xstep_unit = 'month';

useOffEffortBars = 1;
useNormalizedData = 1;
offeffortcolor = [205 201 201]/255;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
shortened=false;
%%%THIS PART SHOULD GO INTO EffSpan%%%%%
for i=1:length(plots)
    


    current = plots(i).Effort;
    if ~isempty(current)
        current = sortrows(current,1);
        total = size(current,1);
        for j = total-1:-1:1
            f1 = current(j,1);
            f2 = current(j+1,1);
            s1 = current(j,2);
            s2 = current(j+1,2);
            isOverlap = (f2 <= s1 + 0.0375);
            if isOverlap
                if s1 < s2
                    current(j,2) = current(j+1,2);
                end
                current(j+1,:) = [];
            end
        end
    end
    plots(i).Effort = current;
    
    

    %days_of_data=[];
    %hours_of_effort=[];
    effort = plots(i).Effort;
    for a=1:size(plots(i).Effort,1)
        clear days_of_deployment
        clear hours_per_day
        days_of_deployment=floor(effort(a,1)):floor(effort(a,2)); %vector of all recording days
        %sometimes effort restarts where effort ends (the same day)
        %need to accouunt for that, i.e., merge days by comparing
        if a>1 && plots(i).days_of_data(end) == days_of_deployment(1)
            days_of_deployment = days_of_deployment(2:end);
        end
        hours_per_day = ones(length(days_of_deployment),1)*24;
        hours_per_day(1) = 24-((effort(a,1) - floor(effort(a,1)))*24);
        hours_per_day(end) = (effort(a,2) - floor(effort(a,2)))*24;
        plots(i).hours_of_effort=[plots(i).hours_of_effort;hours_per_day];
        plots(i).days_of_data=[plots(i).days_of_data days_of_deployment];
        plots(i).length_deployment(a) = length(days_of_deployment);
    end
end
1;




%% Organize Data into desired time units
% This section depends on
% speciesname,      array of strings with species names
% species_index,    array of integers indicating indicies of detections
% matdatestr,       cell array of start times and end times as strings
% days_of_data,    cell array with the days of effort
% matlabDates,      The times of detections in matlab time
% length_deployment, number of days for this deployment
% hours_of_effort, total hours of effort for this deployment (?)

% This section outputs
%   spdatenums,         a cell array with all the start and stop times
%   perdayscaled,       a cell array with only days with nonzero counts
%   days_of_data2,      a cell array with everyday and their counts


%Initialize cell arrays representing the number of successful queries
info.days_of_data2 = cell(length(plots),1);
info.perdayscaled = cell(length(plots),1);


%  Process overlapping entries. If two entries intersect, remove one
%  and take the union of the two as the resulting entry.
for i = 1:length(plots)
    current = plots(i).Detections;
    if ~isempty(current)
        current = sortrows(current,1);
        total = size(current,1);
        for j = total-1:-1:1
            s1 = current(j,1);
            s2 = current(j+1,1);
            f1 = current(j,2);
            f2 = current(j+1,2);
            isOverlap = (s2 <= f1);
            if isOverlap
                if f1 < f2
                    current(j,2) = current(j+1,2);
                end
                current(j+1,:) = [];
            end
        end
    end
    plots(i).Detections = current;
end

%%%%I think this part should loop through each spp. datenums.
%perhaps I should recollect them all into new variables so as to not 
%have to edit much code.
for pidx=1:length(plots); %plot index for queries struct
    n = 1;  % loop count index
    if isempty(plots(pidx).Detections)
        continue;%skip detless plots
    end
    
    plots(pidx).min_date = pstart;      %earliest date
    plots(pidx).max_date = pstop;     %latest date

    %find elapsed time, anything under 1 minute is rounded up to 1 min.

%     spdatediff = bsxfun(@minus,(plots(pidx).Detections(:,2)), (plots(pidx).Detections(:,1)));
% 
%     for itr=1:length(spdatediff)
%         if spdatediff(itr)<=.0007
%             spdatediff(itr)=.0007;
%         end
%     end

    % Add up all bouts that happened on the same julian day - this is GMT.
    starttimes=floor(plots(pidx).Detections(:,1));
    k =1;
    idx = 1;
    starttimes_n = [];
    while idx<=length(starttimes)
        same_days =[];
        same_days = find (starttimes == starttimes(idx));
        starttimes_n(k,1)= starttimes(idx);
        starttimes_n(k,2)= length(same_days);
        k=k+1;
        idx=max(same_days)+1;
    end

    % this part makes sure days where no detections were made are still
    % incorporated in the plot
    info.days_of_data2{pidx}=zeros(length(plots(pidx).days_of_data),2);
    info.days_of_data2{pidx}(:,1)= plots(pidx).days_of_data(:);
    info.perdayscaled{pidx}=[starttimes_n(:,1), starttimes_n(:,2)]; % turn the number into hours per day.

    % Organizes all days into one array. days_of_data2 is assumed to be
    % sequential
    days_with_hits = size(info.perdayscaled{pidx},1);
    for i = 1:days_with_hits
        if i == 33
            1;
        end
        index = find(info.days_of_data2{pidx}(:,1) == info.perdayscaled{pidx}(i,1));
        if size(index,1) == 1
            info.days_of_data2{pidx}(index,2) = info.perdayscaled{pidx}(i,2);
        else
            disp(['Inconsistent data. Multiple or 0 entries for a day, plot=',num2str(pidx),', i=',num2str(i)]);
            return
        end
    end
    info.days_of_data2{pidx}(:,3) = plots(pidx).hours_of_effort;
    %info.days_of_data2{pidx}(:,4) = (info.days_of_data2{pidx}(:,2)./info.days_of_data2{pidx}(:,3))*100;
    
    % Fill in missing days between deployments
    currentdata = info.days_of_data2{pidx};
    
        %fill in time before deployment (for N)
    currentdata_ext = floor(plots(pidx).min_date):floor(plots(pidx).Effort(1,1))-1;
    currentdata_ext = currentdata_ext';
    if ~isempty(currentdata_ext)
        currentdata_ext(:,2:3) = 0;
        %fill in first deployment
        first = currentdata(1:plots(pidx).length_deployment(1),:);
        currentdata_ext = [currentdata_ext;first];
    else 
        currentdata_ext = currentdata(1:plots(pidx).length_deployment(1),:);
    end
        %fill in gaps and further deployments
    for a=1:size(plots(pidx).Effort,1)-1
        clear days_between_deployments
        effort = plots(pidx).Effort;
        days_between_deployments=[ceil(effort(a,2)):1:floor(effort(a+1,1))-1]; %vector of all recording days
        days_between_deployments = days_between_deployments';
        days_between_deployments(:,2:3) = 0;
        currentdata_ext = [currentdata_ext;days_between_deployments];
        start = sum(plots(pidx).length_deployment(1:a))+1;
        stop = sum(plots(pidx).length_deployment(1:a+1));
        currentdata_ext = [currentdata_ext;...
            currentdata(start:stop,:)];
    end
        %fill in time after last deployment
    emptyEnd = currentdata_ext(end,1)+1:plots(pidx).max_date;
    emptyEnd = emptyEnd.';
    emptyEnd(:,2:3) = 0;
    currentdata_ext = [currentdata_ext;emptyEnd];
    info.days_of_data2{pidx} = currentdata_ext;
    n = n+1;
end


%% Y axis calculations
% Y axis should be constant across sites for given sp
% But, should change for different sp
%to achieve this, I create a m by n matrix, where
%   m = No. of input species
%   n = No. of successful queries, plus 1
% each row of the matrix represents a species
% each column represents a successful query, and the last column (+1) is
% reserved for the maximum cum. hours per week for that species.
% we will try to match the successful queries with input spp, and when we
% find a match, that query's index will be stored in the matrix. Then, once
% a row is processed, it will determine the max hours from all queries
% within that row, store it, and retrieve it when plotting.

%I really think this is overly complicated. Need more experience....


%%%%%%%%%%%%%%%%%%i actually do need this, species should have same maxY
shared_max = zeros(length(spp_array),site_count+1);%matrix to hold plot indices



for spidx = 1:length(spp_array)%loop through input spp
    n=1;
    for pidx=1:length(plots)
        if strcmp(spp_array{spidx},plots(pidx).SpeciesID) %check if 
            shared_max(spidx,n) = pidx;
            n = n+1;
        end
    end
end


% shared_max now filled with successful queries. Let's do perweek stuff
for spp_row = 1:size(shared_max,1)
    sharing = nonzeros(shared_max(spp_row,:))';
    sp_hrs_all = [];
    if ~isempty(sharing) % we only want to do this on spp with data
        for pidx = sharing
            if isempty(plots(pidx).Detections)
                continue;
            end
            data = info.days_of_data2{pidx};
            num_of_weeks = ceil(size(data,1)/7);
            plots(pidx).cum_hrs = zeros(num_of_weeks,1);
            
            for i = 1:num_of_weeks
                % Use the first day of the week to identify the week
                first_day = 7*(i-1) + 1;
                last_day = min(first_day + 6, size(data ,1));
                plots(pidx).week(i,1) = data(first_day,1);
                plots(pidx).cum_hrs(i,1) = sum(data(first_day:last_day,2));
                plots(pidx).pcnt_eff(i,1) = (sum(data(first_day:last_day,3)))/(7*24)*100;
            end
            
            sp_hrs_all = [sp_hrs_all; plots(pidx).cum_hrs];
            
        end
        try
            if ~isempty(sp_hrs_all)
                shared_max(spp_row, end) = max(sp_hrs_all);%store max for that spp in matrix
            end
        catch
            1;
        end
        %loop (again) thru those sharing this maxvalue, and assign it
        for yidx = sharing
            plots(yidx).maxY = shared_max(spp_row, end);
        end
    end
end


%% Plotting
%  This section depends on
%   spdatenums,         an cell array with all the start and stop times
%   days_of_data2,      an cell array with everyday and their counts
%   speciesname,        a cell array with species names as strings

for n=1:length(plots);
    if isempty(plots(n).Detections)
        continue;
    end
    clear currentdata
    currentdata = info.days_of_data2{n};
    
    num_of_weeks = ceil(size(currentdata,1)/7);
    %perweek = zeros(num_of_weeks,2);
    

    %account hours per week for effort
    %     perweek(:,2) = (perweek(:,2)./perweek(:,3))*100;
    
    %prepare for plotting
    site = plots(n).Site;
    %deployment = plots(n).Deployments;
    species = plots(n).SpeciesID;
    call = plots(n).Call;
    subtype = plots(n).Subtype;
    deployments = num2str(plots(n).Deployments);
    

    %instead of Figure
    if isempty(subtype)
        title = sprintf('Plot %d: %s%s%s - %s - %s', ...
            n, project,deployments, site, species, call);
    else
        title = sprintf('Plot %d: %s%s%s - %s - %s.%s', ...
            n, project,deployments, site, species, call,subtype);
    end
    rect = [0, 0, 1200, 250];
    figh = figure('NumberTitle','off', ...
        'Name',title,'Position',rect,'Units','Pixel');
    
    hold on
    
    starttimes_n=[];
    first_day = currentdata(1,1);
    last_day = currentdata(end,1);
    current_day = first_day;
    
    % Adjust so the month tick is at the beginning of the calender month,
    % not with respect to when the data collection began.
    [Y, M, D, H, MN, S] = datevec(current_day);
    current_day = addtodate(current_day, -D + 1,'day');
    xtick = [current_day];
    while (last_day > current_day)
        xtick = [xtick addtodate(current_day, xstep_length, xstep_unit)];
        current_day = addtodate(current_day, xstep_length, xstep_unit);
    end
    
    set(gca,'XTickLabelMode','manual')
    set(gca,'XTickLabel', datestr(xtick,'mmmyy'))
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % if useNormalizedData
    label = '';
    fun1 = @(x,y)bar(x,y,1,'FaceColor',[0 0 0]);
    fun2 = @(x,y)plot(x,y,'k.','MarkerSize',20,'Color',[0.5 0.5 0.5]);
    t = [];
    
    t = plots(n).week(:,1);
    y = plots(n).cum_hrs(:,1);
    e = plots(n).pcnt_eff(:,1);
    t2 = t; e2 = e;
    for i = size(e,1):-1:1
        % don't plot cases in which there is 0 or 100% effort
        if e(i) <= 0 || e(i) >= 100
            e2(i) = [];
            t2(i) = [];
        end
    end
    
    [AX,H1,H2] = plotyy(t+3.5,y,t2+3.5,e2,fun1,fun2);
    if ~useNormalizedData
        delete(AX(2))
    end
    
    %Modify Cum. hrs/wk scale
    %MaxY is upper 10th decimal place of maximum detected hours
    %HalfY is half of that value
    maxY = plots(n).maxY;
    minY = 0; %OK to hard-code to zero?
    if maxY<1
        maxY= ceil(maxY*10)/10;
    elseif 10<maxY && maxY<=100
        maxY = ceil(maxY/5)*5;
    elseif 100<maxY && maxY<=1000
        maxY=ceil(maxY/10)*10;
    elseif 1000<maxY && maxY<=5000
        maxY=ceil(maxY/100)*100;
    elseif maxY>5000
        maxY=ceil(maxY/500)*500;
    else
        maxY=ceil(maxY);
    end
    halfY = maxY/2;
    
    if useOffEffortBars
        for i = 1:size(t,1)
            if e(i) == 0
                tmp1 = get(gca,'YTick');
                tmp2 = get(gca,'YLabel');
                tmp3 = get(gca,'YLim');
                
                xmin = t(i);
                tmp = min(i+1,size(t,1));
                xmax = t(tmp);
                ymin = 0;
                %ymax = tmp3(2);
                if i == size(t,1)
                    h = fill([xmin last_day last_day xmin],[ymin ymin maxY maxY],offeffortcolor);
                else
                    h = fill([xmin xmax xmax xmin],[ymin ymin maxY maxY],offeffortcolor);
                end
                set(h,'EdgeColor','None');
            end
        end
    end
    %  uistack(h,'bottom')
    set(AX(1),'Layer','top')
    
    % Set parameters
    if useNormalizedData
        ylabel(AX(2),'Percentage of Effort per Week','FontSize',12);
        set(AX(2),'YColor',[0 0 0])
        set(AX(2),'Xlim',[first_day last_day]);
        set(AX(2),'XTick',xtick);
        set(AX(2),'XTickLabel','');
        %tmp = get(AX(2),'Ylim');
        set(AX(2),'Ylim',[0 100],'YTick',[0 50 100],'FontSize',12);
        
    end
    
    %    set(AX(1), 'Title', text('String',speciesname{n}))
    set(AX(1),'XTick', xtick);
    ylabel(AX(1),'Cumulative Hours Per Week','FontSize',12);
    set(AX(1),'Xlim',[first_day last_day],'YLim',[minY maxY],'YTick',[minY halfY maxY],'FontSize',12);
    %       'XTickLabel', datestr(xtick,'mmmyy'),...
    
    if save
        %try to save file
        fname = sprintf('%s%s_%s_%s_%s.jpg',path,site,species,call,subtype);
        set(figh,'PaperPositionMode','auto')
        print(figh,'-djpeg',fname,'-r0')
    end
end

